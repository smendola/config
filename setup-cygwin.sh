#!/bin/sh
trap "echo Aborting; exit 1" ERR

if [[ `uname` = CYGWIN* ]]
then
    echo "Please run this script in git-bash, not cygwin;"
    echo "in fact, it's probably safest to completely uninstall"
    echo "cygwin before running this setup."
    exit 1
fi

echo "WARNING: this setup is destructive of any pre-existing bash"
echo "configuration you may already have (e.g. .bashrc, and many others)"
echo ""
echo -n "Proceed? (y/n) [n]: "
read proceed
if [[ $proceed != y* ]]
then
    echo "OK, never mind."
    exit
fi

echo "OK, you asked for it..."

## First, fetch all the configuration files from git repo on bitbucket
git config --global --add core.autocrlf false
cd $HOME
rm -rf .config.git
git init --separate-git-dir .config.git
rm .git
alias dots='git --git-dir=$HOME/.config.git/ --work-tree=$HOME'

dots remote add origin https://smendola@bitbucket.org/smendola/config.git
dots fetch origin master
dots checkout --force

# Fetch customized .oh-my-zsh config, also from bitbucket
rm -rf ~/.oh-my-zsh
git clone https://smendola@bitbucket.org/smendola/.oh-my-zsh.git

# Fetch cygwin installer
echo "Fetching cygwin installer from cygwin.com"
curl '-#' -o ./cygwin-setup.exe 'http://cygwin.com/setup.exe'

# Run the installer, requesting some specific packages we need
./cygwin-setup.exe -q -R 'C:\cygwin' -l 'C:\cygwin-pkgs' \
    -P tar,zip,unzip,p7zip,vi,openssh,ca-certificates,curl,wget,source-highlight,dos2unix,git,git-completion,zsh,terminfo,ncurses,xmlstarlet,nc,rsync

echo "**************************************************************"
echo "Cygwin should now be installed."
echo ""

echo "Changing your cygwin HOME directory to match your Windows HOME"
echo "and your git-bash HOME"
# Fix up home directory; instead of cygwin standard, use Windows (and MSYSGIT) standard    
sed --in-place -e "s|/home/${USERNAME}:/bin/bash|${HOME}:/bin/zsh|gi" /c/cygwin/etc/passwd

echo "Mounting C: as /c, which is convenient, and also compatible with MSYSGIT"
echo 'C:/ /c ntfs binary,user 0 0' >> /c/cygwin/etc/fstab

echo "Now, going to pre-fill in some settings into .gitconfig"
echo "and ng-install.ini .  You may still need to edit those to"
echo "finish tailoring them to your environment."
echo ""
# .gitconfig requires your email address, and your full name; the copy
# that came with this zip file contains neither, so add them now.
# Your email address can be constructed, but your full name can't, so prompt for that.
echo -n "Enter your full name; this will go in .gitconfig: "
read FULL_NAME
echo -n "Enter your email address: [${USERNAME}@phtcorp.com]: "
read EMAIL

sed --in-place \
    -e "s/@@EMAIL@@/${EMAIL}/g" \
    -e "s/@@FULL_NAME@@/${FULL_NAME}/g" \
    .gitconfig 


# Pre-fill in some settings in ng-install.ini
sed --in-place \
    -e "s/@@EMAIL@@/${USERNAME}@phtcorp.com/g" \
    -e "s/@@HOSTNAME@@/$(hostname)/g" \
    ng-install.ini 

echo ""
echo "*************************************"
echo " OK, so far so good."
echo " Now you need to edit \$HOME/.bashrc"
echo "   (look for ENVIRONMENT section)"
echo " and \$HOME/ng-install.ini"
echo "*************************************"
