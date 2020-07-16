#!/bin/bash

wan=enp6s0f0
lan=enp6s0f1

echo NIC flow hash ..
/sbin/ethtool -N ${wan} rx-flow-hash udp4 sd
/sbin/ethtool -N ${wan} rx-flow-hash tcp4 sdfn
/sbin/ethtool -N ${lan} rx-flow-hash udp4 sd
/sbin/ethtool -N ${lan} rx-flow-hash tcp4 sdfn

echo NIC Queues ..
/sbin/ethtool -L ${wan} combined 8
/sbin/ethtool -L ${lan} combined 8

echo NIC ring buffers ..
/sbin/ethtool -G ${wan} rx 2048 tx 2048
/sbin/ethtool -G ${lan} rx 2048 tx 2048

echo NIC offloads ..
/sbin/ethtool -K ${wan} tx off rx off gso off tso off gro off lro off
/sbin/ethtool -K ${lan} tx off rx off gso off tso off gro off lro off
/sbin/ethtool -A ${wan} tx off rx off autoneg off
/sbin/ethtool -A ${lan} tx off rx off autoneg off
