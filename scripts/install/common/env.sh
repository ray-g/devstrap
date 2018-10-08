#!/usr/bin/env bash

function install_antigen() {
    local antigen_home="${HOME}/.antigen"
    execute "mkdir -p \"${antigen_home}\"" || return $?
    execute "curl -fsSL git.io/antigen > ${antigen_home}/antigen.zsh.tmp" || return $?
    execute "mv \"${antigen_home}/antigen.zsh.tmp\" \"${antigen_home}/antigen.zsh\""
}

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
            create_link $(realpath $filename) ${HOME}/.$(basename ${filename})
            # create_link $(readlink -f $filename) ${HOME}/.$(basename ${filename})
        fi
    done

    # clean old files
    for filename in ~/.{zsh_prompt,zshrc.local,zshrc.theme.local,gitconfig,vimrc.local}; do
        if [[ -L "$filename" && ! -e "$filename" ]]; then
            # broken link
            execute "rm $filename"
        elif [ -f "$filename" ]; then
            execute "mv ${filename} ${filename}.devstrap.bak"
            print_info "Backup existing file: ${filename} to ${filename}.devstrap.bak"
            print_info "You can get your config back by copy the content"
            print_info "or remove backups if you don't need them."
        fi
    done

    # Create customize (*.local) files if not exists

    # gitconfig should use original filename without ".local" suffix
    # so customized "git config --global" can be saved without touch devstrap repo
    filename=~/.gitconfig
    if [ ! -f "$filename" ]; then
        execute "touch $filename"
        local newline=$'\n'
        local content=""
        content+="# Include devstrap's gitconfig first.${newline}"
        content+="# Keep this in the top of this file to allow any setting overwritten it.${newline}"
        content+="[include]${newline}"
        content+="    # Load local configs.${newline}"
        content+="    # https://git-scm.com/docs/git-config#_includes${newline}"
        content+="${newline}"
        content+="    path = ~/.gitconfig.devstrap"
        content+="${newline}"
        execute "echo \"${content}\" > $filename" "Update file: $filename"
        print_info "You can add your personal configurations in $filename"
    fi

    # Create customize .zshrc.local file if not exists
    filename=~/.zshrc.local
    if [ ! -f "$filename" ]; then
        execute "touch $filename"
        local newline=$'\n'
        local content=""
        content+="# Please add your personal configurations here.${newline}"
        content+="${newline}"
        content+="# Customize Antigen Plugins:${newline}"
        content+="# antigen bundle golang${newline}"
        content+="# antigen bundle python${newline}"
        content+="# antigen bundle ruby${newline}"
        content+="# antigen bundle docker${newline}"
        content+="# antigen bundle docker-compose${newline}"
        content+="# antigen bundle docker-machine${newline}"
        content+="# antigen bundle npm${newline}"
        content+="${newline}"
        content+="# thefuck alias${newline}"
        content+="[ -x \\\"\\\$(command -v thefuck)\\\" ] && eval \\\$(thefuck --alias)"
        execute "echo \"${content}\" > $filename" "Update file: $filename"
        print_info "You can set your personal configurations in $filename"
    fi

    filename=~/.zshrc.final.local
    if [ ! -f "$filename" ]; then
        execute "touch $filename"
        local newline=$'\n'
        local content=""
        content+="# Please add your personal configurations which should apply after antigen here.${newline}"
        content+="if type '...' > /dev/null 2>&1; then${newline}"
        content+="  unalias '...'${newline}"
        content+="fi${newline}"
        execute "echo \"${content}\" > $filename" "Update file: $filename"
        print_info "You can add your personal final contifutations in $filename"
    fi

    # Create customize .vimrc.local file if not exists
    filename=~/.vimrc.local
    if [ ! -f "$filename" ]; then
        execute "touch $filename"
        execute "echo '\" Please add your personal configurations here.' > $filename" "Update file: $filename"
        print_info "You can add your personal configurations in $filename"
    fi

    # Create customize .zshrc.theme.local file if not exists
    filename=~/.zshrc.theme.local
    if [ ! -f "$filename" ]; then
        execute "touch $filename"
        local newline=$'\n'
        local content=""
        content+="# Set name of the theme to load.${newline}"
        content+="# Look in ~/.oh-my-zhe/themes/${newline}"
        content+="# Optionally, if you set this to \"random\", it will load a random theme each${newline}"
        content+="# time that oh-my-zsh is loaded.${newline}"
        content+="# ZSH_THEME=\"ys\"${newline}"
        content+="#${newline}"
        content+="# Use Antigen to load theme${newline}"
        content+="antigen theme ys    #ys, dst, steeef, wedisagree, robbyrussell${newline}"
        execute "echo \"${content}\" > $filename" "Update file: $filename"
        print_info "You can set your favorite theme in $filename"
    fi

    # For Centaur Emacs
    pathfile=~/.path
    zshenvfile=~/.zshenv
    if [ -f "$pathfile" ]; then
        execute "cp $pathfile $zshenvfile" "Update $zshenvfile"
    fi
}

function install_cn_mirrors() {
    for filename in ${BASE_DIR}/dotfiles_cn/*; do
        if [ -e $filename ]; then
            # realpath not found in travis
            create_link $(realpath $filename) ${HOME}/.$(basename ${filename})
            # create_link $(readlink -f $filename) ${HOME}/.$(basename ${filename})
        fi
    done
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

function setup_env_only() {
    install_omz
    install_omt
    install_emacsconf
    install_fzf
    install_z
    install_dotfiles
    change_to_zsh
}
