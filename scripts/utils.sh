#!/usr/bin/env bash

_DEBUG="off"
_DRYRUN="off"

function print_options_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "-h | --help     print this help"
    echo "-d | --debug    enable debug mode"
    echo "-r | --dryrun   enable dryrun mode"
}

function parse_options() {
    while [[ $# -ge 1 ]]
    do
        key="$1"

        case $key in
            -d|--debug)
                print_in_purple "debug enabled\n"
                _DEBUG="on"
                ;;
            -r|--dryrun)
                print_in_purple "dryrun enabled\n"
                _DRYRUN="on"
                ;;
            -h|--help)
                print_options_help
                exit
                ;;
            *)
                # unknown option
                ;;
        esac
        shift # past argument or value
    done
}

YES=0
NO=1
function promote_yn() {
    if [ "$#" -ne 2 ]; then
        print_error "ERROR with promote_yn. Usage: promote_yn <Message> <Variable Name>"
        print_fatal_error_msg_and_exit $FUNCNAME $@
    fi

    eval ${2}=$NO
    print_question "$1 [Yn]"
    read yn
    DEBUG_PRINT "Entered $yn"
    case $yn in
        [Yy]*|'' ) eval ${2}=$YES;;
        [Nn]* )    eval ${2}=$NO;;
        *)         eval ${2}=$NO;;
    esac
}

function ask_for_sudo() {
    # Ask for the administrator password upfront.
    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

function DEBUG() {
    if [ "$_DEBUG" == "on" ]; then
        $@
    else
        :
    fi
}

function DEBUG_PRINT() {
    DEBUG printf "%s" "$@"
}

function DEBUG_BEGIN() {
    DEBUG set -x
}

function DEBUG_END() {
    DEBUG set +x
}

function trim_quote() {
    local var="$*"
    var="${var#\"}"   # remove leading quotes
    var="${var%\"}"   # remove trailing quotes
    # var=${var//\"}    # remove all quotes...
    echo -n $var
}

function trim_space() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n $var
}

function install_executable() {
    declare -r EXECUTABLE_NAME="$2"
    declare -r EXECUTABLE_READABLE_NAME="$1"
    declare -r INSTALL_CMD="$3"

    if ! cmd_exists "$EXECUTABLE_NAME"; then
        # local dir="${BASH_SOURCE%/*}"
        # if [[ ! -d "$dir" ]]; then dir="$PWD"; fi

        execute "$INSTALL_CMD" "$EXECUTABLE_READABLE_NAME"
    else
        print_success "$EXECUTABLE_READABLE_NAME"
    fi
}

function cmd_exists() {
    command -v "$1" &> /dev/null
}

function kill_all_subprocesses() {
    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done
}

function execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXXX)"

    local exitCode=0
    local cmdsPID=""

    if [ "$_DRYRUN" == "on" ]; then
        print_in_blue "DRYRUN: $CMDS\n"
    else
        # If the current process is ended,
        # also end all its subprocesses.
        set_trap "EXIT" "kill_all_subprocesses"

        # Execute commands in background
        eval "$CMDS" \
        &> /dev/null \
        2> "$TMP_FILE" &

        cmdsPID=$!

        # Show a spinner if the commands
        # require more time to complete.
        show_spinner "$cmdsPID" "$CMDS" "$MSG"

        # Wait for the commands to no longer be executing
        # in the background, and then get their exit code.
        wait "$cmdsPID" &> /dev/null
        exitCode=$?

        # Print output based on what happened.
        print_result $exitCode "$MSG"

        if [ $exitCode -ne 0 ]; then
            print_error_stream < "$TMP_FILE"
        fi

        rm -rf "$TMP_FILE"
    fi

    return $exitCode
}

function get_os() {
    local os=""
    local kernelName=""

    kernelName="$(uname -s)"

    if [ "$kernelName" == "Darwin" ]; then
        os="macos"
    elif [ "$kernelName" == "Linux" ] && [ -e "/etc/lsb-release" ]; then
        os="ubuntu"
    else
        os="$kernelName"
    fi

    printf "%s" "$os"
}

function get_os_version() {
    local os=""
    local version=""

    os="$(get_os)"

    if [ "$os" == "macos" ]; then
        version="$(sw_vers -productVersion)"
    elif [ "$os" == "ubuntu" ]; then
        version="$(lsb_release -d | cut -f2 | cut -d' ' -f2)"
    fi

    printf "%s" "$version"
}

function is_git_repository() {
    git rev-parse &> /dev/null
}

function sync_repo() {
    local repo_uri="$1"
    local repo_path="$2"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone "$repo_uri" "$repo_path"
    else
        cd "$repo_path" && git pull origin master && cd - >/dev/null
    fi
}

function is_supported_version() {
    declare -a v1=(${1//./ })
    declare -a v2=(${2//./ })
    local i=""

    # Fill empty positions in v1 with zeros.
    for (( i=${#v1[@]}; i<${#v2[@]}; i++ )); do
        v1[i]=0
    done

    for (( i=0; i<${#v1[@]}; i++ )); do
        # Fill empty positions in v2 with zeros.
        if [[ -z ${v2[i]} ]]; then
            v2[i]=0
        fi

        if (( 10#${v1[i]} < 10#${v2[i]} )); then
            return 1
        elif (( 10#${v1[i]} > 10#${v2[i]} )); then
            return 0
        fi
    done
}

############################################################
# Print functions
############################################################

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1 2> /dev/null)"
    GREEN="$(tput setaf 2 2> /dev/null)"
    YELLOW="$(tput setaf 3 2> /dev/null)"
    BLUE="$(tput setaf 4 2> /dev/null)"
    PURPLE="$(tput setaf 5 2> /dev/null)"
    BOLD="$(tput bold 2> /dev/null)"
    NORMAL="$(tput sgr0 2> /dev/null)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    PURPLE=""
    BOLD=""
    NORMAL=""
fi

function println() {
    printf "%s\n" $1
}

function print_in_color() {
    printf "%b" \
        "$2" \
        "$1" \
        "${NORMAL}"
}

function print_in_red() {
    print_in_color "$1" $RED
}

function print_in_green() {
    print_in_color "$1" $GREEN
}

function print_in_yellow() {
    print_in_color "$1" $YELLOW
}

function print_in_blue() {
    print_in_color "$1" $BLUE
}

function print_in_purple() {
    print_in_color "$1" $PURPLE
}

function print_question() {
    print_in_yellow "   [?] $1"
}

function print_error() {
    print_in_red "   [✖] $1 $2\n"
}

function print_error_stream() {
    while read -r line; do
        print_error "↳ ERROR: $line"
    done
}

function print_call_stack() {
    # Print out the stack trace described by $function_stack
    local -r SKIP_STACKS=2
    if [ ${#FUNCNAME[@]} -gt 2 ]
    then
        print_error "↳ Callstacks:"
        for ((i=${SKIP_STACKS};i<${#FUNCNAME[@]};i++))
        do
            print_error "  $[$i-${SKIP_STACKS}]: ${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]} ${FUNCNAME[$i]}(...)"
        done
    fi
    println ''
}

function print_callstack() {
    print_error "Callstacks:"
    local frame=1
    while caller $frame; do
        ((frame++));
    done
    println ''
}

function print_fatal_error_msg_and_exit() {
    funcname=$1
    shift
    print_error "Error occured in \"$0\", when calling \"$funcname\" with \"$@\"."
    # print_callstack
    print_call_stack
    exit 1
}

function print_result() {
    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"
}

function print_success() {
    print_in_green "   [✔] $1\n"
}

function print_warning() {
    print_in_yellow "   [!] $1\n"
}

function show_spinner() {
    local -r FRAMES='/-\|'

    # shellcheck disable=SC2034
    local -r NUMBER_OR_FRAMES=${#FRAMES}

    local -r CMDS="$2"
    local -r MSG="$3"
    local -r PID="$1"

    local i=0
    local frameText=""

    # Note: In order for the Travis CI site to display
    # things correctly, it needs special treatment, hence,
    # the "is Travis CI?" checks.
    if [ "$TRAVIS" != "true" ]; then
        # Provide more space so that the text hopefully
        # doesn't reach the bottom line of the terminal window.
        #
        # This is a workaround for escape sequences not tracking
        # the buffer position (accounting for scrolling).
        #
        # See also: https://unix.stackexchange.com/a/278888
        printf "\n\n\n"
        tput cuu 3
        tput sc
    fi

    # Display spinner while the commands are being executed.
    while kill -0 "$PID" &>/dev/null; do
        frameText="   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"
        # Print frame text.
        if [ "$TRAVIS" != "true" ]; then
            printf "%s\n" "$frameText"
        else
            printf "%s" "$frameText"
        fi

        sleep 0.2

        # Clear frame text.
        if [ "$TRAVIS" != "true" ]; then
            tput rc
        else
            printf "\r"
        fi
    done
}

############################################################
# Package Conf File Reader
############################################################

declare -A def_packages
declare -A sel_packages
declare package_count=0

declare -r PACKAGE_IFS=,
declare -r PKG_DEFS="pkg_name pkg_desc pkg_exe pkg_type pkg_cmd"

function parse_package_def() {
    if [[ -z $1 ]]; then
        print_fatal_error_msg_and_exit $FUNCNAME $@
    fi

    eval "read $PKG_DEFS <<<\"$1\""
    eval "vars=($PKG_DEFS)"
    for var in ${vars[@]}; do
        eval "$var=\"$(trim_space ${!var})\""
    done
}

function read_package_conf() {
    local conf_file=$1
    local OLD_IFS=$IFS

    while IFS=$'\n' read -r line; do
        if [[ $line != [#]* ]]; then
            IFS=$PACKAGE_IFS
            parse_package_def "${line}"
            if [[ -z ${sel_packages["$pkg_name"]} && -z ${def_packages["$pkg_name"]} ]]; then
                def_packages["$pkg_name"]="${line}"
                sel_packages["$pkg_name"]=0
                ((++package_count))
            else
                IFS=$OLD_IFS
                print_error "Duplicated packages found! name: $pkg_name, desc: $pkg_desc, type: $pkg_type"
                print_fatal_error_msg_and_exit $FUNCNAME $@
            fi
        fi
    done < $conf_file

    IFS=$OLD_IFS
}

function print_packages() {
    local OLD_IFS=$IFS
    IFS=$PACKAGE_IFS
    for pkg in "${def_packages[@]}"; do
        parse_package_def "${pkg}"
        printf "pkg name: %s, pkg desc: %s, pkg type: %s\n" "${pkg_name}" "${pkg_desc}" "${pkg_type}"
    done
    IFS=$OLD_IFS

    for key in "${!sel_packages[@]}"; do
        printf "pkg name: $key, selected: ${sel_packages[${key}]}\n"
    done
}

function select_package() {
    pkg_name=$1
    if [[ -z ${sel_packages[${pkg_name}]} ]]; then
        print_error "$pkg_name not found!"
        print_fatal_error_msg_and_exit $FUNCNAME $@
    else
        sel_packages["$pkg_name"]=1
    fi
}

function has_selected_package() {
    pkg_name=$1
    if [[ -z ${sel_packages[${pkg_name}]} ]]; then
        print_error "$pkg_name not found!"
        print_fatal_error_msg_and_exit $FUNCNAME $@
    else
        if [[ ${sel_packages[${pkg_name}]} == 1 ]]; then
            return 0 # true
        else
            return 1 # false
        fi
    fi
}

function do_box_select_package() {
    DIALOG_HEIGHT=20
    DIALOG_WIDTH=80
    ITEMS_COUNT=${#def_packages[@]}

    declare -a options
    local OLD_IFS=$IFS
    IFS=$PACKAGE_IFS
    for pkg in "${def_packages[@]}"
    do
        parse_package_def "${pkg}"
        options+=("${pkg_name}" "${pkg_desc}" "ON")
    done
    IFS=$OLD_IFS

    result=$( whiptail --title "Select packages you want to install"\
                       --ok-button "Done" --nocancel\
                       --checklist "Packages" $DIALOG_HEIGHT $DIALOG_WIDTH $ITEMS_COUNT\
                       "${options[@]}"\
                       3>&2 2>&1 1>&3-)

    for item in $result; do
        select_package $(trim_quote $item)
    done
}
