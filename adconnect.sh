#!/bin/bash
a=""
b=""
c=""
d=""


dialog --title "Active Directory Settiong" --backtitle "HamoniKR-ME" --ok-label "Save" --cancel-label "Cancle" \
          --stdout --form "" 15 50 4 \
          "UserId  " 1 1 "$a" 1 15 30 0 \
          "UserPw  " 2 1 "$b" 2 15 30 0 \
          "Domain Url " 3 1 "$c" 3 15 30 0 \
          "Domain Ip  " 4 1 "$d" 4 15 30 0 > output.txt


retval=$?

a=$(cat output.txt | head -1)
b=$(cat output.txt | head -2 | tail -1)
c=$(cat output.txt | head -3 | tail -1)
d=$(cat output.txt | head -4 | tail -1)
rm output.txt


if [ "$retval" = "0" ]
then
#        dialog --title "Active Directory Setting" --backtitle "Hamonikr-ME" --msgbox  \ "Saved values: \n $a \n $b \n $c \n $d " 0 0


        echo percentage | dialog --gauge "text" height width percent
        echo "10" | dialog --gauge "Please wait" 10 70 0
        sleep 1

        #PACKAGE check ###
        dpkg -l | service sshd status  >/dev/null 2>&1 || {
		sudo apt install openssh-server -y 1>output.log 2>error.log
	}
        dpkg -l | grep resolvconf  >/dev/null 2>&1 || {
                sudo apt install resolvconf -y 1>output.log 2>error.log
        }

#        dpkg -l | grep libglade2-0  >/dev/null 2>&1 || {
#                sudo apt-get install libglade2-0 -y 1>output.log 2>error.log
#        }
        dpkg -l | grep pbis  >/dev/null 2>&1 || {

                wget https://github.com/BeyondTrust/pbis-open/releases/download/8.5.2/pbis-open-8.5.2.265.linux.x86_64.deb.sh 1>output.log 2>error.log
                sudo chmod +x pbis-open-8.5.2.265.linux.x86_64.deb.sh 1>output.log 2>error.log
                yes | sudo sh pbis-open-8.5.2.265.linux.x86_64.deb.sh 1>output.log 2>error.log
        }
		echo "50" | dialog --gauge "Please wait" 10 70 0
		sleep 1

        
        sudo echo "nameserver $d" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
	sudo systemctl restart resolvconf
	sudo service resolvconf restart

        domainCut=`echo "$c" | cut -d'.' -f1`

	sudo sed -i '/supersede domain-name/d' /etc/dhcp/dhclient.conf
	sudo sed -i '/prepend domain-name-servers/d' /etc/dhcp/dhclient.conf
	sudo sed -i '/domain^users ALL=(ALL) ALL/d' /etc/sudoers
	sudo sed -i '/reeter-show-manual-login/d' /usr/share/lightdm/lightdm.conf.d/50-disable-guest.conf

        sudo sed -i "s/send host-name = gethostname();/supersede domain-name $c\nprepend domain-name-servers $d\nsend host-name = gethostname();/" /etc/dhcp/dhclient.conf
        sudo sed -i "/admin ALL=(ALL) ALL/i\%domain^users ALL=(ALL) ALL " /etc/sudoers
        sudo sed -i "/allow-guest=false/i\greeter-show-manual-login=true" /usr/share/lightdm/lightdm.conf.d/50-disable-guest.conf
       
	    sudo domainjoin-cli join $c $a $b 1>output.log 2>error.log
	    loginchk=$(grep -r 'ERROR' ./output.log)
        
        if [ "$loginchk" != "" ]
        then
                domainAccountError=$(cat output.log  | tail -1)
                dialog --title "Active Directory Setting" --backtitle "HamoniKR-ME" --msgbox  \ "??? ?? ?? ??\n $domainAccountError" 0 0
        else
	  sudo service ssh restart
          sudo /opt/pbis/bin/config UserDomainPrefix adserver
          sudo /opt/pbis/bin/config AssumeDefaultDomain true
          sudo /opt/pbis/bin/config LoginShellTemplate /bin/bash
          sudo /opt/pbis/bin/config HomeDirTemplate %H/%U
          sudo /opt/pbis/bin/config RequireMembershipOf $domainCut\\\Domain^Users
          sudo /opt/pbis/bin/ad-cache --delete-all
          echo "100" | dialog --gauge "Please wait" 10 70 0
          rm -fr output.log error.log
          dialog --title "Active Directory Setting" --backtitle "HamoniKR-ME" --msgbox  \ "??? ?? ??? ??????? \n ??? ???? ??? ???? " 0 0
       fi

else
        # Backup failed, display error log
        dialog --title "Cancle" --msgbox "AD Client Calcle " 10 50
fi
