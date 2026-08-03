#!/usr/bin/env bash
# DONE when: OSPF is FULL between r1/r2 AND VRRP has one Master and one Backup.
set -uo pipefail
ospf=$(docker exec clab-edge-lab-r1 Cli -p 15 -c "show ip ospf neighbor" 2>/dev/null)
echo "$ospf" | grep -E "FULL" || true
echo "$ospf" | grep -q FULL || { echo "  → no OSPF adjacency on the r1-r2 link."; exit 1; }
s1=$(docker exec clab-edge-lab-r1 Cli -p 15 -c "show vrrp" 2>/dev/null | grep -m1 -oE "Master|Backup")
s2=$(docker exec clab-edge-lab-r2 Cli -p 15 -c "show vrrp" 2>/dev/null | grep -m1 -oE "Master|Backup")
printf "  VRRP: r1=%s r2=%s\n" "${s1:-none}" "${s2:-none}"
[ "$s1" = "Master" ] && [ "$s2" = "Backup" ] && exit 0
echo "  → expected r1 Master (priority 110) and r2 Backup (100). Allow ~15s."
exit 1
