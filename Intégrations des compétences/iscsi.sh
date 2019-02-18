### Téléchargement de IET
wget https://downloads.sourceforge.net/project/iscsitarget/iscsitarget/1.4.20.2/iscsitarget-1.4.20.2.tar.gz
tar xzvf iscsitarget-1.4.20.2.tar.gz
apt install make -y
cd /iscsitarget-1.4.20.2/ 
make
make install

### Création du disque
mkdir -p /tmp/raid
dd if=/dev/zero of=/tmp/raid/part0 bs=1024 count=40000
losetup /dev/loop0 /tmp/raid/part0
mkfs.ext4 /dev/loop0
fdisk /dev/loop0
echo "/dev/loop0 	/media/disque	ext4	defaults 	0	1 " >> /etc/fstab
mkdir -p /media/disque

### Création des deux instances
echo " Target iqn.2017-03.lprt:rTS
  Lun 0 Path=/media/disque/,Type=blockio " >> /etc/iet/ietd.conf

echo " Target iqn.2017-03.lprt:rTS2
  Lun 1 Path=/media/disque/,Type=blockio " >> /etc/iet/ietd.conf
  
# nano /etc/default/iscsitarget

### Côté initiateur
apt install iscsi-initiator-utils -y
apt install open-iscsi -y

iscsiadm --mode iface --op=new --interface iscsi1
iscsiadm --mode iface --op=update --interface iscsi1 --name=iface.net_ifacename --value=enp0s3

iscsiadm -m discovery -I iscsi1 -t sendtargets -p localhost
iscsiadm -m node -T iqn.2017-03.tld.domaine:tgt1 --portal localhost --login
tail -f /var/log/dmesg

fdisk /dev/sda
# N / P / 1 / W
mkfs.ext4 /dev/sda1
mkdir /home/dossier
mount -t ext4 /dev/sda1 /home/dossier/
echo "/dev/sda1 /home/dossier ext4 defaults,_netdev,user_xattr,acl 0 2" >> /etc/fstab

apt install -y tgt
mkdir /var/lib/iscsi
dd if=/dev/zero of=/var/lib/iscsi/thomas bs=1M count=1K
tgtadm --lld iscsi --op new --mode target --tid 1 -T iqn.2017-07.fr.lprt:thomas
tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 1 -b /var/lib/iscsi/thomas
tgtadm --lld iscsi --op bind --mode target --tid 1 -I ALL

tgtadm --dump | sudo tee /etc/tgt/conf.d/thomas.conf

cat /proc/partitions

apt install -y open-iscsi

iscsiadm -m discovery -t st -p localhost[::1]:3260,1 iqn.2017-07.fr.lprt:thomas

iscsiadm -m node --targetname iqn.2017-07.fr.lprt:thomas -p localhost -l
