#!/usr/bin/env bash

set -e  # Прекратить выполнение при ошибке

echo "=== Начинаем установку dotfiles и настройку Fedora ==="

# Подготовка
echo "Обновление пакетов и подключение репозиториев..."
sudo dnf update -y
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "=== Обновление и подключение прошло успешно ==="

# 0. Удаление предустановленных программ
echo "Удаление предустановленного софта..."
sudo dnf remove -y libreoffice-* simple-scan gnome-boxes gnome-maps gnome-weather gnome-characters gnome-contacts gnome-connections gnome-tour mediawriter
echo "=== Программы успешно удалены ==="

# 1. Установка пакетов
echo "Установка нужных пакетов..."
sudo dnf install -y flatpak kitty easyeffects gnome-tweaks gimp qbittorrent lollypop
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Extension Manager
flatpak install -y flathub com.mattjakeman.ExtensionManager

#Hiddify
curl -L -o hiddify.rpm https://github.com/hiddify/hiddify-app/releases/download/v2.0.5/Hiddify-rpm-x64.rpm
sudo dnf install -y ./hiddify.rpm
rm -f hiddify.rpm

#Onlyoffice
curl -L -o onlyoffice.rpm https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm
sudo dnf install -y ./onlyoffice.rpm
rm -f onlyoffice.rpm

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
echo "Настройка .bashrc..."
cp -v ./bash/.bashrc ~/.bashrc
echo "=== Bash конфиг применен ==="

# 3. Установка шрифтов
echo "Установка шрифтов..."
mkdir -p ~/.local/share/fonts
cp -rv ./fonts/* ~/.local/share/fonts/
fc-cache -f -v  # Обновление кэша шрифтов
echo "=== Шрифты готовы для выбора в Tweaks ==="

# 4. Применение keybinds
echo "Применение keybinds..."
dconf load /org/gnome/desktop/wm/keybindings/ < ./keybinds/wm-keys.txt
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ./keybinds/media-keys.txt
dconf load /org/gnome/mutter/keybindings/ < ./keybinds/mutter-keys.txt
dconf load /org/gnome/mutter/wayland/keybindings/ < ./keybinds/mutter-wayland-keys.txt
dconf load /org/gnome/shell/keybindings/ < ./keybinds/shell-keys.txt
echo "=== Хоткеи установлены  ==="

# 5. Настройка kitty
echo "Настройка kitty..."
mkdir -p ~/.config/kitty
cp -rv ./kitty/* ~/.config/kitty/
echo "=== Kitty настроен  ==="

# 6. Обновление GRUB
echo "=== Настройка параметров GRUB... ==="
sudo tee /etc/default/grub > /dev/null <<EOF
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_DISABLE_SUBMENU=y
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EOF

# 7. Генерируем новый конфиг grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
echo "=== GRUB настроен ==="

# 8. Перенос расширений  
echo "Установка GNOME Shell Extensions..."
gnome-extensions list | xargs -n1 gnome-extensions disable
mkdir -p ~/.local/share/gnome-shell/extensions
cp -r ./extensions/* ~/.local/share/gnome-shell/extensions/
echo "=== Расширения установлены ==="

# 9. Автостарт приложений
echo "Настройка автозапуска..."
mkdir -p ~/.config/autostart
# EasyEffects service (фоновый режим)
cat > ~/.config/autostart/easyeffects-service.desktop <<EOF
[Desktop Entry]
Name=Easy Effects
Comment=Easy Effects Service
Exec=easyeffects --gapplication-service
Icon=com.github.wwmm.easyeffects
StartupNotify=false
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF

# Hiddify GUI
cat > ~/.config/autostart//hiddify.desktop <<EOF
[Desktop Entry]
Type=Application
Version=2.0.5+20005
Name=Hiddify
GenericName=Hiddify
Icon=hiddify
Exec=hiddify %U
Keywords=Hiddify;Proxy;VPN;V2ray;Nekoray;Xray;Psiphon;OpenVPN;
StartupNotify=true
X-GNOME-Autostart-enabled=true
EOF
echo "=== Приложения поставлены в автозапуск ==="

# 10. Настройка pipewire для аудиокарты
echo "Настройка pipewire под аудиокарту Audient iD4 Mk2..."
mkdir -p ~/.config/pipewire
cp ./pipewire.conf ~/.config/pipewire/pipewire.conf
echo "=== Аудиокарта настроена ==="

# 11. Настройка firefox
echo "Настройка firefox..."
FIREFOX_PROFILE_DIR=$(awk -F= '/^\[Profile[0-9]+\]/{p=0} 
                              /^Name=default-release$/{p=1} 
                              p && /^Path=/{print $2; exit}' ~/.mozilla/firefox/profiles.ini)

FIREFOX_PROFILE_PATH="$HOME/.mozilla/firefox/$FIREFOX_PROFILE_DIR"
PREFS_FILE="$FIREFOX_PROFILE_PATH/prefs.js"

if [ -f "$PREFS_FILE" ]; then
  echo "🛠 Вписываю настройки в $PREFS_FILE"
  cat >> "$PREFS_FILE" <<EOF

// --- custom hardening prefs ---
user_pref("browser.uidensity", 1);
user_pref("extensions.pocket.api", "");
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.pocket.site", "");
user_pref("extensions.pocket.oAuthConsumerKey", "");
user_pref("full-screen-api.transition-duration.enter", "0");
user_pref("full-screen-api.transition-duration.leave", "0");
user_pref("full-screen-api.warning.timeout", 0);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.cachedClientID", "");
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.previousBuildID", "");
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.server_owner", "");
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("datareporting.healthreport.infoURL", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.policy.firstRunURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.tabs.crashReporting.email", false);
user_pref("browser.tabs.crashReporting.emailMe", false);
user_pref("breakpad.reportURL", "");
user_pref("security.ssl.errorReporting.automatic", false);
user_pref("toolkit.crashreporter.infoURL", "");
user_pref("network.allow-experiments", false);
user_pref("dom.ipc.plugins.reportCrashURL", false);
user_pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false);
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.tabs.tabmanager.enabled", false);
EOF

  echo "=== Firefox настроен ==="
else
  echo "!!! prefs.js не найден. Возможно, Firefox не запускался !!!"
fi

# Удаление стандартного терминала
echo "Удаление ptyxis..."
sudo dnf remove -y ptyxis
echo "=== Терминал удален  ==="

echo "Установка завершена. Перезагружаем систему через 10 секунд..."
echo "Для отмены нажмите Ctrl+C"
sleep 10
sudo systemctl reboot
