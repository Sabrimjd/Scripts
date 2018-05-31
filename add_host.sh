#!/bin/bash


clear # Clear the screen.
echo "          Add host to sup"
echo "          ------- -------"
echo "Select IP" 
echo
read -p "IP : " ip
read -s -p "Enter Password: " passwd
echo
echo "-------------------------"
echo

clear # Clear the screen.

sshpass -p $passwd  ssh -n -oStrictHostKeyChecking=no root@$ip 'export http_proxy="http://proxy:3128" && cd /root/ && rm -rf /root/check.sh && wget site/check.sh > /dev/null 2>&1 && chmod +x /root/check.sh && /root/check.sh';

echo "          Add host to sup"
echo "          ------- -------"
echo "             $ip"
echo "Choose an option:" 
echo
echo "[1]Nagios + LibreNMS"
echo "[2]Nagios"
echo "[3]Librenms"
echo "[0]Exit"
echo
read -p "#:" choice
echo
echo "-------------------------"
echo


case "$choice" in
# Note variable is quoted.

  1 )
  echo
  echo "You choosed Nagios + LibreNMS installation"
  sshpass -p $passwd  ssh -n -oStrictHostKeyChecking=no root@$ip 'cat /etc/debian_version | cut -c1-3 && lsb_release -a | grep Code | cut -f 2';
  read -p "You confirm ? [Y/n]" choice2
  
	  case "$choice2" in
	
		  "Y" | "y" )
		  echo "-------------------------"
		  clear # Clear the screen

		  clear
                  echo "          Add host to sup"
		  echo "          ------- -------"
		  echo "             $ip"
		  echo "Choose a VM name:" 
		  echo
		  read -p "#:" choice
		  echo
		  echo "-------------------------"
		  echo
		  vmname=$choice

		  clear
		  echo
		  echo "          Add host to sup"
		  echo "          ------- -------"
		  echo "             $ip"
		  echo "Choose a file:" 
		  echo
		  find /etc/nagios/objects/ -name "host*" | grep -v hostsgroups.cfg
		  read -p "#:" choice
		  echo
		  echo "-------------------------"
		  echo
		  file=$choice

		  clear
		  echo "          Add host to sup"
		  echo "          ------- -------"
		  echo "             $ip"
		  echo "Choose a template:" 
		  echo
		  cat /etc/nagios/objects/templates.cfg | grep name | awk '{print $2}'
		  read -p "#:" choice
		  echo
		  echo "-------------------------"
		  echo
		  template=$choice

		  clear
		  echo "          Add host to sup"
		  echo "          ------- -------"
		  echo "             $ip"
		  echo "Choose a group:" 
		  echo
		  cat /etc/nagios/objects/hostsgroups.cfg | grep name | awk '{print $2}'
		  echo
		  read -p "#:" choice
		  echo
		  echo "-------------------------"
		  echo
		  hostgroup=$choice

		  clear

		  echo "	PREVIEW"
		  echo "    ------- -------"
		  echo
		  echo 
		  echo "define host {"
		  echo "	use                     $template"
		  echo "	host_name               $vmname"
		  echo "	alias                   $vmname"
		  echo "	address                 $ip"
		  echo "}"
		  echo
		  echo "on file $file for group $hostgroup"
		  echo

		  ;;
		
		
		   * )
		   echo
		   echo "Installation canceled."
		   exit
		  ;;
		
	  esac
  
  ;;

  2 )
  echo
  echo "You choosed Nagios installation"
  ;;
  
  3 )
  echo
  echo "You choosed LibreNMS installation"
  ;;


   * )
   # Default option.	  
   # Empty input (hitting RETURN) fits here, too.
   echo
   echo "Installation canceled."
  ;;

esac

echo

exit 0
