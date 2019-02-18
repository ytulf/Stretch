#!/bin/sh
#### Installation pour debian 9 stretch d'un serveur de client leger
#### Update && upgrade puis installation syslinux

apt update -y && apt upgrade -y
apt install syslinux -y

### Créer l'arborescence pour le serveur tftp
mkdir -p /srv/tftp
### On copie le fichier de base de syslinux (qui sert de boot) dans le serveur tftp
cp /usr/lib/syslinux/pxelinux.0 /srv/tftp/

#### Installation dnsmasq
apt install dnsmasq -y
clear 
ip -4 -o address show | grep enp | cut -d: -f2 | awk '{print $1,$3}' > config.txt

read -p "Interface actuelle :  `cat config.txt` 

Quel sera l'interface d'écoute [ex : enp0s3] " interface
read -p "
Quel range souhaitez-vous pour le dhcp [ex 192.168.1.100,192.168.1.105] ? " range
read -p "
Quel masque souhaitez-vous pour la range ? [exemple 255.255.255.0] " netmask
read -p "
Quel gateway souhaitez-vous ? [exemple 192.168.1.1] " gateway

clear
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
dhcp-boot=/srv/tftp/ltsp/i386/pxelinux.0

## Activer le TFTP et definir un repertoire (/srv/tftp)
enable-tftp
tftp-root=/srv/tftp
" > /etc/dnsmasq.conf

### Rédemarrage du service
/etc/init.d/dnsmasq restart

# Installation du serveur ltsp, du serveur d'applications, du NFS et de NBD
apt install ltsp-server ldm-server nfs-kernel-server nbd-server -y

### configuration NFS
mkdir /opt/ltsp
echo "/opt/ltsp *(ro,no_root_squash,async,no_subtree_check)" > /etc/exports
systemctl restart nfs-kernel-server.service

# Installation de lxde pour client lourd et xinit pour pouvoir lancer le bureau lxde sur le serveur LTSP en ligne de commande (avec startx)
apt install lxde xinit -y
### Modification du run-level pour éviter d'avoir une interface graphique sur le serveur
systemctl set-default multi-user.target
## Suppresion des paquets inutiles et lourds
apt purge wicd* deluge* clipit -y
apt autoremove -y

### Création des clients lourds :
ltsp-build-client --arch i386 --fat-client-desktop lxde --locale fr_FR.UTF-8 --prompt-rootpass

## Suppresion des paquets inutiles et lourds
echo "apt purge wicd* deluge* clipit -y" | ltsp-chroot -a i386
echo "apt autoremove -y" | ltsp-chroot -a i386

# Configuration nbd
ltsp-update-image --config-nbd i386           # l'option --config-nbd n'est utile qu'à la 1ère évocation de ltsp-update-image
systemctl restart nbd-server.service  

##### Modification du fichier pxelinux
clear
echo "
# This file is regenerated when update-kernels runs.  Do not edit
# directly, edit the client's /etc/ltsp/update-kernels.conf instead.

default ltsp-NBD
ontimeout ltsp-NBD
LABEL LTSP
	MENU LABEL ^Démarrer le pc en client léger ou lourd
	KERNEL tftp://$gateway/ltsp/i386/vmlinuz
	APPEND ro initrd=tftp://$gateway/ltsp/i386/initrd.img init=/sbin/init-ltsp quiet splash nbdroot=$gateway:/opt/ltsp/i386 root=/dev/nbd0
	IPAPPEND 2
  
# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

label ltsp-NBD
menu label LTSP, using NBD
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/nbd0
ipappend 2

# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

label ltsp-AOE
menu label LTSP, using AOE
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/etherd/e0.0
ipappend 2

# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

label ltsp-NFS
menu label LTSP, using NFS
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/nfs ip=dhcp boot=nfs
ipappend 2

# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

menu begin ltsp-versions-NBD
menu label Other LTSP boot options using NBD


label ltsp-NBD-4.9.0-4-686
menu label LTSP, using NBD, with Linux 4.9.0-4-686
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/nbd0
ipappend 2

menu end
# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

menu begin ltsp-versions-AOE
menu label Other LTSP boot options using AOE


label ltsp-AOE-4.9.0-4-686
menu label LTSP, using AOE, with Linux 4.9.0-4-686
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/etherd/e0.0
ipappend 2

menu end
# This file is regenerated when update-kernels runs.
# Do not edit, see /etc/ltsp/update-kernels.conf instead.

menu begin ltsp-versions-NFS
menu label Other LTSP boot options using NFS


label ltsp-NFS-4.9.0-4-686
menu label LTSP, using NFS, with Linux 4.9.0-4-686
kernel vmlinuz-4.9.0-4-686
append ro initrd=initrd.img-4.9.0-4-686 init=/sbin/init-ltsp quiet root=/dev/nfs ip=dhcp boot=nfs
ipappend 2

menu end
" > /srv/tftp/ltsp/i386/pxelinux.cfg/default

### Modification du niveau de RAM pour passer de client léger a lourd 
echo "
LDM_DIRECTX=True     	   # Pour les clients légers, ne plus crypter les échanges graphiques (l'identification des utilisateurs restant sécurisée)              
FAT_RAM_THREHOLD=500       # Définir le seuil de RAM (en Mo) à partir duquel les clients sont configurés en clients lourds (par défaut à 300) 
USE_LOCAL_SWAP=True        # Utilise une partition swap valide du disque dur du client, si elle existe 
" >> /opt/ltsp/i386/etc/lts.conf
chmod 744 /opt/ltsp/i386/etc/lts.conf

### Installation de samba et de PAM pour le montage automatique des dossiers pour les utilisateurs
apt install libpam-mount cifs-utils samba smbclient -y
### Sauvegarde de la config et modification
cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
### Création des répertoires de partages et attribution des droits
mkdir /srv/public/ /srv/classes && chmod 777 /srv/public/ /srv/classes

echo "
[global]
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
   browseable = yes
   read only = no
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
[public]
   comment = public anonymous access
   path = /srv/public
   browseable = yes
   create mask = 0660
   directory mask = 07771
   writeable = yes 
[Classes]
   comment = Access repository classes
   path = /srv/classes
   browseable = yes
   writeable = yes
   create mask = 0700
   directory mask = 0700
   valid users = %S
" > /etc/samba/smb.conf

systemctl restart smbd

# Pour vérifier : echo "$votre_mot_de_passe" | smbclient -L localhost

### Montage automatique des partages pour les hotes a chaque connexion 
echo '
<!-- 
	See pam_mount.conf(5) for a description.
 -->
<pam_mount>
<!--
 debug should come before everything else,
		since this file is still processed in a single pass
		from top-to-bottom 
-->
<debug enable="0"/>
<!--  Volume definitions  -->
<volume user="*" pgrp="Eleve" fstype="cifs" server="192.168.0.254" path="/srv/samba" mountpoint="~/Bureau/Public" options="nobrl,serverino,iocharset=utf8,sec=ntlmv2"/>
<volume user="*" pgrp="Eleve" fstype="cifs" server="192.168.0.254" path="/srv/classes" mountpoint="~/Bureau/Classes" options="nobrl,serverino,iocharset=utf8,sec=ntlmv2"/>
<!--  pam_mount parameters: General tunables  -->
<!-- 
<luserconf name=".pam_mount.conf.xml" />
 -->
<!--
 Note that commenting out mntoptions will give you the defaults.
     You will need to explicitly initialize it with the empty string
     to reset the defaults to nothing. 
-->
<mntoptions allow="nosuid,nodev,loop,encryption,fsck,nonempty,allow_root,allow_other"/>
<!--

<mntoptions deny="suid,dev" />
<mntoptions allow="*" />
<mntoptions deny="*" />
-->
<mntoptions require="nosuid,nodev"/>
<logout wait="0" hup="no" term="no" kill="no"/>
<!--  pam_mount parameters: Volume-related  -->
<mkmountpoint enable="1" remove="true"/>
</pam_mount>
'  > /etc/security/pam_mount.conf.xml
### Configuration du pam
echo " 
# PAM configuration for the Secure Shell service

# Standard Un*x authentication.
@include common-auth

# Disallow non-root logins when /etc/nologin exists.
account    required     pam_nologin.so

# Uncomment and edit /etc/security/access.conf if you need to set complex
# access limits that are hard to express in sshd_config.
# account  required     pam_access.so

# Standard Un*x authorization.
@include common-account

# SELinux needs to be the first session rule.  This ensures that any
# lingering context has been cleared.  Without this it is possible that a
# module could execute code in the wrong domain.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so close

# Set the loginuid process attribute.
session    required     pam_loginuid.so

# Create a new session keyring.
session    optional     pam_keyinit.so force revoke

# Standard Un*x session setup and teardown.
session required pam_mkhomedir.so skel=/etc/skel umask=0077
@include common-session

# Print the message of the day upon successful login.
# This includes a dynamically generated part from /run/motd.dynamic
# and a static (admin-editable) part from /etc/motd.
session    optional     pam_motd.so  motd=/run/motd.dynamic
session    optional     pam_motd.so noupdate

# Print the status of the user's mailbox upon successful login.
session    optional     pam_mail.so standard noenv # [1]

# Set up user limits from /etc/security/limits.conf.
session    required     pam_limits.so

# Read environment variables from /etc/environment and
# /etc/security/pam_env.conf.
session    required     pam_env.so # [1]
# In Debian 4.0 (etch), locale-related environment variables were moved to
# /etc/default/locale, so read that as well.
session    required     pam_env.so user_readenv=1 envfile=/etc/default/locale

# SELinux needs to intervene at login time to ensure that the process starts
# in the proper default security context.  Only sessions which are intended
# to run in the user's context should be run after this.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so open

# Standard Un*x password updating.
@include common-password 
" > /etc/pam.d/sshd
chmod -R 777 /etc/skel

### Installation de open-office sur les clients lourds
# On stop le service pour éviter les problèmes de montage et démontage des répertoires
systemctl stop nfs-kernel-server.service 
# On install les paquets dans le chroot
clear
### Installation de libreoffice
echo "apt install libreoffice -y" | ltsp-chroot -r -m -a i386
# On démarre le service
systemctl start nfs-kernel-server.service
# Et on met à jour l'image
ltsp-update-image

### Script d'ajout d'utilisateur dans les différents groupes
clear 
echo "Votre serveur est prêt vous pouvez connecter vos machines au réseau "
read -p "Voulez-vous créer vos utilisateurs et les assigner à des groupes ? [Y/N] " choix_user
case $choix_user in
[Yy])
	wget https://raw.githubusercontent.com/Keijix/Stretch/master/script_user.sh
	chmod +x script_user.sh
	./script_user.sh;;
*)
	;;
esac

### Installation et configuration de la solution permettant le maintien des services
apt-get install heartbeat -y

### Modification des fichiers 
## Fichier authkeys
echo "auth 3
3 md5 password" > /etc/ha.d/authkeys
chmod 600 /etc/ha.d/authkeys

## Fichier ha.cf
cat config.txt
read -p "
Quel est votre le nom de votre machine [exemple : ltsp1] ? " machine1
read -p "
Quel est votre le nom de la deuxième machine [exemple : ltsp2]? " machine2
read -p "
Quel est votre l'interface de liaison entre les deux routers [exemple : enp0s3] ? " eth

echo "logfile /var/log/ha-log 
logfacility   local0
keepalive     2
deadtime      10
bcast         $eth
node          $machine1 $machine2
auto_failback  on
respawn        hacluster /usr/lib/heartbeat/ipfail
apiauth        ipfail gid=haclient uid=hacluster" > /etc/ha.d/ha.cf

## Fichier haresources 

read -p "
Quel est l'adresse IP de l'interface virtuel que vous voulez utiliser [exemple : 192.168.0.254]? " ipvirtuel
read -p "
Quel est le masque que vous souhaitez utiliser ? [exemple : 24 ne pas utilisez le '/'] " mask
read -p "
Quel est votre le nom de la première machine [exemple : ltsp1] ? " machine1
read -p "
Quel est nom du service que vous voulez utiliser [exemple : dnsmasq] ? " service

echo "$machine1 IPaddr::$ipvirtuel/$mask/$eth $service" > /etc/ha.d/haresources
read -p "
Veuillez lancer le script sur l'autre serveur, une fois que vous êtes arrivé ici avec l'autre serveur vous pouvez taper 'Go' " depart
/etc/init.d/heartbeat start

#### Installation de italc sur les clients lourd
# On stop le service pour éviter les problèmes de montage et démontage des répertoires
systemctl stop nfs-kernel-server.service 
clear
### Et on installe les paquets
echo "Veuillez taper ceci pour télécharger les paquets 'apt install italc-master italc-client libitalc -y'"
ltsp-chroot -r -m -a i386
systemctl start nfs-kernel-server.service 
ltsp-update-image
rm -f config.txt script_ajout_utilisateur.sh liste_utilisateur.txt script_test_liste_utilisateur.pl ltsp.sh script_user.sh
