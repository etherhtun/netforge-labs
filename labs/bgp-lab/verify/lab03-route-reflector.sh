#!/usr/bin/env bash
# NetForge Labs — Lab 03 Verification Gate: Route Reflection
# DONE when:
#   1. OSPF underlay is FULL between r1, r2, and r3
#   2. iBGP sessions to clients r2 and r3 are Established
#   3. r2 receives reflected route 172.16.30.0/24 with Originator-ID 3.3.3.3 and Cluster-List 1.1.1.1
#   4. r3 receives reflected route 172.16.20.0/24 with Originator-ID 2.2.2.2 and Cluster-List 1.1.1.1
#   5. End-to-end ping between r2 (172.16.20.1) and r3 (172.16.30.1) passes with 0% packet loss

set -uo pipefail

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

echo "  ${c_dim}verify${c_off} checking OSPF underlay on r1..."
ospf_out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip ospf neighbor" 2>/dev/null)
if ! echo "$ospf_out" | grep -q "2.2.2.2.*FULL" || ! echo "$ospf_out" | grep -q "3.3.3.3.*FULL"; then
  echo "  ${c_bad}→ OSPF underlay is not FULL with both r2 and r3.${c_off}"
  echo "$ospf_out"
  exit 1
fi

echo "  ${c_dim}verify${c_off} checking iBGP sessions on r1..."
bgp_out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" 2>/dev/null)
if ! echo "$bgp_out" | grep -q "2.2.2.2.*Estab" || ! echo "$bgp_out" | grep -q "3.3.3.3.*Estab"; then
  echo "  ${c_bad}→ iBGP client sessions on r1 are not Established.${c_off}"
  echo "$bgp_out"
  exit 1
fi

echo "  ${c_dim}verify${c_off} checking reflected route on r2..."
r2_bgp=$(docker exec clab-bgp-lab-r2 Cli -p 15 -c "show ip bgp 172.16.30.0/24" 2>/dev/null)
if ! echo "$r2_bgp" | grep -iqE "Cluster list: 1.1.1.1|C-LST: 1.1.1.1" || ! echo "$r2_bgp" | grep -iqE "Originator: 3.3.3.3|Or-ID: 3.3.3.3"; then
  echo "  ${c_bad}→ r2 has not received reflected prefix 172.16.30.0/24 with RR attributes.${c_off}"
  echo "$r2_bgp"
  exit 1
fi

echo "  ${c_dim}verify${c_off} checking reflected route on r3..."
r3_bgp=$(docker exec clab-bgp-lab-r3 Cli -p 15 -c "show ip bgp 172.16.20.0/24" 2>/dev/null)
if ! echo "$r3_bgp" | grep -iqE "Cluster list: 1.1.1.1|C-LST: 1.1.1.1" || ! echo "$r3_bgp" | grep -iqE "Originator: 2.2.2.2|Or-ID: 2.2.2.2"; then
  echo "  ${c_bad}→ r3 has not received reflected prefix 172.16.20.0/24 with RR attributes.${c_off}"
  echo "$r3_bgp"
  exit 1
fi

echo "  ${c_dim}verify${c_off} checking end-to-end data plane (r2 -> r3)..."
ping=$(printf 'enable\nping 172.16.30.1 source 172.16.20.1 repeat 3\n' | docker exec -i clab-bgp-lab-r2 Cli -p 15 2>/dev/null)
if echo "$ping" | grep -q " 0% packet loss"; then
  echo "  ${c_ok}✅ Route reflection operational. BGP routes reflected and end-to-end traffic forwarded.${c_off}"
  exit 0
fi

echo "  ${c_bad}→ End-to-end ping between r2 and r3 failed.${c_off}"
echo "$ping" | grep -E "packet loss" || true
exit 1
