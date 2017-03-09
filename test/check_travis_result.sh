#!/usr/bin/env bash

BASE_DIR="$(dirname ${BASH_SOURCE%/*})"

. "${BASE_DIR}/scripts/utils.sh"

function print_space_lines() {
    echo
    echo
}

print_info "cat /etc/passwd:"
cat /etc/passwd | grep $(whoami)
cat /etc/passwd | grep $(whoami) | grep "zsh"
print_result $? "Oh-My-Zsh change shell"

print_space_lines

print_info "ls -al ~:"
ls -al ~

print_space_lines

print_info "ls -la ~/.oh-my-zsh"
ls -al ~/.oh-my-zsh

print_space_lines

print_info "ls -al ~/bin"
ls -al ~/bin

print_space_lines

print_info "ls -al $PWD"
ls -al $PWD

exit 0