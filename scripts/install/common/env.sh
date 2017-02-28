#!/usr/bin/env bash

function install_omz() {
    # Install Oh-My-ZSH
    # http://ohmyz.sh/
    execute "sh -c \"$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\"" "Oh-My-ZSH"
}

function install_omt() {
    # Install Oh-My-Tmux
    :
}
