#!/usr/bin/env bash
# This step DEMONSTRATES a fault, so it passes when the fault is PRESENT.
# DONE when: r2 has the prefix but resolves it via Management0.
set -uo pipefail
route=$(docker exec clab-bgp-lab-r2 Cli -p 15 -c "show ip route 172.16.30.0/24" 2>/dev/null)
echo "$route" | grep -A1 "B I" || true
if echo "$route" | grep -A1 "B I" | grep -q "Management0"; then
  echo "  ✓ fault reproduced: route resolves via the MANAGEMENT interface."
  echo "    'show ip bgp' shows it valid and best. It is not usable."
  exit 0
fi
if echo "$route" | grep -A1 "B I" | grep -q "Ethernet1"; then
  echo "  → the route is already CORRECT, so there is no fault to observe."
  echo "    next-hop-self should have been removed by this step; allow ~15s"
  echo "    for reconvergence and re-run:  ./run.sh 04"
  exit 1
fi
echo "  → no iBGP route for 172.16.30.0/24 at all. Re-run step 03 first."
exit 1
