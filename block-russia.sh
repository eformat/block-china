#!/bin/bash

# Create the ipset list
ipset -N russia hash:net
ipset flush russia

# remove any old list that might exist from previous runs of this script
rm -f /tmp/ru.zone

# Pull the latest IP set for Russia
wget -P . http://www.ipdeny.com/ipblocks/data/countries/ru.zone -O /tmp/ru.zone

# Add each IP address from the downloaded list into the ipset 'china'
for i in $(cat /tmp/ru.zone ); do ipset -A russia $i; done
ipset list -terse

# iptables rule
if ! iptables -L INPUT | grep -q russia; then
    iptables -A INPUT -p tcp -m set --match-set russia src -j DROP
fi

# crontab
#
# 0 5 * * * bash -lc /root/bin/block-russia.sh
#
