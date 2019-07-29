#!/bin/bash  

#UUID ¿¿
sudo dmidecode -t 1 | grep UUID|sudo awk '{print "HamoniKR-" $2 > "/etc/uuid"}'

#¿¿ ¿¿
HIZID="administrator"
HIZPW="password"
HIZDOMAIN="ivsad.invesume.com"
HIZIP="192.168.0.153"
HIZCENTERURL="http://192.168.0.54:8088/hmsvc/process"
HIZCOLLECTDIP="192.168.0.57"
HIZSGBNM=""
HIZADJOINOU="http://192.168.0.54:8088/hmsvc/getou"

#device info make Json
SERVER_API=$HIZCENTERURL
DATETIME=`date +'%Y-%m-%d %H:%M:%S'`
#UUID=`sudo dmidecode -t 1|grep UUID | awk -F ':' '{print $2}'`
UUID=`cat /etc/uuid |head -1`
CPUID=`dmidecode -t 4|grep ID`
CPUINFO=`cat /proc/cpuinfo | grep "model name" | head -1 | cut  -d" " -f3- | sed "s/^ *//g"`
#HDDID=`hdparm -I /dev/sda | grep 'Serial\ Number' |awk -F ':' '{print $2}'`
IPADDR=`ifconfig | awk '/inet .*broadcast/'|awk '{print $2}'`
MACADDR=`ifconfig | awk '/ether/'|awk '{print $2}'`
HOSTNAME=`hostname`
MEMORY=`awk '{ printf "%.2f", $2/1024/1024 ; exit}' /proc/meminfo`
HDDTMP=`fdisk -l | head -1 | awk '{print $2}'| awk -F':' '{print $1}'`
HDDID=`hdparm -I $HDDTMP  | grep 'Serial\ Number' |awk -F ':' '{print $2}'`
HDDINFO=`hdparm -I $HDDTMP  | grep 'Model\ Number' |awk -F ':' '{print $2}'`
SGBNAME=''




# pbis leave
#sudo domainjoin-cli leave 2>error.log
#sudo apt-get purge collectd collectd-core -y 



dialog --title "Hamonize PC ¿¿ ¿¿¿¿" --backtitle "Hamonize" --ok-label "Save" --cancel-label "Cancle" \
          --stdout --form "" 15 50 2 \
          "¿¿¿ ¿¿  " 1 1 "$HIZSGBNM" 1 15 30 0 > output.txt

retval=$?

HIZSGBNM=$(cat output.txt | head -1)
rm -fr output.txt

if [ "$retval" = "0" ]
then

	sudo apt-get install curl -y >> curlinstall.log

	RETOU=`curl  -X  POST  -f -s -d "name=$HIZSGBNM" $HIZADJOINOU` >> output.log
	echo $RETOU >> retou.log

	if [ "$RETOU" = "NOSGB" ]
	then
    	    dialog --title "Hamonize Pc ¿¿¿¿¿¿" --backtitle "Hamonikr-ME" --msgbox  \ "[¿¿¿ ¿¿ ¿¿]\n ¿¿¿¿ ¿¿¿¿¿ ¿¿¿¿¿¿¿." 0 0
	    #clear
	    exit 
	fi


	echo percentage | dialog --gauge "text" height width percent
	echo "10" | dialog --gauge "Hamonize Pc ¿¿¿¿¿¿ ¿¿¿..." 10 70 0

	#PACKAGE check  & instll ###
	dpkg -l | service sshd status  >/dev/null 2>&1 || {
		sudo apt install openssh-server -y 2>&1 >output.log 
	}
	dpkg -l | grep resolvconf  >/dev/null 2>&1 || {
		sudo apt install resolvconf -y 2>&1 >output.log 
	}
	dpkg -l | grep pbis  >/dev/null 2>&1 || {
		wget https://github.com/BeyondTrust/pbis-open/releases/download/9.0.1/pbis-open-9.0.1.525.linux.x86_64.deb.sh 2>&1 >output.log 
		sudo chmod +x pbis-open-9.0.1.525.linux.x86_64.deb.sh 2>&1 >output.log 
		yes | sudo sh pbis-open-9.0.1.525.linux.x86_64.deb.sh 2>&1 >output.log 
	}
	dpkg -l | grep collectd > /dev/null 2>&1 || {
		sudo apt-get install collectd -y 2>&1 >output.log 
	}

	echo "20" | dialog --gauge "Hamonize Pc ¿¿¿¿¿¿ ¿¿¿..." 10 70 0
	
	sudo rm /etc/resolv.conf
	sudo ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
	
	sudo sed -i "$ a\search $HIZDOMAIN \nnameserver $HIZIP" /etc/resolv.conf
	sudo echo "nameserver $HIZIP" | sudo tee /etc/resolvconf/resolv.conf.d/head &


	echo "30" | dialog --gauge "Hamonize Pc ¿¿¿¿¿¿ ¿¿¿..." 10 70 0
	#sudo sed -i  "$s/$/nameserver $HIZIP/g" /etc/resolvconf/resolv.conf.d/head
	sudo service resolvconf restart

	sudo sed -i "s/send host-name = gethostname();/supersede domain-name $HIZDOMAIN \nprepend domain-name-servers $HIZIP\nsend host-name = gethostname();/" /etc/dhcp/dhclient.conf
	sudo sed -i "/admin ALL=(ALL) ALL/i\%domain^users ALL=(ALL) ALL " /etc/sudoers
	sudo sed -i "/allow-guest=false/i\greeter-show-manual-login=true" /usr/share/lightdm/lightdm.conf.d/50-disable-guest.conf
       

	#==== AD Join Action ==============================================
   	domainCut=`echo "$HIZDOMAIN" | cut -d'.' -f1`
	domainCut2=`echo "$HIZDOMAIN" | cut -d'.' -f2`
	domainCut3=`echo "$HIZDOMAIN" | cut -d'.' -f3`

	sudo domainjoin-cli join --ou "$RETOU",DC="$domainCut",DC="$domainCut2",DC="$domainCut3" "$HIZDOMAIN" "$HIZID" "$HIZPW" 2>&1 >output.log 
 	sudo domainjoin-cli query >> domainjoin-query.log
 	CHKDOMAINJOIN=$(sudo tail -1 ./domainjoin-query.log | awk '{print $NF}')

	if [ "$CHKDOMAINJOIN" = '=' ] then
		dialog --title "Hamonize Pc °ü¸®ÇÁ·Î±×·¥" --backtitle "Hamonikr-ME" --msgbox  \ "µµ¸ÞÀÎ °èÁ¤ °¡ÀÔ ¿À·ù\n °ü°èÀÚ¿¡°Ô ¹®ÀÇ ¹Ù¶ø´Ï´Ù. " 0 0
		exit
	fi

	echo "40" | dialog --gauge "Hamonize Pc °ü¸®ÇÁ·Î±×·¥ ¼³Ä¡Áß..." 10 70 0

	loginchk=$(grep -r 'ERROR' ./output.log)
	if [ "$loginchk" != "" ]  then
		domainAccountError=$(cat output.log  | tail -1)
	        dialog --title "Hamonize Pc °ü¸®ÇÁ·Î±×·¥" --backtitle "Hamonikr-ME" --msgbox  \ "µµ¸ÞÀÎ °èÁ¤ °¡ÀÔ ¿À·ù\n $domainAccountError" 0 0
    		exit
	fi

	#==== AD PBIS È¯°æ¼³Á¤ ==============================================
      	sudo service ssh restart
      	sudo /opt/pbis/bin/config UserDomainPrefix $domainCut
      	sudo /opt/pbis/bin/config AssumeDefaultDomain true
      	sudo /opt/pbis/bin/config LoginShellTemplate /bin/bash
      	sudo /opt/pbis/bin/config HomeDirTemplate %H/%U
      	sudo /opt/pbis/bin/config RequireMembershipOf $a\\\Domain^Users
      	sudo /opt/pbis/bin/ad-cache --delete-all >> output.log
  	sudo /opt/pbis/bin/update-dns >> output.log 

  	echo "60" | dialog --gauge "Hamonize Pc °ü¸®ÇÁ·Î±×·¥ ¼³Ä¡Áß..." 10 70 0



	#==== AD Á¶ÀÎ ÈÄ  PC device Á¤º¸¸¦ ¼¾ÅÍ¿¡ µî·ÏÇÑ´Ù. ==============================================
	LOG="$UUID|$DATETIME|$CPUID|$CPUINFO|$HDDID|$HDDINFO|$MACADDR|$IPADDR|$HOSTNAME|$MEMORY|$SGBNAME"

	LOG_JSON="{\
     		\"events\" : [ {\
		\"datetime\":\"$DATETIME\",\
		\"uuid\":\"$UUID\",\
		\"cpuid\": \"$CPUID\",\
		\"cpuinfo\": \"$CPUINFO\",\
		\"hddid\": \"$HDDID\",\
		\"hddinfo\": \"$HDDINFO\",\
		\"macaddr\": \"$MACADDR\",\
		\"ipaddr\": \"$IPADDR\",\
		\"hostname\": \"$HOSTNAME\",\
		\"memory\": \"$MEMORY\",\
		\"sgbname\": \"$SGBNAME\",\
		\"user\": \"$USER\"\
		} ]\
	}"

	RETVAL=`curl  -X  POST -H 'User-Agent: HamoniKR OS' -H 'Content-Type: application/json' -f -s -d "$LOG_JSON" $HIZCENTERURL`
	echo $RETVAL >> ./log_json_return.log


	echo "70" | dialog --gauge "Hamonize Pc °ü¸®ÇÁ·Î±×·¥ ¼³Ä¡Áß..." 10 70 0


	#==== collectd setting ==============================================
	sudo  sed  -i "s/#Hostname/Hostname/" /etc/collectd/collectd.conf
	sudo  sed  -i "s/#Interval/Interval/" /etc/collectd/collectd.conf
	sudo  sed  -i "s/#LoadPlugin network/LoadPlugin network/" /etc/collectd/collectd.conf
	sudo  sed  -i "s/#LoadPlugin uuid/LoadPlugin uuid/" /etc/collectd/collectd.conf

	sudo  sed  -i '/#<Plugin uuid>/a\<Plugin uuid>\n UUIDFile "/etc/uuid" \n</Plugin>' /etc/collectd/collectd.conf
	sudo  sed  -i '/df>/a\Device "/dev/sda1" \n MountPoint "/" \n FSType "ext4"' /etc/collectd/collectd.conf
	sudo  sed  -i '/interface>/a\<Plugin interface>\n Interface "eth0" \nIgnoreSelected false \n</Plugin>' /etc/collectd/collectd.conf
	sudo  sed  -i '/network>/a\<Plugin network>\n Server "'"$HIZCOLLECTDIP"'" "25826"\n</Plugin>' /etc/collectd/collectd.conf

	sudo /etc/init.d/collectd restart >> ./collectd_restart.log

	echo "80" | dialog --gauge "Hamonize Pc °ü¸®ÇÁ·Î±×·¥ ¼³Ä¡Áß..." 10 70 0


	#==== lightdm setting ==============================================
	#1. guest auto login
	sudo  sed  -i '/user-session=cinnamon/a\allow-guest=true\nautologin-guest=true\nautologin-user-timeout=5'  /etc/lightdm/lightdm.conf.d/70-linuxmint.conf
	
	#2. disable startup dialog
	echo "touch $HOME/.skip-guest-warning-dialog" | sudo tee /etc/guest-session/prefs.sh 

	#3. hamonize pc program 
	#lighdm µî·ÏÇØ¾ßÇÔ

	
	echo "100" | dialog --gauge "Hamonize Pc °ü¸®ÇÁ·Î±×·¥ ¼³Ä¡ ¿Ï·á..." 10 70 0
	dialog --title "Hamonize pc °ü¸® ÇÁ·Î±×·¥" --backtitle "Hamonize" --msgbox  \ "Hamonize PC °ü¸® ÇÁ·Î±×·¥ ¼³Ä¡°¡ ¿Ï·áµÇ¾ú½À´Ï´Ù. ¹é¾÷À» ½ÃÀÛÇÕ´Ï´Ù.  " 0 0

	#==== backup timeShift ==============================================
	(

		DEVICE=`df -T|grep 'ext*' | awk '{print $1}'`
		sudo timeshift --snapshot-device "$DEVICE" --scripted --create --comments "bak test" >> ./backuplog.log
		#tar cvfz ./backup.tar.gz /home >> ./bakcuplog.log

		BKNAME=`cat ./backuplog.log |grep 'Tagged*' | awk '{print $3}' | awk -F "'" '{print $2}'`
		BKUUID=`cat /etc/uuid |head -1`
		BKDIR="/timeshift/snapshots"
		BKCENTERURL="http://192.168.0.54:8088/backup/setBackupJob"

		BKLOG="$UUID|$DATETIME|$BKNAME|$HOSTNAME|$BKDIR"

	        BK_JSON="{\
			\"events\" : [ {\
			\"datetime\":\"$DATETIME\",\
			\"uuid\":\"$UUID\",\
			\"name\": \"$BKNAME\",\
			\"hostname\": \"$HOSTNAME\",\
			\"dir\": \"$BKDIR\"\
			} ]\
		}"

		RETBAK=`curl  -X  POST -H 'User-Agent: HamoniKR OS' -H 'Content-Type: application/json' -f -s -d "$BK_JSON" $BKCENTERURL`
		echo $RETBAK >> retbak.log
		dialog --title "Hamonize pc °ü¸® ÇÁ·Î±×·¥" --backtitle "Hamonize" --msgbox  \ "Hamonize PC ¹é¾÷ÀÌ ¿Ï·áµÇ¾ú½À´Ï´Ù..  " 0 0
		exit
	)& {

		i="0"
		while (true)
		do
		    proc=$(ps aux | grep -e "tar cvfz*" | head -1 | awk '{print $NF}')
		    if [ "$proc" = "cvfz*" ]; then break; fi
		    # Sleep for a longer period if the database is really big 
		    # as dumping will take longer.
		    sleep 1
		    echo $i
		    i=$(expr $i + 1)
		done
		echo 100
		sleep 2
	} | whiptail --title "Backup" --gauge "Dumping HamoniKR OS" 10 70 0
fi
