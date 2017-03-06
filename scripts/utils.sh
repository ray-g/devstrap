#!/usr/bin/env bash

_DEBUG="off"
_DRYRUN="off"
_ALLYES="off"
_SELECTNONE="off"

function print_options_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "-h | --help     print this help"
    echo "-d | --debug    enable debug mode"
    echo "-r | --dryrun   enable dryrun mode"
    echo "     --all-yes  install all packages without selecting"
    echo "-n | --sel-none select none packages in box"
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
            --all-yes)
                print_in_purple "all yes mode enabled\n"
                _ALLYES="on"
                ;;
            -n|--sel-none)
                print_in_purple "select none mode enabled\n"
                _SELECTNONE="on"
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

function IS_TRAVIS() {
    [[ "$TRAVIS" == "true" ]]
}

function DRYRUN() {
    [[ "$_DRYRUN" == "on" ]]
}

function ALLYES() {
    [[ "$_ALLYES" == "on" ]]
}

function SELECTNONE() {
    [[ "$_SELECTNONE" == "on" ]]
}

function DEBUG() {
    [[ "$_DEBUG" == "on" ]]
}

function DEBUG_PRINT() {
    DEBUG && printf "$1"
}

function DEBUG_BEGIN() {
    DEBUG && set -x
}

function DEBUG_END() {
    DEBUG && set +x
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

function cmd_exists() {
    command -v "$1" &> /dev/null
}

function fn_exists() {
    declare -f "$1" &> /dev/null
}

function kill_all_subprocesses() {
    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done
}

function set_trap() {
    trap -p "$1" | grep "$2" &> /dev/null \
        || trap '$2' "$1"
}

function execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXXX)"

    local exitCode=0
    local cmdsPID=""

    if DRYRUN; then
        print_result $exitCode "${MSG}"
        print_in_blue "     ↳ DRYRUN: ${CMDS}\n"
    else
        if DEBUG; then
            echo "$CMDS"
            eval "$CMDS"
            exitCode=$?
            print_result $exitCode "$MSG"
            return $exitCode
        fi

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
    elif [ "$kernelName" == "Linux" ]; then
        if [ -f "/etc/lsb-release" ]; then
            os="ubuntu"
        elif [ -f "/etc/debian_version" ]; then
            os="debian"
        elif [ -f "/etc/redhat-release" ]; then
            os="redhat"
        elif [ -f "/etc/SuSE-release" ]; then
            os="suse"
        fi
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

function get_arch() {
    printf "%s" "$(uname -m)"
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

function is_git_repository() {
    git rev-parse &> /dev/null
}

function sync_repo() {
    local repo_uri=${1/\~/$HOME}
    local repo_path=${2/\~/$HOME}

    if [ ! -e ${repo_path} ]; then
        execute "mkdir -p ${repo_path}"
        execute "git clone ${repo_uri} ${repo_path}"
    else
        cd ${repo_path} && git pull origin master && cd - >/dev/null
    fi
}

function create_link() {
    local SOURCE=${1/\~/$HOME}
    local DEST=${2/\~/$HOME}

    if [ ! -e ${SOURCE} ]; then
        print_error "${SOURCE} doen't exists."
        return 2
    fi

    if [[ -f ${DEST} && ! -h ${DEST} ]]; then
        # If dest is a file and not a symbolic link, backup it
        execute "mv ${DEST} ${DEST}.devstrap.bak"
    fi

    local dest_dir=$(dirname ${DEST})
    if [ ! -d $dest_dir ]; then
        execute "mkdir -p ${dest_dir}"
    fi

    execute "ln -s -f ${SOURCE} ${DEST}"
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

declare _indent=0
function indent() {
    local spacing=""
    local i=""

    for(( i=0; i<$_indent; i++ )); do
        spacing="${spacing} "
    done

    echo -n "$spacing"
}

function print_in_color() {
    printf "%b" \
        "$2" \
        "$(indent)$1" \
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
    local i=""

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

function print_info() {
    print_in_blue "   [i] $1\n"
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
    if ! IS_TRAVIS; then
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
        frameText="$(indent)   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"
        # Print frame text.
        if ! IS_TRAVIS; then
            printf "%s\n" "$frameText"
        else
            printf "%s" "$frameText"
        fi

        sleep 0.2

        # Clear frame text.
        if ! IS_TRAVIS; then
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
declare -a order_packages
declare package_count=0

declare -r PACKAGE_IFS=$';'
declare -r PKG_DEFS="pkg_name pkg_desc pkg_sel pkg_type pkg_exe pkg_cmd"

function parse_package_def() {
    if [[ -z $1 ]]; then
        print_fatal_error_msg_and_exit $FUNCNAME $@
    fi

    local OLD_IFS=$IFS
    IFS=$PACKAGE_IFS
    eval "read $PKG_DEFS <<<\"$1\""
    eval "vars=($PKG_DEFS)"
    local var=""
    for var in ${vars[@]}; do
        eval "$var=\"$(trim_space ${!var})\""
    done
    IFS=$OLD_IFS
}

declare MAX_NAME_LEN=0
declare MAX_DESC_LEN=0
function read_package_conf() {
    local conf_file=$1
    local OLD_IFS=$IFS

    while IFS=$'\n' read -r line; do
        if [[ ${#line} -gt 1 && $line != [#]* ]]; then
            IFS=$PACKAGE_IFS
            parse_package_def "${line}"
            if [[ -z ${sel_packages["$pkg_name"]} && -z ${def_packages["$pkg_name"]} ]]; then
                def_packages["$pkg_name"]="${line}"
                sel_packages["$pkg_name"]=0
                order_packages+=( $pkg_name )
                ((++package_count))

                local name_len=0
                local desc_len=0
                if [ ${pkg_sel} == "hide" ]; then
                    :
                elif [ ${pkg_type} == "seperator" ]; then
                    # Seperator: ==========
                    # 3 spaces between description and back seperator
                    name_len=10
                    (( desc_len = ${#pkg_desc} + 10 + 3 + 2 )) # 2 ending spaces in seperator
                else
                    name_len=${#pkg_name}
                    (( desc_len = ${#pkg_desc} + 4 )) # 4 ending spaces
                fi
                # Update max length
                if [ $name_len -gt $MAX_NAME_LEN ]; then MAX_NAME_LEN=$name_len; fi
                if [ $desc_len -gt $MAX_DESC_LEN ]; then MAX_DESC_LEN=$desc_len; fi
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

    local name=""
    for name in "${order_packages[@]}"; do
        local pkg
        pkg=${def_packages[$name]}
        parse_package_def "${pkg}"
        printf "pkg name: %s, pkg desc: %s, pkg type: %s\n" "${pkg_name}" "${pkg_desc}" "${pkg_type}"
    done
    IFS=$OLD_IFS

    local key=""
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

function show_select_package_box() {
    local max_len
    # 16 is a magic number, looks like is the spaces between name and description columns
    (( max_len = $MAX_DESC_LEN + $MAX_NAME_LEN + 16 ))

    DIALOG_HEIGHT=40
    DIALOG_WIDTH=$max_len
    # ITEMS_COUNT=${#def_packages[@]}
    ITEMS_COUNT=30

    declare -a options
    declare -r SEP_LINE="=========="
    local OLD_IFS=$IFS
    IFS=$PACKAGE_IFS
    local name=""
    for name in "${order_packages[@]}"
    do
        local pkg
        pkg=${def_packages[$name]}
        parse_package_def "${pkg}"
        # Don't show 'hide' or 'seperator'
        if [[ ${pkg_sel} == "hide" || ${pkg_type} == "seperator" ]]; then
            select_package ${pkg_name}
            if [ ${pkg_type} == "seperator" ]; then
                options+=("${SEP_LINE}" "${pkg_desc}   ${SEP_LINE}  " "OFF")
            fi
            continue
        elif ALLYES; then
            select_package ${pkg_name}
        fi

        if ! SELECTNONE; then
            options+=("${pkg_name}" "${pkg_desc}    " "${pkg_sel}")
        else
            options+=("${pkg_name}" "${pkg_desc}    " "OFF")
        fi
    done
    IFS=$OLD_IFS

    if ! ALLYES; then
        result=$( whiptail --title "Select packages you want to install" \
                           --fb --ok-button "Done" \
                           --clear \
                           --checklist "Packages:" $DIALOG_HEIGHT $DIALOG_WIDTH $ITEMS_COUNT \
                           "${options[@]}" \
                           3>&2 2>&1 1>&3-)

        [[ "$?" == 1 ]] && return 1
        [[ ${#result} == 0 ]] && return 1

        local item=""
        for item in $result; do
            local package_name=$(trim_quote $item)
            if [ ! ${package_name} == ${SEP_LINE} ]; then
                select_package $package_name
            fi
        done
    fi

    return 0
}

function check_and_install_whiptail() {
    if ! cmd_exists "whiptail"; then
        case $(get_os) in
            ubuntu)
                execute "sudo apt-get install -y whiptail"
                ;;
            macos)
                if ! cmd_exists 'brew'; then
                    execute "ruby -e \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"" "Homebrew"
                fi
                execute "brew install newt"
                ;;
            *)
                print_error "Unsupported OS type $(get_os)"
                print_fatal_error_msg_and_exit $FUNCNAME $@
                ;;
        esac
    fi

    if ! $(whiptail -v > /dev/null 2>&1); then
        print_error "Failed to install whiptail."
        print_fatal_error_msg_and_exit $FUNCNAME $@
    fi
}

############################################################
# Package Installer Register and common installers
############################################################

declare -A pkg_installers
function regist_pkg_installer() {
    local type=$1
    local installer=$2

    if [[ -z ${pkg_installers["$type"]} ]]; then
        pkg_installers["$type"]="$installer"
    else
        print_error "Duplicated packages installer! type: '$type', installer: '$installer'"
        print_fatal_error_msg_and_exit $FUNCNAME $@
    fi
}

function install_selected_packages() {
    local pkg=""
    for pkg in ${order_packages[@]}; do
        if has_selected_package $pkg; then
            install_it $pkg
        fi
    done
}

function install_it() {
    local pkg="$1"
    parse_package_def "${def_packages[${pkg}]}"

    DEBUG_PRINT "\nDealing with selected package:\n"
    DEBUG_PRINT "  pkg_name: ${pkg_name}\n"
    DEBUG_PRINT "  pkg_desc: ${pkg_desc}\n"
    DEBUG_PRINT "  pkg_exe:  ${pkg_exe}\n"
    DEBUG_PRINT "  pkg_type: ${pkg_type}\n"
    DEBUG_PRINT "  pkg_cmd:  ${pkg_cmd}\n"
    DEBUG_PRINT "\n"

    if [[ -z ${pkg_installers[${pkg_type}]} ]]; then
        print_error "Unknown package type: '${pkg_type}' of '${pkg_name}'"
    else
        installer="${pkg_installers[${pkg_type}]}"
        eval "${installer}"
    fi

    DEBUG_PRINT "\nDone with selected package: ${pkg_name}\n"
}

function install_via_cmd() {
    if ! cmd_exists "${pkg_exe}"; then
        if fn_exists "${pkg_cmd}"; then
        # install via a pre-defined command
            print_info "Starting ${pkg_desc} ..."
            DRYRUN && print_in_purple "↱     function ${pkg_cmd}     ↰\n"
            ((_indent++))
            eval "$pkg_cmd"
            local exitCode=$?
            ((_indent--))
            DRYRUN && print_in_purple "↳     function ${pkg_cmd}     ↲\n"
            print_result $exitCode "${pkg_desc}"
        else
            execute "$pkg_cmd" "$pkg_desc"
        fi
    else
        print_success "${pkg_desc}"
    fi
}
regist_pkg_installer "cmd" "install_via_cmd"

function install_print_seperator() {
    print_in_purple "\n • ${pkg_desc}\n\n"
}
regist_pkg_installer "seperator" "install_print_seperator"
