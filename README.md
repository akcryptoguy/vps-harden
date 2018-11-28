## <p align="center"> AKcryptoGUY's Awesome Server Hardening Script</p>

This VPS Server Hardening script is designed to be run on new VPS deployments which will simplify a lot of the basic hardening that can be done to protect your server. I assimilated several design ideas and commands for this script from 
[AMega's VPS hardening script](https://github.com/AMega/VPS-Server-Hardening) which I found on Github seemingly abandoned; and I am very happy to pick it up and finish it.

If this script helped you in any way, please contribute some feedback. Donations are also welcome and help permit this script's continued development.

```
HLM: SYQJrFYL7VrEPN7HyhGFBB35nvZ2k1Fbjo
BTC: 3LbUJVW9WmXPgFStTXSLTBwjpnbVTtt8Ja
TRON: TLsday62mhM67Sv5G5Z5Ju66TezJuVFbiw
DGB: DUJ8W8QpmVex87posFPoDYGg5FrYCoMLGq
DOGE: DH9Sj3DQNVBaxb6kZBXc6X2MPQjbv7H6oy
```


## About

A lot of good virtual servers get destroyed every year because they are hacked by evildoers that take advantage of unpatched exploits and simple passwords.  It's frustrating that many of these hacks could have been prevented by some basic hardening. With large numbers of linux newcomers flocking to enter the space and set up masternodes I saw a need for a simple way to secure virtual servers that would, *for the most part*, keep the bad guys out.

The following is a list of different sections of the script, which are broken up into separate functions which are called from the very end of the script.  

1. UPDATE AND UPGRADE / update operating system & pkgs
2. USER SETUP / add new sudo user, copy SSH keys
3. SSH CONFIG / change SSH port, disable root login
4. UFW CONFIG / UFW - add rules, harden, enable firewall
5. HARDENING / before rules, secure shared memory, etc
6. KSPLICE INSTALL / automatically update without reboot
7. MOTD EDIT / replace boring banner with customized one
8. RESTART SSHD / apply settings by restarting systemctl
9. INSTALL COMPLETE / display new SSH and login info

I aggregated these steps from several different server hardening guides and selected the most effective of them to include in this script.  The goal is to make something simple enough for the newcomers to use while still being practical and saving time for Linux veterans.  I am certainly open to suggestions and would like to keep this easy and practical to use.

## Referral Links

Please [use my Vultr referral link](https://www.vultr.com/?ref=7568060) when creating your VPS account at Vultr to support my projects and build some good karma.<br/>

<p align="center"><a href="https://www.vultr.com/?ref=7568060"><img src="https://www.vultr.com/media/banner_1.png"></a></p>

[Digital Ocean](https://www.digitalocean.com/?refcode=bd6020302487) is also very generous, and give a free credit of $100 to use while testing the site to decide if it is right for you.
<p align="center"><a href="https://www.digitalocean.com/?refcode=bd6020302487"><img src="http://www.rrpowered.com/wp-content/uploads/2014/06/digital-ocean-694x219.png" height="100"></a></p>

## Installation

SSH into your VPS and run this command to clone the Github repository and begin installation:

```bash
sudo git clone https://github.com/akcryptoguy/vps-harden.git && cd vps-harden && sudo bash get-hard.sh
```

The script will then walk you through each of the server hardening steps, offering prompts for feedback and other notes along the way.  You really can't mess it up.  I have tried.  

<p align="center"><img src="/media/07. root login.png" alt="Root Login"></p>

The script will keep a log of changes that are made to the system which you can review when it is complete.  The output will also be dispalyed on the screen.

<p align="center"><img src="/media/11. hardening rules.png" alt="Hardening Rules"></p>

When you are finished, you'll see confirmation that the script completed setup and you will be given a list of notes about your installation.  The installation log file is stored in the server's log folder at `/var/log/server_hardening.log`

<p align="center"><img src="/media/15 install complete.png" alt="Install Complete"></p>

I would recommend that you take a screenshot of that page and save it for later.  It has important information about your setup and if you don't keep note of the settings you entered, you could find yourself locked out of your server.


Additionally, there are some additional files you can modify to suit your needs.  I have listed a few of these files below along with why you might consider editing them.


### SSH Configuration
/etc/ssh/sshd_config

### Login Banner
/etc/issue.net

### Automatic Update Settings
/etc/apt/apt.conf.d/10periodic<br/>
/etc/apt/apt.conf.d/50unattended-upgrades<br/>

### Ksplice Settings
/etc/uptrack/uptrack.conf

## Help, Issues and Questions

I have tried to troubleshoot the script for errors and confirmed that it works with a VPS you configure on [Vultr](https://www.vultr.com/?ref=7568060), 
[Digital Ocean](https://www.digitalocean.com/?refcode=bd6020302487), and [Be Your Own VPS](https://www.youtube.com/playlist?list=PLTblguczzdyajCPQGlpJjHUvSNV8WNsGQ). It works in all of these as long as you're using Ubuntu 16.04 LTS.  I have not tested it with anything else.

## Social and Contact

**Follow AKcryptoGUY online:** <br/>
**Medium →** https://medium.com/@AKcryptoGUY <br/>
**Twitter →** https://twitter.com/AKcryptoGUY <br/>
**Facebook →** https://www.facebook.com/AKcryptoGUY <br/>
**YouTube →** https://www.youtube.com/channel/UCIFu9OZWOtfxokGdFY6aTog <br/>

Reach out to me at akcryptoguy<img src="https://www.freeiconspng.com/uploads/at-sign-icon-1.png" alt="@ symbol" height="11">protonmail.com for suggestions or questions and if I helped save you some time, please send some crypto my way.


```
HLM: SYQJrFYL7VrEPN7HyhGFBB35nvZ2k1Fbjo
BTC: 3LbUJVW9WmXPgFStTXSLTBwjpnbVTtt8Ja
TRON: TLsday62mhM67Sv5G5Z5Ju66TezJuVFbiw
DGB: DUJ8W8QpmVex87posFPoDYGg5FrYCoMLGq
DOGE: DH9Sj3DQNVBaxb6kZBXc6X2MPQjbv7H6oy
```



