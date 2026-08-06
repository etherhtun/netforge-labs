#!/usr/bin/env bash
set -euo pipefail
c_dim=$'\033[2m'; c_off=$'\033[0m'

echo "  ${c_dim}verify${c_off} OSPF & LDP underlay..."

# Verify LDP neighbor on pe1
out=$(docker exec -i clab-mpls-l3vpn-lab-pe1 Cli -p 15 <<'EOF'
enable
show mpls ldp neighbor
EOF
)

if echo "$out" | grep -q "Peer LDP Ident: 1.1.1.1"; then
  echo "  ${c_dim}pe1 LDP session to p1 (1.1.1.1): Operational${c_off}"
  exit 0
else
  echo "LDP session to 1.1.1.1 not ready:"
  echo "$out"
  exit 1
fi
