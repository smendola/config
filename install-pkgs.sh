#!/bin/bash
apt update && apt -y upgrade && apt -y autoremove

pkgs=(
    zip
    unzip
    git
    highlight
    jq
    less
    postgresql-client
    rsync
    tree
    vim
    xmlstarlet
)

apt -y install "${pkgs[@]}"

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
  apt -y install ./google-chrome-stable_current_amd64.deb &&
  rm ./google-chrome-stable_current_amd64.deb
