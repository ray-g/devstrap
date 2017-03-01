#!/usr/bin/env bash

function install_omz() {
    # Install Oh-My-ZSH
    # http://ohmyz.sh/
    # Not able to 'execute' due to quotes...
    # execute "sh -c \"$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\"" "Oh-My-ZSH"
    if [ ! -e ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's/env zsh/ /g')" > /dev/null
        local exitCode=$?
    fi
    sync_repo https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    sync_repo https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sync_repo https://github.com/djui/alias-tips.git ~/.oh-my-zsh/custom/plugins/alias-tips
    print_result $exitCode "${pkg_desc}"
}

function install_omt() {
    # Install Oh-My-Tmux
    :
}

function install_emacsconf() {
    # Install .emacs.d
    :
}

function install_fzf() {
    # Install fzf searcher
    :
}

function create_dotfiles() {
    # Create dotfiles
    :
}