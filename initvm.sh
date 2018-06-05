#!/bin/bash
randpass=`openssl rand -base64 32`

choice=0
error=0

#HOSTNAME
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

#IP MAIN
choice=0
error=0

until (($choice!=0))
do

	clear # Clear the screen.
	echo

	echo "          	SELECT IP MAIN (int1)"
	echo "         ----------------- -----------------"
	echo "			e.g (192.168.1.XXX)"
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

#IP BAK
choice=0
error=0

until (($choice!=0))
do

	clear # Clear the screen.
	echo

	echo "          	SELECT IP BACKUP (int2)"
	echo "         ----------------- -----------------"
	echo "			e.g (10.10.10.X)"
	echo

	if [ $error -eq 1 ]; then
		echo " ERROR DE SAISIE VEUILLEZ REESSAYER"
	fi

	echo "IP : " 
	echo
	read -p "#:" choice

	words=${#choice}

	if [ $words -lt 16 ]; then
		ipbak=$choice
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

#IP GW
until (($choice!=0))
do

	clear # Clear the screen.
	echo

	echo "          	SELECT GATEWAY (int1)"
	echo "         ----------------- -----------------"
	echo "			e.g (192.168.1.1)"
	echo

	if [ $error -eq 1 ]; then
		echo " ERROR DE SAISIE VEUILLEZ REESSAYER"
	fi

	echo "GATEWAY IP : " 
	echo
	read -p "#:" choice

	words=${#choice}

	if [ $words -lt 16 ]; then
		gw=$choice
		choice=1
	else
		choice=0
		error=1
	fi
	echo
	echo "---------------------------------------------"

clear
echo
echo "-----------INFORMATION-----------"
echo "Random root password : $randpass"
echo "Hostname : $hostname"
echo "IP : $ip"
echo "GW : $gw"
echo "Regenerating SSH KEYS (SRV + CLIENT)"

echo
echo "----------COMMANDS-------------"

#SSH KEYS
echo "/bin/rm -v /etc/ssh/ssh_host_*"
/bin/rm -v /etc/ssh/ssh_host_*
echo "dpkg-reconfigure openssh-server"
dpkg-reconfigure openssh-server
echo "ssh-keygen"
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
ssh-keygen -b 2048 -t rsa -f /home/vinc/.ssh/id_rsa -q -N ""
chown -R vinc:vinc /home/vinc/.ssh/
chmod -R 0600 /home/vinc/.ssh/
echo

#ROOT PASSWORD
echo $randpass > /home/vinc/DELETEME
echo "WARNING PASSWORD STORED IN /home/vinc/DELETEME, DELETE IT AFTER COPY"
echo "echo $randpass | passwd root --stdin"
echo root:$randpass | chpasswd

#NETWORKING
#INT1
echo
echo "Configuring interface 1 (MAIN)"
echo "sed -i -e 's/192.168.5.16/$ip/g' /etc/network/interfaces.d/int1"
sed -i -e "s/192.168.5.16/$ip/g" /etc/network/interfaces.d/int1
echo
echo "sed -i -e 's/192.168.5.1/$gw/g' /etc/network/interfaces.d/int1"
sed -i -e "s/192.168.5.1/$gw/g" /etc/network/interfaces.d/int1
echo
echo "Configuring interface 2 (BACKUP)"
#INT2
echo "Configuring interface 1 (MAIN)"
echo "sed -i -e 's/10.10.10.16/$ipbak/g' /etc/network/interfaces.d/int2"
sed -i -e "s/10.10.10.16/$ipbak/g" /etc/network/interfaces.d/int2

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

#Update
/root/update_sys.sh

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
