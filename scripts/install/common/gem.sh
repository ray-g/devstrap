#!/usr/bin/env bash

function install_via_gem() {
    local PACKAGE=${pkg_name}
    local PACKAGE_DESC=${pkg_desc}
    local PACKAGE_EXE=${pkg_exe}
    local PACKAGE_LOCATION=${pkg_cmd}

    if ! cmd_exists "gem"; then
        print_error "${PACKAGE_DESC}. Ruby 'gem' didn't installed properly."
        return 1
    fi

    if ! cmd_exists $PACKAGE_EXE; then
        execute "sudo gem install ${PACKAGE}" "${PACKAGE_DESC}"
    else
        print_success "${PACKAGE_DESC}"
    fi
}

regist_pkg_installer "gem" "install_via_gem"
