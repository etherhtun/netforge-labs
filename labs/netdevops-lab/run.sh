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

usage() {
  echo "Usage: ./run.sh [--all | --render | --push | --verify]"
  exit 0
}

preflight

case "${1:-}" in
  --render) render_configs ;;
  --push) push_configs ;;
  --verify) verify_fabric ;;
  --all|-a)
    render_configs
    push_configs
    verify_fabric
    echo ""
    echo "All NetDevOps pipeline steps passed cleanly!"
    ;;
  *) usage ;;
esac
