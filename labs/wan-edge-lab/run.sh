#!/usr/bin/env bash
# ==============================================================================
# NetForge Labs — Automated Step Runner & Verifier (Phase 6 WAN Edge)
# ==============================================================================
set -euo pipefail

FABRIC="clab-wan-edge-lab"
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="${LAB_DIR}/steps"
VERIFY_DIR="${LAB_DIR}/verify"

STEPS=(
  "01:Dual-ISP eBGP Multihoming & Peering Setup"
)

preflight() {
  if ! docker ps --format '{{.Names}}' | grep -q "^${FABRIC}-wan-edge1$"; then
    echo "Fabric not running. Deploy first:"
    echo "  sudo containerlab deploy -t topology.clab.yml --max-workers 1"
    exit 1
  fi
}

apply_step() {
  local num="$1"
  local desc="$2"
  echo ""
  echo "── Step ${num} · ${desc}"

  for cfg in "${STEPS_DIR}/${num}"-*.cfg; do
    [ -f "$cfg" ] || continue
    local fname=$(basename "$cfg")
    local node=$(echo "$fname" | cut -d- -f2-3 | sed 's/-ebgp//;s/-gnmi//')
    local target_container="${FABRIC}-${node}"

    printf "  %-35s → %s\n" "$fname" "$node"
    docker exec -i "$target_container" Cli -p 15 < "$cfg" > /dev/null 2>&1 || {
      echo "  config apply failed on ${node}"
      exit 1
    }
  done

  local vscript="${VERIFY_DIR}/${num}-"*.sh
  for v in $vscript; do
    if [ -f "$v" ]; then
      if ! bash "$v"; then
        echo "  ❌ FAILED — fix this before continuing"
        echo "Stopped at step ${num}."
        exit 1
      fi
    fi
  done

  echo "  ✅ DONE"
}

run_guided_step() {
  local num="$1"
  local desc="$2"
  echo ""
  echo "=========================================================================="
  echo "  📖 FULLY GUIDED WALKTHROUGH: Step ${num} · ${desc}"
  echo "=========================================================================="

  echo ""
  echo "  [1/3] Configuration Snippets to Apply:"
  for cfg in "${STEPS_DIR}/${num}"-*.cfg; do
    [ -f "$cfg" ] || continue
    local fname=$(basename "$cfg")
    local node=$(echo "$fname" | cut -d- -f2-3 | sed 's/-ebgp//;s/-gnmi//')
    echo "  ------------------------------------------------------------------------"
    echo "  📄 Target Node: ${node} (${fname})"
    echo "  ------------------------------------------------------------------------"
    cat "$cfg" | sed 's/^/    /'
    echo ""
  done

  printf "  \033[2m👉 Press [ENTER] to apply configuration to target router nodes...\033[0m"
  read -r _ < /dev/tty || true

  echo ""
  echo "  Applying configuration..."
  for cfg in "${STEPS_DIR}/${num}"-*.cfg; do
    [ -f "$cfg" ] || continue
    local fname=$(basename "$cfg")
    local node=$(echo "$fname" | cut -d- -f2-3 | sed 's/-ebgp//;s/-gnmi//')
    local target_container="${FABRIC}-${node}"

    printf "  %-35s → %s\n" "$fname" "$node"
    docker exec -i "$target_container" Cli -p 15 < "$cfg" > /dev/null 2>&1 || {
      echo "  config apply failed on ${node}"
      exit 1
    }
  done

  echo ""
  echo "  [2/3] Suggested CLI Commands for Manual Verification:"
  echo "    docker exec -it ${FABRIC}-wan-edge1 Cli -p 15 -c \"show ip bgp summary\""
  echo ""

  printf "  \033[2m👉 Press [ENTER] to run automated verification gate...\033[0m"
  read -r _ < /dev/tty || true

  echo ""
  echo "  [3/3] Running Automated Verification Gate:"
  local vscript="${VERIFY_DIR}/${num}-"*.sh
  for v in $vscript; do
    if [ -f "$v" ]; then
      if ! bash "$v"; then
        echo "  ❌ STEP ${num} FAILED — fix configuration before proceeding"
        return 1
      fi
    fi
  done

  echo "  \033[32m✅ STEP ${num} PASSED!\033[0m"
  return 0
}

usage() {
  echo "Usage: ./run.sh [STEP_NUMBER | --all | --guided | --list]"
  echo "Examples:"
  echo "  ./run.sh 01       Apply + verify Step 01"
  echo "  ./run.sh --guided Interactive step-by-step guided walkthrough"
  echo "  ./run.sh --all    Run all steps in sequence"
  echo "  ./run.sh --list   List all available lab steps"
  exit 0
}

list_steps() {
  echo "Available steps in wan-edge-lab:"
  for entry in "${STEPS[@]}"; do
    local num="${entry%%:*}"
    local desc="${entry#*:}"
    echo "  ${num} - ${desc}"
  done
  exit 0
}

if [ $# -eq 0 ]; then usage; fi

case "$1" in
  --list|-l) list_steps ;;
  --help|-h) usage ;;
  --guided|-g)
    preflight
    echo "Starting Fully Guided Interactive Walkthrough across all steps..."
    for entry in "${STEPS[@]}"; do
      num="${entry%%:*}"
      desc="${entry#*:}"
      run_guided_step "$num" "$desc" || exit 1
    done
    echo ""
    echo -e "\033[32m🎉 All guided steps completed successfully!\033[0m"
    ;;
  --all|-a)
    preflight
    for entry in "${STEPS[@]}"; do
      num="${entry%%:*}"
      desc="${entry#*:}"
      apply_step "$num" "$desc"
    done
    echo ""
    echo "All WAN edge pipeline steps passed cleanly!"
    ;;
  *)
    num=$(printf "%02d" "$1" 2>/dev/null || echo "$1")
    found=0
    for entry in "${STEPS[@]}"; do
      snum="${entry%%:*}"
      sdesc="${entry#*:}"
      if [ "$snum" == "$num" ]; then
        preflight
        apply_step "$snum" "$sdesc"
        found=1
        break
      fi
    done
    if [ "$found" -eq 0 ]; then
      echo "Unknown step: $1"
      usage
    fi
    ;;
esac
