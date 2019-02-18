### Installation d'Open LDAP
apt install slapd ldap‐utils -y

### Reconfiguration de SLAPD
dpkg-reconfigure slapd

### Ajout de l'ou=people
# Création du fichier ldif
echo "dn: ou=Utilisateurs,dc=local,dc=iia-laval,dc=info
ou: Utilisateurs
objectClass: top
objectClass: organizationalUnit

dn: cn=Grp-MII,ou=Groupes,dc=local,dc=iia-laval,dc=info
cn: Grp-MII
gidNumber: 20000
objectClass: top
objectClass: posixGroup" > /etc/ldap/ou.ldif
# Ajout de l'ou à la base de donnée
ldapadd ‐x ‐D "cn=admin,dc=local,dc=iia-laval,dc=info" ‐f /etc/ldap/ou.ldif

### Ajout de l'uid=tsavio
# Création du fichier ldif
echo "dn: uid=user1,ou=Utilisateurs,dc=local,dc=iia-laval,dc=info
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
uid: user1
uidNumber: 20001
gidNumber: 20000
sn: Pamiseux
cn: Marc-Henri Pamiseux
homeDirectory: /home/users/user1
userPassword: not24get
loginShell: /bin/bash

dn: uid=user2,ou=Utilisateurs,dc=local,dc=iia-laval,dc=info
objectClass: top
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
uid: user2
uidNumber: 20002
gidNumber: 20000
givenName: Joshua
sn: Martinelle
cn: Joshua Martinelle
homeDirectory: /home/users/user2
userPassword:: e1NIQTUxMn1ORmJncFlPMS9XWXpGZG9KUjhLTERGM2NjT3FoRC9BTlozMjZUMlB
 GMjN1QXNmdm11RTA3c2ZTbkVHaXM5VVpscjlyaXE0NFZQTG1kQldOdFNVM2hLUT09
loginShell: /bin/bash" > /etc/ldap/user.ldif
# Ajout de l'uid à la base de donnée
ldapadd ‐x ‐D "cn=admin,dc=lprt,dc=univ-angers,dc=fr" ‐w root ‐f /etc/ldap/user.ldif

