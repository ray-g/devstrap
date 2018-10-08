#!/usr/bin/env bash

function install_via_pip() {
    local PACKAGE=${pkg_name}
    local PACKAGE_DESC=${pkg_desc}
    local PACKAGE_EXE=${pkg_exe}
    local PACKAGE_LOCATION=${pkg_cmd}

    if ! cmd_exists "pip"; then
        print_error "${PACKAGE_DESC}. Python 'pip' didn't installed properly."
        return 1
    fi

    if ! cmd_exists $PACKAGE_EXE; then
        execute "sudo -H pip install ${PACKAGE}" "${PACKAGE_DESC}"
    else
        print_success "${PACKAGE_DESC}"
    fi
}

function install_via_pip3() {
    local PACKAGE=${pkg_name}
    local PACKAGE_DESC=${pkg_desc}
    local PACKAGE_EXE=${pkg_exe}
    local PACKAGE_LOCATION=${pkg_cmd}

    if ! cmd_exists "pip3"; then
        print_error "${PACKAGE_DESC}. Python3 'pip' didn't installed properly."
        return 1
    fi

    if ! cmd_exists $PACKAGE_EXE; then
        execute "sudo -H pip3 install ${PACKAGE}" "${PACKAGE_DESC}"
    else
        print_success "${PACKAGE_DESC}"
    fi
}

regist_pkg_installer "pip" "install_via_pip"

function regist_pip3() {
    regist_pkg_installer "pip" "install_via_pip3"
}
