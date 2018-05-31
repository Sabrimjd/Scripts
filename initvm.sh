#!/bin/bash
randpass=`openssl rand -base64 32`

choice=0
error=0

until (($choice!=0))
do

	clear # Clear the screen.
	echo

	echo "          	SELECT HOSTNAME"
	echo "         ----------------- -----------------"
	echo "			10 Caracteres maximum"
	echo

	if [ $error -eq 1 ]; then
		echo " ERROR DE SAISIE VEUILLEZ REESSAYER"
	fi

	echo "Hostname : " 
	echo
	read -p "#:" choice

	words=${#choice}

	if [ $words -lt 10 ]; then
		hostname=$choice
		choice=1 
	else
		choice=0
		error=1
	fi
	echo
	echo "---------------------------------------------"
done	

choice=0
error=0

until (($choice!=0))
do

	clear # Clear the screen.
	echo

	echo "          	SELECT IP"
	echo "         ----------------- -----------------"
	echo "			e.g (xxx.xxx.xxx.xxx)"
	echo

	if [ $error -eq 1 ]; then
		echo " ERROR DE SAISIE VEUILLEZ REESSAYER"
	fi

	echo "IP : " 
	echo
	read -p "#:" choice

	words=${#choice}

	if [ $words -lt 16 ]; then
		ip=$choice
		choice=1
	else
		choice=0
		error=1
	fi
	echo
	echo "---------------------------------------------"
done	

clear
echo
echo "-----------INFORMATION-----------"
echo "Random root password : $randpass"
echo "Hostname : $hostname"
echo "IP : $ip"
echo "Regenerating SSH KEYS (SRV + CLIENT)"

echo
echo "----------COMMANDS-------------"

#SSH KEYS
echo "/bin/rm -v /etc/ssh/ssh_host_*"
/bin/rm -v /etc/ssh/ssh_host_*
echo "dpkg-reconfigure openssh-server"
dpkg-reconfigure openssh-server
echo "ssh-keygen"
ssh-keygen 
echo

#ROOT PASSWORD
echo $randpass > /home/vinc/DELETEME
echo "WARNING PASSWORD STORED IN /home/vinc/DELETEME, DELETE IT AFTER COPY"
echo "echo $randpass | passwd root --stdin"
echo root:$randpass | chpasswd

#NETWORKING
echo
echo "sed -i -e 's/192.168.5.16/$ip/g' /etc/network/interface"
sed -i -e "s/192.168.5.16/$ip/g" /etc/network/interfaces
echo
echo "/etc/init.d/networking restart"
/etc/init.d/networking restart

#HOSTNAME
echo "sed -i -e 's/Debian9-Template/$hostname/g' /etc/hostname"
sed -i -e "s/Debian9-Template/$hostname/g" /etc/hostname
echo "sed -i -e 's/Debian9-Template/$hostname/g' /etc/hosts"
sed -i -e "s/Debian9-Template/$hostname/g" /etc/hosts
echo "HOSTNAME : $hostname"
hostname $hostname

#POSTFIX
echo "sed -i -e 's/Debian9-Template/$hostname/g' /etc/postfix/main.cf"
sed -i -e "s/Debian9-Template/$hostname/g" /etc/postfix/main.cf
/etc/init.d/postfix restart

echo
echo "         ----------------- -----------------"
echo
read -p "Reboot [Y/n]#:" choice
echo

if [ $error -eq 1 ]; then
        echo " ERROR DE SAISIE VEUILLEZ REESSAYER"
fi
case "$choice" in
  n )
        exit
  ;;
  Y )
	   reboot
  ;;
  * )
           choice=0
           error=1
  ;;
esac
done
