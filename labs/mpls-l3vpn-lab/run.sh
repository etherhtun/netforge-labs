#!/usr/bin/env bash
# NetForge Labs — Phase 3 (MPLS & L3VPN) step runner
#
#   ./run.sh 01          apply + verify step 01
#   ./run.sh --verify 01 verify only
#   ./run.sh --all       run every step in order
#   ./run.sh --reset     destroy + redeploy fabric, then run all steps
#   ./run.sh --list      show available steps

set -uo pipefail
cd "$(dirname "$0")"

FABRIC="clab-mpls-l3vpn-lab"
STEPS=(01 02 03 04)

declare -A TITLE=(
  [01]="MPLS + LDP Underlay — OSPF & LDP Label Exchange"
  [02]="Customer VRF RED & Route Target Configuration"
  [03]="MP-iBGP VPNv4 Peer Session Setup"
  [04]="PE-CE Routing & End-to-End Data Plane Verification"
)

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

die() { echo "${c_bad}$*${c_off}" >&2; exit 1; }

preflight() {
  command -v docker >/dev/null || die "docker not found"
  docker ps --format '{{.Names}}' | grep -q "^${FABRIC}-pe1$" \
    || die "Fabric not running. Deploy first:
  sudo containerlab deploy -t topology.clab.yml --max-workers 1"
}

apply_step() {
  local step=$1 applied=0
  for cfg in steps/${step}-*.cfg; do
    [ -e "$cfg" ] || continue
    local node; node=$(basename "$cfg" | cut -d- -f2)
    printf "  ${c_dim}apply${c_off} %-28s → %s\n" "$(basename "$cfg")" "$node"
    if ! docker exec -i "${FABRIC}-${node}" Cli -p 15 < "$cfg" > /tmp/nf-apply.$$ 2>&1; then
      cat /tmp/nf-apply.$$; rm -f /tmp/nf-apply.$$
      die "  config apply failed on ${node}"
    fi
    grep -v "not a routed port" /tmp/nf-apply.$$ | grep -iE "^% |invalid|error" && {
      rm -f /tmp/nf-apply.$$; die "  config rejected on ${node}"; }
    rm -f /tmp/nf-apply.$$
    applied=1
  done
  [ $applied -eq 1 ] && sleep 5
  return 0
}

verify_step() {
  local step=$1 script="verify/${step}-"*.sh
  set -- $script
  [ -e "$1" ] || { echo "  (no gate for step ${step})"; return 0; }
  bash "$1"
}

run_step() {
  local step=$1
  echo
  echo "── Step ${step} · ${TITLE[$step]:-}"
  apply_step "$step"
  if verify_step "$step"; then
    echo "  ${c_ok}✅ DONE${c_off}"
    return 0
  else
    echo "  ${c_bad}❌ FAILED — fix this before continuing${c_off}"
    return 1
  fi
}

case "${1:---all}" in
  --reset)
    command -v containerlab >/dev/null || die "containerlab not found"
    echo "Destroying and redeploying the fabric..."
    sudo containerlab destroy -t topology.clab.yml >/dev/null 2>&1
    sudo containerlab deploy -t topology.clab.yml --max-workers 1 >/dev/null \
      || die "deploy failed"
    echo "Fabric redeployed."
    exec "$0" --all ;;
  --list)
    for s in "${STEPS[@]}"; do printf "  %s  %s\n" "$s" "${TITLE[$s]}"; done ;;
  --verify)
    preflight; step="${2:?usage: ./run.sh --verify <step>}"
    verify_step "$step" && echo "  ${c_ok}✅ DONE${c_off}" || { echo "  ${c_bad}❌ FAILED${c_off}"; exit 1; } ;;
  --all)
    preflight
    for s in "${STEPS[@]}"; do
      run_step "$s" || die "Stopped at step ${s}."
    done
    echo
    echo "${c_ok}All steps passed.${c_off} The fabric is in the lab's final state." ;;
  [0-9]*)
    preflight; run_step "$1" || exit 1 ;;
  *)
    die "usage: ./run.sh [--all | --list | --verify <step> | <step>]" ;;
esac
