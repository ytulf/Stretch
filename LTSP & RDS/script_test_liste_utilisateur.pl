use strict;
use warnings;
### On demande a l'utilisateur si il a créer le fichier
print "\nAvez-vous écrit votre liste d'utilisateur de la forme USER MDP GROUP ? \n";
print "Oui [Taper 1]\n";
print "Non [Taper 2]\n";
my $choix = <>;
chomp($choix);
### On ouvre le fichier destination : liste_utilisateur.txt
my $filenames_destination = "liste_utilisateur.txt";
open (my $fh_dest, '>> ', $filenames_destination) or die "Erreur : Le fichier '$filenames_destination' n'existe pas \n";
### Si l'utilisateur n'a pas créer la liste d'utilisateur : 
if ($choix != "1"){
### Initialisation de la variable qui va servir de compteur
my $compteur = 0;
### Nombre d'utilisateur à créer
print "Combien d'utilisateur voulez-vous créer ? ";
my $nombre = <>;
chomp($nombre);
while ($compteur != $nombre){
        ### Nom de l'utilisateur
        print "Nom de l'utilisateur, $compteur : ";
        my $nom = <>;
        chomp ($nom);
        ### Mot de passe de l'utilisateur
        print "Mot de passe de $nom : ";
        my $mdp = <>;
        chomp($mdp);
        ### Groupe d'appartenance de l'utilisateur
        print "Groupe d'appartenance de $nom : ";
        my $groupe = <>;
        chomp($groupe);
        ### Ouverture du fichier pour ajouter les utilisateurs
        print $fh_dest "$nom $mdp $groupe\n";
        $compteur++;
        }
}
### On ferme le fichier
close $fh_dest;
