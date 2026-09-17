#!/usr/bin/env bash
# NetForge Labs — Phase 3 Step 03 Verification Gate: MP-iBGP VPNv4 Peer Session
# DONE when: MP-iBGP VPNv4 session between pe1 (2.2.2.2) and pe2 (3.3.3.3) is Established

set -euo pipefail

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

FABRIC="clab-mpls-l3vpn-lab"
echo "  ${c_dim}verify${c_off} checking MP-iBGP VPNv4 session on pe1..."

out=$(docker exec -i "${FABRIC}-pe1" Cli -p 15 -c "show bgp vpn-ipv4 summary" 2>/dev/null)
if echo "$out" | grep -qE "3.3.3.3.*Estab"; then
  echo "  ${c_ok}✅ MP-iBGP VPNv4 peer 3.3.3.3 Established on pe1${c_off}"
  exit 0
else
  echo "  ${c_bad}→ MP-iBGP VPNv4 session with pe2 (3.3.3.3) not Established:${c_off}"
  echo "$out"
  exit 1
fi
