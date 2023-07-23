#!/bin/bash -ue

function dots() {
    git --git-dir=$HOME/.config.git/ --work-tree=$HOME "$@"
}

cd $HOME

read -er -p "What branch do you want to fetch? (e.g. xubuntu, wsl): " BRANCH

rm -rf config .config.git .oh-my-zsh

git config --global --add core.autocrlf false
git clone -b $BRANCH https://smendola@github.com/smendola/config.git
(cd config && tar cf - .) | tar xf -
mv .git .config.git
dots submodule update --init

sudo apt-get install -y zsh
chsh $USER -s /usr/bin/zsh


# install Meslo fonts
mkdir -p ~/.local/share/fonts
cp ~/Meslo_LG_1.2.1/*ttf ~/.local/share/fonts/
fc-cache -f

exec zsh --login
