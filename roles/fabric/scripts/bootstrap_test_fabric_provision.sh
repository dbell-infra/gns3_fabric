#!/bin/bash
#CONFIGURE LOOPBACKS
ip link add name loop1 type dummy
ip link set loop1 up
ip addr add 10.255.255.1/32 dev loop1
