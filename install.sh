#!/bin/sh
# vim:foldmethod=marker

if [ $(whoami)  = "root" ]; then
    echo "don't run as root"
    exit 0
fi

ls -al ~/.ssh | grep -qi \.pub || {
    echo -e "Set up a GitHub PAT\nRun: ssh-keygen -t ed25519 -C \"email@example.com\""
    exit 1
}

cd "$HOME/repo/linux-conf"

# Install software & config
read -p "Install from spec? [Y/n]: " -n 1 answer
echo ""

if [ "$answer" != "n" -a "$answer" != "N" ]; then
    source installspec.sh

    cat "pac.list" | sudo pacman -S --needed -

    mkdir -p ~/aur
    cat "aur.list" | ./aur.sh -i -
fi

[ -h ~/.zprofile ] || ln -s ~/.config/shell/profile ~/.zprofile

# Tailscale maps
echo -e "\nLog into TailScale before answering this!"
read -p "Add tailscale IPs to /etc/hosts? [y/N]: " -n 1 answer
echo ""
if [ "$answer" = "Y" -o "$answer" = "y" ]; then
    tailscale status | \
    sed -E 's/\s{2,}/ /g' | \
    cut -d' ' -f1,2 | \
    sudo tee -a /etc/hosts
fi
