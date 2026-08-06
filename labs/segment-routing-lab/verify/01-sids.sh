#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-segment-routing-lab"
echo "  verify IS-IS Segment Routing SIDs on pe1..."
out=$(docker exec -i ${FABRIC}-pe1 Cli -p 15 <<'EOF'
enable
show isis segment-routing prefix-segments
EOF
)
if echo "$out" | grep -q "10.255.0.5/32"; then
  echo "  pe1 Node SID to pe2 (10.255.0.5): Operational"
else
  echo "  pe1 Node SID to pe2 not ready:"
  echo "$out"
  exit 1
fi
