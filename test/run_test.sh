#!/usr/bin/env bash

BASE_DIR="$(dirname ${BASH_SOURCE%/*})"

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    ${BASE_DIR}/install.sh --env-only
else
    ${BASE_DIR}/install.sh --all-yes
fi
