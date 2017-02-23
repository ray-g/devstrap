#!/usr/bin/env bash

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
. "${BASE_DIR}/scripts/utils.sh"

parse_options $@

read_package_conf "${BASE_DIR}/scripts/install/ubuntu/package.conf"
# print_packages

if ! do_box_select_package; then
    print_in_purple 'Canceled\n'
    exit 0
fi

for pkg in ${!sel_packages[@]}; do
    if has_selected_package $pkg; then
        parse_package_def "${def_packages[${pkg}]}"
        echo "pkg_name: ${pkg_name} selected"
        echo "pkg_desc: ${pkg_desc}"
        echo "pkg_cmd:  ${pkg_cmd}"
        echo
    fi
done
