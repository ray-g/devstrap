#!/usr/bin/env bash

function check_go_env() {
    if ! cmd_exists "go"; then
        return 1
    elif [ -z $GOPATH ]; then
        return 1
    fi
}

function install_via_go() {
    local PACKAGE=${pkg_name}
    local PACKAGE_DESC=${pkg_desc}
    local PACKAGE_EXE=${pkg_exe}
    local PACKAGE_LOCATION=${pkg_cmd}

    if ! check_go_env; then
        print_error "${PACKAGE_DESC}. Golang didn't installed properly."
        return 1
    fi

    if ! cmd_exists $PACKAGE_EXE; then
        execute "go get -u -v ${PACKAGE}" "${PACKAGE_DESC}"
    else
        print_success "${PACKAGE_DESC}"
    fi
}

regist_pkg_installer "go" "install_via_go"
