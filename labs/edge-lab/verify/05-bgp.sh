#!/usr/bin/env bash
# DONE when: BOTH edge routers have eBGP up, r3 sees TWO paths, and host1 reaches host2.
set -uo pipefail
for n in r1 r2; do
  n_est=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "show ip bgp summary" 2>/dev/null | grep -c Estab || true)
  printf "  %-3s %s BGP sessions established\n" "$n" "$n_est"
  [ "$n_est" -ge 2 ] || { echo "  → expected 2 (iBGP + eBGP) on $n."; exit 1; }
done
paths=$(docker exec clab-edge-lab-r3 Cli -p 15 -c "show ip bgp 192.168.10.0/24" 2>/dev/null | grep -oE "Paths: [0-9]+" || true)
echo "  r3 -> 192.168.10.0/24: $paths"
echo "$paths" | grep -q "Paths: 2" || { echo "  → expected 2 paths (dual-homed). Check both eBGP sessions."; exit 1; }
echo "  host1 -> host2:"
ping=$(docker exec clab-edge-lab-host1 ping -c3 172.16.30.10 2>/dev/null)
echo "$ping" | grep -E "packet loss" | sed 's/^/    /' || true
echo "$ping" | grep -q " 0% packet loss" && exit 0
echo "  → end-to-end forwarding failed."
exit 1
