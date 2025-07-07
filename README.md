1) git clone https://github.com/Yaquochi/dotfiles#
2) cd dotfiles
3) sudo chmod +x install.sh
4) ./install.sh

#Kitty
copy and paste kitty.conf and current-theme.conf in ~/.config/kitty

#Keybinds
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < media-keys.txt
dconf load /org/gnome/shell/keybindings/ < shell-keys.txt
dconf load /org/gnome/desktop/wm/keybindings/ < wm-keys.txt
dconf load /org/gnome/mutter/keybindings/ < mutter-keys.txt
dconf load /org/gnome/mutter/wayland/keybindings/ < mutter-wayland-keys.txt

#Sound
copy and paste pipewire.conf in ~/etc/pipewire/
import shp9500.txt in easyeffects in eq tab in apo import

#Fonts
download and mv roboto and robotomono in ~/.local/share/fonts

#Extensions
cd extensions
cp -r * ~/.local/share/gnome-shell/extensions

#Programs
dconf, kitty, git, easyeffects, tweaks, extension-manager, hiddify, telegram, obsidian, virtual machine maanger, onlyoffice, qbittorent, obs, discord, vscode

#Script
# Перед использованием прогреем sudo для дальнейшего удобства через sudo -v, затем /.install.sh
# Скачиваем приложения, потом все из папок растаскиваем по директориям, не забываем про authostart, далее надо установить все драйвера, в фаерфокс дополнить pref.js
