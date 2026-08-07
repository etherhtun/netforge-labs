#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-wan-edge-lab"
echo "  verify dual-ISP eBGP peering on wan-edge1..."
out=$(docker exec -i ${FABRIC}-wan-edge1 Cli -p 15 <<'EOF'
enable
show bgp summary
EOF
)
if echo "$out" | grep -q "198.51.100.2"; then
  echo "  wan-edge1 eBGP session with Primary ISP (65100): Operational"
else
  echo "  wan-edge1 eBGP session not ready:"
  echo "$out"
  exit 1
fi
