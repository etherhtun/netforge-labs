#!/usr/bin/env bash
# ==============================================================================
# NetForge Labs — Automated Step Runner & Verifier (Phase 7 Telemetry)
# ==============================================================================
set -euo pipefail

FABRIC="clab-telemetry-lab"
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="${LAB_DIR}/steps"
VERIFY_DIR="${LAB_DIR}/verify"

STEPS=(
  "01:gNMI Management Service & OpenConfig YANG Setup"
)

preflight() {
  if ! docker ps --format '{{.Names}}' | grep -q "^${FABRIC}-leaf1$"; then
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
    local node=$(echo "$fname" | cut -d- -f2)
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

usage() {
  echo "Usage: ./run.sh [STEP_NUMBER | --all | --list]"
  echo "Examples:"
  echo "  ./run.sh 01      Apply + verify Step 01"
  echo "  ./run.sh --all   Run all steps in sequence"
  echo "  ./run.sh --list  List all available lab steps"
  exit 0
}

list_steps() {
  echo "Available steps in telemetry-lab:"
  for entry in "${STEPS[@]}"; do
    local num="${entry%%:*}"
    local desc="${entry#*:}"
    echo "  ${num} - ${desc}"
  done
  exit 0
}

preflight

if [ $# -eq 0 ]; then usage; fi

case "$1" in
  --list|-l) list_steps ;;
  --all|-a)
    for entry in "${STEPS[@]}"; do
      num="${entry%%:*}"
      desc="${entry#*:}"
      apply_step "$num" "$desc"
    done
    echo ""
    echo "All telemetry pipeline steps passed cleanly!"
    ;;
  *)
    num=$(printf "%02d" "$1" 2>/dev/null || echo "$1")
    found=0
    for entry in "${STEPS[@]}"; do
      snum="${entry%%:*}"
      sdesc="${entry#*:}"
      if [ "$snum" == "$num" ]; then
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
