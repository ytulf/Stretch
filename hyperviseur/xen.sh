echo "" > /etc/apt/sources.list
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) main contrib non-free"
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)-updates main contrib non-free"
add-apt-repository "deb [arch=amd64] https://security.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)/updates main contrib non-free"

sed -i "s/#\ //" /etc/apt/sources.list

### Mise à jour du système
apt update -y && apt upgrade -y


apt install lvm2 -y
/etc/init.d/lvm start

vgcreate VolumeLogique1 /dev/sda1

### installation paquet xen
apt install xen-linux-system xen-tools -y

### booter sur Xen en changeant la priorité de Xen dans Grub
dpkg-divert --divert /etc/grub.d/08_linux_xen --rename /etc/grud.b/20_linux_xen
### Mise à jour du grub
update-grub

xen-create-image --hostname Machinexen1 --ip 192.168.1.249 --vcpus 2 --dist Stretch
