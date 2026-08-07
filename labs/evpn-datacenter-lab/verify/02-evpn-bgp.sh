#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-evpn-datacenter-lab"
echo "  verify MP-iBGP EVPN peerings..."
out=$(docker exec -i ${FABRIC}-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn summary
EOF
)
if echo "$out" | grep "10.255.0.1" | grep -vE "Idle|Active|Connect" > /dev/null; then
  echo "  leaf1 EVPN peering to spine1: Established"
else
  echo "  leaf1 EVPN peering to spine1 not ready:"
  echo "$out"
  exit 1
fi
