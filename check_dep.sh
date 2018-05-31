#!/bin/bash
# différentes lignes des fichiers de configuration
#Vérifie si l'adresse IP du serveur est présente dans le fichier de configuration nrpe.cfg

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`



#PACKAGE TEST
dpkg -s nagios-nrpe-server | grep "Status: install ok installed" > /dev/null 2>&1
nagios=$?
if [ $nagios -eq 0 ]; then
        echo "${green}[SUCCESS] Nagios-nrpe-server is installed ${reset}"
		nrpe=1
else
        echo "${red}[ERROR] NRPE IS NOT INSTALLED ${reset}"
		nrpe=0
fi


#PACKAGE TEST
dpkg -s snmpd | grep "Status: install ok installed" > /dev/null 2>&1
snmpd=$?
if [ $snmpd -eq 0 ]; then
        echo "${green}[SUCCESS] snmpd is installed ${reset}"
		snmpd=1
else
        echo "${red}[ERROR] SNMPD IS NOT INSTALLED ${reset}"
		snmpd=0
fi


#IP TEST
grep -q '192.168.5.15' /etc/nagios/nrpe.cfg > /dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "${green}[SUCCESS] IP is found ${reset}"
		ip=1
elif [ $? -eq 2 ]; then
		echo "${red}[ERROR] FILE NOT FOUND ${reset}"
		ip=0
else
        echo "${red}[ERROR] IP NOT FOUND ${reset}"
		ip=0
fi


#PACKAGE TEST
grep -q 'command[check_debian_packages]=' /etc/nagios/nrpe.cfg > /dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "${green}[SUCCESS] Debian packages is found ${reset}"
		package1=1
elif [ $? -eq 2 ]; then
		echo "${red}[ERROR] FILE NOT FOUND ${reset}"
		package1=0
else
        echo "${red}[ERROR] DEBIAN PACKAGES IS NOT FOUND ${reset}"
		package1=0
fi


#SSL TEST
grep -q '#DAEMON_OPTS="--no-ssl"' /etc/default/nagios-nrpe-server > /dev/null 2>&1
if [ $? -eq 1 ]; then
        echo "${green}[SUCCESS] SSL is disabled ${reset}"
		nrpessl=1
elif [ $? -eq 2 ]; then
		echo "${red}[ERROR] FILE NOT FOUND ${reset}"
		nrpessl=0
else
        echo "${red}[ERROR] SSL IS ENABLED ${reset}"
		nrpessl=0
fi


#COMMUNITY TEST
grep -q 'vincsps' /etc/snmp/snmpd.conf > /dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "${green}[SUCCESS]SNMP COMMUNITY FOUND ${reset}"
		community=1
elif [ $? -eq 2 ]; then
		echo "${red}[ERROR] FILE NOT FOUND ${reset}"
		community=0
else
        echo "${red}[ERROR]SNMP COMMUNITY NOT FOUND ${reset}"
		community=0
fi

echo "${yellow}[INFO]PUSHING CONFIGURATION ${reset}"

echo "$nrpe;$snmpd;$ip;$package1;$community" >> /root/configuration.csv
