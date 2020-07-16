#!/bin/bash

sysctl -p
nft -f /etc/nftables.conf
/root/verkko.sh
/root/set_irq_affinity.sh -x local enp6s0f0
/root/set_irq_affinity.sh -x local enp6s0f1
/root/luksopen.sh
zpool import tank
ip addr add 10.0.100.1/24 dev ovsbr0
ip link set dev ovsbr0 up
systemctl restart isc-dhcp-server nginx mumble-server smbd snmpd
virsh start valvonta.digipahuus.fi
virsh start nc1.digipahuus.fi
virsh start deko1
tc qdisc add dev enp6s0f0 root cake bandwidth 100Mbit ethernet regional triple-isolate nat
tc qdisc add dev enp6s0f1 root cake bandwidth 950Mbit ethernet regional triple-isolate nat

#tc qdisc add dev enp6s0f0 root cake ethernet regional triple-isolate nat
#tc qdisc add dev enp6s0f1 root cake ethernet regional triple-isolate nat
wg-quick up rex-wg

