#!/usr/bin/env bash
# DONE when: both providers are up, peered with each other, and reach their hosts.
set -uo pipefail
for t in "r3:10.0.34.4:172.16.30.10:A" "r4:10.0.34.3:172.16.40.10:B"; do
  IFS=: read -r n peer host label <<<"$t"
  est=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "show ip bgp summary" 2>/dev/null | grep "$peer" | grep -c Estab || true)
  loss=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "ping $host repeat 2" 2>/dev/null | grep -oE "[0-9]+% packet loss")
  printf "  provider %s (%s): peering=%s  host=%s\n" "$label" "$n" "$est" "$loss"
  [ "$est" -eq 1 ] && [ "$loss" = "0% packet loss" ] || { echo "  → provider $label not ready."; exit 1; }
done
