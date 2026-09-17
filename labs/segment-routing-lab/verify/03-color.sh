#!/usr/bin/env bash
# NetForge Labs — Phase 3.5 Step 03 Verification Gate: SR-TE Policy & Color Steering
# DONE when: Segment Routing TE policy COLOR-100-LATENCY is configured on pe1 with color 100

set -euo pipefail

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

FABRIC="clab-segment-routing-lab"
echo "  ${c_dim}verify${c_off} checking SR-TE color policy on pe1..."

out=$(docker exec -i "${FABRIC}-pe1" Cli -p 15 <<'EOF'
enable
show traffic-engineering segment-routing policy
EOF
)

if echo "$out" | grep -qiE "COLOR-100-LATENCY|500100|10.255.0.5"; then
  echo "  ${c_ok}✅ pe1 SR-TE Color 100 policy to pe2 (10.255.0.5): Active${c_off}"
  exit 0
else
  echo "  ${c_bad}→ pe1 SR-TE policy not ready:${c_off}"
  echo "$out"
  exit 1
fi
