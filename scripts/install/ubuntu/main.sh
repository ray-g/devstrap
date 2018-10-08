#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "helper.sh" \
    && cd - &> /dev/null

# Register apt installer
regist_pkg_installer "apt" "install_package"

function pre_install() {
    update
}

function post_install() {
    :
}

function install_docker() {
    execute "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -" || return $?
    execute "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"" || return $?
    update || return $?
    execute "apt-cache policy docker-ce" || return $?
    install_package "docker-ce" "Docker CE" || return $?
    execute "sudo usermod -aG docker $(whoami)" || return $?
    # execute "sudo mkdir /docker" || return $?
    # execute "sudo ln -s /docker /var/lib/docker" || return $?
    # execute "echo 'DOCKER_OPTS=\"-g /docker\"' | sudo tee /etc/default/docker" || return $?

    # # Install Docker Compose
    # if ! cmd_exists "docker-compose"; then
    #     if cmd_exists "pip"; then
    #         execute "sudo pip install docker-compose" "Docker Compose"
    #     else
    #         print_error "Failed to install docker-compose. 'pip' is not installed properly"
    #         return 1
    #     fi
    # fi
}

function install_nodejs6() {
    # Install Node.JS
    # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    execute "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -" || return $?
    install_package "nodejs" "NodeJS_6"
}

function install_nodejs8() {
    execute "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -" || return $?
    install_package "nodejs" "NodeJS_8"
}

function install_nodejs10() {
    execute "curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -" || return $?
    install_package "nodejs" "NodeJS_10"
}

function remove_golang() {
    local GO_ROOT="/usr/local/go"
    local GO_EXE="go"
    if cmd_exists "${GO_EXE}"; then
        if [[ -d "${GO_ROOT}" && "${GO_ROOT}/bin/go" == "$(which go)" ]]; then
            execute "sudo rm -rf ${GO_ROOT}"
        fi
    fi
}

function install_golang() {
    local GO_VER="1.11.1"
    local GO_OS="linux"
    local GO_ARCH="amd64"

    if ! cmd_exists "${pkg_exe}"; then
        execute "wget --no-check-certificate https://storage.googleapis.com/golang/go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz" || return $?
        execute "sudo tar -C /usr/local -xzf go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
        local exitCode=$?
        execute "rm go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"

        if [ $exitCode -eq 0 ]; then
            # Successfully installed Golang, setup environment
            export GOPATH="${HOME}/.gopath/cache"
            export PATH=${GOPATH}/bin:/usr/local/go/bin:$PATH
        fi
        return $exitCode
    else
        return 0
    fi
}

function install_vscode() {
    local vscode="vscode_stable_devstrap.deb"
    execute "wget --no-check-certificate https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O $vscode" || return $?
    execute "sudo dpkg -i $vscode"
    local exitCode=$?
    execute "rm $vscode"
    return $exitCode
}

function install_emacs_ppa() {
    execute "sudo add-apt-repository ppa:kelleyk/emacs -y && sudo apt-get update"
    install_package
}

function install_ripgrep() {
    local RG_VER="0.7.1"
    local RG_TAR="ripgrep-${RG_VER}-x86_64-unknown-linux-musl.tar.gz"

    if ! cmd_exists "${pkg_exe}"; then
        execute "wget --no-check-certificate https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/${RG_TAR}" || return $?
        execute "sudo mkdir -p /usr/local/rg && sudo tar -C /usr/local/rg --strip-components 1 -xzf ${RG_TAR}"
        if [ ! -e "/usr/local/bin/rg" ]; then
            execute "sudo ln -s /usr/local/rg/rg /usr/local/bin/rg"
        fi
        local exitCode=$?
        execute "rm ${RG_TAR}"

        return $exitCode
    else
        return 0
    fi
}

function install_fd() {
    local FD_VER="7.0.0"
    local FD_DEB="fd_${FD_VER}_amd64.deb"

    if ! cmd_exists "${pkg_exe}"; then
        execute "wget --no-check-certificate https://github.com/sharkdp/fd/releases/download/v${FD_VER}/${FD_DEB}" || return $?
        execute "sudo dpkg -i ${FD_DEB}"
        local exitCode=$?
        execute "rm ${FD_DEB}"

        return $exitCode
    else
        return 0
    fi
}

function install_peco() {
    local PECO_VER="v0.5.2"
    local PECO_TAR="peco_linux_amd64.tar.gz"

    if ! cmd_exists "${pkg_exe}"; then
        execute "wget --no-check-certificate https://github.com/peco/peco/releases/download/${PECO_VER}/${PECO_TAR}" || return $?
        execute "sudo mkdir -p /usr/local/peco && sudo tar -C /usr/local/peco --strip-components 1 -xzf ${PECO_TAR}"
        if [ ! -e "/usr/local/bin/peco" ]; then
            execute "sudo ln -s /usr/local/peco/peco /usr/local/bin/peco"
        fi
        local exitCode=$?
        execute "rm ${PECO_TAR}"

        return $exitCode
    else
        return 0
    fi
}

function install_bazel() {
    execute "sudo apt-get install openjdk-8-jdk" || return $?
    execute "echo \"deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8\" | sudo tee /etc/apt/sources.list.d/bazel.list" || return $?
    execute "curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -" || return $?
    update || return $?
    install_package
}
