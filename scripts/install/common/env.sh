#!/usr/bin/env bash

function install_omz() {
    # Install Oh-My-ZSH
    # http://ohmyz.sh/
    local exitCode=0
    if [ ! -e ~/.oh-my-zsh ]; then
        execute "sh -c \"\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's/env zsh/ /g;s/chsh -s .*/sudo & \$(whoami)/g')\"" "Oh-My-ZSH"
        exitCode=$?
    fi

    if [ $exitCode ]; then
        # Oh-My-Zsh plugins
        execute "sync_repo https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        execute "sync_repo https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        execute "sync_repo https://github.com/djui/alias-tips.git ~/.oh-my-zsh/custom/plugins/alias-tips"
    fi
    return $exitCode
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
    else
        return 0
    fi
}

function install_z() {
    # Install z, the new j
    execute "sync_repo https://github.com/rupa/z ~/bin/z"
}

function install_dotfiles() {
    # Create dotfiles
    local filename=""

    for filename in ${BASE_DIR}/dotfiles/*; do
        if [ -e $filename ]; then
            # realpath not found in travis
            # create_link $(realpath $filename) ${HOME}/.$(basename ${filename})
            create_link $(readlink -f $filename) ${HOME}/.$(basename ${filename})
        fi
    done

    for filename in ~/.{gitconfig,zshrc}_local; do
	    if [ ! -f "$filename" ]; then
            execute "touch $filename"
            execute "echo '# Please add your personal configurations here.' > $filename" "Update file: $filename"
            print_info "You can add your personal configurations in $filename"
        fi
    done;
}

function change_to_zsh() {
    if hash zsh 2> /dev/null; then
        print_info "Now enter ZSH"
        if ! IS_TRAVIS && ! DRYRUN; then
            env zsh
        else
            execute "env zsh"
        fi
    else
        print_error "ZSH not installed."
    fi
}
