#!/bin/bash
pkgs=(
    zip
    unzip
    tree
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

apt install "${pkgs[@]}"
