#!/usr/bin/env bash
set -euo pipefail
c_dim=$'\033[2m'; c_off=$'\033[0m'

echo "  ${c_dim}verify${c_off} CE1 to CE2 ping end-to-end..."

out=$(docker exec -i clab-mpls-l3vpn-lab-ce1 Cli -p 15 <<'EOF'
enable
ping 10.100.2.2 repeat 3
EOF
)

if echo "$out" | grep -q "bytes from 10.100.2.2"; then
  echo "  ${c_dim}ce1 -> ce2 ping successful${c_off}"
  exit 0
else
  echo "Ping failed:"
  echo "$out"
  exit 1
fi
