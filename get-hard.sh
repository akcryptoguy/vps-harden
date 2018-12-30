#!/bin/bash
# Script to Harden Security on Ubuntu 16.04 LTS (untested on anything else)
# This VPS Server Hardening script is designed to be run on new VPS deployments to simplify a lot of the
# basic hardening that can be done to protect your server. I assimilated several design ideas from AMega's
# VPS hardening script which I found on Github seemingly abandoned. I am very happy to finish it.

function akguy_banner() {
cat << "EOF" 
 ▄████████    ▄█   ▄█▄  ▄████████    ▄████████ ▄██   ▄      ▄███████▄     ███      ▄██████▄     ▄██████▄  ███    █▄  ▄██   ▄   
  ███    ███   ███ ▄███▀ ███    ███   ███    ███ ███   ██▄   ███    ███ ▀█████████▄ ███    ███   ███    ███ ███    ███ ███   ██▄ 
  ███    ███   ███▐██▀   ███    █▀    ███    ███ ███▄▄▄███   ███    ███    ▀███▀▀██ ███    ███   ███    █▀  ███    ███ ███▄▄▄███ 
  ███    ███  ▄█████▀    ███         ▄███▄▄▄▄██▀ ▀▀▀▀▀▀███   ███    ███     ███   ▀ ███    ███  ▄███        ███    ███ ▀▀▀▀▀▀███ 
▀███████████ ▀▀█████▄    ███        ▀▀███▀▀▀▀▀   ▄██   ███ ▀█████████▀      ███     ███    ███ ▀▀███ ████▄  ███    ███ ▄██   ███ 
  ███    ███   ███▐██▄   ███    █▄  ▀███████████ ███   ███   ███            ███     ███    ███   ███    ███ ███    ███ ███   ███ 
  ███    ███   ███ ▀███▄ ███    ███   ███    ███ ███   ███   ███            ███     ███    ███   ███    ███ ███    ███ ███   ███ 
  ███    █▀    ███   ▀█▀ ████████▀    ███    ███  ▀█████▀   ▄████▀         ▄████▀    ▀██████▀    ████████▀  ████████▀   ▀█████▀  
               ▀                      ███    ███                                                                                        
EOF
}
	 
# ###### SECTIONS ######
# 1. CREATE SWAP / if no swap exists, create 1 GB swap
# 2. UPDATE AND UPGRADE / update operating system & pkgs
# 3. INSTALL FAVORED PACKAGES / useful tools & utilities
# 4. INSTALL CRYPTO PACKAGES / common crypto packages
# 5. USER SETUP / add new sudo user, copy SSH keys
# 6. SSH CONFIG / change SSH port, disable root login
# 7. UFW CONFIG / UFW - add rules, harden, enable firewall
# 8. HARDENING / before rules, secure shared memory, etc
# 9. KSPLICE INSTALL / automatically update without reboot
# 10. MOTD EDIT / replace boring banner with customized one
# 11. RESTART SSHD / apply settings by restarting systemctl
# 12. INSTALL COMPLETE / display new SSH and login info

# Add to log command and display output on screen
# echo " `date +%d.%m.%Y" "%H:%M:%S` : $MESSAGE" | tee -a "$LOGFILE"
# Add to log command and do not display output on screen
# echo " `date +%d.%m.%Y" "%H:%M:%S` : $MESSAGE" >> $LOGFILE 2>&1

# write to log only, no output on screen # echo  -e "---------------------------------------------------- " >> $LOGFILE 2>&1
# write to log only, no output on screen # echo  -e "    ** This entry gets written to the log file directly. **" >> $LOGFILE 2>&1
# write to log only, no output on screen # echo  -e "---------------------------------------------------- \n" >> $LOGFILE 2>&1

function setup_environment() {
### add colors ###
lightred='\033[1;31m'  # light red
red='\033[0;31m'  # red
lightgreen='\033[1;32m'  # light green
green='\033[0;32m'  # green
lightblue='\033[1;34m'  # light blue
blue='\033[0;34m'  # blue
lightpurple='\033[1;35m'  # light purple
purple='\033[0;35m'  # purple
lightcyan='\033[1;36m'  # light cyan
cyan='\033[0;36m'  # cyan
lightgray='\033[0;37m'  # light gray
white='\033[1;37m'  # white
brown='\033[0;33m'  # brown
yellow='\033[1;33m'  # yellow
darkgray='\033[1;30m'  # dark gray
black='\033[0;30m'  # black
nocolor='\033[0m'    # no color

# Used this while testing color output
# printf " ${lightred}Light Red${nocolor}\n"
# printf " ${red}Red${nocolor}\n"
# printf " ${lightgreen}Light Green${nocolor}\n"
# printf " ${green}Green${nocolor}\n"
# printf " ${lightblue}Light Blue${nocolor}\n"
# printf " ${blue}Blue${nocolor}\n"
# printf " ${lightpurple}Light Purple${nocolor}\n"
# printf " ${purple}Purple${nocolor}\n"
# printf " ${lightcyan}Light Cyan${nocolor}\n"
# printf " ${cyan}Cyan${nocolor}\n"
# printf " ${lightgray}Light Gray${nocolor}\n"
# printf " ${white}White${nocolor}\n"
# printf " ${lightbrown}Brown${nocolor}\n"
# printf " ${yellow}Yellow${nocolor}\n"
# printf " ${darkgray}Dark Gray${nocolor}\n"
# printf " ${black}Black${nocolor}\n"
# figlet " hello $(whoami)" -f small

printf "${lightred}"
printf "${red}"
printf "${lightgreen}"
printf "${green}"
printf "${lightblue}"
printf "${blue}"
printf "${lightpurple}"
printf "${purple}"
printf "${lightcyan}"
printf "${cyan}"
printf "${lightgray}"
printf "${white}"
printf "${brown}"
printf "${yellow}"
printf "${darkgray}"
printf "${black}"
printf "${nocolor}"
clear

# Set Vars
LOGFILE='/var/log/server_hardening.log'
SSHDFILE='/etc/ssh/sshd_config'
}

function begin_log() {
# Create Log File and Begin
printf "${lightcyan}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : SCRIPT STARTED SUCCESSFULLY " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e "------- AKcryptoGUY's VPS Hardening Script --------- " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${nocolor}"
sleep 2
}

#########################
## CHECK & CREATE SWAP ##
#########################

function create_swap() {
# Check for and create swap file if necessary
# this is an alternative that will disable swap, and create a new one at the size you like
# sudo swapoff -a && sudo dd if=/dev/zero of=/swapfile bs=1M count=6144 MB && sudo mkswap /swapfile && sudo swapon /swapfile
	printf "${yellow}"
	echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : CHECK FOR AND CREATE SWAP " | tee -a "$LOGFILE"
	echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${white}"
	
	# Check for swap file - if none, create one
	if free | awk '/^Swap:/ {exit !$2}'; then
		printf "${lightred}"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e " `date +%m.%d.%Y_%H:%M:%S` : Swap exists- No changes made " | tee -a "$LOGFILE"
		echo -e "---------------------------------------------------- \n"  | tee -a "$LOGFILE"
		sleep 2
		printf "${nocolor}"
	else
	    	fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && cp /etc/fstab /etc/fstab.bak && echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
		printf "${lightgreen}"	
		echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e " `date +%m.%d.%Y_%H:%M:%S` : SWAP CREATED SUCCESSFULLY " | tee -a "$LOGFILE"
		echo -e "--> Thanks @Cryptotron for supplying swap code <-- "
		echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
		sleep 2
		printf "${nocolor}"
	fi
}

######################
## UPDATE & UPGRADE ##
######################

function update_upgrade() {

# NOTE I learned the hard way that you must put a "\" BEFORE characters "\" and "`"
echo -e "${lightcyan}"
printf "  ___  ____    _   _           _       _ \n" | tee -a "$LOGFILE"
printf " / _ \/ ___|  | | | |_ __   __| | __ _| |_ ___ \n" | tee -a "$LOGFILE"
printf "| | | \\___ \\  | | | | '_ \\ / _\` |/ _\` | __/ _ \\ \n" | tee -a "$LOGFILE"
printf "| |_| |___) | | |_| | |_) | (_| | (_| | ||  __/ \n" | tee -a "$LOGFILE"
printf " \___/|____/   \___/| .__/ \__,_|\__,_|\__\___| \n" | tee -a "$LOGFILE"
printf "                    |_| \n"
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : INITIATING SYSTEM UPDATE " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
	# remove grub to prevent interactive user prompt: https://tinyurl.com/y9pu7j5s
	echo '# rm /boot/grub/menu.lst     (prevent update issue)' | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
 	rm /boot/grub/menu.lst
 	echo '# update-grub-legacy-ec2 -y  (prevent update issue)' | tee -a "$LOGFILE"
	echo -e "--------------------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
 	update-grub-legacy-ec2 -y | tee -a "$LOGFILE"
	printf "${white}"
	echo '# apt-get -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true update' | tee -a "$LOGFILE"
	echo -e "--------------------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true update | tee -a "$LOGFILE"
	printf "${white}"
	echo -e "----------------------------------------------------------------------------- " | tee -a "$LOGFILE"
	echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install figlet' | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install figlet | tee -a "$LOGFILE"
	printf "${lightgreen}"
	echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : SYSTEM UPDATED SUCCESSFULLY " | tee -a "$LOGFILE"
	echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"

	printf "${cyan}"
	figlet System Upgrade | tee -a "$LOGFILE"
	printf "${yellow}"
	echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : INITIATING SYSTEM UPGRADE " | tee -a "$LOGFILE"
	echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${white}"
	echo ' # apt-get upgrade -y' | tee -a "$LOGFILE"
	# the next line seemed to break it so I install without new-pkgs
	# echo ' # apt-get --with-new-pkgs upgrade -y' | tee -a "$LOGFILE"
	echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get upgrade -y | tee -a "$LOGFILE"
printf "${lightgreen}"	
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : SYSTEM UPGRADED SUCCESSFULLY " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

#
#  PROMPT WHETHER USER WANTS TO INSTALL FAVORED PACKAGES OR ALSO ADD THEIR OWN CUSTOM PACKAGES
#

function favored_packages() {
# install my favorite and commonly used packages
printf "${lightcyan}"
figlet Install Favored | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : INSTALLING FAVORED PACKAGES " | tee -a "$LOGFILE"
echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${white}"
	echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
	echo '   htop nethogs ufw fail2ban wondershaper glances ntp figlet lsb-release ' | tee -a "$LOGFILE"
	echo '   update-motd unattended-upgrades secure-delete' | tee -a "$LOGFILE"
	echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
	htop nethogs ufw fail2ban wondershaper glances ntp figlet lsb-release \
	update-motd unattended-upgrades secure-delete | tee -a "$LOGFILE"
printf "${lightgreen}"
echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : FAVORED INSTALLED SUCCESFULLY " | tee -a "$LOGFILE"
echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

#
#  PROMPT WHETHER USER WANTS TO INSTALL COMMON CRYPTO PACKAGES TO SAVE TIME LATER
#

function crypto_packages() {
# install development and build packages that are common on all cryptos
printf "${lightcyan}"
figlet Install Crypto | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : INSTALLING CRYPTO PACKAGES " | tee -a "$LOGFILE"
echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
	echo ' # add-apt-repository -yu ppa:bitcoin/bitcoin' | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	add-apt-repository -yu ppa:bitcoin/bitcoin | tee -a "$LOGFILE"
	printf "${white}"
	echo -e "---------------------------------------------------------------------- " | tee -a "$LOGFILE"
	echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
	echo '   build-essential g++ protobuf-compiler libboost-all-dev autotools-dev ' | tee -a "$LOGFILE"
	echo '   automake libcurl4-openssl-dev libboost-all-dev libssl-dev libdb++-dev ' | tee -a "$LOGFILE"
	echo '   make autoconf automake libtool git apt-utils libprotobuf-dev pkg-config ' | tee -a "$LOGFILE"
	echo '   libcurl3-dev libudev-dev libqrencode-dev bsdmainutils pkg-config libssl-dev ' | tee -a "$LOGFILE"
	echo '   libgmp3-dev libevent-dev jp2a pv virtualenv lsb-release figlet update-motd ' | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
	build-essential g++ protobuf-compiler libboost-all-dev autotools-dev \
	automake libcurl4-openssl-dev libboost-all-dev libssl-dev libdb++-dev \
	make autoconf automake libtool git apt-utils libprotobuf-dev pkg-config \
	libcurl3-dev libudev-dev libqrencode-dev bsdmainutils pkg-config libssl-dev \
	libgmp3-dev libevent-dev jp2a pv virtualenv lsb-release figlet update-motd  | tee -a "$LOGFILE"
	
# need more testing to see if autoremove breaks the script or not
# apt autoremove -y | tee -a "$LOGFILE"
clear
printf "${lightgreen}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : CRYPTO INSTALLED SUCCESFULLY " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

################
## USER SETUP ##
################

function add_user() {
# query user to setup a non-root user account or not
printf "${lightcyan}"
figlet User Setup | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : QUERY TO CREATE NON-ROOT USER " | tee -a "$LOGFILE"
echo -e "----------------------------------------------------- \n"
printf "${lightcyan}"
	echo " Conventional wisdom would encourage you to disable root login over SSH"
	echo " because it makes accessing your server more difficult if you use password"
	echo " authentication. Since using RSA public-private key authentication is"
	echo " infinitely more secure, I will not think less of you if you choose to"
	echo " use an RSA key and continue to login as root. I am able to create a "
	echo " non-root user if you want me to, but it is not required. "
	echo -e "\n"
	printf "${cyan}"
        read -p " Would you like to add a non-root user? y/n  " ADDUSER
	printf "${nocolor}"
	
	while [ "${ADDUSER,,}" != "yes" ] && [ "${ADDUSER,,}" != "no" ] && [ "${ADDUSER,,}" != "y" ] && [ "${ADDUSER,,}" != "n" ]; do
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " ADDUSER
	printf "${nocolor}"
	done
        # check if ADDUSER is valid
        if [ "${ADDUSER,,}" = "yes" ] || [ "${ADDUSER,,}" = "y" ]
        then echo -e "\n"
		printf "${yellow}"
		echo -e " Great; let's set one up now... \n"
		printf "${cyan}"
		read -p " Enter New Username: " UNAME
                while [[ "$UNAME" =~ [^0-9A-Za-z]+ ]] || [ -z $UNAME ]; do echo -e "\n"
                printf "${lightred}"
		read -p " --> Please enter a username that contains only letters or numbers: " UNAME
                printf "${nocolor}"
		done
		echo -e "\n"
		printf "${yellow}"
		echo  -e " User elected to create a new user named ${UNAME,,}. \n" >> $LOGFILE 2>&1
                printf "${cyan}"
		id -u ${UNAME,,} >> $LOGFILE > /dev/null 2>&1
                	if [ $? -eq 0 ]
                	then
			clear
			printf "${yellow}"
                	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                	echo " `date +%m.%d.%Y_%H:%M:%S` : SKIPPING : User Already Exists " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
                	else
			printf "${cyan}"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                	printf "${nocolor}"
			adduser --gecos "" ${UNAME,,} | tee -a "$LOGFILE"
                	usermod -aG sudo ${UNAME,,} | tee -a "$LOGFILE"
			printf "${lightgreen}"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : '${UNAME,,}' added to SUDO group" | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
				# copy SSH keys if they exist
				if [ -n /root/.ssh/authorized_keys ]
				then mkdir /home/${UNAME,,}/.ssh
				chmod 700 /home/${UNAME,,}/.ssh
				# copy root SSH key to new non-root user
				cp /root/.ssh/authorized_keys /home/${UNAME,,}/.ssh
                        	# fix permissions on RSA key
                        	chmod 400 /home/${UNAME,,}/.ssh/authorized_keys
                        	chown ${UNAME,,}:${UNAME,,} /home/${UNAME,,} -R
                        	echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : SSH keys were copied to ${UNAME,,}'s profile" | tee -a "$LOGFILE"
                        	else printf "${yellow}"
				echo " `date +%m.%d.%Y_%H:%M:%S` : RSA keys not present for root, so none were copied." | tee -a "$LOGFILE"
                        	fi   
			clear
			fi
        else 	printf "${yellow}"
		clear
		echo  -e "----------------------------------------------------- " >> $LOGFILE 2>&1
		echo  "    ** User chose not to create a new user **" >> $LOGFILE 2>&1
		echo  -e "-----------------------------------------------------" >> $LOGFILE 2>&1
        fi
	printf "${lightgreen}"
	echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : USER SETUP IS COMPLETE " | tee -a "$LOGFILE"
	echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
}

################ 
## SSH CONFIG ##
################

function collect_sshd() {
# Prompt for custom SSH port between 11000 and 65535
printf "${lightcyan}"
figlet SSH Config | tee -a "$LOGFILE"
printf "${nocolor}"
SSHPORTWAS=$(sed -n -e '/^Port /p' $SSHDFILE)
printf "${yellow}"
echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : CONFIGURE SSH SETTINGS " | tee -a "$LOGFILE"
echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " --> Your current SSH port number is ${SSHPORTWAS} <-- " | tee -a "$LOGFILE"
echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${nocolor}"
	printf "${lightcyan}"
	echo -e " By default, SSH traffic occurs on port 22, so hackers are always"
	echo -e " scanning port 22 for vulnerabilities. If you change your server to"
	echo -e " use a different port, you gain some security through obscurity.\n"
	while :; do
		printf "${cyan}"
		read -p " Enter a custom port for SSH between 11000 and 65535 or use 22: " SSHPORT
		[[ $SSHPORT =~ ^[0-9]+$ ]] || { printf "${lightred}";echo -e " --> Try harder, that's not even a number. \n";printf "${nocolor}";continue; }
		if (($SSHPORT >= 11000 && $SSHPORT <= 65535)); then break
		elif [ $SSHPORT = 22 ]; then break
		else printf "${lightred}"
			echo -e " --> That number is out of range, try again. \n"
			echo "---------------------------------------------------- " >> $LOGFILE 2>&1
			echo " `date +%m.%d.%Y_%H:%M:%S` : ERROR: User entered: $SSHPORT " >> $LOGFILE 2>&1
			echo "---------------------------------------------------- " >> $LOGFILE 2>&1
			printf "${nocolor}"
		fi
	done
		# Take a backup of the existing config
		BTIME=$(date +%F_%R)
		cat $SSHDFILE > $SSHDFILE.$BTIME.bak
		echo -e "\n"
		printf "${yellow}"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e "     SSH config file backed up to :" | tee -a "$LOGFILE"
		echo -e " $SSHDFILE.$BTIME.bak" | tee -a "$LOGFILE"
        	echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
		printf "${nocolor}"
		sed -i "s/$SSHPORTWAS/Port $SSHPORT/" $SSHDFILE >> $LOGFILE 2>&1
		clear
			# Error Handling
			if [ $? -eq 0 ]
	        	then
	                printf "${lightgreen}"
			echo -e "---------------------------------------------------- "
			echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : SSH port set to $SSHPORT " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
			else
			printf "${lightred}"
			echo -e "---------------------------------------------------- "
	                echo -e " ERROR: SSH Port couldn't be changed. Check log file for details."
                	echo -e " `date +%m.%d.%Y_%H:%M:%S` : ERROR: SSH port couldn't be changed " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
			printf "${nocolor}"
			fi
			
# Set SSHPORTIS to the final value of the SSH port
SSHPORTIS=$(sed -n -e '/^Port /p' $SSHDFILE)
}

function prompt_rootlogin {
# Prompt use to permit or deny root login
ROOTLOGINP=$(sed -n -e '/^PermitRootLogin /p' $SSHDFILE)
printf "${lightcyan}"
figlet Root Login | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "-------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : CONFIGURE ROOT LOGIN " | tee -a "$LOGFILE"
echo -e "-------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${nocolor}"
if [ -n "${UNAME,,}" ]
then 
	if [ -z "$ROOTLOGINP" ]
        then ROOTLOGINP=$(sed -n -e '/^# PermitRootLogin /p' $SSHDFILE)
        else :
        fi
	printf "${lightcyan}"
	echo -e " If you have a non-root user, you can disable root login to prevent"
	echo -e " anyone from logging into your server remotely as root. This can"
	echo -e " improve security. Disable root login if you don't need it.\n"
	printf "${yellow}"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " Your root login settings are: " $ROOTLOGINP  | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${cyan}"
        read -p " Would you like to disable root login? y/n  " ROOTLOGIN
	printf "${nocolor}"
	while [ "${ROOTLOGIN,,}" != "yes" ] && [ "${ROOTLOGIN,,}" != "no" ] && [ "${ROOTLOGIN,,}" != "y" ] && [ "${ROOTLOGIN,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " ROOTLOGIN
	printf "${nocolor}"
	done		
	# check if ROOTLOGIN is valid
        if [ "${ROOTLOGIN,,}" = "yes" ] || [ "${ROOTLOGIN,,}" = "y" ]
        then :
		# search for root login and change to no
                sed -i "s/PermitRootLogin yes/PermitRootLogin no/" $SSHDFILE >> $LOGFILE
                sed -i "s/# PermitRootLogin yes/PermitRootLogin no/" $SSHDFILE >> $LOGFILE
                sed -i "s/# PermitRootLogin no/PermitRootLogin no/" $SSHDFILE >> $LOGFILE
	        # Error Handling
                if [ $? -eq 0 ]
                then
                	printf "${lightgreen}"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE" 
			echo -e " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : Root login disabled " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
                else
			printf "${lightred}"
                        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE" 
                        echo -e " `date +%m.%d.%Y_%H:%M:%S` : ERROR: Couldn't disable root login" | tee -a "$LOGFILE" 
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
                fi
        else  	printf "${yellow}"
		echo -e "------------------------------------------------------------- " | tee -a "$LOGFILE"
		echo "It looks like you want to enable root login; making it so..." | tee -a "$LOGFILE"
                sed -i "s/PermitRootLogin no/PermitRootLogin yes/" $SSHDFILE >> $LOGFILE 2>&1
                sed -i "s/# PermitRootLogin no/PermitRootLogin yes/" $SSHDFILE >> $LOGFILE 2>&1
                sed -i "s/# PermitRootLogin yes/PermitRootLogin yes/" $SSHDFILE >> $LOGFILE 2>&1
		echo -e "------------------------------------------------------------- " | tee -a "$LOGFILE"
		printf "${nocolor}"
        fi
	ROOTLOGINP=$(sed -n -e '/^PermitRootLogin /p' $SSHDFILE)
else 	printf "${yellow}"
	echo -e "---------------------------------------------------- "
	echo " Since you chose not to create a non-root user, "
     	echo " I did not disable root login for obvious reasons."
     	echo -e "---------------------------------------------------- \n"
	echo -e "----------------------------------------------------- " >> $LOGFILE 2>&1
	echo -e " Root login not changed; no non-root user was created " >> $LOGFILE 2>&1
	echo -e "----------------------------------------------------- \n" >> $LOGFILE 2>&1
	printf "${nocolor}"
fi
clear
printf "${yellow}"
echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " Your root login settings are:" $ROOTLOGINP | tee -a "$LOGFILE"
echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

function disable_passauth() {
# query user to disable password authentication or not

printf "${lightcyan}"
figlet Pass Auth | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "----------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : PASSWORD AUTHENTICATION " | tee -a "$LOGFILE"
echo -e "----------------------------------------------- \n"
printf "${lightcyan}"
	echo -e " You can log into your server using an RSA public-private key pair or"
	echo -e " a password.  Using RSA keys for login is tremendously more secure"
	echo -e " than just using a password. If you have installed an RSA key-pair"
	echo -e " and use that to login, you should disable password authentication.\n"
printf "${nocolor}"
PASSWDAUTH=$(sed -n -e '/.*PasswordAuthentication /p' $SSHDFILE)
if [ -n "/root/.ssh/authorized_keys" ]
then
        # PASSWDAUTH=$(sed -n -e '/PasswordAuthentication /p' $SSHDFILE)
        #       if [ -z "${PASSWDAUTH}" ]
        #       then PASSWDAUTH=$(sed -n -e '/^# PasswordAuthentication /p' $SSHDFILE)
        #       else :
        #       fi
        # Prompt user to see if they want to disable password login
	printf "${yellow}"
	# output to screen
	echo -e "     --------------------------------------------------- "
        echo -e "      Your current password authentication settings are   "
	echo -e "             ** $PASSWDAUTH ** " | tee -a "$LOGFILE"
	echo -e "     --------------------------------------------------- \n"
	# output to log
	echo -e "--------------------------------------------------- " >> $LOGFILE 2>&1
        echo -e " Your current password authentication settings are   " >> $LOGFILE 2>&1
	echo -e "      ** $PASSWDAUTH ** " >> $LOGFILE 2>&1
	echo -e "--------------------------------------------------- \n" >> $LOGFILE 2>&1
	printf "${cyan}"
        read -p " Would you like to disable password login & require RSA key login? y/n  " PASSLOGIN
	printf "${nocolor}"
	while [ "${PASSLOGIN,,}" != "yes" ] && [ "${PASSLOGIN,,}" != "no" ] && [ "${PASSLOGIN,,}" != "y" ] && [ "${PASSLOGIN,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " PASSLOGIN
	printf "${nocolor}"
	done
	echo -e "\n"	
        # check if PASSLOGIN is valid
        if [ "${PASSLOGIN,,}" = "yes" ] || [ "${PASSLOGIN,,}" = "y" ]
        then 	sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/" $SSHDFILE >> $LOGFILE
                # Error Handling
                if [ $? -eq 0 ]
                then
			printf "${lightgreen}"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : PassAuth set to NO " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
			printf "${nocolor}"
                else
			printf "${lightred}"
			echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                        echo " `date +%m.%d.%Y_%H:%M:%S` : ERROR: PasswordAuthentication couldn't be changed to no : " | tee -a "$LOGFILE"
			echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
			printf "${nocolor}"
                fi
        else 
		sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/" $SSHDFILE >> $LOGFILE
        fi
else	
	printf "${yellow}"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " With no RSA key; I can't disable PasswordAuthentication." | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${nocolor}"
fi
	PASSWDAUTH=$(sed -n -e '/PasswordAuthentication /p' $SSHDFILE)
	printf "${lightgreen}"
	echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : PASSWORD AUTHENTICATION COMPLETE " | tee -a "$LOGFILE"
	echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e "    Your PasswordAuthentication settings are now "  | tee -a "$LOGFILE"
	echo -e "        ** $PASSWDAUTH ** " | tee -a "$LOGFILE"
	echo -e "------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${nocolor}"
clear
printf "${lightgreen}"
echo -e "------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : SSH CONFIG COMPLETE " | tee -a "$LOGFILE"
echo -e "------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

################ 
## UFW CONFIG ##
################

function ufw_config() {
# query user to disable password authentication or not
printf "${lightcyan}"
figlet Firewall Config | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : FIREWALL CONFIGURATION " | tee -a "$LOGFILE"
echo -e "---------------------------------------------- \n"
	printf "${lightcyan}"
        echo -e " Uncomplicated Firewall (UFW) is a program for managing a"
        echo -e " netfilter firewall designed to be easy to use. We recommend"
        echo -e " that you activate this firewall and assign default rules"
        echo -e " to protect your server." 
        echo -e
        echo -e " * If you already configured UFW, choose NO to keep your existing rules\n"
	printf "${cyan}"
	read -p " Would you like to enable UFW firewall and assign basic rules? y/n  " FIREWALLP
        while [ "${FIREWALLP,,}" != "yes" ] && [ "${FIREWALLP,,}" != "no" ] && [ "${FIREWALLP,,}" != "y" ] && [ "${FIREWALLP,,}" != "n" ]; do
        echo -e "\n"
	printf "${lightred}"
        read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " FIREWALLP
	printf "${nocolor}"
        done
        echo -e "\n"
        if [ ${FIREWALLP,,} = "yes" ] || [ ${FIREWALLP,,} = "y" ]
        then	printf "${nocolor}"
                # make sure ufw is installed #
                apt-get install ufw -qqy >> $LOGFILE 2>&1
                # add firewall rules
		printf "${white}"
                echo -e "------------------------------------------- " | tee -a "$LOGFILE"
                echo " # ufw default allow outgoing"
                ufw default allow outgoing >> $LOGFILE 2>&1
                echo -e "------------------------------------------- " | tee -a "$LOGFILE"
                echo " # ufw default deny incoming"
                ufw default deny incoming >> $LOGFILE 2>&1
                echo -e "------------------------------------------- " | tee -a "$LOGFILE"
                echo -e " # ufw allow $SSHPORT" | tee -a "$LOGFILE"
                ufw allow $SSHPORT | tee -a "$LOGFILE"
                echo -e "------------------------- \n" | tee -a "$LOGFILE"
		printf "${nocolor}"
		sleep 1
                # wait until after SSHD is restarted to enable firewall to not break SSH
        else	printf "${yellow}"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo -e " ** User chose not to setup firewall at this time **"  | tee -a "$LOGFILE"
                echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
		printf "${nocolor}"
		sleep 1
        fi

clear
printf "${lightgreen}"
echo -e "------------------------------------------------ " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : FIREWALL CONFIG COMPLETE " | tee -a "$LOGFILE"
echo -e "------------------------------------------------ " | tee -a "$LOGFILE"
printf "${nocolor}"
}

################ 
## Hardening  ##
################

function server_hardening() {
# prompt users on whether to harden server or not
printf "${lightcyan}"
figlet Get Hard | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : QUERY TO HARDEN THE SERVER " | tee -a "$LOGFILE"
echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${lightcyan}"
echo -e " The next steps are to secure your server's shared memory, prevent"
echo -e " IP spoofing, enable DDOS protection, harden the networking layer, "
echo -e " and enable automatic installation of security updates."
echo -e "\n"
	printf "${cyan}"
	read -p " Would you like to perform these steps now? y/n  " GETHARD
	printf "${nocolor}"
	while [ "${GETHARD,,}" != "yes" ] && [ "${GETHARD,,}" != "no" ] && [ "${GETHARD,,}" != "y" ] && [ "${GETHARD,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " GETHARD
	printf "${nocolor}"
	done
	echo -e "\n"
        # check if GETHARD is valid
        if [ "${GETHARD,,}" = "yes" ] || [ "${GETHARD,,}" = "y" ]
        then
		
# secure shared memory
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : SECURING SHARED MEMORY " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
echo -e ' --> Adding line to bottom of file /etc/fstab'  | tee -a "$LOGFILE"
echo -e ' tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
sleep 2	; #  dramatic pause
# only add line if line does not already exist in /etc/fstab
if grep -q "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" /etc/fstab; then :
else echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' >> /etc/fstab
fi

# prevent IP spoofing
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : PREVENTING IP SPOOFING " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
echo -e " --> Updating /etc/host.conf to include 'nospoof' " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
sleep 2	; #  dramatic pause
cat etc/host.conf > /etc/host.conf

# enable DDOS protection
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : ENABLING DDOS PROTECTION " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
echo -e " Replace /etc/ufw/before.rules with hardened rules " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
sleep 2	; #  dramatic pause
cat etc/ufw/before.rules > /etc/ufw/before.rules

# harden the networking layer
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : HARDENING NETWORK LAYER " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
echo -e " --> Secure /etc/sysctl.conf with hardening rules " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
sleep 2	; #  dramatic pause
cat etc/sysctl.conf > /etc/sysctl.conf

# enable automatic security updates
printf "${yellow}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : ENABLING SECURITY UPDATES " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${white}"
echo -e " Configure system to auto install security updates " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
sleep 2	; #  dramatic pause
cat etc/apt/apt.conf.d/10periodic > /etc/apt/apt.conf.d/10periodic
cat etc/apt/apt.conf.d/50unattended-upgrades > /etc/apt/apt.conf.d/50unattended-upgrades
# consider editing the above 50-unattended-upgrades to automatically reboot when necessary

                # Error Handling
                if [ $? -eq 0 ]
                then 	echo -e " \n" ; clear
			printf "${green}"
			echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : Server Hardened" | tee -a "$LOGFILE"
			echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
                else	clear
			printf "${lightred}"
                        echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : ERROR: Hardening Failed" | tee -a "$LOGFILE"
			echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
			printf "${nocolor}"
		fi
		
        else :
	clear
	printf "${yellow}"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " *** User elected not to GET HARD at this time *** " | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
        fi
}

#####################
## Ksplice Install ##
#####################

function ksplice_install() {

# -------> I still need to install an error check after installing Ksplice to make sure \
#          the install completed before moving on the configuration

# prompt users on whether to install Oracle ksplice or not
# install created using https://tinyurl.com/y9klkx2j and https://tinyurl.com/y8fr4duq
# Official page: https://ksplice.oracle.com/uptrack/guide
printf "${lightcyan}"
figlet Ksplice Uptrack | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : INSTALL ORACLE KSPLICE " | tee -a "$LOGFILE"
echo -e "---------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${lightcyan}"
echo -e " Normally, kernel updates in Linux require a system reboot. Ksplice"
echo -e " Uptrack installs these patches in memory for Ubuntu and Fedora"
echo -e " Linux so reboots are not needed. It is free for non-commercial use."
echo -e " To minimize server downtime, this is a good thing to install."
echo -e "\n"
printf "${cyan}"
	read -p " Would you like to install Oracle Ksplice Uptrack now? y/n  " KSPLICE
	while [ "${KSPLICE,,}" != "yes" ] && [ "${KSPLICE,,}" != "no" ] && [ "${KSPLICE,,}" != "y" ] && [ "${KSPLICE,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " GETHARD
	printf "${nocolor}"
	done
	echo -e "\n"
        # check if KSPLICE is valid
        if [ "${KSPLICE,,}" = "yes" ] || [ "${KSPLICE,,}" = "y" ]
        then		
	# install ksplice uptrack
	printf "${yellow}"
	echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : INSTALLING KSPLICE PACKAGES " | tee -a "$LOGFILE"
	echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${white}"
	echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
	echo '   libgtk2-perl consolekit iproute libck-connector0 libcroco3 libglade2-0 ' | tee -a "$LOGFILE"
	echo '   libpam-ck-connector librsvg2-2 librsvg2-common python-cairo ' | tee -a "$LOGFILE"
	echo '   python-dbus python-gi python-glade2 python-gobject-2 ' | tee -a "$LOGFILE"
	echo '   python-gtk2 python-pycurl python-yaml dbus-x11' | tee -a "$LOGFILE"
	echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
	libgtk2-perl consolekit iproute libck-connector0 libcroco3 libglade2-0 \
	libpam-ck-connector librsvg2-2 librsvg2-common python-cairo \
	python-dbus python-gi python-glade2 python-gobject-2 \
	python-gtk2 python-pycurl python-yaml dbus-x11 | tee -a "$LOGFILE"
	printf "${yellow}"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " `date +%m.%d.%Y_%H:%M:%S` : KSPLICE PACKAGES INSTALLED" | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " --> Download & install Ksplice package from Oracle " | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
	wget -o /var/log/ksplicew1.log https://ksplice.oracle.com/uptrack/dist/xenial/ksplice-uptrack.deb
	dpkg --log "$LOGFILE" -i ksplice-uptrack.deb
		if [ -e /etc/uptrack/uptrack.conf ]
		then         
		printf "${lightgreen}"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e " `date +%m.%d.%Y_%H:%M:%S` : KSPLICE UPTRACK INSTALLED" | tee -a "$LOGFILE"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		printf "${yellow}"
		echo -e " ** Enabling autoinstall & correcting permissions ** " | tee -a "$LOGFILE"
		sed -i "s/autoinstall = no/autoinstall = yes/" /etc/uptrack/uptrack.conf
		chmod 755 /etc/cron.d/uptrack
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e " ** Activate & install Ksplice patches & updates ** " | tee -a "$LOGFILE"
		echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
		printf "${nocolor}"
		cat $LOGFILE /var/log/ksplicew1.log > /var/log/join.log
		cat /var/log/join.log > $LOGFILE
		rm /var/log/ksplicew1.log
		rm /var/log/join.log
		uptrack-upgrade -y | tee -a "$LOGFILE"
		printf "${lightgreen}"
		echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
		echo -e " `date +%m.%d.%Y_%H:%M:%S` : KSPLICE UPDATES INSTALLED" | tee -a "$LOGFILE"
		echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
		printf "${nocolor}"
		sleep 1	; #  dramatic pause
		clear
		printf "${lightgreen}"
		echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
		echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : Ksplice Enabled" | tee -a "$LOGFILE"
		echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
		printf "${nocolor}"
		else  	printf "${lightred}"
			clear
			echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : FAIL : Ksplice was not Installed" | tee -a "$LOGFILE"
                	echo -e "-------------------------------------------------------- \n" | tee -a "$LOGFILE"
			printf "${nocolor}"
		fi
	else :
	clear
	printf "${yellow}"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e "     ** User elected not to install Ksplice ** " | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${nocolor}"
        fi

# original steps I gathered
# sudo apt-get install libgtk2-perl consolekit iproute libck-connector0 libcroco3 libglade2-0 libpam-ck-connector librsvg2-2 librsvg2-common python-cairo python-dbus python-gi python-glade2 python-gobject-2 python-gtk2 python-pycurl python-yaml dbus-x11 -y
# sudo wget https://ksplice.oracle.com/uptrack/dist/xenial/ksplice-uptrack.deb
# sudo dpkg -i ksplice-uptrack.deb
# sudo sed -i "s/autoinstall = no/autoinstall = yes/" /etc/uptrack/uptrack.conf
# sudo chmod 755 /etc/cron.d/uptrack
# sudo uptrack-upgrade -y
}

###################
## MOTD Install  ##
###################

function motd_install() {
# prompt users to install custom MOTD or not
printf "${lightcyan}"
figlet Enhance MOTD | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : PROMPT USER TO INSTALL MOTD " | tee -a "$LOGFILE"
echo -e "--------------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${lightcyan}"
echo -e " The normal MOTD banner displayed after a successful SSH login"
echo -e " is pretty boring so this mod edits it to include more useful"
echo -e " information along with a login banner prohibiting unauthorized"
echo -e " access.  All modifications are strictly cosmetic."
echo -e "\n"
	printf "${cyan}"
	read -p " Would you like to enhance your MOTD & login banner? y/n  " MOTDP
	printf "${nocolor}"
	while [ "${MOTDP,,}" != "yes" ] && [ "${MOTDP,,}" != "no" ] && [ "${MOTDP,,}" != "y" ] && [ "${MOTDP,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " MOTDP
	printf "${nocolor}"
	done
	echo -e "\n"
        # check if MOTDP is affirmative
        if [ "${MOTDP,,}" = "yes" ] || [ "${MOTDP,,}" = "y" ]
        then
		sudo apt-get -o Acquire::ForceIPv4=true update -y
		sudo apt-get -o Acquire::ForceIPv4=true install lsb-release update-motd curl -y
		rm -r /etc/update-motd.d/
		mkdir /etc/update-motd.d/
		touch /etc/update-motd.d/00-header ; touch /etc/update-motd.d/10-sysinfo ; touch /etc/update-motd.d/90-footer ; touch /etc/update-motd.d/99-esm
		chmod +x /etc/update-motd.d/*
		cat etc/update-motd.d/00-header > /etc/update-motd.d/00-header
		cat etc/update-motd.d/10-sysinfo > /etc/update-motd.d/10-sysinfo
		cat etc/update-motd.d/90-footer > /etc/update-motd.d/90-footer
		cat etc/update-motd.d/99-esm > /etc/update-motd.d/99-esm
		sed -i 's,#Banner /etc/issue.net,Banner /etc/issue.net,' /etc/ssh/sshd_config
		cat etc/issue.net > /etc/issue.net
		clear	
		# Error Handling
                if [ $? -eq 0 ]
                then printf "${lightgreen}"
				echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
				echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : MOTD & Banner updated" | tee -a "$LOGFILE"
				echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
				printf "${nocolor}"
                else printf "${lightred}"
			echo -e "----------------------------------------------- " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : ERROR: MOTD not updated" | tee -a "$LOGFILE"
                	echo -e "----------------------------------------------- \n" | tee -a "$LOGFILE"
		fi
		
        else echo -e "\n"
	clear
	printf "${yellow}"
	echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " *** User elected not to customize MOTD & banner *** " | tee -a "$LOGFILE"
	echo -e "----------------------------------------------------- \n" | tee -a "$LOGFILE"
	printf "${nocolor}"
        fi
}

##################
## Restart SSHD ##
##################

function restart_sshd() {
# prompt users to leave this session open, then create a second connection after restarting SSHD to make sure they can connect
printf "${lightcyan}"
figlet Restart SSH | tee -a "$LOGFILE"
printf "${yellow}"
echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " `date +%m.%d.%Y_%H:%M:%S` : PROMPT USER TO RESTART SSH " | tee -a "$LOGFILE"
echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
printf "${lightcyan}"
echo " Changes to login security will not take effect until SSHD restarts"
echo " and firewall is enabled. You should keep this existing connection"
echo " open while restarting SSHD just in case you have a problem or"
echo " copied down the information incorrectly. This will prevent you"
echo " from getting locked out of your server."
echo -e "\n"
	printf "${cyan}"
	read -p " Would you like to restart SSHD and enable UFW now? y/n  " SSHDRESTART
	printf "${nocolor}"
	while [ "${SSHDRESTART,,}" != "yes" ] && [ "${SSHDRESTART,,}" != "no" ] && [ "${SSHDRESTART,,}" != "y" ] && [ "${SSHDRESTART,,}" != "n" ]; do
	echo -e "\n"
	printf "${lightred}"
	read -p " --> I don't understand. Enter 'y' for yes or 'n' for no: " SSHDRESTART
	printf "${nocolor}"
	done
	echo -e "\n"
        # check if SSHDRESTART is valid
        if [ "${SSHDRESTART,,}" = "yes" ] || [ "${SSHDRESTART,,}" = "y" ]
        then
                # insert a pause or delay to add suspense
		systemctl restart sshd
			if [ $FIREWALLP = "yes" ] || [ $FIREWALLP = "y" ]
			then ufw --force enable | tee -a "$LOGFILE"
			echo -e " \n" | tee -a "$LOGFILE"
			else :
			fi			
		# Error Handling
                if [ $? -eq 0 ]
                then 	printf "${lightgreen}"
			echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : SSHD restart complete" | tee -a "$LOGFILE"
			echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"	
			printf "${nocolor}"
			if [ $FIREWALLP = "yes" ] || [ $FIREWALLP = "y" ]
			printf "${lightgreen}"
			then echo " `date +%m.%d.%Y_%H:%M:%S` : SUCCESS : UFW firewall enabled" | tee -a "$LOGFILE"
			echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"	
			printf "${nocolor}"
			else :
			fi
                else
                        printf "${lightred}"
			echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
			echo " `date +%m.%d.%Y_%H:%M:%S` : ERROR: SSHD could not restart" | tee -a "$LOGFILE"
			echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
                fi
		
        else echo -e "\n"
	printf "$yellow"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	echo -e " *** User elected not to restart SSH at this time *** " | tee -a "$LOGFILE"
	echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
	printf "${nocolor}"
        fi
}

######################
## Install Complete ##
######################

function install_complete() {
# Display important login variables before exiting script
clear
printf "${lightcyan}"
figlet Install Complete -f small | tee -a "$LOGFILE"
printf "${lightgreen}"
echo -e "---------------------------------------------------- " >> $LOGFILE 2>&1
echo -e " `date +%m.%d.%Y_%H:%M:%S` : YOUR SERVER IS NOW SECURE " >> $LOGFILE 2>&1
printf "${lightpurple}"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e "  * * * Save these important login variables! * * *  " | tee -a "$LOGFILE"
echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${yellow}"
echo -e " --> Your SSH port for remote access is" $SSHPORTIS	| tee -a "$LOGFILE"
echo -e " --> Root login settings are:" $ROOTLOGINP | tee -a "$LOGFILE"
	printf "${white}"
	if [ -n "${UNAME,,}" ] 
	then echo -e " We created a non-root user named (lower case):" ${UNAME,,} | tee -a "$LOGFILE" 
	else echo -e " A new user was not created during the setup process" | tee -a "$LOGFILE" 
	fi
	printf "${nocolor}"
printf "${white}"
echo " PasswordAuthentication settings:" $PASSWDAUTH | tee -a "$LOGFILE"
	printf "${lightcyan}"
	if [ ${FIREWALLP,,} = "yes" ] || [ ${FIREWALLP,,} = "y" ]
	then echo -e " --> UFW was installed and basic firewall rules were added" | tee -a "$LOGFILE" 
	else echo -e " --> UFW was not installed or configured" | tee -a "$LOGFILE" 
	fi
		# if [ "${GETHARD,,}" = "yes" ] || [ "${GETHARD,,}" = "y" ]
		# then echo -e " --> The server and networking layer were hardened <--" | tee -a "$LOGFILE" 
		# else echo -e " --> The server and networking layer were NOT hardened" | tee -a "$LOGFILE" 
		# fi
			printf "${lightcyan}"
			if [ "${KSPLICE,,}" = "yes" ] || [ "${KSPLICE,,}" = "y" ]
			then echo -e " You installed Oracle's Ksplice to update without reboot" | tee -a "$LOGFILE"
			else echo -e " You chose NOT to auto-update OS with Oracle's Ksplice" | tee -a "$LOGFILE"
			fi
printf "${yellow}"
echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"	
echo -e " Installation log saved to" $LOGFILE | tee -a "$LOGFILE"
echo -e " Before modification, your SSH config was backed up to" | tee -a "$LOGFILE"
echo -e " --> $SSHDFILE.$BTIME.bak"				| tee -a "$LOGFILE"
printf "${lightred}"
echo -e " ---------------------------------------------------- " | tee -a "$LOGFILE"
echo -e " | NOTE: Please create a new connection to test SSH | " | tee -a "$LOGFILE"
echo -e " |       settings before you close this session     | " | tee -a "$LOGFILE"
echo -e " ---------------------------------------------------- " | tee -a "$LOGFILE"
printf "${nocolor}"
}

function display_banner() {

echo -e "${lightcyan}"
cat << "EOF"
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     _    _  __                     _         ____ _   ___   __
    / \  | |/ /___ _ __ _   _ _ __ | |_ ___  / ___| | | \ \ / /
   / _ \ | ' // __| '__| | | | '_ \| __/ _ \| |  _| | | |\ V /
  / ___ \| . \ (__| |  | |_| | |_) | || (_) | |_| | |_| | | |
 /_/   \_\_|\_\___|_|   \__, | .__/ \__\___/ \____|\___/  |_|
                        |___/|_|
            __  __             __  __  ___          __
  -->  \  /|__)/__`   |__| /\ |__)|  \|__ |\ |||\ |/ _`  <--
        \/ |   .__/   |  |/~~\|  \|__/|___| \||| \|\__>
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
EOF
echo -e "${nocolor}"
}

setup_environment
display_banner
begin_log
create_swap
update_upgrade
favored_packages
crypto_packages
add_user
collect_sshd
prompt_rootlogin
disable_passauth
ufw_config
server_hardening
ksplice_install
motd_install
restart_sshd
install_complete

exit
