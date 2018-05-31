#!/bin/bash

#Parameters
scriptfolder="/root/script"
dnsip=
dnsfolder="/var/cache/bind/master/"
ns=
regex=""
email=""

#Cleaning
rm -rf $scriptfolder/domains.txt
rm -rf $scriptfolder/autority-fault.txt
rm -rf $scriptfolder/autority-success.txt
rm -rf $scriptfolder/reloop-errors.txt

domain=""

#Stats
successes=0
faults=0
whoistest=default

#Retriving domaines list
ssh root@$dnsip "ls $dnsfolder"  | egrep '\.[a-z]{2,3}\.hosts$' > $scriptfolder/domains.txt

#Cleaning domaines list
sed -i 's/.hosts$//' $scriptfolder/domains.txt

#Loop Test
for domain in $(cat /root/script/domains.txt)
do
	#Dig Test
	echo "dig $domain NS @$ns | egrep -q -io '$regex'" | bash
	digtest=$?
	#Whois Test
	if [ $digtest -eq 1 ]; then
		sleep 5
		echo "whois $domain | egrep -q -io '$regex'" | bash
		whoistest=$?

		if [ $whoistest -eq 2 ]; then
		#If error in whois add to rellop file
			echo $domain >> $scriptfolder/reloop-errors.txt
			echo -e "\e\e[93m$domain FGETS ERROR ADDING TO LOOP\e[39m"
		fi
	fi

	#Verbose echo more info
	if [ "$1" = "-v" ]; then
		echo "digtest = $digtest || whoistest = $whoistest"
		echo -e "\e[93m$domain WHOIS RETURN CODE = $whoistest \e[39m"
	fi

	if [ $digtest -eq 0 ] || [ $whoistest -eq 0 ]; then
		#If one of the test return 0 add to success file
              	echo $domain >> $scriptfolder/autority-success.txt
	   	echo -e "\e[32m$domain FOUND\e[39m"
		((successes++))
	else
              	echo $domain >> $scriptfolder/autority-fault.txt
              	echo -e "\e[31m$domain pas d'autorite\e[39m"
		((faults++))
    	fi
done

echo "SUCCESSES = $successes ; FAULTS = $faults"

cat $scriptfolder/autority-fault.txt | mail -s "Rapport des domaines sans autorite" $email
