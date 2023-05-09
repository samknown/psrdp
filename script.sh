#!/bin/bash

# Set variables
CRP1=''
Pin=123456
Name="PaperSpcae"
username="user"
password="root"

apt purge nvidia*
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/525.116.03/NVIDIA-Linux-x86_64-525.116.03.run
sudo sh NVIDIA-Linux-x86_64-525.116.03.run -s

apt update && apt upgrade

# Create user and set up
echo "Creating User and Setting it up"
useradd -m $username
adduser $username sudo
echo "$username:$password" | sudo chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo "User Created and Configured"

# Replace hostname
CRP=${CRP1/\$\{hostname\}/$Name}

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
apt install ./chrome-remote-desktop_current_amd64.deb
apt install --assume-yes --fix-broken
groupadd chrome-remote-desktop

# Install Desktop Environment
echo "Installing Desktop Environment"
export DEBIAN_FRONTEND=noninteractive
apt install --assume-yes xfce4 desktop-base xfce4-terminal
bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
apt remove --assume-yes gnome-terminal
apt install --assume-yes xscreensaver
systemctl disable lightdm.service

# Install Google Chrome
echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome-stable_current_amd64.deb
apt install --assume-yes --fix-broken

# Finalize
echo "Finalizing"
adduser $username chrome-remote-desktop
command="$CRP --pin=$Pin"
su - $username -c "$command"
service chrome-remote-desktop start
echo "Finished Successfully"
