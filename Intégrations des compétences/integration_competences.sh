
### Configuration de LDAP
apt install ldap‐utils -y && apt install slapd -y

# Reconfiguration de SLAPD
dpkg-reconfigure slapd
/etc/init.d/slapd restart

# création de l'OU
echo "dn: ou=people,dc=lprt,dc=univ-angers,dc=fr
ou: people
objectClass: top
objectClass: organizationalUnit" > /etc/ldap/ou.ldif
# Ajout de l'ou à la base de donnée
ldapadd ‐x ‐D "cn=admin,dc=lprt,dc=univ-angers,dc=fr" ‐w root ‐f /etc/ldap/ou.ldif

echo "tsavio; thomas SAVIO; thomas; SAVIO; 5001
maxguer; maxime GUERIN; maxime; GUERIN; 5002
tflauss; tanguy FLAUSS; tanguy; FLAUSS; 5003
cgalle; clement GALLE; clement; GALLE; 5004
vguillaud; valentin GUILLAUD; valentin; GUILLAUD; 5005
mbricard; matthias BRICARD; matthias; BRICARD; 5006
dleverrier; dylan LEVERRIER; dylan; LEVERRIER; 5007
ypaggin; yann PAGGIN; yann; PAGGIN; 5008
jbattut; jerome BATTUT; jerome; BATTUT; 5009
tloubry; thomas LOUBRY; thomas; LOUBRY; 5010
aletort; alexis LETORT; alexis; LETORT; 5011
mniepceron; maxime NIEPCERON; maxime; NIEPERCON; 5012
" > user.txt

# Création des utilisateurs
echo '
open FILE1, "< user.txt";
while($item = <FILE1>){
$item =~ /(\w+);\s(\w+\s\w+);\s(\w+);\s(\w+);\s(\d+)/;
$cn = $1;
$user = $2; 
$surname = $3; 
$name = $4; 
$gidnumber = $5;

`echo "dn: cn=$cn,ou=people,dc=lprt,dc=univ-angers,dc=fr
cn: $cn
gidNumber: $gidnumber
objectClass: posixGroup
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount

dn: uid=$cn,ou=people,dc=lprt,dc=univ-angers,dc=fr
uid: $cn
uidNumber: $gidnumber
gidNumber: $gidnumber
cn: $user
sn: $name
userPassword: root
objectClass: posixAccount
objectClass: organizationalPerson
loginShell: /bin/bash
homeDirectory: /home/$cn" >> /etc/ldap/user.ldif`;
}
close FILE1; ' > script_ajout_user.pl
perl script_ajout_user.pl

# On entre les informations dans ldap
ldapadd ‐x ‐D "cn=admin,dc=lprt,dc=univ-angers,dc=fr" ‐w root ‐f /etc/ldap/user.ldif


### Configuration du RAID
read -p "Combien de fichiers voulez-vous ? " nbr_fich
# Créations des fichiers et répertoires
mkdir -p /tmp/raid
for i in `seq 1 $nbr_fich`;
do
        dd if=/dev/zero of=/tmp/raid/part$i bs=1024 count=40000
        losetup /dev/loop$i /tmp/raid/part$i
        mkfs.ext4 /dev/loop$i
        fdisk /dev/loop$i
done
clear
# Création du raid
apt install mdadm -y
clear
read -p "Quel raid souhaitez-vous créer ? " ch_raid
read -p "Nous allons faire le raid avec deux loopback " stop
mdadm --create /dev/md0 --level=$ch_raid --assume-clean --raid-devices=2 /dev/loop1 /dev/loop2
read -p "Souhaitez-vous faire un autre raid ? [Y/N]" yes_no
if [ $yes_no = "Y" ]||[ $yes_no = "y" ]
then
read -p "Quel raid souhaitez-vous créer ? " choix_raid
mdadm --create /dev/md1 --level=$choix_raid --assume-clean --raid-devices=2 /dev/loop3 /dev/loop4
read -p "Souhaitez-vous faire un autre raid ? [Y/N]" yes_no
fi
# formatage des raids
mkfs.ext4 /dev/md0
mkfs.ext4 /dev/md1

### On rajoute les lignes dans fstab
echo "/dev/md0 	/media/disqueraid0	ext4	defaults 	0	1 " >> /etc/fstab
echo "/dev/md1 	/media/disqueraid1	ext4	defaults 	0	1 " >> /etc/fstab

### Créer les médias
mkdir -p /media/disqueraid0
mkdir -p /media/disqueraid1

### iSCSI

mkdir -p /var/lib/iscsi_disks 
dd if=/dev/zero of=/var/lib/iscsi_disks/disk01 bs=1024 count=40000
dd if=/dev/zero of=/var/lib/iscsi_disks/disk02 bs=1024 count=40000
apt -y install tgt dkms

echo "# create new
# naming rule : [ iqn.yaer-month.domain:any name ]
<target iqn.2017-11.fr.lprt:target01>
    # provided devicce as a iSCSI target
    backing-store /var/lib/iscsi_disks/disk01
    # iSCSI Initiator's IP address you allow to connect
</target>
" >> /etc/tgt/conf.d/target01.conf
echo "# create new
<target iqn.2017-11.fr.lprt:target02>
    backing-store /var/lib/iscsi_disks/disk02
</target>
" >> /etc/tgt/conf.d/target02.conf
systemctl restart tgt
tgtadm --mode target --op show 

### Iptables
#-F --flush : Permet de vider toutes les règles d'une chaîne. iptables -F INPUT
#-L --list : Permet d'afficher les règles. iptables -L 
#-N --new-chain : Permet de créer une nouvelle chaîne. iptables -N LOG_DROP
#-X --delete-chain : Permet d'effacer une chaîne. iptables -X LOG_DROP
## Déclaration des alias
/sbin/ifconfig enp0s3:0 192.168.6.1
/sbin/ifconfig enp0s3:1 192.168.60.1
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/route add -host 192.168.6.1 dev enp0s3:0
/sbin/route add -host 192.168.60.1 dev enp0s3:1
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -o enp0s3:0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o enp0s3:1 -j MASQUERADE
# --state : Permet de spécifier l'état du paquet à matcher parmi les états suivants : 
#ESTABLISHED : paquet associé à une connexion déjà établie 
#NEW : paquet demandant une nouvelle connexion 
#INVALID : paquet associé à une connexion inconnue 
#RELATED : Nouvelle connexion mais liée, idéal pour les connexions FTP 

## On passe tout en DROP et on accepte ce qu'on veut après 
iptables -A INPUT -i enp0s3 -j DROP
iptables -A OUTPUT -o enp0s3 -j DROP
# On accepte les requêtes ICMP provenant de enp0s3:0
iptables -A INPUT -i enp0s3 --protocol icmp -j ACCEPT
iptables -A OUTPUT -o enp0s3 --protocol icmp -j ACCEPT
# On accepte les connexions sur client vers le serveur web
iptables -A INPUT -s 192.168.6.2 --protocol tcp --source-port 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 192.168.60.2 --protocol tcp --destination-port 80 -m state --state NEW,ESTABLISHED -j ACCEPT
