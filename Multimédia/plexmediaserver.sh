apt update -y && apt upgrade -y
cd /tmp
wget https://downloads.plex.tv/plex-media-server/1.8.4.4249-3497d6779/plexmediaserver_1.8.4.4249-3497d6779_amd64.deb
dpkg -i plexmediaserver_1.8.4.4249-3497d6779_amd64.deb
systemctl status plexmediaserver

read -p "Se connecter sur : http://@IP:32400/manage" pause