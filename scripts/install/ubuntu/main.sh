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
    execute "sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D"
    execute "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" | sudo tee /etc/apt/sources.list.d/docker.list"
    update
    execute "apt-cache policy docker-engine"
    install_package "docker-engine" "Docker Engine"
    execute "sudo usermod -aG docker $(whoami)"
    execute "sudo mkdir /docker"
    execute "sudo ln -s /docker /var/lib/docker"
    execute "sudo echo \"DOCKER_OPTS=\\\"-g /docker\\\"\" >> /etc/default/docker"

    # Install Docker Compose
    if ! cmd_exists "docker-compose"; then
        execute "sudo pip install docker-compose" "Docker Compose"
    fi
}

function install_nodejs() {
    # Install Node.JS
    # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    execute "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -"
    install_package "nodejs" "NodeJS"
}

function install_golang() {
    local GO_VER="1.7.5"
    local GO_OS="linux"
    local GO_ARCH="amd64"
    execute "wget https://storage.googleapis.com/golang/go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
    execute "sudo tar -C /usr/local -xzf go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
}

function install_vscode() {
    local vscode="vscode_stable_myenv.deb"
    execute "wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O $vscode"
    execute "sudo dpkg -i $vscode"
    execute "rm $vscode"
}

# Register apt installer
regist_pkg_installer "apt" "install_package"
