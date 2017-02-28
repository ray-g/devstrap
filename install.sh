#!/usr/bin/env bash

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi

. "${BASE_DIR}/scripts/utils.sh"
. "${BASE_DIR}/scripts/install/$(get_os)/main.sh"
. "${BASE_DIR}/scripts/install/common/main.sh"

parse_options $@

read_package_conf "${BASE_DIR}/scripts/install/$(get_os)/package.conf"
read_package_conf "${BASE_DIR}/scripts/install/common/package.conf"
# print_packages

_continue=show_select_package_box

if $_continue; then
    install_selected_packages
else
    print_in_purple 'Canceled\n'
    exit 0
fi
