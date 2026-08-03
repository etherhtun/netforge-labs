#!/usr/bin/env bash
# DONE when: all 4 switches/routers have ready ports and both hosts are addressed.
set -uo pipefail
fail=0
for n in r1 r2 r3 r4 sw1; do
  ready=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "show interfaces status" 2>/dev/null \
          | grep -cE "^Et[0-9].*EbraTestPhyPort" || true)
  bad=$(docker exec "clab-edge-lab-$n" Cli -p 15 -c "show interfaces status" 2>/dev/null \
          | grep -cE "^Et[0-9].*Unknown" || true)
  printf "  %-4s %s ready, %s unknown\n" "$n" "$ready" "$bad"
  { [ "$bad" -gt 0 ] || [ "$ready" -eq 0 ]; } && fail=1
done
for h in host1 host2 host3; do
  ip=$(docker exec "clab-edge-lab-$h" ip -o addr show eth1 2>/dev/null | grep -oE "inet [0-9.]+" | awk '{print $2}')
  printf "  %-6s %s\n" "$h" "${ip:-NO ADDRESS}"
  [ -z "$ip" ] && fail=1
done
[ $fail -eq 0 ] || echo "  → destroy and redeploy with --max-workers 1"
exit $fail
