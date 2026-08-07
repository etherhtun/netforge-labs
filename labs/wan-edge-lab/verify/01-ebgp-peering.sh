#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-wan-edge-lab"
echo "  verify dual-ISP eBGP peering on wan-edge1..."

for i in {1..10}; do
  out=$(docker exec -i ${FABRIC}-wan-edge1 Cli -p 15 <<'EOF'
enable
show bgp summary
EOF
  )
  if echo "$out" | grep -q "198.51.100.2"; then
    echo "  wan-edge1 eBGP session with Primary ISP (65100): Operational"
    exit 0
  fi
  sleep 3
done

echo "  wan-edge1 eBGP session not ready after retries:"
echo "$out"
exit 1
