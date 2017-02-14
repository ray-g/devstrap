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
