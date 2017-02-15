#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/scripts/utils.sh"

parse_options $@

DEBUG_BEGIN

function main_entry() {
    local continue
    echo "Currently only work on Ubuntu Xenial (16.04) distro."
    promote_yn "Do you wish to continue?" "continue"
    if [ $continue -eq $NO ]; then
        exit
    fi

    if [ "$HOME" != "$PWD" ]; then
        local CURRENT_DIR=$PWD
        cd $HOME
    fi

    local headless
    promote_yn "Is this a headless machine?" "headless"

    # Update Repo
    execute "sudo apt-get update"

    # Install GIT, CURL, WGET
    execute "sudo apt-get install git curl wget -y"

    # Install ZSH and Oh-My-Zsh
    execute "sudo apt-get install zsh -y"
    execute "curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -"

    # Install Tmux
    execute "sudo apt-get install tmux -y"
    execute "git clone https://github.com/gpakosz/.tmux.git"
    execute "ln -s -f .tmux/.tmux.conf"
    execute "cp .tmux/.tmux.conf.local ."

    # Install FZF
    execute "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"
    execute "~/.fzf/install --all"

    # Install EMACS
    if [ $headless -eq $NO ]; then
        execute "sudo apt-get install emacs -y"
    else
        execute "sudo apt-get install emacs-nox -y"
    fi
    execute "git clone https://github.com/seagle0128/.emacs.d"

    # Install Python & PIP
    execute "sudo apt-get install python python-pip -y"

    # Install Docker
    execute "sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D"
    execute "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" | sudo tee /etc/apt/sources.list.d/docker.list"
    execute "sudo apt-get update"
    execute "apt-cache policy docker-engine"
    execute "sudo apt-get install -y docker-engine"
    execute "sudo usermod -aG docker $(whoami)"
    execute "sudo mkdir /docker"
    execute "sudo ln -s /docker /var/lib/docker"
    execute "sudo echo "\nDOCKER_OPTS=\"-g /docker\"\n" >> /etc/default/docker"
    execute "sudo pip install docker-compose"

    # Install VS-Code
    if [ $headless -eq $NO ]; then
        local vscode="vscode_stable_myenv.deb"
        execute "wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O $vscode"
        execute "sudo dpkg -i $vscode"
        execute "rm $vscode"
    fi

    # Install Golang
    # Follow this link https://golang.org/doc/install
    local GO_VER="1.7.5"
    local GO_OS="linux"
    local GO_ARCH="amd64"
    execute "wget https://storage.googleapis.com/golang/go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"
    execute "tar -C /usr/local -xzf go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz"

    # Install Ruby
    execute "apt-get install ruby2.3 ruby2.3-dev -y"
    execute "sudo gem install rubocop"

    # Install Node.JS
    # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    execute "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -"
    execute "sudo apt-get install -y nodejs"
    execute "npm install -g gulp-cli"

    # Install JDK

    # Install Maven

    # Install Ant

    # Install Nginx
    execute "sudo apt-get install -y nginx"

    if [ ! -z "$CURRENT_DIR" ]; then
        cd $CURRENT_DIR
    fi
}

main_entry

DEBUG_END
