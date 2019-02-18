apt-get update -y && apt-get upgrade -y

################# 6.3 Activer le routage #################

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

################## 6.5 Installer DHCP ################### 
apt-get -y install isc-dhcp-server
read -p "Quelle interface voulez-vous écouter ?[exemple : eth0] " interface

echo '
### Fichier de configuration pour DHCPD v4
DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
### Interface d"écoute 
INTERFACESv4="$interface" ' > /etc/default/isc-dhcp-server

read -p "Quel réseau souhaitez-vous configurer pour le DHCP [ex : 192.168.4.0] ? " reseau
read -p "Quel masque souhaitez-vous ? [ex : 255.255.255.0] " masque
read -p "Quel range voulez-vous [ex : 192.168.4.10 192.168.4.20] ? " range
read -p "Quel DNS souhaitez-vous attribuer [ex : 8.8.8.8] ? " DNS

echo "
# Configuration pour le réseau $reseau
subnet $reseau netmask $masque {
range $range;
option domain-name-servers $DNS;
default-lease-time 600;
max-lease-time 7200;
} " > /etc/dhcp/dhcpd.conf


echo "Il ne vous reste plus qu'à redémarrer le service isc-dhcp-server"

################ 6.6 Installer serveur Webmin ###############

apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python apt-transport-https

echo "deb http://download.webmin.com/download/repository sarge contrib " | tee /etc/apt/sources.list.d/webmin.list
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
apt-get update -y
apt-get -y install webmin
systemctl start webmin
read -p "Connectez-vous sur https://your-ip-addr-ess:10000 " pause

############### 6.7 Installer un serveur Samba ##############
apt-get install samba smbclient -y
cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
grep -v -E "^#|^;" /etc/samba/smb.conf_backup | grep . > /etc/samba/smb.conf

echo "
cat /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes
[homes]
   comment = Home Directories
   browseable = no
   read only = yes
   create mask = 0700
   directory mask = 0700
   valid users = %S
[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no " > /etc/samba/smb.conf

systemctl restart smbd

############# 6.8 Installer FTP ###############
apt-get install vsftpd ftp -y
echo " write_enable=YES " >> /etc/vsftpd.conf
systemctl restart vsftpd
