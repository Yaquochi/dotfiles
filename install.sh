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
echo "=== Программы успешно установлены ==="

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
