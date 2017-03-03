#!/usr/bin/env bash

echo 'cat /etc/passwd:'
cat /etc/passwd

echo 'ls -al ~:'
ls -al ~

echo 'ls -al ~/bin'
ls -al ~/bin

echo 'ls -al $PWD'
echo "PWD: $PWD"
ls -al $PWD

exit 0