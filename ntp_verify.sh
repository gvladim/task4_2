#!/bin/bash
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#Check if ntpd is running
ps auxw | grep ntpd | grep -v grep > /dev/null
if [ $? != 0 ]; then
	echo "NOTICE: ntp is not running"
        /etc/init.d/ntp start 

fi

#Comparing configuration to the bacup and restoring if changed
diff /etc/ntp.conf /etc/ntp.conf.bak > /dev/null
if [ $? == 1 ]; then
	# they're different!
	echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"
	diff -u0  /etc/ntp.conf.bak /etc/ntp.conf 
	cat /etc/ntp.conf.bak > /etc/ntp.conf
	/etc/init.d/ntp restart

fi;
exit 0