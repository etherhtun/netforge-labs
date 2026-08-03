#!/usr/bin/env bash
# DONE when: sw1 has VLAN 10 active with all three ports in it.
set -uo pipefail
out=$(docker exec clab-edge-lab-sw1 Cli -p 15 -c "show vlan 10" 2>/dev/null)
echo "$out" | grep -E "^10" || true
echo "$out" | grep -q "Et1, Et2, Et3" && exit 0
echo "  → expected Et1, Et2 and Et3 in VLAN 10."
exit 1
