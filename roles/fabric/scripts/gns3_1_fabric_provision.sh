#CONFIGURE LOOPBACKS
ip link add name loop1 type dummy
ip link set loop1 up
ip addr add 10.255.255.2/32 dev loop1
#CREATE VRF AND BGP BRIDGE
ip link add INET type vrf table 1
ip link set dev INET up

ip link add INET_PEERING type bridge
ip link set INET_PEERING master INET
ip addr add 172.16.254.1/29 dev INET_PEERING
ip link set INET_PEERING up
#
ip link add VPN1 type vrf table 2
ip link set dev VPN1 up

ip link add VPN1_PEERING type bridge
ip link set VPN1_PEERING master VPN1
ip addr add 172.16.254.9/29 dev VPN1_PEERING
ip link set VPN1_PEERING up
#
ip link add VPN2 type vrf table 3
ip link set dev VPN2 up

ip link add VPN2_PEERING type bridge
ip link set VPN2_PEERING master VPN2
ip addr add 172.16.254.17/29 dev VPN2_PEERING
ip link set VPN2_PEERING up
#
#
#CREATE VXLAN SEGMENTS
#
ip link add vxlan100 type vxlan id 100 dstport 4789 local 10.255.255.2 nolearning
brctl addbr br100
brctl addif br100  vxlan100
brctl stp br100  off
ip link set up dev br100
ip link set up dev vxlan100
ip link add vxlan101 type vxlan id 101 dstport 4789 local 10.255.255.2 nolearning
brctl addbr br101
brctl addif br101  vxlan101
brctl stp br101  off
ip link set up dev br101
ip link set up dev vxlan101
ip link add vxlan102 type vxlan id 102 dstport 4789 local 10.255.255.2 nolearning
brctl addbr br102
brctl addif br102  vxlan102
brctl stp br102  off
ip link set up dev br102
ip link set up dev vxlan102