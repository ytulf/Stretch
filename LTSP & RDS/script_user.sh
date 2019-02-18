### On télécharge les paquets pour utiliser mkpasswd
apt install whois -y
### On télécharge le test pour savoir si les utilisateurs sont crée
wget https://raw.githubusercontent.com/Keijix/Stretch/master/script_test_liste_utilisateur.pl
### On l'exécute
perl script_test_liste_utilisateur.pl
# On écris le script
echo '
# On récupère la liste des utilisateurs
NEW_USERS="liste_utilisateur.txt"
# On lit le fichier
cat ${NEW_USERS} | \
# Et on ajoute le groupe, utilisateur, mdp 
while read USER PASSWORD GROUP
do
groupadd ${GROUP}
useradd ${USER} -p $(mkpasswd ${PASSWORD}) -m
echo ${USER} crée !
addgroup ${USER} ${GROUP}
echo ${USER} ajouté au groupe ${GROUP}!
done
' > script_ajout_utilisateur.sh
## On donne les droits aux utilisateurs pour exécuter le script et on l'exécute
chmod +x script_ajout_utilisateur.sh
./script_ajout_utilisateur.sh

echo "Script fini, vous pouvez désormais vous connectez"
