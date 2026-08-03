#!/usr/bin/env bash
# DONE when: r3 is advertising its network and host2 is reachable from r3.
set -uo pipefail
docker exec clab-edge-lab-r3 Cli -p 15 -c "show ip bgp" 2>/dev/null | grep "172.16.30.0/24" || true
docker exec clab-edge-lab-r3 Cli -p 15 -c "ping 172.16.30.10 repeat 2" 2>/dev/null | grep -E "packet loss" || true
docker exec clab-edge-lab-r3 Cli -p 15 -c "ping 172.16.30.10 repeat 2" 2>/dev/null | grep -q " 0% packet loss" && exit 0
echo "  → r3 cannot reach host2. Check Ethernet3 addressing."
exit 1
