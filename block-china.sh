#!/bin/bash

# Create the ipset list
ipset -N china hash:net
ipset flush china

# remove any old list that might exist from previous runs of this script
rm -f /tmp/cn.zone

# Pull the latest IP set for China
wget -P . http://www.ipdeny.com/ipblocks/data/countries/cn.zone -O /tmp/cn.zone

# Add each IP address from the downloaded list into the ipset 'china'
for i in $(cat /tmp/cn.zone ); do ipset -A china $i; done
ipset list -terse

# iptables rule
if ! iptables -L INPUT | grep -q china; then
    iptables -A INPUT -p tcp -m set --match-set china src -j DROP
fi

# crontab
#
# * 5 * * * /root/bin/block-china.sh
#
