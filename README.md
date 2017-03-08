# DevStrap

[![Build Status](https://travis-ci.org/ray-g/devstrap.svg?branch=master)](https://travis-ci.org/ray-g/devstrap)

Quickly add necessary packages and a set of dotfiles to
bootstrap your development environments.

The packages and settings are based on my personal favorite,
but they are customizable during installation via an
interactive `whiptail` dialog.

And some dotfiles are also [custmizable](#Customize) after installation.
Details are here [~/.zshrc.local](#~/.zshrc.local),
[~/.vimrc.local](#~/.vimrc.local),
[~/.gitconfig.local](#~/.gitconfig.local).

## Quick Start

```shell
git clone https://github.com/ray-g/devstrap.git ~/.devstrap
~/.devstrap/install.sh
```

## Snapshots

__TODO:__ add snapshots later.

## Command Line Options

```text
./install.sh -h
Usage: ./install.sh [options]
Options:
-h | --help     print this help
-d | --debug    enable debug mode
-r | --dryrun   enable dryrun mode
     --all-yes  install all packages without selecting
-n | --sel-none select none packages in box
```

## Customize

The `dotfiles` can be easily extended to suit additional
local requirements by using the following files:

### ~/.zshrc.local

The `~/.zshrc.local` file it will be automatically sourced after
all the other `shell` related files, thus, allowing its content
to add to or overwrite the existing aliases, settings, PATH, etc.

Here is a very simple example of a `~/.zshrc.local` file:

```shell
#!/bin/bash

# Set local aliases.
alias starwars="telnet towel.blinkenlights.nl"

# Set PATH additions.
PATH="$PATH:$HOME/projects/bin"
export PATH
```

### ~/.vimrc.local

The `~/.vimrc.local` file it will be automatically sourced after
`~/.vimrc`, thus, allowing its content to add or overwrite the
settings from `~/.vimrc`.

### ~/.gitconfig.local

The `~/.gitconfig.local` file it will be automatically included
after the configurations from `~/.gitconfig`, thus, allowing its
content to overwrite or add to the existing `git` configurations.

__Note:__ Use `~/.gitconfig.local` to store sensitive information
such as the `git` user credentials, e.g.:

```shell
[commit]
    # Sign commits using GPG.
    # https://help.github.com/articles/signing-commits-using-gpg/

    gpgsign = true

[user]
    name = John Doe
    email = john.doe@example.com
    signingkey = XXXXXXXX
```

## Acknowledgements

Inspiration and code was taken from many sources, including:

* [Mathias Bynens'](https://github.com/mathiasbynens) [dotfiles](https://github.com/mathiasbynens/dotfiles)
* [Cătălin Mariș'](https://github.com/alrra) [dotfiles](https://github.com/alrra/dotfiles)
* [Amir Salihefendic's](https://github.com/amix) [vimrc](https://github.com/amix/vimrc)
* [Vincent Zhang's](https://github.com/seagle0128) [dotfiles](https://github.com/seagle0128/dotfiles)

## License

The code is available under the [MIT License](LICENSE)
