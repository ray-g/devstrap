#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"
cd -

function add_key() {
    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output
}

function add_ppa() {
    sudo add-apt-repository -y ppa:"$1" &> /dev/null
}

function add_to_source_list() {
    sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'"
}

function autoremove() {
    # Remove packages that were automatically installed to satisfy
    # dependencies for other packages and are no longer needed.
    execute "sudo apt-get autoremove -qqy" "APT (autoremove)"
    #                 suppress output ─┘│
    #     assume "yes" to all prompts ──┘
}

function install_package() {
    declare -r PACKAGE="$2"
    declare -r PACKAGE_READABLE_NAME="$1"
    declare -r EXECUTABLE_NAME="$3"

    if ! package_is_installed "$PACKAGE"; then
        execute "sudo apt-get install --allow-unauthenticated -qqy $PACKAGE" "$PACKAGE_READABLE_NAME"
        #                                      suppress output ─┘│
        #            assume "yes" as the answer to all prompts ──┘
    elif ! cmd_exists "$EXECUTABLE_NAME"
        local dir="${BASH_SOURCE%/*}"
        if [[ ! -d "$dir" ]]; then dir="$PWD"; fi

        execute "bash ${dir}/${package}.sh" "$PACKAGE_READABLE_NAME"
    else
        print_success "$PACKAGE_READABLE_NAME"
    fi
}

function package_is_installed() {
    dpkg -s "$1" &> /dev/null
}

function update() {
    # Resynchronize the package index files from their sources.
    execute "sudo apt-get update -qqy" "APT (update)"
    #             suppress output ─┘│
    # assume "yes" to all prompts ──┘
}

function upgrade() {
    # Install the newest versions of all packages installed.
    execute \
        "export DEBIAN_FRONTEND=\"noninteractive\" \
            && sudo apt-get -o Dpkg::Options::=\"--force-confnew\" upgrade -qqy" \
        "APT (upgrade)"
    #                                                       suppress output ─┘│
    #                                           assume "yes" to all prompts ──┘
}