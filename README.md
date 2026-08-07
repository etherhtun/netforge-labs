# ⚡ NetForge Labs

> **Learn networking by building it** — hands-on, executable lab-driven courses for BGP, MPLS L3VPN, Segment Routing, and VXLAN-EVPN Datacenter Fabrics.

📖 **Live Documentation Portal**: **[https://netforge-labs.pages.dev](https://netforge-labs.pages.dev)**

---

## 🏛️ Curriculum Roadmap & Lab Matrix

NetForge Labs takes you from foundational routing protocols up to enterprise-grade service provider and data center fabric architectures. Every lab includes **single-source-of-truth configuration snippets**, **automated step runners (`run.sh`)**, and **live verification gates**:

| Phase | Course Focus | Validated Environment | Status |
|---|---|---|---|
| **Phase 0** | **IGP Fundamentals** (OSPF Area 0 & IS-IS Wide Metrics RFC 5305) | Arista cEOS | ✅ Published |
| **Phase 1** | **BGP Mechanics** (eBGP/iBGP Loop Prevention, 10-Step Path Selection, RRs) | Arista cEOS | ✅ Published |
| **Phase 3** | **MPLS Backbone & L3VPNs** (LDP, PHP Label 3, VRF RDs/RTs, Inter-AS Options A/B/C, L2VPN) | Arista cEOS 5-Node | ✅ Published |
| **Phase 3.5** | **Segment Routing (SR-MPLS)** (SRGB 16000–23999, Node SIDs, Ti-LFA Sub-50ms FRR, SR-PCE) | Arista cEOS 5-Node | ✅ Published |
| **Phase 4** | **VXLAN-EVPN Datacenter Fabrics** (Pure L2VNI, Symmetric IRB, ESI All-Active, VPWS/ELAN, DCI) | Arista cEOS 6-Node | ✅ Published |
| **Phase 5** | **NetDevOps & Automation** (PyATS, Batfish, CI/CD Pipelines) | Python & Containerlab | 📋 Planned |

---

## 🛠️ The Hybrid Lab Approach

Every lab in NetForge Labs supports two flexible execution modes:

### Option A · Automated Script Push (Fast & Validated)
Run all step configurations and live gate checks with a single command:
```bash
cd labs/evpn-datacenter-lab
./run.sh --all
```

### Option B · Manual Hands-on Typing (Deep Learning)
Access interactive CLI shells directly on container nodes:
```bash
docker exec -it clab-evpn-datacenter-lab-leaf1 Cli
leaf1> enable
leaf1# configure
```

---

## 💻 Local Development & Docs Build

To run the documentation site locally with live hot-reloading:

```bash
# 1. Clone repository
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Set up Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 3. Serve docs locally
mkdocs serve
# Access site at http://127.0.0.1:8000

# 4. Strict build verification
mkdocs build --strict
```

---

## 📄 License

MIT License — see [LICENSE](LICENSE).
