#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-evpn-datacenter-lab"
echo "  verify host1 -> host2 EVPN VXLAN ping across fabric..."
out=$(docker exec -i ${FABRIC}-host1 Cli -p 15 <<'EOF'
enable
ping 10.10.10.20 repeat 4
EOF
)
if echo "$out" | grep -q "bytes from 10.10.10.20"; then
  echo "  host1 -> host2 ping successful"
else
  echo "  ping host2 failed:"
  echo "$out"
  exit 1
fi
