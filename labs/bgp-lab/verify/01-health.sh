#!/usr/bin/env bash
# DONE when: every data-plane port reports a real type (not "Unknown").
set -uo pipefail
fail=0
for n in r1 r2 r3; do
  status=$(printf 'enable\nshow interfaces status\n' | docker exec -i "clab-bgp-lab-$n" Cli -p 15 2>/dev/null)
  bad=$(echo "$status" | grep -cE "^Et[0-9].*Unknown" || true)
  ready=$(echo "$status" | grep -cE "^Et[0-9].*EbraTestPhyPort" || true)
  printf "  %-4s %s ready, %s unknown\n" "$n" "$ready" "$bad"
  { [ "$bad" -gt 0 ] || [ "$ready" -eq 0 ]; } && fail=1
done
[ $fail -eq 0 ] || echo "  → boot race: destroy and redeploy with --max-workers 1"
exit $fail
