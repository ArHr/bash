#!/bin/bash

DOMAIN=$1

check_webservice () {
	WEBSRV=`lsof -i tcp:80 | head -2 | tail -1 | awk '{print$1}'`
	if [[ "$WEBSRV" == "" ]];
	then
       printf "No service detected running on port 80.\n"
	   printf "Service needs to be listening on port 80 for web sites to be served from this server.\n"
	else
        printf "\nPort 80 is used by $WEBSRV.\n"
		if [[ "$WEBSRV" == "nginx" ]]; 
		then
			printf "If sites are being served from Nginx, corresponding vhost needs to exists in sites-enabled.\n"
			printf "If site is not being served by nginx, check if Nginx is listening on the domain IP.\n"
			printf "Check if cPanel plugins like Nginx Admin or cPnginx exist in WHM and try to rebuild vhosts from WHM plugin page, if site has VirtualHosts in httpd.conf.\n"
		fi
	fi
}

get_vhost_ip () {
	VHOST_IP=`grep -m 1 -B 3 -A 5 "\s$DOMAIN\b" /usr/local/apache/conf/httpd.conf | grep VirtualHost | awk '{print$2}' | awk -F: '{print$1}'`
}

get_user () {
	CPUSER=`/scripts/whoowns $DOMAIN`
	if [[ "$CPUSER" == "" ]];
	then
       printf "\n/scrips/whoowns returns no domain.\n"
	else
        printf "\nDomain belongs to $CPUSER.\n"
	fi
}

check_vhost_instances () {
	printf "\n\t=== Domain has following VirtualHosts in /usr/local/apache/conf/httpd.conf. ===\n\n"
	grep -B 3 -A 5 "\s$DOMAIN\b" /usr/local/apache/conf/httpd.conf
	printf "\n\t===\t End VirtualHost section. \t===\n\n"
}

get_webroot () {
        printf "\nChecking for $DOMAIN in /usr/local/apache/conf/httpd.conf\n"
        WEBROOT=`grep -m 1 -A 3 "\s$DOMAIN\b" /usr/local/apache/conf/httpd.conf | grep DocumentRoot | awk '{print $2}'`
		if [[ "$WEBROOT" == "" ]];
		then
        	printf "Domain not found in /usr/local/apache/conf/httpd.conf.\n" 
		else
        	printf "WebRoot for $DOMAIN is: "
		fi
		echo $WEBROOT
}

change_cwd () {
		if [[ "$WEBROOT" == "" ]];
		then
        	printf "Domain was not found in /usr/local/apache/conf/httpd.conf, there is no directory to jump to.\n"
			printf "Check if the domain belongs to any existing user, and rebuild httpd.conf if needed.\n"
		else
        	printf "Changing working directory to $WEBROOT\n"
        	cd $WEBROOT
		fi
}

if [[ "$DOMAIN" == "" ]]; 
then 
	printf "No domain was provided, please provide the domain/subdomain you want to check.\n"
	return
else
	check_webservice
	check_vhost_instances
	get_user
	get_webroot
	change_cwd
fi