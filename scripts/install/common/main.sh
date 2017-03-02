#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "npm.sh" \
    && . "go.sh" \
    && . "gem.sh" \
    && . "env.sh" \
    && cd - &> /dev/null

function install_calibre() {
    execute "sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c \"import sys; main=lambda:sys.stderr.write('Download failed\\n'); exec(sys.stdin.read()); main()\"" "Calibre"
}
