echo ""
echo "************************************"
echo "One-time post-vagrant-porovisioning"
echo "************************************"
echo ""

echo -n "Enter your full name: "
read FULL_NAME
echo -n "Enter your PHT email address: "
read EMAIL

sed --in-place \
		-e "s/@@EMAIL@@/${EMAIL}/g" \
		-e "s/@@FULL_NAME@@/${FULL_NAME}/g" \
		$HOME/.gitconfig


# Pre-fill in some settings in ng-install.ini
sed --in-place \
		-e "s/@@EMAIL@@/${LOGNAME}@phtcorp.com/g" \
		-e "s/@@HOSTNAME@@/$(hostname)/g" \
		$HOME/ng-install.ini

sudo hostname ${EMAIL%@*}
