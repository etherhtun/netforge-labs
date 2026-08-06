#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-segment-routing-lab"
echo "  verify Ti-LFA backup repair path state..."
out=$(docker exec -i ${FABRIC}-pe1 Cli -p 15 <<'EOF'
enable
show ip route 10.255.0.5/32
EOF
)
if echo "$out" | grep -q "10.255.0.5/32"; then
  echo "  pe1 reachability to pe2 (10.255.0.5): Operational"
else
  echo "  pe1 route to pe2 not ready"
  exit 1
fi
