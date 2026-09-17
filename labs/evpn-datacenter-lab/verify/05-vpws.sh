#!/usr/bin/env bash
# NetForge Labs — Phase 4 Step 05 Verification Gate: EVPN-VPWS
# DONE when: VPWS patch panel and EVPN service is configured on leaf1

set -euo pipefail

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

FABRIC="clab-evpn-datacenter-lab"
echo "  ${c_dim}verify${c_off} checking EVPN-VPWS on leaf1..."

out=$(docker exec -i "${FABRIC}-leaf1" Cli -p 15 <<'EOF'
enable
show patch panel
EOF
)

if echo "$out" | grep -qiE "VPWS-CUSTOMER-A|Ethernet3"; then
  echo "  ${c_ok}✅ leaf1 EVPN-VPWS patch panel active${c_off}"
  exit 0
else
  echo "  ${c_bad}→ leaf1 VPWS not active:${c_off}"
  echo "$out"
  exit 1
fi
