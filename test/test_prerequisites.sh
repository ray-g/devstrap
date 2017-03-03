#!/usr/bin/env bash

BASE_DIR="$(dirname ${BASH_SOURCE%/*})"

. "${BASE_DIR}/scripts/utils.sh"

execute "check_and_install_whiptail"

# Log shell before install on Travis
cat /etc/passwd | grep $(whoami)