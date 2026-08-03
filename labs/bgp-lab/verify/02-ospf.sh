#!/usr/bin/env bash
# DONE when: r1 has an OSPF neighbour in FULL state.
set -uo pipefail
out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip ospf neighbor" 2>/dev/null)
echo "$out" | grep -E "FULL" || true
if echo "$out" | grep -q "FULL"; then exit 0; fi
echo "  → no FULL adjacency. Check 'no switchport' and 'ip ospf area' on Ethernet1."
exit 1
