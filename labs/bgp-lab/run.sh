#!/usr/bin/env bash
# NetForge Labs — Phase 1 Lab 01 step runner
#
# Applies a step's config, then runs its verification gate.
# Refuses to report success unless the gate passes.
#
#   ./run.sh --guided    run interactive step-by-step fully guided walkthrough (-g)
#   ./run.sh 02          apply + verify step 02
#   ./run.sh --verify 02 verify only, change nothing
#   ./run.sh --all       run every step in order, stopping at the first failure
#   ./run.sh --reset     destroy + redeploy the fabric, then run every step
#   ./run.sh --list      show the steps
#
# The .cfg files here are the SAME files the published guide displays.
# Nothing is duplicated, so nothing can drift.

set -uo pipefail
cd "$(dirname "$0")"

FABRIC="clab-bgp-lab"
STEPS=(01 02 03 04 05)

declare -A TITLE=(
  [01]="Health check — interfaces ready"
  [02]="OSPF underlay (r1, r2)"
  [03]="BGP sessions (r1, r2, r3)"
  [04]="Observe the next-hop trap"
  [05]="Fix with next-hop-self"
)

c_ok=$'\033[32m'; c_bad=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_ok=; c_bad=; c_dim=; c_off=; }

die() { echo "${c_bad}$*${c_off}" >&2; exit 1; }

preflight() {
  command -v docker >/dev/null || die "docker not found"
  docker ps --format '{{.Names}}' | grep -q "^${FABRIC}-r1$" \
    || die "Fabric not running. Deploy first:
  sudo containerlab deploy -t topology.clab.yml --max-workers 1"
}

apply_step() {
  local step=$1 applied=0
  for cfg in steps/${step}-*.cfg; do
    [ -e "$cfg" ] || continue
    # Convention: steps/<NN>-<node>-<description>.cfg  → node is field 2.
    # The node must come BEFORE the description: descriptions contain hyphens
    # (e.g. "next-hop-self"), so taking the last field parses them as the node.
    local node; node=$(basename "$cfg" | cut -d- -f2)
    printf "  ${c_dim}apply${c_off} %-28s → %s\n" "$(basename "$cfg")" "$node"
    # -i is mandatory: without stdin attached the CLI exits 0 having done nothing
    if ! docker exec -i "${FABRIC}-${node}" Cli -p 15 < "$cfg" > /tmp/nf-apply.$$ 2>&1; then
      cat /tmp/nf-apply.$$; rm -f /tmp/nf-apply.$$
      die "  config apply failed on ${node}"
    fi
    # EOS prints this mid-parse before 'no switchport' takes effect; harmless.
    grep -v "not a routed port" /tmp/nf-apply.$$ | grep -iE "^% |invalid|error" && {
      rm -f /tmp/nf-apply.$$; die "  config rejected on ${node}"; }
    rm -f /tmp/nf-apply.$$
    applied=1
  done
  [ $applied -eq 1 ] && sleep 12   # let the control plane settle before verifying
  return 0
}

verify_step() {
  local step=$1 script="verify/${step}-"*.sh
  # shellcheck disable=SC2086
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

run_guided_step() {
  local step=$1
  echo
  echo "=========================================================================="
  echo "  📖 FULLY GUIDED WALKTHROUGH: Step ${step} · ${TITLE[$step]:-}"
  echo "=========================================================================="
  
  echo
  echo "  [1/3] Configuration Snippets to Apply:"
  for cfg in steps/${step}-*.cfg; do
    [ -e "$cfg" ] || continue
    local node; node=$(basename "$cfg" | cut -d- -f2)
    echo "  ------------------------------------------------------------------------"
    echo "  📄 Target Node: ${node} (${cfg})"
    echo "  ------------------------------------------------------------------------"
    cat "$cfg" | sed 's/^/    /'
    echo
  done

  printf "  ${c_dim}👉 Press [ENTER] to apply configuration to target router nodes...${c_off}"
  read -r _ < /dev/tty || true

  echo
  echo "  Applying configuration..."
  apply_step "$step"

  echo
  echo "  [2/3] Suggested CLI Commands for Manual Verification:"
  case "$step" in
    01) echo "    docker exec -it clab-bgp-lab-r1 Cli -p 15 -c \"show interfaces status\"" ;;
    02) echo "    docker exec -it clab-bgp-lab-r1 Cli -p 15 -c \"show ip ospf neighbor\"" ;;
    03) echo "    docker exec -it clab-bgp-lab-r1 Cli -p 15 -c \"show ip bgp summary\"" ;;
    04) echo "    docker exec -it clab-bgp-lab-r1 Cli -p 15 -c \"show ip route bgp\"" ;;
    05) echo "    docker exec -it clab-bgp-lab-r1 Cli -p 15 -c \"show ip bgp\"" ;;
  esac
  echo

  printf "  ${c_dim}👉 Press [ENTER] to run automated verification gate...${c_off}"
  read -r _ < /dev/tty || true

  echo
  echo "  [3/3] Running Automated Verification Gate:"
  if verify_step "$step"; then
    echo "  ${c_ok}✅ STEP ${step} PASSED!${c_off}"
    return 0
  else
    echo "  ${c_bad}❌ STEP ${step} FAILED — fix configuration before proceeding${c_off}"
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
  --guided|-g)
    preflight
    echo "Starting Fully Guided Interactive Walkthrough across all steps..."
    for s in "${STEPS[@]}"; do
      run_guided_step "$s" || die "
Stopped at step ${s}. Fix issue before continuing."
    done
    echo
    echo "${c_ok}🎉 All guided steps completed successfully!${c_off}" ;;
  --all)
    preflight
    for s in "${STEPS[@]}"; do
      run_step "$s" || die "
Stopped at step ${s}. Later steps build on this one, so continuing
would only produce confusing failures further along."
    done
    echo
    echo "${c_ok}All steps passed.${c_off} The fabric is in the lab's final state." ;;
  [0-9]*)
    preflight; run_step "$1" || exit 1 ;;
  *)
    die "usage: ./run.sh [--all | --guided | --list | --verify <step> | <step>]" ;;
esac
