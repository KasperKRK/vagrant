#!/usr/bin/env bash

sudo apt-get update 2> /dev/null

sudo apt-get install -y make 2> /dev/null

sudo apt-get install -y vim 2> /dev/null

sudo apt-get install -y apache2 2> /dev/null
sudo apt-get install -y openssl 2> /dev/null
sudo a2enmod rewrite 2> /dev/null

APACHEUSR=`grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars`
APACHEGRP=`grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars`
if [ APACHEUSR ]; then
    sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi
if [ APACHEGRP ]; then
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
fi
sudo chown -R vagrant:www-data /var/lock/apache2

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password digitalprint'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password digitalprint'
sudo apt-get install -y mysql-server 2> /dev/null
sudo apt-get install -y mysql-client 2> /dev/null

if [ ! -f /var/log/dbinstalled ];
then
    echo "CREATE USER 'digitalprint'@'localhost' IDENTIFIED BY 'USERPASSWORD'" | mysql -uroot -pROOTPASSWORD
    echo "CREATE DATABASE internal" | mysql -uroot -pROOTPASSWORD
    echo "GRANT ALL ON internal.* TO 'digitalprint'@'localhost'" | mysql -uroot -pROOTPASSWORD
    echo "flush privileges" | mysql -uroot -pROOTPASSWORD
    touch /var/log/dbinstalled
    if [ -f /vagrant/data/initial.sql ];
    then
        mysql -uroot -pROOTPASSWORD internal < /vagrant/data/initial.sql
    fi
fi

sudo apt-get install -y memcached libmemcached-tools 2> /dev/null

sudo apt-get install -y php5 php-pear php5-dev php5-gd php5-curl php5-mcrypt 2> /dev/null

yes | sudo pecl install memcache 2> /dev/null

sudo touch /etc/php5/conf.d/memcache.ini
sudo echo "extension=memcache.so" >> /etc/php5/conf.d/memcache.ini
sudo echo "memcache.hash_strategy=\"consistent\"" >> /etc/php5/conf.d/memcache.ini

# if /var/www is not a symlink then create the symlink and set up apache
if [ ! -h /var/www ];
then
    rm -rf /var/www
    ln -fs /vagrant /var/www
    sudo a2enmod rewrite 2> /dev/null
    sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
    sudo service apache2 restart 2> /dev/null
fi

# restart apache
sudo service apache2 reload 2> /dev/null

# copy addwebsite command
# cp /vagrant/addwebsite /usr/local/bin/addwebsite 2> /dev/null
# chmod +x /usr/local/bin/addwebsite 2> /dev/null
# cp /vagrant/skeleton /etc/apache2/sites-available/skeleton 2> /dev/null

sudo apt-get install -y git 2> /dev/null

sudo apt-get install -y subversion 2> /dev/null

# install phpmyadmin
# mkdir /vagrant/phpmyadmin/ 2> /dev/null
# wget -O /vagrant/phpmyadmin/index.html http://www.phpmyadmin.net/
# awk 'BEGIN{ RS="<a *href *= *\""} NR>2 {sub(/".*/,"");print; }' /vagrant/phpmyadmin/index.html >> /vagrant/phpmyadmin/url-list.txt
# grep "http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/" /vagrant/phpmyadmin/url-list.txt > /vagrant/phpmyadmin/phpmyadmin.url
# sed -i 's/.zip/.tar.bz2/' /vagrant/phpmyadmin/phpmyadmin.url
# wget -O /vagrant/phpmyadmin/phpMyAdmin.tar.bz2 `cat /vagrant/phpmyadmin/phpmyadmin.url`
# mkdir /vagrant/myadm.localhost
# tar jxvf /vagrant/phpmyadmin/phpMyAdmin.tar.bz2 -C /vagrant/myadm.localhost --strip 1
# rm -rf /vagrant/phpmyadmin 2> /dev/null

# configure phpmyadmin
# mv /vagrant/myadm.localhost/config.sample.inc.php /vagrant/myadm.localhost/config.inc.php
# sed -i 's/a8b7c6d/keyBoardCas123/' /vagrant/myadm.localhost/config.inc.php
# echo "CREATE DATABASE pma" | mysql -uroot -pROOTPASSWORD
# echo "CREATE USER 'pma'@'localhost' IDENTIFIED BY 'PMAUSERPASSWD'" | mysql -uroot -pROOTPASSWORD
# echo "GRANT ALL ON pma.* TO 'pma'@'localhost'" | mysql -uroot -pROOTPASSWORD
# echo "GRANT ALL ON phpmyadmin.* TO 'pma'@'localhost'" | mysql -uroot -pROOTPASSWORD
# echo "flush privileges" | mysql -uroot -pROOTPASSWORD
# mysql -D pma -u pma -pPMAUSERPASSWD < /vagrant/myadm.localhost/examples/create_tables.sql
# cat /vagrant/phpmyadmin.conf > /vagrant/myadm.localhost/config.inc.php

# set up digitalprint.loc
# if [ ! -d /vagrant/digitalprint.loc ];
# then
#     git clone ssh://git@github.com:digitalprintpro/vprojekt.git /vagrant/digitalprint.loc 2> /dev/null
#     cp /vagrant/skeleton /etc/apache2/sites-available/digitalprint.loc 2> /dev/null
#     find /etc/apache2/sites-available/digitalprint.loc -type f -exec sed -i "s/SKELETON/digitalprint.loc/" {} \;
# fi
# if [ ! -d /var/lib/mysql/digitalprintloc ];
# then
#     echo "CREATE USER 'digitalprintloc'@'localhost' IDENTIFIED BY 'digitalprintloc'" | mysql -uroot -pROOTPASSWORD
#     echo "CREATE DATABASE digitalprintloc" | mysql -uroot -pROOTPASSWORD
#     echo "GRANT ALL ON digitalprintloc.* TO 'digitalprintloc'@'localhost'" | mysql -uroot -pROOTPASSWORD
#     echo "flush privileges" | mysql -uroot -pROOTPASSWORD
#     if [ -f /vagrant/digitalprintloc.sql ];
#     then
#         mysql -uroot -pROOTPASSWORD digitalprintloc < /vagrant/digitalprintloc.sql 2> /dev/null
#     fi
# fi