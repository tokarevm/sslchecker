#!/bin/bash

NET_LIST="172.16.0.0/24
	192.168.0.0/24"

outfile="~/certs.csv"

if [ -f $outfile ]; then
  rm -f $outfile
fi


for net in $NET_LIST
do
    net_addr=`echo $net | awk -F"/" '{print $1}'`
    nmap -n $net -p443 -oG - | awk '/open/ { if ($5~/open/) print $2":443"; if ($6~/open/) print $2":8443"; }' > "~/"$net_addr"_ssl.txt"
    sh /usr/local/bin/certchecker.sh "~/"$net_addr"_ssl.txt" $outfile
done

