#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/utils.sh"

parse_options $@

DEBUG_BEGIN

function main() {
    local continue
    echo "Currently only work on Ubuntu distro."
    promote_yn "Do you wish to continue?" "continue"
    if [ $continue -eq $NO ]; then
        exit
    fi

    local headless
    promote_yn "Is this a headless machine?" "headless"

    # Update Repo
    DRYRUN sudo apt-get update

    # Install GIT
    DRYRUN sudo apt-get install git -y

    # Install ZSH and Oh-My-Zsh
    DRYRUN sudo apt-get install zsh -y

    # Install Tmux
    DRYRUN sudo apt-get install tmux -y

    # Install EMACS
    if [ $headless -eq $NO ]; then
        DRYRUN sudo apt-get install emacs -y
    else
        DRYRUN sudo apt-get install emacs-nox -y
    fi

    # Install Docker

    # Install VS-Code

    # Install Golang

    # Install Ruby

    # Install Node.JS

    # Install Python & PIP

    # Install JDK

    # Install Maven

    # Install Ant

    # Install Nginx
}

main

DEBUG_END
