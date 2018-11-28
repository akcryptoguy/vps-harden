# motd
update motd on ubuntu-server

This script replaces the standard Ubuntu welcome message with a Helium logo and useful server information through modifying the MOTD files on the VPS.

**Usage:**

As root:
```
git clone https://github.com/akcryoptoguy/motd.git
cd motd
bash install-motd.sh
```

Changes will take effect immediately, so there is no need to reboot the VPS. Example:


<img src="final.png" alt="MOTD" class="inline"/>


To update your location for weather, update "weathercity" and "weatherurl" with your nearest major city supported by AccuWeather in 00-header. You can also personalize other variables.  If your IP address does not display correctly, change the "networkad" variable from "ens3" to that of your local network interface.

```
sudo nano /etc/update-motd.d/00-header
```

With grandest thanks to Teela for doing most of the hard work.
