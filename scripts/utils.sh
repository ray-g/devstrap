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
                echo "debug enabled"
                _DEBUG="on"
                ;;
            -r|--dryrun)
                echo "dryrun enabled"
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

function print_callstack() {
    echo "Callstacks:"
    local frame=1
    while caller $frame; do
        ((frame++));
    done
    echo "$*"
}

function error_msg() {
    funcname=$1
    shift
    print_error "Error occured in \"$0\", when calling \"$funcname\" with \"$@\"."
    print_callstack
}

function promote_yn() {
    if [ "$#" -ne 2 ]; then
        print_error "ERROR with promote_yn. Usage: promote_yn <Message> <Variable Name>"
        error_msg $FUNCNAME $@
        exit 1
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