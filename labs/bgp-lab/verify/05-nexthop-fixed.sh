#!/usr/bin/env bash
# DONE when: r2 resolves the prefix via Ethernet1 AND traffic forwards.
set -uo pipefail
route=$(printf 'enable\nshow ip route 172.16.30.0/24\n' | docker exec -i clab-bgp-lab-r2 Cli -p 15 2>/dev/null)
echo "$route" | grep -A1 "B I" || true
if ! echo "$route" | grep -A1 "B I" | grep -q "Ethernet1"; then
  echo "  → still not resolving via Ethernet1. Allow ~10s for reconvergence."
  exit 1
fi
ping=$(printf 'enable\nping 172.16.30.1 source 172.16.20.1 repeat 3\n' | docker exec -i clab-bgp-lab-r2 Cli -p 15 2>/dev/null)
echo "$ping" | grep -E "packet loss" || true
echo "$ping" | grep -q " 0% packet loss" && exit 0
echo "  → route is correct but forwarding failed."
exit 1
