#!/usr/bin/env bash

set -e  # Прекратить выполнение при ошибке

PROGRESS_FILE="./.install_progress"
STEP=0
if [ -f "$PROGRESS_FILE" ]; then
  STEP=$(cat "$PROGRESS_FILE")
fi

echo "=== Начинаем установку dotfiles и настройку Fedora ==="

# Подготовка
if [ "$STEP" -lt 1 ]; then
    echo "Обновление пакетов и подключение репозиториев..."
    sudo dnf clean all
    sudo dnf makecache
    sudo dnf update -y
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    echo "=== Обновление и подключение прошло успешно ==="
    echo 1 > "$PROGRESS_FILE"
fi

# Удаление предустановленных программ
if [ "$STEP" -lt 2 ]; then
    echo "Удаление предустановленного софта..."
    sudo dnf remove -y libreoffice-* simple-scan gnome-boxes gnome-maps gnome-weather gnome-characters gnome-contacts gnome-connections gnome-tour mediawriter
    echo "=== Программы успешно удалены ==="
    echo 2 > "$PROGRESS_FILE"
fi

# Установка пакетов
if [ "$STEP" -lt 3 ]; then
    echo "Установка нужных пакетов..."
    sudo dnf install -y flatpak easyeffects qbittorrent gnome-tweaks gimp helix tmux alacritty k9s ripgrep fzf zoxide 
    sudo dnf install -y dnf-plugins-core
    sudo dnf copr enable lihaohong/yazi -y
    sudo dnf install -y yazi
    cp -rv ./helix/* ~/.config/helix
    chmod +x ~/.config/helix/yazi-picker.sh
 
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    #Extension Manager
    flatpak install -y flathub com.mattjakeman.ExtensionManager

    #OpenLens
    curl -L -o OpenLens.rpm https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens-6.5.2-366.x86_64.rpm
    sudo dnf install -y OpenLens.rpm
    rm -f OpenLens.rpm
    
    #Onlyoffice
    curl -L -o onlyoffice.rpm https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm
    sudo dnf install -y ./onlyoffice.rpm
    rm -f onlyoffice.rpm
    
    #Obsidian
    flatpak install -y flathub md.obsidian.Obsidian
    
    #Telegram
    flatpak install -y flathub org.telegram.desktop 

    #Discord
    flatpak install -y flathub com.discordapp.Discord
    
    #OBS Studio
    flatpak install -y flathub com.obsproject.Studio
    
    #Foliate
    flatpak install -y flathub com.github.johnfactotum.Foliate
    
    #Virtual Machine Manager
    sudo dnf install -y @virtualization
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
    echo "=== Программы успешно установлены ==="
    echo 3 > "$PROGRESS_FILE"
fi
    
# Настройка bash
if [ "$STEP" -lt 4 ]; then
    echo "Настройка .bashrc..."
    cp -v ./bash/.bashrc ~/.bashrc
    echo "=== Bash конфиг применен ==="
    echo 4 > "$PROGRESS_FILE"
fi

# Установка шрифтов
if [ "$STEP" -lt 5 ]; then
    echo "Установка шрифтов..."
    mkdir -p ~/.local/share/fonts
    cp -rv ./fonts/* ~/.local/share/fonts/
    fc-cache -f -v  # Обновление кэша шрифтов
    echo "=== Шрифты готовы для выбора в Tweaks ==="
    echo 5 > "$PROGRESS_FILE"
fi

# Применение keybinds
if [ "$STEP" -lt 6 ]; then
    echo "Применение keybinds..."
    dconf load /org/gnome/desktop/wm/keybindings/ < ./keybinds/wm-keys.txt
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ./keybinds/media-keys.txt
    dconf load /org/gnome/mutter/keybindings/ < ./keybinds/mutter-keys.txt
    dconf load /org/gnome/mutter/wayland/keybindings/ < ./keybinds/mutter-wayland-keys.txt
    dconf load /org/gnome/shell/keybindings/ < ./keybinds/shell-keys.txt
    echo "=== Хоткеи установлены  ==="
    echo 6 > "$PROGRESS_FILE"
fi

# Настройка alacritty и tmux
if [ "$STEP" -lt 7 ]; then
    echo "Настройка alacritty..."
    mkdir -p ~/.config/alacritty
    cp -rv ./alacritty/* ~/.config/alacritty/
    echo "=== Alacritty настроен  ==="
    echo "Настройка tmux..."
    mkdir -p ~/.config/tmux/
    cp -rv ./tmux/* ~/.config/tmux/
    tmux source-file ~/.config/tmux/tmux.conf
    echo 7 > "$PROGRESS_FILE"
fi

# Обновление GRUB
if [ "$STEP" -lt 8 ]; then
    echo "=== Настройка параметров GRUB... ==="
    sudo tee /etc/default/grub > /dev/null <<EOF
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_DISABLE_SUBMENU=y
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EOF
    
# Генерируем новый конфиг grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    echo "=== GRUB настроен ==="
    echo 8 > "$PROGRESS_FILE"
fi

# Перенос расширений  
if [ "$STEP" -lt 9 ]; then
    echo "Установка GNOME Shell Extensions..."
    gnome-extensions list | xargs -n1 gnome-extensions disable
    mkdir -p ~/.local/share/gnome-shell/extensions
    cp -r ./extensions/* ~/.local/share/gnome-shell/extensions/
    for ext in $(gnome-extensions list --user); do
        gnome-extensions enable "$ext"
    done
    echo "=== Расширения установлены ==="
    echo 9 > "$PROGRESS_FILE"
fi

# Автостарт приложений
if [ "$STEP" -lt 10 ]; then
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

    echo "=== Приложения поставлены в автозапуск ==="
    echo 10 > "$PROGRESS_FILE"
fi

# Настройка pipewire для аудиокарты
if [ "$STEP" -lt 11 ]; then
    echo "Настройка pipewire под аудиокарту Audient iD4 Mk2..."
    mkdir -p ~/.config/pipewire
    cp ./sound/pipewire.conf ~/.config/pipewire/pipewire.conf
    systemctl --user enable pipewire
    systemctl --user enable wireplumber
    systemctl --user start pipewire wireplumber

    echo "=== Аудиокарта настроена ==="
    echo 11 > "$PROGRESS_FILE"
fi

# Настройка firefox
if [ "$STEP" -lt 12 ]; then
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
    echo 12 > "$PROGRESS_FILE"
fi

# Перенос картинок
if [ "$STEP" -lt 13 ]; then
    echo "Перенос картинок..."
    cp -r ./pics/* ~/Pictures 
    echo "=== Картинки перемещены  ==="
    echo 13 > "$PROGRESS_FILE"
fi

# Настройка docker + podman
if [ "$STEP" -lt 14 ]; then
    echo "Настройка docker + podman..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo dnf install -y podman
    echo "=== Docker и podamn настроены  ==="
    echo 14 > "$PROGRESS_FILE"
fi


# Удаление стандартного терминала
echo "Удаление ptyxis..."
sudo dnf remove -y ptyxis
echo "=== Терминал удален  ==="

echo "Установка завершена. Перезагружаем систему через 10 секунд..."
echo "Для отмены нажмите Ctrl+C"
sleep 10
sudo systemctl reboot
