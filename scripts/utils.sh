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
    echo "Error occured in \"$0\", when calling \"$funcname\" with \"$@\"."
    print_callstack
}

function promote_yn() {
    if [ "$#" -ne 2 ]; then
        echo "ERROR with promote_yn. Usage: promote_yn <Message> <Variable Name>"
        error_msg $FUNCNAME $@
        exit 1
    fi

    eval ${2}=$NO
    read -p "$1 [Yn]: " yn
    DEBUG_PRINT "Entered $yn"
    case $yn in
        [Yy]*|'' ) eval ${2}=$YES;;
        [Nn]* )    eval ${2}=$NO;;
        *)         eval ${2}=$NO;;
    esac
}

function DEBUG() {
    if [ "$_DEBUG" == "on" ]; then
        $@
    else
        :
    fi
}

function DEBUG_PRINT() {
    DEBUG echo "$@"
}

function DEBUG_BEGIN() {
    DEBUG set -x
}

function DEBUG_END() {
    DEBUG set +x
}

function DRYRUN() {
    if [ "$_DRYRUN" == "on" ]; then
        echo "DRYRUN: $@"
    else
        $@
    fi
}

function execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXXX)"

    local exitCode=0
    local cmdsPID=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If the current process is ended,
    # also end all its subprocesses.

    set_trap "EXIT" "kill_all_subprocesses"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Execute commands in background

    eval "$CMDS" \
        &> /dev/null \
        2> "$TMP_FILE" &

    cmdsPID=$!

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Show a spinner if the commands
    # require more time to complete.

    show_spinner "$cmdsPID" "$CMDS" "$MSG"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait for the commands to no longer be executing
    # in the background, and then get their exit code.

    wait "$cmdsPID" &> /dev/null
    exitCode=$?

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Print output based on what happened.

    print_result $exitCode "$MSG"

    if [ $exitCode -ne 0 ]; then
        print_error_stream < "$TMP_FILE"
    fi

    rm -rf "$TMP_FILE"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    return $exitCode
}

function get_os() {
    local os=""
    local kernelName=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    os="$(get_os)"

    if [ "$os" == "macos" ]; then
        version="$(sw_vers -productVersion)"
    elif [ "$os" == "ubuntu" ]; then
        version="$(lsb_release -d | cut -f2 | cut -d' ' -f2)"
    fi

    printf "%s" "$version"
}
