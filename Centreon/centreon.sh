apt update -y && apt upgrade -y
apt install sudo -y
read -p "Pause pour voir si tout fonctionne" pause 
apt install tofrodos bsd-mailx lsb-release mysql-server libdatetime-perl -y
read -p "Pause pour voir si tout fonctionne" pause 
apt install apache2 php7.0 php7.0-mysql php-pear php7.0-intl php7.0-ldap php7.0-snmp php7.0-gd php7.0-sqlite3 -y
read -p "Pause pour voir si tout fonctionne" pause 
apt install rrdtool librrds-perl libconfig-inifiles-perl libcrypt-des-perl libdigest-hmac-perl libdigest-sha-perl -y
read -p "Pause pour voir si tout fonctionne" pause 
apt install libgd-perl snmp snmpd libnet-snmp-perl libsnmp-perl nagios-plugins -y
read -p "Pause pour voir si tout fonctionne" pause 
apt install snmp-mibs-downloader -y
read -p "Pause pour voir si tout fonctionne" pause 

###### Installation de Centreon WEB
wget "https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon/centreon-web-2.8.16.tar.gz"
tar zxf centreon-web-2.8.16.tar.gz
## Création de l'utilisateur pour centreon global
groupadd centreon
useradd -g centreon -m -r -d /var/lib/centreon centreon
## Création de l'utilisateur pour engine
groupadd centreon-engine
useradd -g centreon-engine -m -r -d /var/lib/centreon-engine centreon-engine
## Création de l'utilisateur pour broker
groupadd centreon-broker
useradd -g centreon-broker -m -r -d /var/lib/centreon-broker centreon-broker

mkdir -p /var/log/centreon-engine && mkdir -p /var/log/centreon-broker
touch /etc/sudoers.d/centreon && touch /usr/sbin/centengine
mkdir -p /etc/centreon-engine && mkdir -p /etc/centreon-broker

cd centreon-web-2.8.16 && ./install.sh -i


### Création d'un fichier timezone pour php
echo "date.timezone = Europe/Paris" > /etc/php.d/php-timezone.ini
### SELinux doit être désactivé
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
