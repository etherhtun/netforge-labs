#!/usr/bin/env bash
# DONE when: IS-IS neighbor adjacency is Up AND end-to-end BGP forwarding succeeds.
set -uo pipefail

isis_out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis neighbors" 2>/dev/null)
echo "$isis_out"
if ! echo "$isis_out" | grep -iE "r2|0000.0000.0002" | grep -qi "Up"; then
  echo "  → IS-IS adjacency with r2 is not Up yet."
  exit 1
fi

bgp_out=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" 2>/dev/null)
if ! echo "$bgp_out" | grep -q "2.2.2.2.*Estab"; then
  echo "  → iBGP session over IS-IS underlay is not Established."
  exit 1
fi

ping=$(printf 'enable\nping 172.16.30.1 source 172.16.20.1 repeat 3\n' | docker exec -i clab-bgp-lab-r2 Cli -p 15 2>/dev/null)
echo "$ping" | grep -E "packet loss" || true
if echo "$ping" | grep -q " 0% packet loss"; then
  echo "  ✅ IS-IS underlay migration complete. End-to-end BGP forwarding verified."
  exit 0
fi

echo "  → End-to-end ping failed across IS-IS underlay."
exit 1
