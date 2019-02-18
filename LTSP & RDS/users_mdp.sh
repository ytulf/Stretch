#!/bin/sh

fichier= $1   #Récupération du fichier passer en paramètre
listeUser=$(cat $fichier)     #Récupération de la liste des utilisateur à créer

for nom in $listeUser       #Pour tous les noms inscrit dans la liste
do 
      pass=$(pwgen|cut -f1)   #on créer un mot de passe aléatoire
      echo $nom":"$pass  >> listeuserMdp.txt        # on sauve le nom et le passe dans un fichier
      passcrypt=$(mkpasswd $pass)  #on crypte le mot de passe
      useradd -p $passcrypt -d /home/$nom $nom -m   # on créé l'utilisateur

      # supprimer user (a décommenter si besoin)
      # userdel -r $nom
done
exit
exit 0
