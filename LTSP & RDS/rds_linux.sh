
#### Update && upgrade puis installation syslinux

apt-get update -y && apt-get upgrade -y
apt-get install syslinux -y

### Créer l'arborescence pour le serveur tftp
mkdir -p /srv/tftp
### On copie le fichier de base de syslinux (qui sert de boot) dans le serveur tftp
cp /usr/lib/syslinux/pxelinux.0 /srv/tftp/

#### Installation dnsmasq
apt-get install dnsmasq -y
read -p "Quel sera l'interface d'écoute [ex : enp0s3] " interface
read -p "Quel range souhaitez-vous pour le dhcp [ex 192.168.1.100,192.168.1.105] " range
read -p "Quel masque souhaitez-vous pour la range ? [exemple 255.255.255.0] " netmask
read -p "Quel gateway souhaitez-vous ? [exemple 192.168.1.1] " gateway

echo "
# Configuration file for dnsmasq.
## Activation d'une plage DHCP pour les clients PXE

## Interface d'écoute 
interface = $interface

## Une adresse IP est attribuée pour 6heures au client
dhcp-range=$range,6h

# Masque
dhcp-option=1,$netmask

# Passerelle par défaut
dhcp-option=3,$gateway

## Fichier de boot PXE
dhcp-boot=pxelinux.0

## Activer le TFTP et definir un repertoire (/srv/tftp)
enable-tftp
tftp-root=/srv/tftp
" >> /etc/dnsmasq.conf

### Rédemarrage du service
service dnsmasq restart

### téléchargement du netboot debian 
cd /srv/tftp
wget http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar zxf netboot.tar.gz 
rm netboot.tar.gz

### Téléchargement du netboot Ubuntu
cd /srv/tftp
wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar zxf netboot.tar.gz
rm netboot.tar.gz
