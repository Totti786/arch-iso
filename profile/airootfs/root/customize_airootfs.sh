#!/usr/bin/env bash

## Script to perform several important tasks before `mkarchcraftiso` create filesystem image.

set -e -u

## -------------------------------------------------------------- ##

# Get new user's username
new_user=`cat /etc/passwd | grep "/home" | cut -d: -f1 | head -1`

## Modify /etc/mkinitcpio.conf file
sed -i '/etc/mkinitcpio.conf' \
	-e "s/base udev/base udev plymouth/g" \
	-e "s/#COMPRESSION=\"zstd\"/COMPRESSION=\"zstd\"/g"

## Fix Initrd Generation in Installed System
cat > "/etc/mkinitcpio.d/linux.preset" <<- _EOF_
	# mkinitcpio preset file for the 'linux' package

	ALL_kver="/boot/vmlinuz-linux"
	ALL_config="/etc/mkinitcpio.conf"

	PRESETS=('default' 'fallback')

	#default_config="/etc/mkinitcpio.conf"
	default_image="/boot/initramfs-linux.img"
	#default_options=""

	#fallback_config="/etc/mkinitcpio.conf"
	fallback_image="/boot/initramfs-linux-fallback.img"
	fallback_options="-S autodetect"    
_EOF_

## Delete ISO specific init files
rm -rf /etc/mkinitcpio.conf.d
rm -rf /etc/mkinitcpio.d/linux-nvidia.preset
rm -rf /etc/mkinitcpio-nvidia.conf

## -------------------------------------------------------------- ##

## Set zsh as default shell for new user
sed -i -e 's#SHELL=.*#SHELL=/bin/zsh#g' /etc/default/useradd

## -------------------------------------------------------------- ##

## Copy Few Configs Into Root Dir
rdir="/root/.config"
sdir="/etc/skel"
if [[ ! -d "$rdir" ]]; then
	mkdir "$rdir"
fi

cp -r /etc/skel/.config /root
cp -r /etc/skel/.icons /root
cp -r /etc/skel/.local /root

# -------------------------------------------------------------- ##

## Fix cursor theme
rm -rf /usr/share/icons/default

## Update xdg-user-dirs for bookmarks in thunar and pcmanfm
runuser -l liveuser -c 'xdg-user-dirs-update'
runuser -l liveuser -c 'xdg-user-dirs-gtk-update'
xdg-user-dirs-update
xdg-user-dirs-gtk-update

## Delete stupid gnome backgrounds
gndir='/usr/share/backgrounds/gnome'
if [[ -d "$gndir" ]]; then
	rm -rf "$gndir"
fi

## -------------------------------------------------------------- ##

## Hide Unnecessary Apps
adir="/usr/share/applications"
apps=(avahi-discover.desktop bssh.desktop bvnc.desktop echomixer.desktop \
	envy24control.desktop exo-preferred-applications.desktop feh.desktop \
	hdajackretask.desktop hdspconf.desktop hdspmixer.desktop hwmixvolume.desktop lftp.desktop \
	libfm-pref-apps.desktop lxshortcut.desktop lstopo.desktop \
	networkmanager_dmenu.desktop pcmanfm-desktop-pref.desktop \
	qv4l2.desktop qvidcap.desktop stoken-gui.desktop stoken-gui-small.desktop thunar-bulk-rename.desktop \
	thunar-settings.desktop thunar-volman-settings.desktop yad-icon-browser.desktop)

for app in "${apps[@]}"; do
	if [[ -e "$adir/$app" ]]; then
		sed -i '$s/$/\nNoDisplay=true/' "$adir/$app"
	fi
done

## -------------------------------------------------------------- ##

# Fix permissions for all the scripts

# Make all the scripts excutable
declare -a directory=(ags bspwm openbox i3 polybar jgmenu rofi zathura)

getfiles(){
	for i in "${directory[@]}"; do
		files=$(file $(find "/home/${new_user}/.config/$i" "/home/${new_user}/.local/bin" -type f) | grep  "script")
		file="$( echo "$files" | cut -d ":" -f1)"
		echo "$file"
	done
}

getfiles > /tmp/shell-files

for i in $(cat /tmp/shell-files); do 
	chmod +x "$i"
done && echo "Done!"

## -------------------------------------------------------------- ##
