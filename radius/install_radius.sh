echo "" > /etc/apt/sources.list
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) main contrib non-free"
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)-updates main contrib non-free"
add-apt-repository "deb [arch=amd64] https://security.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)/updates main contrib non-free"

sed -i "s/#\ //" /etc/apt/sources.list

### Mise à jour du système
apt update -y && apt upgrade -y

### Installation de freeradius
apt install freeradius freeradius-ldap freeradius-mysql freeradius-postgresql -y

cd /etc/freeradius/3.0/


read -p "Réseau souhaité [ex : 192.168.1.0/24] : " reseau
read -p "Mot de passe [ex : wifiPwd] : " mdp
read -p "Nom souhaité [ex : WifiAP] : " name
echo "
client $reseau {
        secret      = $mdp
        shortname   = $name
        nastype     = other
}" >> /etc/freeradius/3.0/clients.conf

/etc/init.d/freeradius restart

echo '
demolocal Auth-Type := Local, Password == "demolocal"
         Service-Type = Framed-User,
         Framed-Protocol = PPP,
         Framed-Compression = Van-Jacobson-TCP-IP,
         Framed-MTU = 1500
 
demolan  Auth-Type := Local, Password == "demolan"
         Service-Type = Framed-User,
         Framed-Protocol = PPP,
         Framed-Compression = Van-Jacobson-TCP-IP,
         Framed-MTU = 1500 ' > /etc/freeradius/3.0/users
         
cat /etc/freeradius/3.0/clients.conf | egrep -v -e '^[[:blank:]]*#|^$' > radiusd.conf

