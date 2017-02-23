#!/usr/bin/env bash

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
. "${BASE_DIR}/scripts/utils.sh"

parse_options $@

read_package_conf "${BASE_DIR}/scripts/install/ubuntu/package.conf"
# print_packages

_continue=show_select_package_box

if $_continue; then
    install_selected_packages
else
    print_in_purple 'Canceled\n'
    exit 0
fi
