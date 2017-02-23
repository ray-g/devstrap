#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "helper.sh" \
    && cd - &> /dev/null

function pre_install() {
    :
}

function post_install() {
    :
}

function install() {
    :
}

function register() {
    :
}

regist_pkg_installer "apt" "install_package"
