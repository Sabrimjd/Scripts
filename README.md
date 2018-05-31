# Scripts
My scripts for automating things

####initvm.sh
Shell script for initialiazing new VM : 
-Regen ssh master key
-Regen ssh user keys
-Generate random root password stored in /home/vinc/DELETEME
-Change hostname
-Change IP (IP + MASK + GW) of eth0
-Edit Postfix

####check_dep.sh
Shell script for checking remote dependancies with cools color view and CSV push

####autority-report.sh
Shell script that make report of all domain list that the server does not have autority on them
-Extract all domaine name from remote DNS server
-make DNS Dig NS
-make whois NS
-Report by email
WIP

####add_host.sh
Shell script that install/configure remote supervision host and configure nagios and librenms
WIP
