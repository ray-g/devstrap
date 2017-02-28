#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "helper.sh" \
    && cd - &> /dev/null

function pre_install() {
    update
    upgrade
}

function post_install() {
    execute "echo 'hello postinstall'"
    :
}

function install() {
    :
}

function register() {
    :
}

regist_pkg_installer "apt" "install_package"
