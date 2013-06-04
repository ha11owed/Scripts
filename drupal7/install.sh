#=== misc stuff ===
dpkg-reconfigure locales
apt-get update
apt-get install nano
# chech that english is selected as a locale

#=== CERTIFICATES ===
mkdir certs
cd certs
# create a CA key with a pass. will allow the creation of certs.
openssl genrsa -des3 -out ca.key 4096
# create a CA cert with complete info. (name adress...). Common Name must be: www.alghe.ro CA
openssl req -new -x509 -days 365 -key ca.key -out ca.crt

# create a server key
openssl genrsa -des3 -out server.key 4096
# create a server cert.  Common Name must be: www.alghe.ro
openssl req -new -key server.key -out server.csr
# sign server cert
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
# create a server key without a password (to be used by web server)
openssl rsa -in server.key -out server.key.insecure
mv server.key server.key.secure
mv server.key.insecure server.key

# Results:
#ca.crt: The Certificate Authority's own certificate.
#ca.key: The key which the CA uses to sign server signing requests. 
#server.crt: The self-signed server certificate.
#server.csr: Server certificate signing request.
#server.key: The private server key, does not require a password when starting Apache.
#server.key.secure: The private server key, it does require a password when starting Apache. 




cd ..

#=== sources.list ===
## PHP5-FPM
# deb http://packages.dotdeb.org stable all
# deb-src http://packages.dotdeb.org stable all
## Nginx
# deb http://nginx.org/packages/debian/ squeeze nginx
# deb-src http://nginx.org/packages/debian/ squeeze nginx

## key for PHP FPM
wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg
rm dotdeb.gpg
## key for Nginx
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
rm nginx_signing.key
apt-get update

#=== PHP ===
apt-get install php5
apt-get install php5-pgsql
apt-get install php5-gd
apt-get install php5-cgi
apt-get install php5-cli
# PHP optimization
apt-get install php5-apc
apt-get install php5-memcache
cp /usr/local/src/php-5.3/php.ini-recommended /usr/local/lib/php.ini
# PHP FPM
apt-get install php5-fpm

#=== nginx ===
apt-get install nginx-extras
# upload .conf in /etc/nginx/conf.d

#=== postgresql ===
apt-get install postgresql
apt-get install postgresql-client
# login as postgres user to create a db
su postgres
# init a db at the specified location
CREATE USER ecommerceuser WITH PASSWORD 'todo:set a real password';
CREATE DATABASE ecommerce;
GRANT ALL PRIVILEGES ON DATABASE ecommerce to ecommerceuser;
\q
# logout from postgres, back to root
exit

#=== dovecot ===
mkdir -p /etc/ssl/dovecot
cd /etc/ssl/dovecot
openssl req -new -x509 -nodes -out cert.pem -keyout key.pem -days 365
chmod 640 /etc/ssl/dovecot/*

#=== apache and php ===
apt-get install apache2
apt-get install libapache2-mod-php5
#a2enmod rewrite
#a2enmod ssl
/etc/init.d/apache2 restart

#=== postfix ===


#=== download and install drupal commerce ===
cd /var/www
wget -O commerce.zip http://ftp.drupal.org/files/projects/commerce_kickstart-7.x-2.0-rc1-core.zip
unzip commerce.zip
mv commerce_kickstart-7.x-2.0-rc1 drupalcommerce
cp ./drupalcommerce/sites/default/default.settings.php ./drupalcommerce/sites/default/settings.php
chmod -R a+rwx ./drupalcommerce

#=== config apache ===
cd /etc/apache2/sites-available/
cp default drupalcommerce
# edit drupalcommerce -> port 8081, add drupalcommerce to path
cd ..
ln -s /etc/apache2/sites-available/drupalcommerce /etc/apache2/sites-enabled/drupalcommerce
rm ./sites-enabled/000-default
#edit ports.conf Listen localhost:8081
/etc/init.d/apache2 restart









