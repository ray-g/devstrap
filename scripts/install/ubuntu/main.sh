#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "helper.sh" \
    && cd - &> /dev/null

function pre_install() {
    update
}

function post_install() {
    :
}

function install_docker() {
    execute "sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D" || return $?
    execute "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" | sudo tee /etc/apt/sources.list.d/docker.list" || return $?
    update || return $?
    execute "apt-cache policy docker-engine" || return $?
    install_package "docker-engine" "Docker Engine" || return $?
    execute "sudo usermod -aG docker $(whoami)" || return $?
    execute "sudo mkdir /docker" || return $?
    execute "sudo ln -s /docker /var/lib/docker" || return $?
    execute "sudo echo \"DOCKER_OPTS=\\\"-g /docker\\\"\" >> /etc/default/docker" || return $?

    # Install Docker Compose
    if ! cmd_exists "docker-compose"; then
        execute "sudo pip install docker-compose" "Docker Compose"
    fi
}

function install_nodejs() {
    # Install Node.JS
    # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    execute "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -" || return $?
    install_package "nodejs" "NodeJS"
}

function install_golang() {
    local GO_VER="1.7.5"
    local GO_OS="linux"
    local GO_ARCH="amd64"
    execute "wget https://storage.googleapis.com/golang/go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz" || return $?
    execute "sudo tar -C /usr/local -xzf go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
    local exitCode=$?
    execute "rm go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
    return $exitCode
}

function install_vscode() {
    local vscode="vscode_stable_myenv.deb"
    execute "wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O $vscode" || return $?
    execute "sudo dpkg -i $vscode"
    local exitCode=$?
    execute "rm $vscode"
    return $exitCode
}

# Register apt installer
regist_pkg_installer "apt" "install_package"
