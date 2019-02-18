
### Installation de eZ
DIALOG=${DIALOG=dialog}
fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
trap "rm -f $fichtemp" 0 1 2 5 15

$DIALOG --backtitle "Que voulez-vous faire ?" \
	--title "Choix" --clear \
        --radiolist "Vous pouvez choisir parmi la liste ci-dessous :\n
	Pour sélectionner faites défiler puis 'espace' pour choisir " 20 61 5 \
	"1" "Accès via interface graphique" ON\
	  "2" "Accès via terminal" off\
           "3" "Rien de tout ça" off 2> $fichtemp
valret=$?
choix=`cat $fichtemp`
case $choix in 
        "1")
clear
### Installation des dépôts 
apt install apache2 php7.0 unzip -y

cd /var/www/html
wget https://www.ezservermonitor.com/esm-web/downloads/version/2.5
unzip /var/www/html/2.5

mv /var/www/html/eZServerMonitor-2.5 /var/www/html/ez
chown www-data:www-data -Rf /var/www/html/ez/

ip addr sh | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > ip.txt
read -p "
Aller maintenant sur http://`cat ip.txt`/ez, une fois fait appuyer sur n'importe quel touche pour retourner sur l'hôte" pause
rm -rf ip.txt
;;
"2")
clear
apt install -y unzip
wget https://www.ezservermonitor.com/esm-sh/downloads/version/2.2
unzip  2.2
chmod +x eZServerMonitor.sh
./eZServerMonitor.sh -a
read -p "
Pour relancer le script quand vous voulez il suffit de faire ./eZserverMonitor.sh -a
appuyez sur n'importe quel touche pour continuer" pause
;;
*)
clear
echo "
Vous n'avez rien selectionné donc redémarrer le script "
;;
esac
