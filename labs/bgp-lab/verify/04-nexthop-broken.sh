#!/usr/bin/env bash
# This step DEMONSTRATES a fault. It "passes" when the fault is present.
# DONE when: r2 has the prefix but resolves it via Management0 (the trap).
set -uo pipefail
route=$(docker exec clab-bgp-lab-r2 Cli -p 15 -c "show ip route 172.16.30.0/24" 2>/dev/null)
echo "$route" | grep -A1 "B I" || true
if echo "$route" | grep -A1 "B I" | grep -q "Management0"; then
  echo "  ✓ fault reproduced: route resolves via the MANAGEMENT interface."
  echo "    'show ip bgp' shows it valid and best. It is not usable."
  exit 0
fi
echo "  → expected the route via Management0. Did you already apply step 05?"
exit 1
