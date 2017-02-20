#!/usr/bin/env bash

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
. "${BASE_DIR}/scripts/utils.sh"

parse_options $@

read_package_conf "${BASE_DIR}/scripts/install/ubuntu/package.conf"
# print_packages

do_box_select_package

if has_selected_package "golang"; then echo "selected golang"; fi
