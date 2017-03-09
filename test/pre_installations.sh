#!/usr/bin/env bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    if ! hash brew 2>/dev/null; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew update
    brew install bash bash-completion
    sudo sh -c "echo '$(brew --prefix)/bin/bash' >> /etc/shells"
    sudo chsh -s $(brew --prefix)/bin/bash $(whoami)
else
    # ubuntu
    sudo apt-get update
    sudo apt-get install realpath
fi
