#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-evpn-datacenter-lab"
echo "  verify EVPN Route Type 3 (IMET)..."
out=$(docker exec -i ${FABRIC}-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type imet
EOF
)
if echo "$out" | grep -q "10.255.1.12"; then
  echo "  leaf1 learned route-type 3 from leaf2: Operational"
else
  echo "  leaf1 did not learn route-type 3 from leaf2:"
  echo "$out"
  exit 1
fi
