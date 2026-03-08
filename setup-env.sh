#!/bin/bash -ue

function dots() {
    git --git-dir=$HOME/.config.git/ --work-tree=$HOME "$@"
}

cd $HOME

# Fetch available branches from the repository
echo "Fetching available branches..."
BRANCHES=($(git ls-remote --heads https://smendola@github.com/smendola/config.git | sed 's|.*refs/heads/||' | sort))

if [ ${#BRANCHES[@]} -eq 0 ]; then
    echo "Error: No branches found in repository"
    exit 1
fi

# Display branches as a numbered menu
echo "Available branches:"
for i in "${!BRANCHES[@]}"; do
    echo "$((i+1))) ${BRANCHES[$i]}"
done

# Prompt for selection
while true; do
    read -er -p "Select branch number (1-${#BRANCHES[@]}): " SELECTION </dev/tty
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le ${#BRANCHES[@]} ]; then
        BRANCH="${BRANCHES[$((SELECTION-1))]}"
        echo "Selected branch: $BRANCH"
        break
    else
        echo "Invalid selection. Please enter a number between 1 and ${#BRANCHES[@]}"
    fi
done

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
