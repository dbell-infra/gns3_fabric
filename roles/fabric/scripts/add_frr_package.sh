#!/bin/bash
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
