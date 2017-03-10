# DevStrap

[![Build Status](https://travis-ci.org/ray-g/devstrap.svg?branch=master)](https://travis-ci.org/ray-g/devstrap)

Quickly add necessary packages and a set of dotfiles to
bootstrap your development environments.

Currently it only supports Ubuntu now. But this framework should
work on MacOS and any other Linux.

For platforms other than Ubuntu, `install.sh --env-only` is an option
to skip package selection and installation, only setup the dotfiles.

PRs are welcome. :smile:

The packages and settings are based on my personal favorite,
but they are customizable during installation via an
interactive `whiptail` dialog.

And some dotfiles are also [custmizable](#customize) after installation.
Details are here
[~/.zshrc.local](#zshrclocal),
[~/.zshrc.theme.local](#zshrcthemelocal),
[~/.vimrc.local](#vimrclocal),
[~/.gitconfig.local](#gitconfiglocal).

## Quick Start

```shell
git clone https://github.com/ray-g/devstrap.git ~/.devstrap
~/.devstrap/install.sh
```

## Snapshots

### Package Select Dialog

<img src="https://github.com/ray-g/devstrap/blob/master/docs/snapshots/package_box.PNG" width="600" height="400">

### Installing Result

<img src="https://github.com/ray-g/devstrap/blob/master/docs/snapshots/installing.PNG" width="600" height="400">

### Sample UI with Tmux

<img src="https://github.com/ray-g/devstrap/blob/master/docs/snapshots/layout.PNG" width="600" height="400">

### Git Log

<img src="https://github.com/ray-g/devstrap/blob/master/docs/snapshots/git_log.PNG" width="600" height="400">

## Command Line Options

```text
./install.sh -h
Usage: ./install.sh [options]
Options:
-h | --help       print this help
-d | --debug      enable debug mode
-r | --dryrun     enable dryrun mode
     --all-yes    install all packages without selecting
-n | --sel-none   select none packages in box
     --env-only   setup environments only
```

## Customize

The `dotfiles` can be easily extended to suit additional
local requirements by using the following files:

### ~/.zshrc.local

The `~/.zshrc.local` file will be automatically sourced after
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

### ~/.zshrc.theme.local

The `~/.zshrc.theme.local` file will be automatically sourced before
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) setting up theme.
Thus, allowing you to set your favorite `oh-my-zsh` theme.
By default I have set it to a fence one [ys](https://github.com/robbyrussell/oh-my-zsh/wiki/themes#ys)

### ~/.vimrc.local

The `~/.vimrc.local` file will be automatically sourced after
`~/.vimrc`, thus, allowing its content to add or overwrite the
settings from `~/.vimrc`.

### ~/.gitconfig.local

The `~/.gitconfig.local` file will be automatically included
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
