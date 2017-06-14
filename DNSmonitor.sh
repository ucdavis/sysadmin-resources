#!/bin/bash

# Script created by: Brian Rose
# Email: BrianCanFixIT@Gmail.com
# Last modified: 2017.06.17

# Send alerts to this email addrress
adminEmail="bjrose@ucdavis.edu"

# Sites to monitor
sites[0]="vpn.dss.ucdavis.edu"
sites[1]="jss.ucdavis.edu"
answers[0]="169.237.160.75"
answers[1]="agdt-jss-01.ucdavis.edu.
128.120.46.162"

# DNS servers to test lookups against
dnsServers[0]="169.237.160.10" #infoblox
dnsServers[1]="169.237.1.250" #UCD main
dnsServers[2]="169.237.250.250" #UCD main
dnsServers[3]="128.120.252.9" #dns-one.ucdavis.edu
dnsServers[4]="128.120.252.10" #dns-two.ucdavis.edu
dnsServers[5]="192.82.111.197" #dns-three.ucdavis.edu
dnsServers[6]="169.237.229.82" #addc6c.AD3.UCDAVIS.EDU
dnsServers[7]="169.237.229.88" #addc9c.ad3.ucdavis.edu
dnsServers[8]="169.237.229.83" #addc7c.AD3.UCDAVIS.EDU
dnsServers[9]="128.120.42.42" #addc8c.ad3.ucdavis.edu
dnsServers[10]="152.79.115.115" #ucdmc
dnsServers[11]="152.79.105.105" #ucdmc
dnsServers[12]="152.79.253.6" #ucdmc

simpleTime=`date "+%H:%M"`
touch dnserrorlog.txt

date >> dnslookuplog.txt

siteIndex=0
siteCount=${#sites[@]}
while [ "$siteIndex" -lt "$siteCount" ]
do
	for i in "${dnsServers[@]}"
	do
		result=`dig +short ${sites[$siteIndex]} "$i"`;
#		echo result=$result;
#		echo answer=${answers[$siteIndex]};
		if [[ $result != ${answers[$siteIndex]} ]];
		then
			echo "fail";
			fulldate=`date`
			echo "$fulldate\t\c" >> dnserrorlog.txt
			echo "$i\twas not able to resolve the following host:\t${sites[$siteIndex]}." >> dnserrorlog.txt
		fi
	done
	((siteIndex++))
done

#should do a better test here in case file does not exist, enought with cat pipe grep too
sendError=`cat dnserrorlog.txt | grep "$simpleTime:"`

if [ -n "$sendError" ]
then
	sendError=`echo "$sendError" && echo "" && echo "Unless listed above, all other DNS servers resolved all other hosts."`
	echo "$sendError" | /usr/bin/mail -s "DNS is down" "$adminEmail"
fi


exit 0
