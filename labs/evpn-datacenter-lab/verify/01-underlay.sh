#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-evpn-datacenter-lab"
echo "  verify OSPF underlay & loopback reachability..."
out=$(docker exec -i ${FABRIC}-leaf1 Cli -p 15 <<'EOF'
enable
show ip route 10.255.0.2
EOF
)
if echo "$out" | grep -q "10.255.0.2/32"; then
  echo "  leaf1 OSPF route to spine2 (10.255.0.2): Operational"
else
  echo "  leaf1 OSPF route to spine2 not ready:"
  echo "$out"
  exit 1
fi
