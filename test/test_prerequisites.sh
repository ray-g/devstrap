#!/usr/bin/env bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    if ! cmd_exists 'brew'; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew install bash bash-completion
    sudo sh -c "echo '$(brew --prefix)/bin/bash' >> /etc/shells"
    sudo chsh -s $(brew --prefix)/bin/bash $(whoami)
fi

BASE_DIR="$(dirname ${BASH_SOURCE%/*})"

. "${BASE_DIR}/scripts/utils.sh"

execute "check_and_install_whiptail"

# Log shell before install on Travis
cat /etc/passwd | grep $(whoami)
