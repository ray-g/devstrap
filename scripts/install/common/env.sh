#!/usr/bin/env bash

function install_omz() {
    # Install Oh-My-ZSH
    # http://ohmyz.sh/
    local exitCode=0
    if [ ! -e ~/.oh-my-zsh ]; then
        # TODO: sudo chsh -s $(grep /zsh$ /etc/shells | tail -1) $(whoami)
        execute "sh -c \"\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's/env zsh/ /g;s/chsh -s .*/sudo & \$(whoami)/g')\"" "Oh-My-ZSH"
        exitCode=$?
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
    execute "sync_repo https://github.com/seagle0128/.emacs.d ~/.emacs.d"
}

function install_fzf() {
    # Install fzf searcher
    if [ ! -e ~/.fzf ]; then
        execute "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf" || return $?
        execute "~/.fzf/install --all"
    fi
}

function install_z() {
    # Install z, the new j
    execute "sync_repo https://github.com/rupa/z ~/bin/z"
}

function install_dotfiles() {
    # Create dotfiles
    for filename in ${BASEDIR}/dotfiles; do
        create_link $filename ${HOME}/.${filename}
    done
}
