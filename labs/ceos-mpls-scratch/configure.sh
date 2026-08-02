#!/bin/bash
# Configure MPLS + LDP on a 3-node scratch topology

set -e

FABRIC="ceos-mpls-scratch"

configure_node() {
  local node=$1
  local lo_ip=$2
  local config=$3

  docker exec clab-${FABRIC}-${node} Cli -p 15 <<EOF
enable
configure
$config
end
write memory
exit
EOF
}

echo "=== Configuring P1 (core router) ==="
configure_node "p1" "1.1.1.1" "
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.1.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
interface Ethernet2
 no shutdown
 ip address 10.1.2.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 1.1.1.1
 no shutdown
!
mpls ldp
 router-id 1.1.1.1
 no shutdown
"

echo "=== Configuring PE1 ==="
configure_node "pe1" "2.2.2.2" "
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.1.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 2.2.2.2
 no shutdown
!
mpls ldp
 router-id 2.2.2.2
 no shutdown
"

echo "=== Configuring PE2 ==="
configure_node "pe2" "3.3.3.3" "
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.2.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 3.3.3.3
 no shutdown
!
mpls ldp
 router-id 3.3.3.3
 no shutdown
"

echo ""
echo "=== Configuration complete ==="
echo ""
echo "=== OSPF Neighbors (should be FULL) ==="
docker exec clab-${FABRIC}-p1 Cli -p 15 -c "show ip ospf neighbor" | grep -E "^[0-9]|Neighbor"
echo ""
echo "=== LDP Neighbors (should be ESTABLISHED) ==="
docker exec clab-${FABRIC}-p1 Cli -p 15 -c "show mpls ldp neighbor" | grep -E "^[0-9]|Peer|State"
echo ""
echo "=== MPLS Route on P1 ==="
docker exec clab-${FABRIC}-p1 Cli -p 15 -c "show mpls route"
echo ""
echo "=== MPLS Route on PE1 ==="
docker exec clab-${FABRIC}-pe1 Cli -p 15 -c "show mpls route"
