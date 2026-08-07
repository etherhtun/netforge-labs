#!/usr/bin/env bash
set -euo pipefail
FABRIC="clab-security-lab"
echo "  verify Control Plane Policing (CoPP) policy on spine1..."
out=$(docker exec -i ${FABRIC}-spine1 Cli -p 15 <<'EOF'
enable
show policy-map type copp
EOF
)
if echo "$out" | grep -iq "POLICY-COPP"; then
  echo "  spine1 CoPP Policy Engine: Operational"
else
  echo "  spine1 CoPP Policy Engine not active:"
  echo "$out"
  exit 1
fi
