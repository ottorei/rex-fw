#!/bin/bash

# Interfaces
wan=enp6s0f0
lan=enp6s0f1

# Reload sysctl variables
echo Reloading sysctl variables ..
/sbin/sysctl -p

echo Custom sysctl variables ..
/sbin/sysctl -w net.ipv4.tcp_congestion_control=bbr
/sbin/sysctl -w net.ipv4.conf.default.rp_filter=0
/sbin/sysctl -w net.ipv4.conf.all.rp_filter=0
/sbin/sysctl -w net.ipv4.ip_forward=1
/sbin/sysctl -w net.ipv4.neigh.default.gc_thresh1=1024
/sbin/sysctl -w net.ipv4.neigh.default.gc_thresh2=2048
/sbin/sysctl -w net.ipv4.neigh.default.gc_thresh3=4096
/sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=1
/sbin/sysctl -w net.ipv6.conf.default.disable_ipv6=1
/sbin/sysctl -w net.ipv6.conf.lo.disable_ipv6=1
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_loose=0
/sbin/sysctl -w net.nf_conntrack_max=1048576
/sbin/sysctl -w net.ipv4.ip_early_demux=0
/sbin/sysctl -w net.ipv4.conf.all.arp_filter=0
/sbin/sysctl -w net.ipv4.conf.all.arp_ignore=1
/sbin/sysctl -w net.ipv4.conf.all.arp_announce=2
/sbin/sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
/sbin/sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
/sbin/sysctl -w net.ipv4.icmp_errors_use_inbound_ifaddr=1
/sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0
/sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0
/sbin/sysctl -w net.ipv4.conf.all.secure_redirects=1
/sbin/sysctl -w net.core.netdev_max_backlog=2000
/sbin/sysctl -w net.core.netdev_budget=50000
/sbin/sysctl -w net.core.netdev_budget_usecs=10000
#/sbin/sysctl -w net.core.rmem_max=67108864
#/sbin/sysctl -w net.core.wmem_max=67108864
#/sbin/sysctl -w net.ipv4.tcp_rmem=4096 5242880 33554432
#/sbin/sysctl -w net.ipv4.tcp_wmem=4096 65536 33554432
/sbin/sysctl -w net.ipv4.tcp_l3mdev_accept=1
/sbin/sysctl -w net.ipv4.udp_l3mdev_accept=1
/sbin/sysctl -w net.core.netdev_tstamp_prequeue=0
/sbin/sysctl -w net.ipv4.tcp_syncookies=0

# Reload nftables ruleset
echo Reloading nftables ruleset ..
nft -f nftables.conf

echo NIC flow hash ..
/sbin/ethtool -N ${wan} rx-flow-hash udp4 sd
/sbin/ethtool -N ${wan} rx-flow-hash tcp4 sdfn
/sbin/ethtool -N ${lan} rx-flow-hash udp4 sd
/sbin/ethtool -N ${lan} rx-flow-hash tcp4 sdfn

echo NIC Queues ..
/sbin/ethtool -L ${wan} combined 8
/sbin/ethtool -L ${lan} combined 8

echo NIC ring buffers ..
/sbin/ethtool -G ${wan} rx 4096 tx 4096
/sbin/ethtool -G ${lan} rx 4096 tx 4096

echo NIC offloads ..
/sbin/ethtool -K ${wan} tx off rx off gso off tso off gro off lro off
/sbin/ethtool -K ${lan} tx off rx off gso off tso off gro off lro off
/sbin/ethtool -A ${wan} tx off rx off autoneg off
/sbin/ethtool -A ${lan} tx off rx off autoneg off

# Set IRQ-affinities (Intel provided script)
#echo Changing IRQ-affinities ..
#./set_irq_affinity.sh -x local ${wan}
#./set_irq_affinity.sh -x local ${lan}

# Set qdiscs for interfaces
#/sbin/tc qdisc del dev ${wan} root
#/sbin/tc qdisc del dev ${lan} root
#/sbin/tc qdisc add dev ${wan} root cake bandwidth 215Mbit ethernet regional triple-isolate nat
#/sbin/tc qdisc add dev ${lan} root cake bandwidth 950Mbit ethernet regional triple-isolate nat

# Start management VPN-tunnel
# /usr/bin/wg-quick up rex-wg
ip link del rex-wg
ifup rex-wg

# Fix this: assign address and up openvswitch bridge
# TODO: Switch back to basic linux bridge dev
/sbin/ip addr add 10.0.100.1/24 dev ovsbr0
/sbin/ip link set dev ovsbr0 up

# Import encrypted zpool
echo Importing zpool ..
/sbin/zpool import vamp
/sbin/zfs load-key -r vamp
/sbin/zfs mount -a

# Fix this: restart services which are binding before interfaces are up
echo Restarting services ..
/bin/systemctl restart isc-dhcp-server nginx mumble-server smbd snmpd

# QoS
echo Loading QoS-script ..
./tc_qdisc.sh
