#!/usr/bin/env bash
# ==============================================================================
# NetForge Labs — Automated Step Runner & Verifier (Phase 5 NetDevOps)
# ==============================================================================
set -euo pipefail

FABRIC="clab-netdevops-lab"
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${LAB_DIR}/scripts"
RENDERED_DIR="${LAB_DIR}/rendered"

preflight() {
  if ! docker ps --format '{{.Names}}' | grep -q "^${FABRIC}-leaf1$"; then
    echo "Fabric not running. Deploy first:"
    echo "  sudo containerlab deploy -t topology.clab.yml --max-workers 1"
    exit 1
  fi
}

render_configs() {
  echo "── Step 01 · Render Configuration Templates (Jinja2 + YAML)"
  python3 "${SCRIPTS_DIR}/generate_configs.py"
  echo "  ✅ DONE"
}

push_configs() {
  echo "── Step 02 · Push Rendered Configurations to Fabric Nodes"
  for node in spine1 spine2 leaf1 leaf2; do
    local cfg="${RENDERED_DIR}/${node}.cfg"
    if [ -f "$cfg" ]; then
      printf "  Applying %-25s → %s\n" "$(basename "$cfg")" "$node"
      docker exec -i "${FABRIC}-${node}" Cli -p 15 < "$cfg" > /dev/null 2>&1 || {
        echo "  Failed on ${node}"
        exit 1
      }
    fi
  done
  echo "  ✅ DONE"
}

verify_fabric() {
  echo "── Step 03 · Verify Fabric Health & Neighbor Status"
  out=$(docker exec -i ${FABRIC}-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn summary
EOF
)
  if echo "$out" | grep -q "10.255.0.1"; then
    echo "  leaf1 EVPN session with spine1: Operational"
  else
    echo "  EVPN session not ready"
    exit 1
  fi
  echo "  ✅ DONE"
}

list_steps() {
  echo "Available steps in netdevops-lab:"
  echo "  01 - Render Configuration Templates (Jinja2 + YAML)"
  echo "  02 - Push Rendered Configurations to Fabric Nodes"
  echo "  03 - Verify Fabric Health & Neighbor Status"
  exit 0
}

usage() {
  echo "Usage: ./run.sh [--all | --guided | --render | --push | --verify | --list]"
  exit 0
}

case "${1:-}" in
  --list|-l) list_steps ;;
  --help|-h) usage ;;
  --render) render_configs ;;
  --push) preflight; push_configs ;;
  --verify) preflight; verify_fabric ;;
  --guided|-g)
    preflight
    echo "=========================================================================="
    echo "  📖 FULLY GUIDED WALKTHROUGH: Phase 5 NetDevOps Automation Pipeline"
    echo "=========================================================================="
    echo ""
    echo "  [1/3] Step 01: Template Rendering (Jinja2 + YAML)"
    printf "  \033[2m👉 Press [ENTER] to execute template generation...\033[0m"
    read -r _ < /dev/tty || true
    render_configs

    echo ""
    echo "  [2/3] Step 02: Deploy Rendered Configurations to Fabric"
    printf "  \033[2m👉 Press [ENTER] to push configurations via EOS Cli...\033[0m"
    read -r _ < /dev/tty || true
    push_configs

    echo ""
    echo "  [3/3] Step 03: Automated Network Verification Gate"
    printf "  \033[2m👉 Press [ENTER] to run EVPN verification...\033[0m"
    read -r _ < /dev/tty || true
    verify_fabric
    echo ""
    echo -e "\033[32m🎉 NetDevOps pipeline executed and verified successfully!\033[0m"
    ;;
  --all|-a)
    preflight
    render_configs
    push_configs
    verify_fabric
    echo ""
    echo "All NetDevOps pipeline steps passed cleanly!"
    ;;
  *) usage ;;
esac
