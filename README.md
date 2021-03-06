# gns3_fabric
Build multi-node GNS3 fabrics that offer L2 and L3 VPNs using Ansible

L2VPN Implementation: VXLAN BGP EVPN

L3VPN Implementation: MPLS L3VPN

Functionality
-------------

The role accomplishes three tasks:
1. Initial bootstrap that installs FRR, enables MPLS, and reboots the server.

2. Generate Linux networking config per device and tie configuration to systemd service to persist on reboot.

3. Generate FRR config per device and restart FRR service. 


The configuration data per device is stored in `roles/fabric/python/configs` 

Example configuration data is provided for a setup with one route reflector and two server nodes

These example configurations build 3 L3VPN tenants and 3 EVPN VXLAN domains

```
roles/fabric/python/configs
├── gns3_1_bgpd.yml
├── gns3_1_fabric_provision.yml
├── gns3_1_ldpd.yml
├── gns3_1_ospfd.yml
├── gns3_2_bgpd.yml
├── gns3_2_fabric_provision.yml
├── gns3_2_ldpd.yml
├── gns3_2_ospfd.yml
├── rr_1_bgpd.yml
├── rr_1_fabric_provision.yml
├── rr_1_ldpd.yml
└── rr_1_ospfd.yml

```

The J2 templates used to produce configurations are stored in `roles/fabric/python/templates`

Ansible uses the inventory hostname to locate the correct yaml file per device on playbook execution. Configuration data should follow the naming convention 

`
<host_name>_<function>.yml
`


Tags can be utilized to run a specific functionality 

installing FRR and MPLS

`ansible-playbook site.yml -t "bootstrap"`

Creating linux networking config and fabric provision service

`ansible-playbook site.yml -t "fabric_provision"`

Installing/Updating FRR configuration

`ansible-playbook site.yml -t "frr"`

Fabric Architecture
-------------------

Route reflector(s) learn EVPN and L3VPN routes from GNS3 server nodes.

GNS3 Server nodes are configured with VRFs and VTEPs to learn BGP routes at L3 and MAC addresses at L2.
 
Devices within the GNS3 topology connect to BGP or VXLAN bridges for inter-host connectivity.

Fabric Components
-----------------

One or more Ubuntu servers acting as route reflectors
Two or more GNS3 servers serving as Leaf/PE routers


Expected playbook output
-----------------------
```
(venv) you@your-control-node gns3_fabric % ansible-playbook site.yml -t "fabric" -i inventory.yaml 

PLAY [Master Playbook] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host rr_1 should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release 
will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [Include Fabric Role] *******************************************************************************************************************************************************************************

TASK [fabric : add newer FRR package] ********************************************************************************************************************************************************************
changed: [rr_1]
changed: [gns3_2]
changed: [gns3_1]

TASK [fabric : Install FRR] ******************************************************************************************************************************************************************************
ok: [gns3_1]
ok: [rr_1]
ok: [gns3_2]

TASK [fabric : check daemons] ****************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : update daemons] ***************************************************************************************************************************************************************************
skipping: [gns3_1]
skipping: [gns3_2]
skipping: [rr_1]

TASK [fabric : check modules.conf] ***********************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : update modules.conf] **********************************************************************************************************************************************************************
skipping: [gns3_1]
skipping: [gns3_2]
skipping: [rr_1]

TASK [fabric : check sysctl.conf] ************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : update sysctl.conf] ***********************************************************************************************************************************************************************
skipping: [gns3_1]
skipping: [gns3_2]
skipping: [rr_1]

TASK [fabric : Reboot hosts] *****************************************************************************************************************************************************************************
changed: [rr_1]
changed: [gns3_2]
changed: [gns3_1]

TASK [fabric : create spine fabric config] ***************************************************************************************************************************************************************
changed: [gns3_2 -> localhost]
changed: [gns3_1 -> localhost]
changed: [rr_1 -> localhost]

TASK [fabric : create systemd service] *******************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : add fabric_provision config] **************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : update service priveleges] ****************************************************************************************************************************************************************
changed: [rr_1]
changed: [gns3_1]
changed: [gns3_2]

TASK [fabric : enable service] ***************************************************************************************************************************************************************************
changed: [rr_1]
changed: [gns3_2]
changed: [gns3_1]

TASK [fabric : ensure fabric_provision has started] ******************************************************************************************************************************************************
changed: [rr_1]
changed: [gns3_2]
changed: [gns3_1]

TASK [fabric : create bgpd config] ***********************************************************************************************************************************************************************
changed: [gns3_1 -> localhost]
changed: [gns3_2 -> localhost]
changed: [rr_1 -> localhost]

TASK [fabric : create ospfd config] **********************************************************************************************************************************************************************
changed: [gns3_1 -> localhost]
changed: [gns3_2 -> localhost]
changed: [rr_1 -> localhost]

TASK [fabric : create ldpd config] ***********************************************************************************************************************************************************************
changed: [gns3_1 -> localhost]
changed: [gns3_2 -> localhost]
changed: [rr_1 -> localhost]

TASK [fabric : add vtysh config] *************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : Remove conf file] *************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_2]
ok: [gns3_1]

TASK [fabric : add bgpd config] **************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : add ospfd config] *************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : add ldpd config] **************************************************************************************************************************************************************************
ok: [rr_1]
ok: [gns3_1]
ok: [gns3_2]

TASK [fabric : Restart frr service] **********************************************************************************************************************************************************************
changed: [gns3_1]
changed: [rr_1]
changed: [gns3_2]

PLAY RECAP ***********************************************************************************************************************************************************************************************
gns3_1                     : ok=22   changed=10   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
gns3_2                     : ok=22   changed=10   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
rr_1                       : ok=22   changed=10   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   

```

Validation
----------

Validate L3VPN routes on route reflector 
```
rr_1# sh ip bgp ipv4 vpn 
BGP table version is 2, local router ID is 10.255.255.1, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 65000:1
*>i172.16.254.0/29  10.255.255.2             0    100      0 ?
    UN=10.255.255.2 EC{65000:1} label=16 type=bgp, subtype=0
*>i172.16.255.0/29  10.255.255.3             0    100      0 ?
    UN=10.255.255.3 EC{65000:1} label=16 type=bgp, subtype=0
Route Distinguisher: 65000:2
*>i172.16.254.8/29  10.255.255.2             0    100      0 ?
    UN=10.255.255.2 EC{65000:2} label=17 type=bgp, subtype=0
*>i172.16.255.8/29  10.255.255.3             0    100      0 ?
    UN=10.255.255.3 EC{65000:2} label=17 type=bgp, subtype=0
Route Distinguisher: 65000:3
*>i172.16.254.16/29 10.255.255.2             0    100      0 ?
    UN=10.255.255.2 EC{65000:3} label=18 type=bgp, subtype=0
*>i172.16.255.16/29 10.255.255.3             0    100      0 ?
    UN=10.255.255.3 EC{65000:3} label=18 type=bgp, subtype=0

Displayed  6 routes and 6 total paths
rr_1#

```

Validate EVPN routes on route reflector 

```
rr_1# sh ip bgp l2vpn evpn
BGP table version is 1, local router ID is 10.255.255.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[ESI]:[EthTag]:[IPlen]:[VTEP-IP]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.255.2:5
*>i[3]:[0]:[32]:[10.255.255.2]
                    10.255.255.2                  100      0 i
                    RT:65000:100 ET:8
Route Distinguisher: 10.255.255.2:6
*>i[3]:[0]:[32]:[10.255.255.2]
                    10.255.255.2                  100      0 i
                    RT:65000:101 ET:8
Route Distinguisher: 10.255.255.2:7
*>i[3]:[0]:[32]:[10.255.255.2]
                    10.255.255.2                  100      0 i
                    RT:65000:102 ET:8
Route Distinguisher: 10.255.255.3:5
*>i[3]:[0]:[32]:[10.255.255.3]
                    10.255.255.3                  100      0 i
                    RT:65000:100 ET:8
Route Distinguisher: 10.255.255.3:6
*>i[3]:[0]:[32]:[10.255.255.3]
                    10.255.255.3                  100      0 i
                    RT:65000:101 ET:8
Route Distinguisher: 10.255.255.3:7
*>i[3]:[0]:[32]:[10.255.255.3]
                    10.255.255.3                  100      0 i
                    RT:65000:102 ET:8

Displayed 6 out of 6 total prefixes
```
