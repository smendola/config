#!/bin/bash

if grep -q @@EMAIL@@ ~/.gitconfig ~/ng-install.ini
then

    echo ""
    echo "************************************"
    echo "One-time post-vagrant-porovisioning"
    echo "************************************"
    echo ""

	echo -n "Enter your full name: "
	read FULL_NAME
	echo -n "Enter your PHT email address: "
	read EMAIL

    if [ -z "$EMAIL" ]
    then
      echo "Skipping this procedure"
      exit
    fi

	sed --in-place \
			-e "s/@@EMAIL@@/${EMAIL}/g" \
			-e "s/@@FULL_NAME@@/${FULL_NAME}/g" \
			$HOME/.gitconfig


	# Pre-fill in some settings in ng-install.ini
	sed --in-place \
			-e "s/@@EMAIL@@/${LOGNAME}@phtcorp.com/g" \
			-e "s/@@HOSTNAME@@/$(hostname)/g" \
			$HOME/ng-install.ini
    echo ${EMAIL%@*}-ng-dev > ~/.hostname
fi

#sudo hostname $(cat ~/.hostname)
#sudo sed -i "s/^127.0.0.1[ \t]*localhost.*$/127.0.0.1 localhost $(hostname)/g" /etc/hosts
