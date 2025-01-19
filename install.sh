#!/bin/bash

#YAY
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si


#OH-MY-ZSH
yay -S zsh curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp .zshrc ~/.zshrc


#VIM 
cp .vimrc ~/.vimrc


#I3 & CONFIG
yay -S i3-wm i3blocks i3status i3-lock-color xss-lock rofi \
	nm-applet numlockx \
	pulseaudio brightnessctl \
	feh picom redshift \
	nautilus alacritty terminator 

cp -r ./i3 ~/.config/i3
cp -r ./i3status ~/.config/i3status


#XORG CONFIGS
read -p "Copy xorg configuration files (check devices)? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo
	sudo cp -r ./xorg.conf.d /etc/X11/xorg.conf.d
	sudo cp -r ./nvidia.xorg.conf.d /etc/X11/nvidia.xorg.conf.d
fi


#LY
yay -S ly
sudo cp ./ly/config.ini /etc/ly/config.ini


#ASUS BATTERY LIMIT
read -p "Install battery limiter? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo
	sudo bash ./limitd.sh 60
fi
