### Créations des fichiers et répertoires
mkdir -p /tmp/raid
dd if=/dev/zero of=/tmp/raid/part0 bs=1024 count=40000
dd if=/dev/zero of=/tmp/raid/part1 bs=1024 count=40000
dd if=/dev/zero of=/tmp/raid/part2 bs=1024 count=40000
dd if=/dev/zero of=/tmp/raid/part3 bs=1024 count=40000
dd if=/dev/zero of=/tmp/raid/part4 bs=1024 count=40000
dd if=/dev/zero of=/tmp/raid/part5 bs=1024 count=10000
dd if=/dev/zero of=/tmp/raid/part6 bs=1024 count=10000
dd if=/dev/zero of=/tmp/raid/part7 bs=1024 count=10000

### Transformer les fichiers en blocs
losetup /dev/loop0 /tmp/raid/part0
losetup /dev/loop1 /tmp/raid/part1
losetup /dev/loop2 /tmp/raid/part2
losetup /dev/loop3 /tmp/raid/part3
losetup /dev/loop4 /tmp/raid/part4
losetup /dev/loop5 /tmp/raid/part5
losetup /dev/loop6 /tmp/raid/part6
losetup /dev/loop7 /tmp/raid/part7

### Création du système de fichier
mke2fs /dev/loop0
mke2fs /dev/loop1
mke2fs /dev/loop2
mke2fs /dev/loop3
mke2fs /dev/loop4
mke2fs /dev/loop5
mke2fs /dev/loop6
mke2fs /dev/loop7

### Mettre partition en FD (d'abord n puis (3x entrée) puis t puis FD)
fdisk /dev/loop0
fdisk /dev/loop1
fdisk /dev/loop2
fdisk /dev/loop3
fdisk /dev/loop4
fdisk /dev/loop5
fdisk /dev/loop6
fdisk /dev/loop7

read "Taper la commande : watch -n1 'cat /proc/mdstat' " -p

### installation de mdadm et création des RAID0 et 1
apt install mdadm -y
mdadm --create /dev/md0 --level=0 --assume-clean --raid-devices=2 /dev/loop0 /dev/loop1
mdadm --create /dev/md1 --level=1 --assume-clean --raid-devices=2 /dev/loop2 /dev/loop3

### On deamonise le RAID pour qu'il l'utilise à chaque redémarrage 
mdadm --daemonise /dev/md0
mdadm --daemonise /dev/md1

### On regarde les détails
mdadm --detail /dev/md0
mdadm --detail /dev/md1

### Formatage des disques en ext4
mkfs.ext4 /dev/md0
mkfs.ext4 /dev/md1

### On rajoute les lignes dans fstab
echo "/dev/md0 	/media/disqueraid0	ext4	defaults 	0	1 " >> /etc/fstab
echo "/dev/md1 	/media/disqueraid1	ext4	defaults 	0	1 " >> /etc/fstab

### Créer les médias
mkdir -p /media/disqueraid0
mkdir -p /media/disqueraid1

read "Pause regarder la fenêtre watch... " -p
### Tolérance de pannes
mdadm /dev/md1 --fail /dev/loop3
mdadm /dev/md1 --remove /dev/loop3
mdadm /dev/md1 --add /dev/loop4 

### Install LVM
apt-get install lvm2
vgcreate vmg /dev/loop5
vgcreate vmg /dev/loop6
vgcreate vmg /dev/loop7

lvcreate -L 100 -n debian_lvcreate vmvg
