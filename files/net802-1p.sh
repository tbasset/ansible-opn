#!/bin/bash
# tcpdump -e -n -i eno1 vlan 3 and icmp

#Set MGMT (vlan 2) priority is 6
ip link set bond0.2 type vlan ingress 0:6
ip link set bond0.2 type vlan egress 0:6
#Set STORAGE (vlan 3) priority is 4
ip link set bond0.3 type vlan ingress 0:4
ip link set bond0.3 type vlan egress 0:4
#Set VXLAN (vlan 4) ingress priority is 2
ip link set bond0.4 type vlan ingress 0:2
ip link set bond0.4 type vlan egress 0:2
