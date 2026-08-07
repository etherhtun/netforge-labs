#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-ipv6-lab"
echo "  verify IPv6 neighbor reachability from r1-v6 to leaf1-v6..."

for i in {1..5}; do
  out=$(docker exec -i ${FABRIC}-r1-v6 Cli -p 15 <<'EOF'
enable
ping ipv6 2001:db8:1::2 repeat 2
EOF
  )
  if echo "$out" | grep -q "2 packets transmitted, 2 received"; then
    echo "  r1-v6 IPv6 ping to leaf1-v6 (2001:db8:1::2): Operational"
    exit 0
  fi
  sleep 2
done

echo "  r1-v6 IPv6 ping failed:"
echo "$out"
exit 1
