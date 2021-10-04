#dit is een comment  en een wijziging 







#!/bin/bash
#functies van het script

#ctrl f voor het zoeken naar de onderdelen in het script

#Apt update voordat script begint 	-- #update
#Een while loop 			-- #restart script start -#restart script end
#verwelkom user 			-- #inleiding
#hostname set 				-- #set de hostname
#Keuze menu voor webservers 		-- #webserver keuze
#Keuze menu voor database 	 	-- #module keuze
#Instalatie van php en de modules	-- #php instalatie
#Nextcloud zip download 		-- #install nextcloud
#Rechten voor de mappen en files	-- #permisions nexcloud --#php permisions
#Config voor mariadb en mysql 		-- #config database maria/mysql
#Config voor apache 			-- #config apache
#Config voor php 			-- #config php
#Config voor nextcloud 			-- #config nextcloud
#Keuze menu voor certificate en config	-- #install openssl/letsencrypt
#Install fail2ban en config 		-- #insall fail2ban -#config fail2ban
#Config iptabels 			-- #firewall config iptabels


#update
clear
apt update
apt-get install sudo
apt dist-upgrade

#restart script start
opnieuwstart=y
while [ $opnieuwstart == y ]
do
clear

#inleiding
echo "Welkom "$USER" bij het installatie script voor de nextcould omgeving."
echo ""

#set de hostname(al gezet in de start van instalatie)
#echo -n "welke hostname wil je? "; read hostname
#sed 's/localhost/$hostname/g' /etc/hostname
#sed '/localhost/a \127.0.1.1	localhost' /etc/hosts


#webserver keuze
echo "Er is keuze uit 3 webservers Apache, Nginx, Lighttpd."
echo -n "welke webserver wil je? (Apache, Nginx, Lighttpd): "; read webservers
echo ""

	function Install-web
	{
	echo "Er is gekozen voor "$webservers"."
	echo "Instalatie "$webservers" wordt gestart."
	}

	function message-web
	{
	echo ""$webservers" is al geinstaleerd."
	}

if [ $webservers == "apache" ]
	then
		Install-web
		if ( systemctl -q is-active apache2 == "inactive" )
			then
				message-web
			else
				apt install apache2
				systemctl stop apache2.service
				systemctl start apache2.service
				systemctl enable apache2.service
		fi
systemctl start apache2
elif [ $webservers == "nginx" ]
	then
		Install-web
		if ( systemctl -q is-active nginx == "inactive" )
			then 
				message-web
			else
				apt install nginx
		fi
systemctl start nginx
elif [ $webservers == "lighttpd" ]
	then
		Install-web
		if ( systemctl -q is-active lighttpd == "inactive")
			then
				message-web
			else
				apt install lighthttpd
		fi
systemctl start lighttpd
	#else
		#echo ""$webservers" is geen goede invoer."
		#echo "De instalatie is gestopt, probeer de volgende keer Apache, Nginx, Lighttpd."
fi


#module keuze
echo ""
echo "Nu moet er een database gekozen worden."
echo -n "Welke database wil je geinstaleerd hebben Mysql of MariaDB: "; read database
echo ""

	function Install-data
	{
	echo "Er is gekozen voor "$database"."
	echo "Instalatie "$database" wordt gestart."
	}

	function message-data
	{
	echo ""$database" is al geinstaleerd."
	}


if [ $database == "mysql" ]
	then
		Install-data
		systemctl start mysql
		if ( systemctl -q is-active mysql == "inactive" )
			then
				message-data
			else
				apt istall gnupg
				wget https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
				dpkg -i mysql-apt-config_0.8.15-1_all.deb
				apt install mysql-community-server
		fi

elif [ $database == "mariadb" ]
	then
		Install-data
		systemctl start mariadb
		if ( systemctl -q is-active mariadb == "inactive" )
			then
				message-data
			else
				echo "test"
				apt install mariadb-server mariadb-client
				systemctl stop mariadb.service
				systemctl start mariadb.service
				systemctl enable mariadb.service
				echo ""
		fi
else
	echo ""$database" is geen goede invoer."
	echo "De instalatie is gestopt, probeer de volgende keer mysql of mariadb"
fi

echo "Enter bij pasword, set new password, remove annonymous users ,disalawe login remote, delete test database, reload "
mysql_secure_installation




#php instalatie
echo ""
read -p "Druk op een toets om PHP te instaleren"
if [ -d "/etc/php/7.3" ]
	then
		echo "php is al geinstaleerd"
	else
		apt-get install software-properties-common
		add-apt-repository ppa:ondrej/php
		apt update

		#all modules
		apt install php libapache2-mod-php php-common php-gmp
		echo "1/3 geinstaleerd"
		apt install php-curl phpintl php-mbstring php-xmlrpc
		echo "2/3 geinstaleerd"
		apt install php-mysql php-gd php-xml php-cli php-zip
		echo "3/3 geinstaleerd"
		apt-get install php7.3-mbstring
		apt-get install curl
		apt-get install php7.3-curl
fi

#phpenmod bcmath gmp imagich intl





#install nextcloud
echo ""
echo "Nextcloud.zip wordt gedownload, uitgepakt en wordt verplaast naar /var/www"
echo ""

#check download zip
if [ -f "nextcloud-21.0.2.zip" ];
	then
		echo "nextcloud is al gedownload"
	else
		wget https://download.nextcloud.com/server/releases/nextcloud-21.0.2.zip
fi
#check unzip
if [ -f "/usr/bin/unzip" ]
        then
                echo "unzip is al geinstleerd"
        else
                apt install unzip
fi
unzip -qq nextcloud-21.0.2.zip
mv nextcloud/ /var/www/
rm -f nextcloud-21.0.2.zip

#permisions nexcloud
chown -R www-data:www-data /var/www/nextcloud
a2dissite 000-default.conf
systemctl reload apache2

#vraag config
echo -n "config van de mariadb/mysql, apache, php en nextcloud zelf doen?: (y/n)"; read config

#config database maria/mysql
echo "config mariadb/mysql"
if [ $config == "y" ]
	then
		echo "typ zelf"
		echo "sudo mariadb"
		echo "CREATE DATABASE nextcloud;"
		echo "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud-user'@'localhost' IDENTIFIED BY 'password';"
		echo "FLUSH PRIVILEGES;"
		echo ""
elif [ $config == "n" ]
	then
		mysql -e "CREATE DATABASE nextcloud"
		mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud-user'@'localhost' IDENTIFIED BY 'password'"
		mysql -e "FLUSH PRIVILEGES;"
fi


#config apache
echo "config apache"

if [ $config == "y" ]
	then 
		echo "edit file/make"
		echo "nano /etc/apache2/sites-available/nextcloud.conf"
		echo "deze config moet het worden"
		echo ""
		echo "<VirtualHost *:80>"
		echo '   DocumentRoot "/var/www/nextcloud"'
		echo "   ServerName nextcloud"
		echo ""
		echo '   <Directory "/var/www/nextcloud/">'
		echo "      Options MultiViews FollowSymlinks"
		echo "      AllowOverride All"
		echo "      Order allow,deny"
		echo "      Allow from all"
		echo "   </Directory>"
		echo ""
		echo "   TransferLog /var/log/apache2/nextcloud_access.log"
		echo "   ErrorLog /var/log/apache2/nextcloud_error.log"
		echo ""
		echo "</VirtualHost>"

elif [ $config == "n" ]
	then
                rm -f /etc/apache2/sites-available/nextcloud.conf
		touch /etc/apache2/sites-available/nextcloud.conf
                echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/nextcloud.conf
                echo '   DocumentRoot "/var/www/nextcloud"' >> /etc/apache2/sites-available/nextcloud.conf
                echo "   ServerName nextcloud" >> /etc/apache2/sites-available/nextcloud.conf
                echo "" >> /etc/apache2/sites-available/nextcloud.conf
                echo '   <Directory "/var/www/nextcloud/">' >> /etc/apache2/sites-available/nextcloud.conf
                echo "      Options MultiViews FollowSymlinks" >> /etc/apache2/sites-available/nextcloud.conf
                echo "      AllowOverride All" >> /etc/apache2/sites-available/nextcloud.conf
                echo "      Order allow,deny" >> /etc/apache2/sites-available/nextcloud.conf
                echo "      Allow from all" >> /etc/apache2/sites-available/nextcloud.conf
                echo "   </Directory>" >> /etc/apache2/sites-available/nextcloud.conf
                echo "" >> /etc/apache2/sites-available/nextcloud.conf
                echo "   TransferLog /var/log/apache2/nextcloud_access.log" >> /etc/apache2/sites-available/nextcloud.conf
                echo "   ErrorLog /var/log/apache2/nextcloud_error.log" >> /etc/apache2/sites-available/nextcloud.conf
                echo "" >> /etc/apache2/sites-available/nextcloud.conf
                echo "</VirtualHost>" >> /etc/apache2/sites-available/nextcloud.conf

fi
a2ensite nextcloud.conf
#config php
echo "config php"

if [ $config == "y" ]
        then
                echo "edit file"
                echo "nano /etc/php/7.3/apache2/php.ini"
                echo "memory_limit = 512M"
                echo "upload_max_filesize = 200M"
                echo "max_execution_time = 360"
                echo "post_max_size = 200M"
                echo "date.timezone = America/Detroit"
                echo "opcache.enable=1"
                echo "opcache.interned_strings_buffer=8"
                echo "opcache.max_accelerated_files=10000"
                echo "opcache.memory_consumption=128"
                echo "opcache.save_comments=1"
                echo "opcache.revalidate_freq=1"

elif [ $config == "n" ]
        then
		sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/post_max_size = 8M/post_max_size = 200M/g' /etc/php/7.3/apache2/php.ini
                #sed 's/;date.timezone =/date.timezone = America/Detroit/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.enable=1/opcache.enable=1/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.3/apache2/php.ini
                sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g' /etc/php/7.3/apache2/php.ini            
fi
a2enmod dir env headers mime rewrite ssl
sudo a2ensite nextcloud.conf
systemctl restart apache2


#config nextcloud
echo "config nextcloud"

if [ $config == "y" ]
        then
                echo "edit file"
                echo "nano /var/www/nextcloud/config/config.php"
                echo "voeg deze regel toe"
                echo "'memcache.local' => '\OC\Memcache\APCu',"

elif [ $config == "n" ]
        then
                sed -i "s/);/  'memcache.local' => '\OC\Memcache\APCu',/g" /var/www/nextcloud/config/config.php
		sed -i -e '$a);' /var/www/nextcloud/config/config.php

fi

#php permisions
chmod 660 /var/www/nextcloud/config/config.php
chown root:www-data /var/www/nextcloud/config/config.php


#install openssl/letsencrypt - fail2ban - firewall config
#install openssl/letsencrypt
echo -n "certificate instalatie openssl of letsencrypt(dan is er wel een gerigistreed domain nodig)"; read cert

if [ $cert == "openssl" ]
        then
		apt install openssl
		mkdir /etc/apache2/ssl
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/nextcloud.key -out /etc/apache2/ssl/nextcloud.crt
		a2ensite nextcloud.conf
		a2enmod ssl
		sed -i 's/80/443/g' /etc/apache2/sites-enabled/nextcloud.conf
		sed -i '4 i SSLEngine on' /etc/apache2/sites-enabled/nextcloud.conf
		sed -i '5 i SSLCertificateFile      /etc/apache2/ssl/nextcloud.crt' /etc/apache2/sites-enabled/nextcloud.conf
		sed -i '6 i SSLCertificateKeyFile   /etc/apache2/ssl/nextcloud.key' /etc/apache2/sites-enabled/nextcloud.conf
		a2ensite default-ssl
		a2dissite default-ssl.conf
		systemctl reload apache2.service
 		

elif [ $cert == "letsencrypt" ]
        then
		sudo apt install certbot python3-certbot-apache                
		sudo certbot --apache --agree-tos --redirect --staple-ocsp --register-unsafely-without-email -d nextcloud.com
		sudo apache2ctl -t
		sudo systemctl reload apache2

		


elif [ $cert == "skip" ]
	then
		echo "skiped"

fi


#insall fail2ban
apt install fail2ban
if ( systemctl -q is-active fail2ban == "inactive" )
	then
		echo "fail2ban geinstaleerd"
	else
		apt install fail2ban
		systemctl stop fail2ban.service
		systemctl start fail2ban.service
		systemctl enable fail2ban.service

#config fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
#edit

		sed -i 's/#ignoreip = 127.0.0.1/ignoreip = 127.0.0.1/g' /etc/fail2ban/jail.local
		sed -i 's/bantime  = 10m/bantime  = 20m/g' /etc/fail2ban/jail.local
		sed -i 's/findtime  = 10m/findtime  = 20m/g' /etc/fail2ban/jail.local
		sed -i 's/maxretry = 5/maxretry = 10/g' /etc/fail2ban/jail.local
		sed -i '247 i maxretry = 3' /etc/fail2ban/jail.local
		sed -i '248 i enable = true' /etc/fail2ban/jail.local
		systemctl enable fail2ban
		systemctl start fail2ban
fi

#firewall config iptabels
# # de iptabels als ssh gebruikt wordt
iptable -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP


#ssh in
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#http/https in
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#restart script end
echo -n "Script opnieuw starten? (y/n)"; read opnieuwstart
done
#copyright rick van dijk nextcloud installer met valid certificate
