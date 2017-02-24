#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "npm.sh" \
    && . "go.sh" \
    && . "gem.sh" \
    && cd - &> /dev/null
