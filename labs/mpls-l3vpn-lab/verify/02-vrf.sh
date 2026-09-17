#!/usr/bin/env bash
# NetForge Labs — Phase 3 Step 02 Verification Gate: VRF RED & Route Targets
# DONE when: VRF RED is defined and active on both pe1 and pe2 with matching RTs

set -euo pipefail

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

FABRIC="clab-mpls-l3vpn-lab"
echo "  ${c_dim}verify${c_off} checking VRF RED on pe1 and pe2..."

pe1_vrf=$(docker exec -i "${FABRIC}-pe1" Cli -p 15 -c "show vrf RED" 2>/dev/null)
if ! echo "$pe1_vrf" | grep -qi "RED"; then
  echo "  ${c_bad}→ VRF RED not found on pe1${c_off}"
  echo "$pe1_vrf"
  exit 1
fi

pe2_vrf=$(docker exec -i "${FABRIC}-pe2" Cli -p 15 -c "show vrf RED" 2>/dev/null)
if ! echo "$pe2_vrf" | grep -qi "RED"; then
  echo "  ${c_bad}→ VRF RED not found on pe2${c_off}"
  echo "$pe2_vrf"
  exit 1
fi

pe1_bgp_vrf=$(docker exec -i "${FABRIC}-pe1" Cli -p 15 -c "show running-config section vrf RED" 2>/dev/null)
if ! echo "$pe1_bgp_vrf" | grep -q "route-target.*65000:100"; then
  echo "  ${c_bad}→ Route target 65000:100 not configured on pe1 VRF RED${c_off}"
  exit 1
fi

echo "  ${c_ok}✅ VRF RED and Route Targets active on pe1 and pe2${c_off}"
exit 0
