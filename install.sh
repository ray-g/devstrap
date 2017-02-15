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
    DRYRUN sudo apt-get update

    # Install GIT, CURL, WGET
    DRYRUN sudo apt-get install git curl wget -y

    # Install ZSH and Oh-My-Zsh
    DRYRUN sudo apt-get install zsh -y
    DRYRUN curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | DRYRUN sh -

    # Install Tmux
    DRYRUN sudo apt-get install tmux -y
    DRYRUN git clone https://github.com/gpakosz/.tmux.git
    DRYRUN ln -s -f .tmux/.tmux.conf
    DRYRUN cp .tmux/.tmux.conf.local .

    # Install FZF
    DRYRUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    DRYRUN ~/.fzf/install --all

    # Install EMACS
    if [ $headless -eq $NO ]; then
        DRYRUN sudo apt-get install emacs -y
    else
        DRYRUN sudo apt-get install emacs-nox -y
    fi
    DRYRUN git clone https://github.com/seagle0128/.emacs.d

    # Install Python & PIP
    DRYRUN sudo apt-get install python python-pip -y

    # Install Docker
    DRYRUN sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    DRYRUN echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | DRYRUN sudo tee /etc/apt/sources.list.d/docker.list
    DRYRUN sudo apt-get update
    DRYRUN apt-cache policy docker-engine
    DRYRUN sudo apt-get install -y docker-engine
    DRYRUN sudo usermod -aG docker $(whoami)
    DRYRUN sudo mkdir /docker
    DRYRUN sudo ln -s /docker /var/lib/docker
    DRYRUN sudo echo "\nDOCKER_OPTS=\"-g /docker\"\n" >> /etc/default/docker
    DRYRUN sudo pip install docker-compose

    # Install VS-Code
    if [ $headless -eq $NO ]; then
        local vscode="vscode_stable_myenv.deb"
        DRYRUN wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O $vscode
        DRYRUN sudo dpkg -i $vscode
        DRYRUN rm $vscode
    fi

    # Install Golang
    # Follow this link https://golang.org/doc/install
    local GO_VER="1.7.5"
    local GO_OS="linux"
    local GO_ARCH="amd64"
    DRYRUN wget https://storage.googleapis.com/golang/go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz
    DRYRUN tar -C /usr/local -xzf go${GO_VER}.${GO_OS}-${GO_ARCH}.tar.gz

    # Install Ruby
    DRYRUN apt-get install ruby2.3 ruby2.3-dev -y
    DRYRUN sudo gem install rubocop

    # Install Node.JS
    # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    DRYRUN curl -sL https://deb.nodesource.com/setup_6.x | DRYRUN sudo -E bash -
    DRYRUN sudo apt-get install -y nodejs
    DRYRUN npm install -g gulp-cli

    # Install JDK

    # Install Maven

    # Install Ant

    # Install Nginx
    DRYRUN sudo apt-get install -y nginx

    if [ ! -z "$CURRENT_DIR" ]; then
        cd $CURRENT_DIR
    fi
}

main_entry

DEBUG_END
