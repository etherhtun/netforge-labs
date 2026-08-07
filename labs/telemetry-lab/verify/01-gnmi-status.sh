#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-telemetry-lab"
echo "  verify gNMI management service on leaf1..."
out=$(docker exec -i ${FABRIC}-leaf1 Cli -p 15 <<'EOF'
enable
show management api gnmi
EOF
)
if echo "$out" | grep -iq "enabled"; then
  echo "  leaf1 gNMI Management Service: Operational"
else
  echo "  leaf1 gNMI service not enabled:"
  echo "$out"
  exit 1
fi
