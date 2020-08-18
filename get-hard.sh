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
# 9. GOOGLE AUTH / enable 2fa using Google Authenticator
# 10. KSPLICE INSTALL / automatically update without reboot
# 11. MOTD EDIT / replace boring banner with customized one
# 12. RESTART SSHD / apply settings by restarting systemctl
# 13. INSTALL COMPLETE / display new SSH and login info

# Add to log command and display output on screen
# echo " $(date +%m.%d.%Y_%H:%M:%S) : $MESSAGE" | tee -a "$LOGFILE"
# Add to log command and do not display output on screen
# echo " $(date +%m.%d.%Y_%H:%M:%S) : $MESSAGE" >> $LOGFILE 2>&1

# write to log only, no output on screen # echo  -e "---------------------------------------------------- " >> $LOGFILE 2>&1
# write to log only, no output on screen # echo  -e "    ** This entry gets written to the log file directly. **" >> $LOGFILE 2>&1
# write to log only, no output on screen # echo  -e "---------------------------------------------------- \n" >> $LOGFILE 2>&1

function setup_environment() {
    ### define colors ###
    lightred=$'\033[1;31m'  # light red
    red=$'\033[0;31m'  # red
    lightgreen=$'\033[1;32m'  # light green
    green=$'\033[0;32m'  # green
    lightblue=$'\033[1;34m'  # light blue
    blue=$'\033[0;34m'  # blue
    lightpurple=$'\033[1;35m'  # light purple
    purple=$'\033[0;35m'  # purple
    lightcyan=$'\033[1;36m'  # light cyan
    cyan=$'\033[0;36m'  # cyan
    lightgray=$'\033[0;37m'  # light gray
    white=$'\033[1;37m'  # white
    brown=$'\033[0;33m'  # brown
    yellow=$'\033[1;33m'  # yellow
    darkgray=$'\033[1;30m'  # dark gray
    black=$'\033[0;30m'  # black
    nocolor=$'\e[0m' # no color

    echo -e -n "${lightred}"
    echo -e -n "${red}"
    echo -e -n "${lightgreen}"
    echo -e -n "${green}"
    echo -e -n "${lightblue}"
    echo -e -n "${blue}"
    echo -e -n "${lightpurple}"
    echo -e -n "${purple}"
    echo -e -n "${lightcyan}"
    echo -e -n "${cyan}"
    echo -e -n "${lightgray}"
    echo -e -n "${white}"
    echo -e -n "${brown}"
    echo -e -n "${yellow}"
    echo -e -n "${darkgray}"
    echo -e -n "${black}"
    echo -e -n "${nocolor}"
    clear

    # Set Vars
    LOGFILE='/var/log/server_hardening.log'
    SSHDFILE='/etc/ssh/sshd_config'
}

function check_distro() {
    # currently only for Ubuntu 16.04
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        if [[ "${VERSION_ID}" != "16.04" ]] ; then
            echo -e "\nThis script works the very best with Ubuntu 16.04 LTS."
            echo -e "Some elements of this script won't work correctly on other releases.\n"
        fi
    else
        # no, thats not ok!
        echo -e "This script only supports Ubuntu 16.04, exiting.\n"
        exit 1
    fi
}

function begin_log() {
    # Create Log File and Begin
    echo -e -n "${lightcyan}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SCRIPT STARTED SUCCESSFULLY " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e "------- AKcryptoGUY's VPS Hardening Script --------- " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    sleep 2
}

#########################
## CHECK & CREATE SWAP ##
#########################

function create_swap() {
    # Check for and create swap file if necessary
    # this is an alternative that will disable swap, and create a new one at the size you like
    # sudo swapoff -a && sudo dd if=/dev/zero of=/swapfile bs=1M count=6144 MB && sudo mkswap /swapfile && sudo swapon /swapfile
    echo -e -n "${yellow}"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : CHECK FOR AND CREATE SWAP " | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${white}"

    # Check for swap file - if none, create one
    if free | awk '/^Swap:/ {exit !$2}'; then
        echo -e -n "${lightred}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : Swap exists- No changes made " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n"  | tee -a "$LOGFILE"
        sleep 2
        echo -e -n "${nocolor}"
    else
        # set swap to twice the physical RAM but not less than 2GB
        PHYSRAM=$(grep MemTotal /proc/meminfo | awk '{print int($2 / 1024 / 1024 + 0.5)}')
        let "SWAPSIZE=2*$PHYSRAM"
        (($SWAPSIZE >= 1 && $SWAPSIZE >= 31)) && SWAPSIZE=31
        (($SWAPSIZE <= 2)) && SWAPSIZE=2

        fallocate -l ${SWAPSIZE}G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && cp /etc/fstab /etc/fstab.bak && echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
        echo -e -n "${lightgreen}"
        echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SWAP CREATED SUCCESSFULLY " | tee -a "$LOGFILE"
        echo -e "--> Thanks @Cryptotron for supplying swap code <-- "
        echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
        sleep 2
        echo -e -n "${nocolor}"
    fi
}

######################
## UPDATE & UPGRADE ##
######################

function update_upgrade() {

    # NOTE I learned the hard way that you must put a "\" BEFORE characters "\" and "`"
    echo -e -n "${lightcyan}"
    printf "  ___  ____    _   _           _       _ \n" | tee -a "$LOGFILE"
    printf " / _ \/ ___|  | | | |_ __   __| | __ _| |_ ___ \n" | tee -a "$LOGFILE"
    printf "| | | \\___ \\  | | | | '_ \\ / _\` |/ _\` | __/ _ \\ \n" | tee -a "$LOGFILE"
    printf "| |_| |___) | | |_| | |_) | (_| | (_| | ||  __/ \n" | tee -a "$LOGFILE"
    printf " \___/|____/   \___/| .__/ \__,_|\__,_|\__\___| \n" | tee -a "$LOGFILE"
    printf "                    |_| \n"
    echo -e -n "${yellow}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INITIATING SYSTEM UPDATE " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${white}"
    # remove grub to prevent interactive user prompt: https://tinyurl.com/y9pu7j5s
    echo '# export DEBIAN_FRONTEND=noninteractive' | tee -a "$LOGFILE"
    export DEBIAN_FRONTEND=noninteractive
    echo '# rm /boot/grub/menu.lst     (prevent update issue)' | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    rm /boot/grub/menu.lst
    echo '# update-grub-legacy-ec2 -y  (prevent update issue)' | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    update-grub-legacy-ec2 -y | tee -a "$LOGFILE"
    echo -e -n "${white}"
    echo '# apt-get -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true update' | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    apt-get -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true update | tee -a "$LOGFILE"
    echo -e -n "${white}"
    echo -e "----------------------------------------------------------------------------- " | tee -a "$LOGFILE"
    echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install figlet' | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install figlet | tee -a "$LOGFILE"
    echo -e -n "${lightgreen}"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SYSTEM UPDATED SUCCESSFULLY " | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"

    echo -e -n "${cyan}"
    figlet System Upgrade | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INITIATING SYSTEM UPGRADE " | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${white}"
    echo ' # apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y' | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y | tee -a "$LOGFILE"
    echo -e -n "${lightgreen}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SYSTEM UPGRADED SUCCESSFULLY " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

#
#  PROMPT WHETHER USER WANTS TO INSTALL FAVORED PACKAGES OR ALSO ADD THEIR OWN CUSTOM PACKAGES
#

function favored_packages() {
    # install my favorite and commonly used packages
    echo -e -n "${lightcyan}"
    figlet Install Favored | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INSTALLING FAVORED PACKAGES " | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${white}"
    echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
    echo '   htop nethogs ufw fail2ban wondershaper glances ntp figlet lsb-release ' | tee -a "$LOGFILE"
    echo '   update-motd unattended-upgrades secure-delete net-tools dnsutils' | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
        htop nethogs ufw fail2ban wondershaper glances ntp figlet lsb-release \
        update-motd unattended-upgrades secure-delete net-tools dnsutils | tee -a "$LOGFILE"
    echo -e -n "${lightgreen}"
    echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : FAVORED INSTALLED SUCCESFULLY " | tee -a "$LOGFILE"
    echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

#  PROMPT WHETHER USER WANTS TO INSTALL COMMON CRYPTO PACKAGES OR NOT

#####################
## CRYPTO PACKAGES ##
#####################
function crypto_packages() {
    echo -e -n "${lightcyan}"
    figlet Crypto Setup | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : QUERY TO INSTALL CRYPTO PKGS " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- \n"
    echo -e -n "${lightcyan}"
    echo " I frequently use Ubuntu Virtual Machines for cryptocurrency projects"
    echo " to compile or build wallets from source code but I realize that there"
    echo " are plenty of other reasons to use them. If using the VPS for crypto,"
    echo " installing these packages now can save you some time later. "
    echo -e "\n"

        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to install these crypto packages now? y/n  " INSTALLCRYPTO
            if [[ ${INSTALLCRYPTO,,} == "y" || ${INSTALLCRYPTO,,} == "Y" || ${INSTALLCRYPTO,,} == "N" || ${INSTALLCRYPTO,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}"

    # check if INSTALLCRYPTO is valid
    if [ "${INSTALLCRYPTO,,}" = "Y" ] || [ "${INSTALLCRYPTO,,}" = "y" ]
    then echo -e "\n"
        echo -e -n "${yellow}"
        echo -e " Great; let's install them now... \n"
        echo -e -n "${lightcyan}"
        figlet Install Crypto | tee -a "$LOGFILE"
        echo -e -n "${yellow}"
        echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INSTALLING CRYPTO PACKAGES " | tee -a "$LOGFILE"
        echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo ' # add-apt-repository -yu ppa:bitcoin/bitcoin' | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
        add-apt-repository -yu ppa:bitcoin/bitcoin | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo -e "---------------------------------------------------------------------- " | tee -a "$LOGFILE"
        echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
        echo '   build-essential g++ protobuf-compiler libboost-all-dev autotools-dev ' | tee -a "$LOGFILE"
        echo '   automake libcurl4-openssl-dev libboost-all-dev libssl-dev libdb++-dev ' | tee -a "$LOGFILE"
        echo '   make autoconf automake libtool git apt-utils libprotobuf-dev pkg-config ' | tee -a "$LOGFILE"
        echo '   libcurl3-dev libudev-dev libqrencode-dev bsdmainutils pkg-config libssl-dev ' | tee -a "$LOGFILE"
        echo '   libgmp3-dev libevent-dev jp2a pv virtualenv lsb-release update-motd ' | tee -a "$LOGFILE"
        echo -e "----------------------------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${lightred}"
        echo -e " This step can appear to hang for a minute or two so don't be alarmed "
        echo -e "---------------------------------------------------------------------- "
        echo -e -n "${nocolor}"
        apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
            build-essential g++ protobuf-compiler libboost-all-dev autotools-dev \
            automake libcurl4-openssl-dev libboost-all-dev libssl-dev libdb++-dev \
            make autoconf automake libtool git apt-utils libprotobuf-dev pkg-config \
            libcurl3-dev libudev-dev libqrencode-dev bsdmainutils pkg-config libssl-dev \
            libgmp3-dev libevent-dev jp2a pv virtualenv lsb-release update-motd  | tee -a "$LOGFILE"
			
        # need more testing to see if autoremove breaks the script or not
        # apt autoremove -y | tee -a "$LOGFILE"
        clear
        echo -e -n "${lightgreen}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : CRYPTO INSTALLED SUCCESFULLY " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    else 	echo -e -n "${yellow}"
        clear
        echo  -e "----------------------------------------------------- " >> $LOGFILE 2>&1
        echo  "    ** User chose not to install crypto packages **" >> $LOGFILE 2>&1
        echo  -e "-----------------------------------------------------" >> $LOGFILE 2>&1
    fi
    echo -e -n "${lightgreen}"
    echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : CRYPTO PACKAGE SETUP COMPLETE " | tee -a "$LOGFILE"
    echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

################
## USER SETUP ##
################

function add_user() {
    # query user to setup a non-root user account or not
    echo -e -n "${lightcyan}"
    figlet User Setup | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : QUERY TO CREATE NON-ROOT USER " | tee -a "$LOGFILE"
    echo -e "----------------------------------------------------- \n"
    echo -e -n "${lightcyan}"
    echo " Conventional wisdom would encourage you to disable root login over SSH"
    echo " because it makes accessing your server more difficult if you use password"
    echo " authentication. Since using RSA public-private key authentication is"
    echo " infinitely more secure, I will not think less of you if you choose to"
    echo " use an RSA key and continue to login as root. I am able to create a "
    echo -e " non-root user if you want me to, but it is not required. \n"
    
            echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to add a non-root user? y/n  " ADDUSER
            if [[ ${ADDUSER,,} == "y" || ${ADDUSER,,} == "Y" || ${ADDUSER,,} == "N" || ${ADDUSER,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}"

    # check if ADDUSER is valid
    if [ "${ADDUSER,,}" = "Y" ] || [ "${ADDUSER,,}" = "y" ]
    then echo -e "\n"
        echo -e -n "${yellow}"
        echo -e " Great; let's set one up now... \n"
        echo -e -n "${cyan}"
        read -p " Enter New Username: " UNAME
        while [[ "$UNAME" =~ [^0-9A-Za-z]+ ]] || [ -z "$UNAME" ]; do echo -e "\n"
            echo -e -n "${lightred}"
            read -p " --> Please enter a username that contains only letters or numbers: " UNAME
            echo -e -n "${nocolor}"
        done
        echo -e "\n"
        echo -e -n "${yellow}"
        echo  -e " User elected to create a new user named ${UNAME,,}. \n" >> $LOGFILE 2>&1
        echo -e -n "${cyan}"
        id -u "${UNAME,,}" >> $LOGFILE > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            clear
            echo -e -n "${yellow}"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SKIPPING : User Already Exists " | tee -a "$LOGFILE"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        else
            echo -e -n "${cyan}"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
            adduser --gecos "" "${UNAME,,}" | tee -a "$LOGFILE"
            usermod -aG sudo "${UNAME,,}" | tee -a "$LOGFILE"
            echo -e -n "${lightgreen}"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : '${UNAME,,}' added to SUDO group" | tee -a "$LOGFILE"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            # copy SSH keys if they exist
            if [ -e /root/.ssh/authorized_keys ]
            then mkdir /home/"${UNAME,,}"/.ssh
                chmod 700 /home/"${UNAME,,}"/.ssh
                # copy root SSH key to new non-root user
                cp /root/.ssh/authorized_keys /home/"${UNAME,,}"/.ssh
                # fix permissions on RSA key
                chmod 400 /home/"${UNAME,,}"/.ssh/authorized_keys
                chown "${UNAME,,}":"${UNAME,,}" /home/"${UNAME,,}" -R
                echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : SSH keys were copied to ${UNAME,,}'s profile" | tee -a "$LOGFILE"
            else echo -e -n "${yellow}"
                echo " $(date +%m.%d.%Y_%H:%M:%S) : RSA keys not present for root, so none were copied." | tee -a "$LOGFILE"
            fi
            clear
        fi
    else 	echo -e -n "${yellow}"
        clear
        echo  -e "----------------------------------------------------- " >> $LOGFILE 2>&1
        echo  "    ** User chose not to create a new user **" >> $LOGFILE 2>&1
        echo  -e "-----------------------------------------------------" >> $LOGFILE 2>&1
    fi
    echo -e -n "${lightgreen}"
    echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : USER SETUP IS COMPLETE " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

################
## SSH CONFIG ##
################

function collect_sshd() {
    # Prompt for custom SSH port between 11000 and 65535
    echo -e -n "${lightcyan}"
    figlet SSH Config | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    SSHPORTWAS=$(sed -n -e '/Port /p' $SSHDFILE)
    echo -e -n "${yellow}"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : CONFIGURE SSH SETTINGS " | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " --> Your current SSH port number is ${SSHPORTWAS} <-- " | tee -a "$LOGFILE"
    echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    echo -e -n "${lightcyan}"
    echo -e " By default, SSH traffic occurs on port 22, so hackers are always"
    echo -e " scanning port 22 for vulnerabilities. If you change your server to"
    echo -e " use a different port, you gain some security through obscurity.\n"
    while :; do
        echo -e -n "${cyan}"
        read -p " Enter a custom port for SSH between 11000 and 65535 or use 22: " SSHPORT
        [[ $SSHPORT =~ ^[0-9]+$ ]] || { echo -e -n "${lightred}";echo -e " --> Try harder, that's not even a number. \n";echo -e -n "${nocolor}";continue; }
        if (($SSHPORT >= 11000 && $SSHPORT <= 65535)); then break
        elif [ "$SSHPORT" = 22 ]; then break
        else echo -e -n "${lightred}"
            echo -e " --> That number is out of range, try again. \n"
            echo "---------------------------------------------------- " >> $LOGFILE 2>&1
            echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: User entered: $SSHPORT " >> $LOGFILE 2>&1
            echo "---------------------------------------------------- " >> $LOGFILE 2>&1
            echo -e -n "${nocolor}"
        fi
    done
    # Take a backup of the existing config
    BTIME=$(date +%F_%R)
    cat $SSHDFILE > $SSHDFILE."$BTIME".bak
    echo -e "\n"
    echo -e -n "${yellow}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e "     SSH config file backed up to :" | tee -a "$LOGFILE"
    echo -e " $SSHDFILE.$BTIME.bak" | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"

    # create jail.local and replace 'ssh' with custom port or 22
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sed -i "s/port.*= ssh/port     = $SSHPORT/" /etc/fail2ban/jail.local

    sed -i "s/$SSHPORTWAS/Port $SSHPORT/" $SSHDFILE >> $LOGFILE 2>&1
    clear
    # Error Handling
    if [ $? -eq 0 ]
    then
        echo -e -n "${lightgreen}"
        echo -e "---------------------------------------------------- "
        echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : SSH port set to $SSHPORT " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    else
        echo -e -n "${lightred}"
        echo -e "---------------------------------------------------- "
        echo -e " ERROR: SSH Port couldn't be changed. Check log file for details."
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: SSH port couldn't be changed " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi

    # Set SSHPORTIS to the final value of the SSH port
    SSHPORTIS=$(sed -n -e '/^Port /p' $SSHDFILE)
}

function prompt_rootlogin {
    # Prompt use to permit or deny root login
    ROOTLOGINP=$(sed -n -e '/^PermitRootLogin /p' $SSHDFILE)
    echo -e -n "${lightcyan}"
    figlet Root Login | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "-------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : CONFIGURE ROOT LOGIN " | tee -a "$LOGFILE"
    echo -e "-------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    if [ -n "${UNAME,,}" ]
    then
        if [ -z "$ROOTLOGINP" ]
        then ROOTLOGINP=$(sed -n -e '/^# PermitRootLogin /p' $SSHDFILE)
        else :
        fi
        echo -e -n "${lightcyan}"
        echo -e " If you have a non-root user, you can disable root login to prevent"
        echo -e " anyone from logging into your server remotely as root. This can"
        echo -e " improve security. Disable root login if you don't need it.\n"
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " Your root login settings are: " "$ROOTLOGINP"  | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        
            echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to disable root login? y/n  " ROOTLOGIN
            if [[ ${ROOTLOGIN,,} == "y" || ${ROOTLOGIN,,} == "Y" || ${ROOTLOGIN,,} == "N" || ${ROOTLOGIN,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}"
        
        # check if ROOTLOGIN is valid
        if [ "${ROOTLOGIN,,}" = "Y" ] || [ "${ROOTLOGIN,,}" = "y" ]
        then :
            # search for root login and change to no
            sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/" $SSHDFILE >> $LOGFILE
            # Error Handling
            if [ $? -eq 0 ]
            then
                echo -e -n "${lightgreen}"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : Root login disabled " | tee -a "$LOGFILE"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo -e -n "${nocolor}"
            else
                echo -e -n "${lightred}"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo -e " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: Couldn't disable root login" | tee -a "$LOGFILE"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo -e -n "${nocolor}"
            fi
        else  	echo -e -n "${yellow}"
            echo -e "------------------------------------------------------------- " | tee -a "$LOGFILE"
            echo "It looks like you want to enable root login; making it so..." | tee -a "$LOGFILE"
            sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/" $SSHDFILE >> $LOGFILE 2>&1
            echo -e "------------------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        fi
        ROOTLOGINP=$(sed -n -e '/^PermitRootLogin /p' $SSHDFILE)
    else 	echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- "
        echo " Since you chose not to create a non-root user, "
        echo " I did not disable root login for obvious reasons."
        echo -e "---------------------------------------------------- \n"
        echo -e "----------------------------------------------------- " >> $LOGFILE 2>&1
        echo -e " Root login not changed; no non-root user was created " >> $LOGFILE 2>&1
        echo -e "----------------------------------------------------- \n" >> $LOGFILE 2>&1
        echo -e -n "${nocolor}"
    fi
    clear
    echo -e -n "${yellow}"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " Your root login settings are:" "$ROOTLOGINP" | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

function disable_passauth() {
    # query user to disable password authentication or not

    echo -e -n "${lightcyan}"
    figlet Pass Auth | tee -a "$LOGFILE"
    echo -e "${yellow}"
    echo -e "----------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : PASSWORD AUTHENTICATION " | tee -a "$LOGFILE"
    echo -e "----------------------------------------------- \n"
    echo -e "${lightcyan}"
    echo -e " You can log into your server using an RSA public-private key pair or"
    echo -e " a password.  Using RSA keys for login is tremendously more secure"
    echo -e " than just using a password. If you have installed an RSA key-pair"
    echo -e " and use that to login, you should disable password authentication.\n"
    echo -e "${nocolor}"
    PASSWDAUTH=$(sed -n -e '/.*PasswordAuthentication /p' $SSHDFILE)
    if [ -n "/root/.ssh/authorized_keys" ]
    then
        # PASSWDAUTH=$(sed -n -e '/PasswordAuthentication /p' $SSHDFILE)
        #       if [ -z "${PASSWDAUTH}" ]
        #       then PASSWDAUTH=$(sed -n -e '/^# PasswordAuthentication /p' $SSHDFILE)
        #       else :
        #       fi
        # Prompt user to see if they want to disable password login
        echo -e -n "${yellow}"
        # output to screen
        echo -e "     --------------------------------------------------- "
        echo -e "      Your current password authentication settings are   "
        echo -e "             ** $PASSWDAUTH ** " | tee -a "$LOGFILE"
        echo -e "     --------------------------------------------------- \n"
        # output to log
        echo -e "--------------------------------------------------- " >> $LOGFILE 2>&1
        echo -e " Your current password authentication settings are   " >> $LOGFILE 2>&1
        echo -e "      ** $PASSWDAUTH ** " >> $LOGFILE 2>&1
        echo -e "--------------------------------------------------- " >> $LOGFILE 2>&1
        
        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to disable password login & require RSA key login? y/n  " PASSLOGIN
            if [[ ${PASSLOGIN,,} == "y" || ${PASSLOGIN,,} == "Y" || ${PASSLOGIN,,} == "N" || ${PASSLOGIN,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n"
        
        # check if PASSLOGIN is valid
        if [ "${PASSLOGIN,,}" = "Y" ] || [ "${PASSLOGIN,,}" = "y" ]
        then
            sed -i "s/PasswordAuthentication .*/PasswordAuthentication no/" $SSHDFILE >> $LOGFILE
            sed -i "s/#PasswordAuthentication .*/PasswordAuthentication no/" $SSHDFILE >> $LOGFILE
            sed -i "s/# PasswordAuthentication .*/PasswordAuthentication no/" $SSHDFILE >> $LOGFILE

            # Error Handling
            if [ $? -eq 0 ]
            then
                echo -e -n "${lightgreen}"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : PassAuth set to NO " | tee -a "$LOGFILE"
                echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
                echo -e -n "${nocolor}"
            else
                echo -e -n "${lightred}"
                echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
                echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: PasswordAuthentication couldn't be changed to no : " | tee -a "$LOGFILE"
                echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
                echo -e -n "${nocolor}"
            fi
        else
            sed -i "s/PasswordAuthentication .*/PasswordAuthentication yes/" $SSHDFILE >> $LOGFILE
            sed -i "s/#PasswordAuthentication .*/PasswordAuthentication yes/" $SSHDFILE >> $LOGFILE
            sed -i "s/# PasswordAuthentication .*/PasswordAuthentication yes/" $SSHDFILE >> $LOGFILE
        fi
    else
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " With no RSA key; I can't disable PasswordAuthentication." | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi
    PASSWDAUTH=$(sed -n -e '/PasswordAuthentication /p' $SSHDFILE)
    echo -e -n "${lightgreen}"
    echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : PASSWORD AUTHENTICATION COMPLETE " | tee -a "$LOGFILE"
    echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e "    Your PasswordAuthentication settings are now "  | tee -a "$LOGFILE"
    echo -e "        ** $PASSWDAUTH ** " | tee -a "$LOGFILE"
    echo -e "------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
    clear
    echo -e -n "${lightgreen}"
    echo -e "------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SSH CONFIG COMPLETE " | tee -a "$LOGFILE"
    echo -e "------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

################
## UFW CONFIG ##
################

function ufw_config() {
    # query user to disable password authentication or not
    echo -e -n "${lightcyan}"
    figlet Firewall Config | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : FIREWALL CONFIGURATION " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------- \n"
    echo -e -n "${lightcyan}"
    echo -e " Uncomplicated Firewall (UFW) is a program for managing a"
    echo -e " netfilter firewall designed to be easy to use. We recommend"
    echo -e " that you activate this firewall and assign default rules"
    echo -e " to protect your server."
    echo -e
    echo -e " * If you already configured UFW, choose NO to keep your existing rules\n"
    
        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to enable UFW firewall and assign basic rules? y/n  " FIREWALLP
            if [[ ${FIREWALLP,,} == "y" || ${FIREWALLP,,} == "Y" || ${FIREWALLP,,} == "N" || ${FIREWALLP,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n"
    
    if [ "${FIREWALLP,,}" = "Y" ] || [ "${FIREWALLP,,}" = "y" ]
    then	echo -e -n "${nocolor}"
        # make sure ufw is installed #
        apt-get install ufw -qqy >> $LOGFILE 2>&1
        # add firewall rules
        echo -e -n "${white}"
        echo -e "------------------------------------------- " | tee -a "$LOGFILE"
        echo " # ufw default allow outgoing"
        ufw default allow outgoing >> $LOGFILE 2>&1
        echo -e "------------------------------------------- " | tee -a "$LOGFILE"
        echo " # ufw default deny incoming"
        ufw default deny incoming >> $LOGFILE 2>&1
        echo -e "------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " # ufw allow $SSHPORT" | tee -a "$LOGFILE"
        ufw allow "$SSHPORT" | tee -a "$LOGFILE"
        echo -e "------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
        sleep 1
        # wait until after SSHD is restarted to enable firewall to not break SSH
    else	echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " ** User chose not to setup firewall at this time **"  | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
        sleep 1
    fi

    clear
    echo -e -n "${lightgreen}"
    echo -e "------------------------------------------------ " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : FIREWALL CONFIG COMPLETE " | tee -a "$LOGFILE"
    echo -e "------------------------------------------------ " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
}

################
## Hardening  ##
################

function server_hardening() {
    # prompt users on whether to harden server or not
    echo -e -n "${lightcyan}"
    figlet Get Hard | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : QUERY TO HARDEN THE SERVER " | tee -a "$LOGFILE"
    echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${lightcyan}"
    echo -e " The next steps are to secure your server's shared memory, enable"
    echo -e " DDOS protection, harden the networking layer, and enable automatic"
    echo -e " installation of security updates.\n"

        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to perform these steps now? y/n  " GETHARD
            if [[ ${GETHARD,,} == "y" || ${GETHARD,,} == "Y" || ${GETHARD,,} == "N" || ${GETHARD,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n"    
    
    # check if GETHARD is valid
    if [ "${GETHARD,,}" = "Y" ] || [ "${GETHARD,,}" = "y" ]
    then

        # secure shared memory
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : SECURING SHARED MEMORY " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo -e ' --> Adding line to bottom of file /etc/fstab'  | tee -a "$LOGFILE"
        echo -e ' tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        sleep 2	; #  dramatic pause
        # only add line if line does not already exist in /etc/fstab
        if grep -q "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" /etc/fstab; then :
        else echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' >> /etc/fstab
        fi

        # enable DDOS protection
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : ENABLING DDOS PROTECTION " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo -e " Replace /etc/ufw/before.rules with hardened rules " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
        sleep 2	; #  dramatic pause
        cat etc/ufw/before.rules > /etc/ufw/before.rules

        # harden the networking layer
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : HARDENING NETWORK LAYER " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo -e " --> Secure /etc/sysctl.conf with hardening rules " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
        sleep 2	; #  dramatic pause
        cat etc/sysctl.conf > /etc/sysctl.conf

        # enable automatic security updates
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : ENABLING SECURITY UPDATES " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo -e " Configure system to auto install security updates " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n " | tee -a "$LOGFILE"
        sleep 2	; #  dramatic pause

        . /etc/os-release
        if [[ "${VERSION_ID}" = "16.04" ]] 
        then cat etc/apt/apt.conf.d/10periodic > /etc/apt/apt.conf.d/10periodic
        else cat etc/apt/apt.conf.d/20auto-upgrades > /etc/apt/apt.conf.d/20auto-upgrades
        fi

        cat etc/apt/apt.conf.d/50unattended-upgrades > /etc/apt/apt.conf.d/50unattended-upgrades
        # consider editing the above 50-unattended-upgrades to automatically reboot when necessary

        # Error Handling
        if [ $? -eq 0 ]
        then 	echo -e " \n" ; clear
            echo -e -n "${green}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : Server Hardened" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        else	clear
            echo -e -n "${lightred}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: Hardening Failed" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        fi

    else :
        clear
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " *** User elected not to GET HARD at this time *** " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi
}

##################
## Google Auth  ##
##################

function google_auth() {
    # prompt users to install Google Authenticator or not
    echo -e -n "${lightcyan}"
    figlet Goog Auth | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : QUERY TO INSTALL GOOGLE 2FA " | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${lightcyan}"
    echo -e " You can increase the security of your VPS by installing a 2-factor"
    echo -e " authentication solution which will require a time-based, one-time"
    echo -e " token in addition to your username and password. This installation"
    echo -e " requires you to use the Google Authenticator app on your phone.\n"

        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to install Google 2FA Authentication? y/n  " GOOGLEAUTH
            if [[ ${GOOGLEAUTH,,} == "y" || ${GOOGLEAUTH,,} == "Y" || ${GOOGLEAUTH,,} == "N" || ${GOOGLEAUTH,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n"    
    
    # check if GOOGLEAUTH is valid
    if [ "${GOOGLEAUTH,,}" = "Y" ] || [ "${GOOGLEAUTH,,}" = "y" ]
    then

        # installing google authenticator
        echo -e -n "${yellow}"
        echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INSTALLING GOOGLE AUTHENTICATOR " | tee -a "$LOGFILE"
        echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"

        echo -e -n "${nocolor}"
        apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install libpam-google-authenticator | tee -a "$LOGFILE"
        google-authenticator

        echo -e ' --> Enabling Google Authenticator in /etc/pam.d/sshd'  | tee -a "$LOGFILE"
        sed -i "s/@include common-auth/#@include common-auth/" /etc/pam.d/sshd
        echo 'auth required pam_google_authenticator.so' | sudo tee -a /etc/pam.d/sshd

        echo -e ' --> Enabling Google Authenticator in /etc/ssh/sshd_config'  | tee -a "$LOGFILE"
        sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
        sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
        echo 'AuthenticationMethods publickey,keyboard-interactive' | sudo tee -a /etc/ssh/sshd_config
        
            # copy Google Auth key to new user if it exists
            if [ "${UNAME,,}" ] && [ -e /root/.google_authenticator ]
            then # copy root Google Authenticator file new non-root user
                cp /root/.google_authenticator /home/"${UNAME,,}"/.google_authenticator
                # fix permissions on RSA key
                chmod 400 /home/"${UNAME,,}"/.google_authenticator
                chown "${UNAME,,}":"${UNAME,,}" /home/"${UNAME,,}" -R
                echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : Google Auth file was applied to ${UNAME,,}'s profile" | tee -a "$LOGFILE"
            else echo -e -n "${yellow}"
                echo " $(date +%m.%d.%Y_%H:%M:%S) : Google Auth file not present for root, so none was copied." | tee -a "$LOGFILE"
            fi

        # Error Handling
        if [ $? -eq 0 ]
        then 	echo -e " \n" ; clear
            echo -e -n "${green}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : 2FA Installed" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        else	clear
            echo -e -n "${lightred}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: 2FA Failed" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        fi

    else :
        clear
        echo -e -n "${yellow}"
        echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " *** User chose to not install Google Authenticator *** " | tee -a "$LOGFILE"
        echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi
}

#####################
## Ksplice Install ##
#####################

function ksplice_install() {

    # This KSplice install script only works for Ubuntu 16.04 at the moment
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        if [[ "${VERSION_ID}" != "16.04" ]] ; then
            echo -e "This KSplice install script only works for Ubuntu 16.04 at the moment, skipping.\n"
        else 

    # -------> I still need to install an error check after installing Ksplice to make sure \
        #          the install completed before moving on the configuration

    # prompt users on whether to install Oracle ksplice or not
    # install created using https://tinyurl.com/y9klkx2j and https://tinyurl.com/y8fr4duq
    # Official page: https://ksplice.oracle.com/uptrack/guide
    echo -e -n "${lightcyan}"
    figlet Ksplice Uptrack | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "---------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INSTALL ORACLE KSPLICE " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${lightcyan}"
    echo -e " Normally, kernel updates in Linux require a system reboot. Ksplice"
    echo -e " Uptrack installs these patches in memory for Ubuntu and Fedora"
    echo -e " Linux so reboots are not needed. It is free for non-commercial use."
    echo -e " To minimize server downtime, this is a good thing to install.\n"
    
        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to install Oracle Ksplice Uptrack now? y/n  " KSPLICE
            if [[ ${KSPLICE,,} == "y" || ${KSPLICE,,} == "Y" || ${KSPLICE,,} == "N" || ${KSPLICE,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n" 

        if [ "${KSPLICE,,}" = "Y" ] || [ "${KSPLICE,,}" = "y" ]
        then
        # install ksplice uptrack
        echo -e -n "${yellow}"
        echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : INSTALLING KSPLICE PACKAGES " | tee -a "$LOGFILE"
        echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${white}"
        echo ' # apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install ' | tee -a "$LOGFILE"
        echo '   libgtk2-perl consolekit iproute libck-connector0 libcroco3 libglade2-0 ' | tee -a "$LOGFILE"
        echo '   libpam-ck-connector librsvg2-2 librsvg2-common python-cairo python-gtk2 ' | tee -a "$LOGFILE"
        echo '   python-dbus python-gi python-glade2 python-gobject-2 python-pycurl ' | tee -a "$LOGFILE"
        echo '   python-yaml dbus-x11 python-six python3-yaml ' | tee -a "$LOGFILE"
        echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
        apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install \
            libgtk2-perl consolekit iproute libck-connector0 libcroco3 libglade2-0 \
            libpam-ck-connector librsvg2-2 librsvg2-common python-cairo python-gtk2 \
            python-dbus python-gi python-glade2 python-gobject-2 python-pycurl \
            python-yaml dbus-x11 python-six python3-yaml | tee -a "$LOGFILE"
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " $(date +%m.%d.%Y_%H:%M:%S) : KSPLICE PACKAGES INSTALLED" | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " --> Download & install Ksplice package from Oracle " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
        wget -o /var/log/ksplicew1.log https://ksplice.oracle.com/uptrack/dist/xenial/ksplice-uptrack.deb
        dpkg --log "$LOGFILE" -i ksplice-uptrack.deb
        if [ -e /etc/uptrack/uptrack.conf ]
        then
            echo -e -n "${lightgreen}"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e " $(date +%m.%d.%Y_%H:%M:%S) : KSPLICE UPTRACK INSTALLED" | tee -a "$LOGFILE"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${yellow}"
            echo -e " ** Enabling autoinstall & correcting permissions ** " | tee -a "$LOGFILE"
            sed -i "s/autoinstall = no/autoinstall = yes/" /etc/uptrack/uptrack.conf
            chmod 755 /etc/cron.d/uptrack
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e " ** Activate & install Ksplice patches & updates ** " | tee -a "$LOGFILE"
            echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
            cat $LOGFILE /var/log/ksplicew1.log > /var/log/join.log
            cat /var/log/join.log > $LOGFILE
            rm /var/log/ksplicew1.log
            rm /var/log/join.log
            uptrack-upgrade -y | tee -a "$LOGFILE"
            echo -e -n "${lightgreen}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e " $(date +%m.%d.%Y_%H:%M:%S) : KSPLICE UPDATES INSTALLED" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
            sleep 1	; #  dramatic pause
            clear
            echo -e -n "${lightgreen}"
            echo -e "------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : Ksplice Enabled" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------- \n" | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        else  	echo -e -n "${lightred}"
            clear
            echo -e "-------------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : FAIL : Ksplice was not Installed" | tee -a "$LOGFILE"
            echo -e "-------------------------------------------------------- \n" | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        fi
    else :
        clear
        echo -e -n "${yellow}"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e "     ** User elected not to install Ksplice ** " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi

        fi
    else
        # no, thats not ok!
        echo -e "This script only supports Ubuntu, skipping.\n"
    fi
}

###################
## MOTD Install  ##
###################

function motd_install() {
    # prompt users to install custom MOTD or not
    echo -e -n "${lightcyan}"
    figlet Enhance MOTD | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "--------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : PROMPT USER TO INSTALL MOTD " | tee -a "$LOGFILE"
    echo -e "--------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${lightcyan}"
    echo -e " The normal MOTD banner displayed after a successful SSH login"
    echo -e " is pretty boring so this mod edits it to include more useful"
    echo -e " information along with a login banner prohibiting unauthorized"
    echo -e " access.  All modifications are strictly cosmetic.\n"

        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to enhance your MOTD & login banner? y/n  " MOTDP
            if [[ ${MOTDP,,} == "y" || ${MOTDP,,} == "Y" || ${MOTDP,,} == "N" || ${MOTDP,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n" 

    # check if MOTDP is affirmative
    if [ "${MOTDP,,}" = "Y" ] || [ "${MOTDP,,}" = "y" ]
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
        then echo -e -n "${lightgreen}"
            echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : MOTD & Banner updated" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------------- " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
        else echo -e -n "${lightred}"
            echo -e "----------------------------------------------- " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: MOTD not updated" | tee -a "$LOGFILE"
            echo -e "----------------------------------------------- \n" | tee -a "$LOGFILE"
        fi

    else echo -e "\n"
        clear
        echo -e -n "${yellow}"
        echo -e "----------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " *** User elected not to customize MOTD & banner *** " | tee -a "$LOGFILE"
        echo -e "----------------------------------------------------- \n" | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi
}

##################
## Restart SSHD ##
##################

function restart_sshd() {
    # prompt users to leave this session open, then create a second connection after restarting SSHD to make sure they can connect
    echo -e -n "${lightcyan}"
    figlet Restart SSH | tee -a "$LOGFILE"
    echo -e -n "${yellow}"
    echo -e "-------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : PROMPT USER TO RESTART SSH " | tee -a "$LOGFILE"
    echo -e "-------------------------------------------------- \n" | tee -a "$LOGFILE"
    echo -e -n "${lightcyan}"
    echo " Changes to login security will not take effect until SSHD restarts"
    echo " and firewall is enabled. You should keep this existing connection"
    echo " open while restarting SSHD just in case you have a problem or"
    echo " copied down the information incorrectly. This will prevent you"
    echo -e " from getting locked out of your server.\n"

        echo -e -n "${cyan}"
            while :; do
            echo -e "\n"
            read -n 1 -s -r -p " Would you like to restart SSHD and enable UFW now? y/n  " SSHDRESTART
            if [[ ${SSHDRESTART,,} == "y" || ${SSHDRESTART,,} == "Y" || ${SSHDRESTART,,} == "N" || ${SSHDRESTART,,} == "n" ]]
            then
                break
            fi
        done
        echo -e "${nocolor}\n" 

    # check if SSHDRESTART is valid
    if [ "${SSHDRESTART,,}" = "Y" ] || [ "${SSHDRESTART,,}" = "y" ]
    then
        # insert a pause or delay to add suspense
        systemctl restart sshd
        if [ "$FIREWALLP" = "yes" ] || [ "$FIREWALLP" = "y" ]
        then ufw --force enable | tee -a "$LOGFILE"
            echo -e " \n" | tee -a "$LOGFILE"
        else :
        fi
        # Error Handling
        if [ $? -eq 0 ]
        then 	echo -e -n "${lightgreen}"
            echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : SSHD restart complete" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
            echo -e -n "${nocolor}"
            if [ "$FIREWALLP" = "yes" ] || [ "$FIREWALLP" = "y" ]
            echo -e -n "${lightgreen}"
            then echo " $(date +%m.%d.%Y_%H:%M:%S) : SUCCESS : UFW firewall enabled" | tee -a "$LOGFILE"
                echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
                echo -e -n "${nocolor}"
            else :
            fi
        else
            echo -e -n "${lightred}"
            echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
            echo " $(date +%m.%d.%Y_%H:%M:%S) : ERROR: SSHD could not restart" | tee -a "$LOGFILE"
            echo -e "------------------------------------------------------ " | tee -a "$LOGFILE"
        fi

    else echo -e "\n"
        printf "$yellow"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e " *** User elected not to restart SSH at this time *** " | tee -a "$LOGFILE"
        echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
        echo -e -n "${nocolor}"
    fi
}

######################
## Install Complete ##
######################

function install_complete() {
    # Display important login variables before exiting script
    clear
    echo -e -n "${lightcyan}"
    figlet Install Complete -f small | tee -a "$LOGFILE"
    echo -e -n "${lightgreen}"
    echo -e "---------------------------------------------------- " >> $LOGFILE 2>&1
    echo -e " $(date +%m.%d.%Y_%H:%M:%S) : YOUR SERVER IS NOW SECURE " >> $LOGFILE 2>&1
    echo -e -n "${lightpurple}"
    echo -e "---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e "  * * * Save these important login variables! * * *  " | tee -a "$LOGFILE"
    echo -e "---------------------------------------------------- ${yellow}" | tee -a "$LOGFILE"
    echo -e " --> Your SSH port for remote access is" "$SSHPORTIS"	| tee -a "$LOGFILE"
    echo -e " --> Root login settings are:" "$ROOTLOGINP" | tee -a "$LOGFILE"

    if [ "${INSTALLCRYPTO,,}" = "yes" ] || [ "${INSTALLCRYPTO,,}" = "y" ]
    then echo -e " --> Common crypto packages were installed" | tee -a "$LOGFILE"
    fi
    if [ -n "${UNAME,,}" ]
    then echo -e "${white} We created a non-root user named (lower case):${nocolor}" "${UNAME,,}" | tee -a "$LOGFILE"
    else echo -e "${white} A new user was not created during the setup process ${nocolor}" | tee -a "$LOGFILE"
    fi
    echo " ${white}PasswordAuthentication settings:${lightred}" "$PASSWDAUTH" | tee -a "$LOGFILE"
    if [ "${FIREWALLP,,}" = "yes" ] || [ "${FIREWALLP,,}" = "y" ]
    then echo -e "${lightcyan} --> UFW was installed and basic firewall rules were added" | tee -a "$LOGFILE"
    else echo -e "${lightcyan} --> UFW was not installed or configured" | tee -a "$LOGFILE"
    fi
    # if [ "${GETHARD,,}" = "yes" ] || [ "${GETHARD,,}" = "y" ]
    # then echo -e " --> The server and networking layer were hardened <--" | tee -a "$LOGFILE"
    # else echo -e " --> The server and networking layer were NOT hardened" | tee -a "$LOGFILE"
    # fi
    if [ "${KSPLICE,,}" = "yes" ] || [ "${KSPLICE,,}" = "y" ]
    then echo -e " You installed Oracle's Ksplice to update without reboot" | tee -a "$LOGFILE"
    else echo -e " You chose NOT to auto-update OS with Oracle's Ksplice" | tee -a "$LOGFILE"
    fi
    echo -e "${yellow}-------------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " Installation log saved to" $LOGFILE | tee -a "$LOGFILE"
    echo -e " Before modification, your SSH config was backed up to" | tee -a "$LOGFILE"
    echo -e " --> $SSHDFILE.$BTIME.bak"				| tee -a "$LOGFILE"
    echo -e "${lightred} ---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e " | NOTE: Please create a new connection to test SSH | " | tee -a "$LOGFILE"
    echo -e " |       settings before you close this session     | " | tee -a "$LOGFILE"
    echo -e " ---------------------------------------------------- " | tee -a "$LOGFILE"
    echo -e -n "${nocolor}"
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
    echo -e -n "${nocolor}"
}

check_distro
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
google_auth
ksplice_install
motd_install
restart_sshd
install_complete

exit
