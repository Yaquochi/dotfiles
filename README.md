1) git clone https://github.com/Yaquochi/dotfiles.git
2) cd dotfiles
3) sudo chmod +x install.sh
4) ./install.sh
5) закрыть firefox

После установки в tweaks выбрать шрифты Roboto для первых двух и RobotoMono Nerd Font Mono для последнего пункта. В teaks поменять caps и esp местами. 

Добавить в easyeffects конфиг с эквалайзером

Удалить через software parental controls

--------------------------------------------

Далее речь пройдет про ускорение системы и автозагрузку
Следующие команды запустят тесты на загрузку системы и покажут время
systemd-analyze
systemd-analyze critical-chain
systemd-analyze blame | head -n 20

sudo systemctl enable docker.socket #если нужен docker, но не хочется ставить в автозагрузку
sudo systemctl enable docker.service #полная автозагрузка docker
