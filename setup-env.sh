#!/bin/bash -ue

cd $HOME

read -er -p "What branch do you want to fetch? (e.g. xubuntu, wsl): " BRANCH

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
dots fetch origin $BRANCH
dots checkout --force $BRANCH

rm -rf ~/.oh-my-zsh
git clone https://smendola@bitbucket.org/smendola/.oh-my-zsh.git


sudo apt-get install -y zsh
chsh $USER -s /usr/bin/zsh
exec zsh --login
