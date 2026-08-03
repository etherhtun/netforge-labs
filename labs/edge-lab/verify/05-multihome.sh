#!/usr/bin/env bash
# DONE when: both edges have 2 sessions, AS 65001 sees TWO upstream paths to a
# remote prefix, the transit filter holds, and both remote hosts are reachable.
set -uo pipefail
for n in r1 r2; do
  est=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "show ip bgp summary" 2>/dev/null | grep -c Estab || true)
  printf "  %-3s %s BGP sessions\n" "$n" "$est"
  [ "$est" -ge 2 ] || { echo "  → expected 2 (iBGP + eBGP upstream) on $n."; exit 1; }
done
p=$(docker exec clab-edge-lab-r1 Cli -p 15 -c "show ip bgp 172.16.40.0/24" 2>/dev/null | grep -oE "Paths: [0-9]+" || true)
echo "  r1 -> 172.16.40.0/24 (behind provider B): $p"
echo "$p" | grep -q "Paths: 2" || { echo "  → expected 2 paths, one via each upstream."; exit 1; }
leak=$(docker exec clab-edge-lab-r3 Cli -p 15 -c "show ip bgp neighbors 10.0.13.1 received-routes" 2>/dev/null | grep -c "172.16.40" || true)
if [ "$leak" -ne 0 ]; then
  echo "  → TRANSIT LEAK: provider A is learning provider B's routes from us."
  exit 1
fi
echo "  transit filter: provider A receives only our own prefix ✓"
fail=0
for t in "172.16.30.10:provider A" "172.16.40.10:provider B"; do
  ip=${t%%:*}; label=${t##*:}
  loss=$(docker exec clab-edge-lab-host1 ping -c3 -W2 "$ip" 2>/dev/null | grep -oE "[0-9]+% packet loss")
  printf "  host1 -> %-12s %s\n" "$label" "$loss"
  [ "$loss" = "0% packet loss" ] || fail=1
done
exit $fail
