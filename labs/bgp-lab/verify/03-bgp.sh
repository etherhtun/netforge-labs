#!/usr/bin/env bash
# DONE when: r1 has BOTH peers Established (iBGP 2.2.2.2 and eBGP 10.0.13.3).
set -uo pipefail
out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" 2>/dev/null)
echo "$out" | grep -E "^  (2\.2\.2\.2|10\.0\.13\.3)" || true
n=$(echo "$out" | grep -cE "^  (2\.2\.2\.2|10\.0\.13\.3).*Estab" || true)
[ "$n" -eq 2 ] && exit 0
echo "  → expected 2 Established peers, found $n."
echo "    'Active' means TCP failed — for iBGP check the loopback is in OSPF."
exit 1
