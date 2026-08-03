#!/usr/bin/env bash
# DONE when: every data-plane port reports a real type (not "Unknown").
set -uo pipefail
fail=0
for n in r1 r2 r3; do
  bad=$(docker exec "clab-bgp-lab-$n" Cli -p 15 -c "show interfaces status" 2>/dev/null \
        | grep -cE "^Et[0-9].*Unknown" || true)
  ready=$(docker exec "clab-bgp-lab-$n" Cli -p 15 -c "show interfaces status" 2>/dev/null \
        | grep -cE "^Et[0-9].*EbraTestPhyPort" || true)
  printf "  %-4s %s ready, %s unknown\n" "$n" "$ready" "$bad"
  { [ "$bad" -gt 0 ] || [ "$ready" -eq 0 ]; } && fail=1
done
[ $fail -eq 0 ] || echo "  → boot race: destroy and redeploy with --max-workers 1"
exit $fail
