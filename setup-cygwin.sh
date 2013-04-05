#!/bin/sh
trap "echo Aborting; exit 1" ERR

# Fetch cygwin installer
echo "Fetching cygwin installer from cygwin.com"
curl '-#' -o ./cygwin-setup.exe 'http://cygwin.com/setup.exe'
echo "Done"

# Run the installer, requesting some specific packages we need
./cygwin-setup.exe -q -R 'C:\cygwin' -l 'C:\cygwin-pkgs' \
    -P tar,zip,unzip,p7zip,vi,openssh,curl,wget,git,source-highlight,dos2unix

# Fix up home directory; instead of cygwin standard, use Windows (and MSYSGIT) standard    
sed --in-place -e "s|/home/${USERNAME}|${HOME}|gi" /c/cygwin/etc/passwd

# Mount C: as /c, which is convenient, and also compatible with MSYSGIT
echo 'C:/ /c ntfs binary,user 0 0' >> /c/cygwin/etc/fstab


# .gitconfig requires your email address, and your full name; the copy
# that came with this zip file contains neither, so add them now.
# Your email address can be constructed, but your full name can't, so prompt for that.
echo -n "Enter your full name; this will go in .gitconfig: "
read FULL_NAME
sed --in-place .gitconfig -e "s/@@EMAIL@@/${USERNAME}@phtcorp.com/g" -e "s/@@FULL_NAME@@/${FULL_NAME}/g"

HOME_DOS=$($HOME/bin/msys/cygpath -d $HOME | tr '/' '\\')
# Pre-fill in some settings in ng-install.ini
sed -r --in-place ng-install.ini \
    -e "s/@@EMAIL@@/${USERNAME}@phtcorp.com/g" \
    -e "s/@@HOSTNAME@@/$(hostname)/g" \
    -e "s!@@HOME_DOS@@!${HOME_DOS}!g"


