#!/bin/bash

set -e  # Прекратить выполнение при ошибке

echo "=== Начинаем установку dotfiles и настройку Fedora ==="

# Подготовка
echo "Обновление пакетов и подключение репозиториев..."
sudo dnf update -y
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "=== Обновление и подключение прошло успешно ==="

# 0. Удаление предустановленных программ
echo "[0/5] Удаление предустановленного софта..."
sudo dnf remove -y libreoffice-* simple-scan gnome-boxes gnome-maps gnome-weather gnome-characters gnome-contacts gnome-connections gnome-tour mediawriter
echo "=== Программы успешно удалены ==="

# 1. Установка пакетов
echo "[1/5] Установка нужных пакетов..."
sudo dnf install -y flatpak kitty easyeffects gnome-tweaks gimp qbittorrent lollypop
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Extension Manager
flatpak install -y flathub com.mattjakeman.ExtensionManager

#Hiddify
curl -L -o hiddify.rpm https://github.com/hiddify/hiddify-app/releases/download/v2.0.5/Hiddify-rpm-x64.rpm
sudo dnf install -y ./hiddify.rpm
rm hiddify.rpm

#Onlyoffice
curl -L -o onlyoffice.rpm https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm
sudo dnf install -y ./onlyoffice.rpm
rm onlyoffice.rpm

#Obsidian
flatpak install -y flathub md.obsidian.Obsidian

#Telegram
flatpak install -y flathub org.telegram.desktop 

#OBS Studio
flatpak install -y flathub com.obsproject.Studio

#Foliate
flatpak install -y flathub com.github.johnfactotum.Foliate

#Virtual Machine Manager
sudo dnf install -y @virtualization
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
echo "=== Программы успешно установлены ==="

# 2. Настройка bash
echo "[2/5] Настройка .bashrc..."
cp -v ./bash/.bashrc ~/.bashrc
echo "=== Bash конфиг применен ==="

# 3. Установка шрифтов
echo "[3/5] Установка шрифтов..."
mkdir -p ~/.local/share/fonts
cp -rv ./fonts/* ~/.local/share/fonts/
fc-cache -f -v  # Обновление кэша шрифтов
echo "=== Шрифты готовы для выбора в Tweaks ==="

# 4. Применение keybinds
echo "[4/5] Применение keybinds..."
dconf load /org/gnome/desktop/wm/keybindings/ < ./keybinds/wm-keys.txt
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ./keybinds/media-keys.txt
dconf load /org/gnome/mutter/keybindings/ < ./keybinds/mutter-keys.txt
dconf load /org/gnome/mutter/wayland/keybindings/ < ./keybinds/mutter-wayland-keys.txt
dconf load /org/gnome/shell/keybindings/ < ./keybinds/shell-keys.txt
echo "=== Хоткеи установлены  ==="

# 5. Настройка терминала (kitty)
echo "[5/5] Настройка kitty..."
mkdir -p ~/.config/kitty
cp -rv ./kitty/* ~/.config/kitty/
echo "=== Kitty настроен  ==="

# 6. Настройка терминала (kitty)
echo "[5/5] Удаление ptyxis..."
sudo dnf remove -y ptyxis
echo "=== Терминал удален  ==="

echo "Установка и настройка завершены!"
