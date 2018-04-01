#!/bin/bash
exec 1> /dev/null 2>&1

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Check if NTP package is installed and then install it if it's not
if [ $(dpkg-query -W -f='${Status}' ntp 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  apt-get install ntp -y;
fi

#Editing NTP configuration
sed -i.bak 's/0.ubuntu.pool.ntp.org/ua.pool.ntp.org/g' /etc/ntp.conf
sed -i.bak '/.ubuntu.pool.ntp.org/d' /etc/ntp.conf

#Restarting NTP service
/etc/init.d/ntp restart

#Schedule the verify script
SCR="$workdir/ntp_verify.sh"
JOB="*/1 * * * * $SCR MAILTO=root@localhost"
TMPC="mycron"
grep "$SCR" -q <(crontab -l) || (crontab -l>"$TMPC"; echo "$JOB">>"$TMPC"; crontab "$TMPC")
rm mycron
#Backup of the NTP configuration
cat /etc/ntp.conf > /etc/ntp.conf.bak
exit 0