#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"
cd -

print_in_purple "\n • Installs\n\n"

# OS dependent packages.
"./$(get_os)/install.sh"

# OS indepedent packages.
"./common/gem.sh"
"./common/go.sh"
"./common/npm.sh"
"./common/nvm.sh"
