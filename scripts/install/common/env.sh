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
    execute "sync_repo https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    execute "sync_repo https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    execute "sync_repo https://github.com/djui/alias-tips.git ~/.oh-my-zsh/custom/plugins/alias-tips"
    print_result $exitCode "Oh-My-Zsh"
}

function install_omt() {
    # Install Oh-My-Tmux
    execute "sync_repo https://github.com/gpakosz/.tmux.git ~/.tmux" || return $?
    execute "ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf"
}

function install_emacsconf() {
    # Install .emacs.d
    execute "git clone https://github.com/seagle0128/.emacs.d"
}

function install_fzf() {
    # Install fzf searcher
    if [ ! -e ~/.fzf ]; then
        execute "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf" || return $?
        execute "~/.fzf/install --all"
    fi
}

function create_dotfiles() {
    # Create dotfiles
    :
}