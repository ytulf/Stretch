### Mise à jour des sources listes
echo "" > /etc/apt/sources.list
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) main contrib non-free"
add-apt-repository "deb [arch=amd64] https://deb.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)-updates main contrib non-free"
add-apt-repository "deb [arch=amd64] https://security.debian.org/$(. /etc/os-release; echo "$ID") $(lsb_release -cs)/updates main contrib non-free"

sed -i "s/#\ //" /etc/apt/sources.list

### Mise à jour du système
apt update -y && apt upgrade -y

apt install apache2 -y
apt install openssl -y
a2enmod ssl
systemctl restart apache2

mkdir /tmp/ssl_conf
cd /tmp/ssl_conf
openssl req -config /etc/ssl/openssl.cnf -new -out csr_ssl.csr

openssl rsa -in privkey.pem -out cle_ssl.key
openssl x509 -in csr_ssl.csr -out crt_ssl.crt -req -signkey cle_ssl.key -days 3650
openssl x509 -in crt_ssl.crt -out crt_ssl.der.crt -outform DER

cd /tmp/ssl_conf
mkdir /etc/apache2/ssl.crt/ && mkdir /etc/apache2/ssl.key/
cp crt_ssl.crt /etc/apache2/ssl.crt/
cp cle_ssl.key /etc/apache2/ssl.key/


### Activation des modules nécessaires au proxy
a2enmod proxy proxy_http

/etc/init.d/apache2 restart
echo "
<VirtualHost *:80>

        ServerName srv-web-http

        # Redirect Requests to SSL
        Redirect permanent / https://192.168.1.254

        ErrorLog ${APACHE_LOG_DIR}/example.com.error.log
        CustomLog ${APACHE_LOG_DIR}/example.com.access.log combined
        
        ProxyPass / http://192.168.1.254:443/
        ProxyPassReverse / http://192.168.1.254:443/
        ProxyPreserveHost On

</VirtualHost>
<VirtualHost *:443>
       DocumentRoot /var/www/site_ssl
       ServerName srv-web-https
    <Directory /var/www/site_ssl>
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from all
    </Directory>
       SSLEngine on
       SSLCertificateFile /etc/apache2/ssl.crt/crt_ssl.crt
      SSLCertificateKeyFile /etc/apache2/ssl.key/cle_ssl.key
</VirtualHost> " > /etc/apache2/sites-available/000-default.conf
/etc/init.d/apache2 reload

