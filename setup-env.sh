#!/bin/bash

set -e

cd $HOME

rm -rf config
git config --global --add core.autocrlf false
git clone https://smendola@bitbucket.org/smendola/config.git

rm -rf .config.git
git init --separate-git-dir .config.git
rm .git
function dots() {
    git --git-dir=$HOME/.config.git/ --work-tree=$HOME "$@"
}

dots remote add origin https://smendola@bitbucket.org/smendola/config.git
dots fetch origin xubuntu
dots checkout --force xubuntu

rm -rf ~/.oh-my-zsh
git clone https://smendola@bitbucket.org/smendola/.oh-my-zsh.git
