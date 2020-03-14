#!/bin/bash

######## Muuttujat ########
wan="enp1s0"
laniverkko="enp4s0"
up=40
down=150
tc=/sbin/tc

echo TC vanhat pois ..
tc qdisc del dev ${wan} root
tc qdisc del dev ${laniverkko} root

echo NIC offloads ..
ethtool -K ${wan} tx off
ethtool -K ${wan} rx off
ethtool -K ${wan} gso off
ethtool -K ${wan} tso off
ethtool -K ${wan} gro off
ethtool -A ${wan} tx off rx off autoneg off

ethtool -K ${laniverkko} tx off
ethtool -K ${laniverkko} rx off
ethtool -K ${laniverkko} gso off
ethtool -K ${laniverkko} tso off
ethtool -K ${laniverkko} gro off
ethtool -A ${laniverkko} tx off rx off autoneg off

#echo NIC flow hash ..
#ethtool -N ${wan} rx-flow-hash udp4 sd
#ethtool -N ${wan} rx-flow-hash tcp4 sdfn
#ethtool -N ${laniverkko} rx-flow-hash udp4 sd
#ethtool -N ${laniverkko} rx-flow-hash tcp4 sdfn

#echo TC classit ...
#echo EGRESS ..
#$tc qdisc add dev ${wan} root handle 1:0 hfsc default 1
#$tc class add dev ${wan} parent 1:0 classid 1:1 hfsc ls rate ${up}mbit ul rate ${up}mbit
#$tc qdisc add dev ${wan} parent 1:1 handle 2:1 ${egress}

#echo INGRESS ..
#$tc qdisc add dev ${laniverkko} root handle 1:0 hfsc default 2
#$tc class add dev ${laniverkko} parent 1:0 classid 1:1 hfsc ls rate 1000mbit ul rate 1000mbit
#$tc class add dev ${laniverkko} parent 1:1 classid 1:2 hfsc ls rate ${down}mbit ul rate ${down}mbit
#$tc class add dev ${laniverkko} parent 1:1 classid 1:3 hfsc ls rate 700mbit ul rate 1000mbit
#$tc qdisc add dev ${laniverkko} parent 1:2 handle 2: ${ingress}
#$tc qdisc add dev ${laniverkko} parent 1:3 handle 3: ${ingress}


# UUDER CAKET
#echo TC-CAKET ..
$tc qdisc add dev ${wan} root cake bandwidth autorate-ingress internet diffserv3 triple-isolate nat nowash split-gso noatm ethernet 
#$tc qdisc add dev ${wan} root cake bandwidth ${up}Mbit internet diffserv3 triple-isolate nat nowash split-gso noatm ethernet 
$tc qdisc add dev ${laniverkko} root cake bandwidth autorate-ingress internet diffserv3 triple-isolate nat nowash split-gso noatm ethernet 
#$tc qdisc add dev ${laniverkko} root cake bandwidth ${down}Mbit internet diffserv3 triple-isolate nat nowash split-gso noatm ethernet 
