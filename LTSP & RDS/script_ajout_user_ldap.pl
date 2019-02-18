`rm user.txt`;

`wget https://raw.githubusercontent.com/keijix/stretch/master/user.txt`;
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
homeDirectory: /home/$cn" >> user.ldif`;
}
close FILE1;
