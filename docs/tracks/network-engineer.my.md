<div class="nf-hud-tag">TRACK 01 / 06 &bull; HYPERSCALE CORE ARCHITECTURE (မြန်မာဗားရှင်း)</div>

# 🌐 Network for AI & Hyperscale Infrastructure Architect သင်ယူမှုလမ်းကြောင်း

> 🚀 **အဆင့်မြင့် အခြေခံအဆောက်အအုံ လက်တွေ့သင်ရိုး**: Non-blocking AI training fabrics (RoCEv2, PFC, ECN)၊ 5-stage BGP Clos fabrics (RFC 7938)၊ Segment Routing Ti-LFA backbones နှင့် EVPN-VXLAN ESI multihomed clusters များကို စစ်မှန်သော Arista cEOS containers များပေါ်တွင် ကိုယ်တိုင်တိုက်ရိုက် ဒီဇိုင်းဆွဲ၊ တည်ဆောက်ပြီး မောင်းနှင်လည်ပတ်ပါ။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အချက်အလက် (Metric) | သတ်မှတ်ချက် (Target Specification) |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၄၀ – ၅၀ နာရီ** (မိမိစိတ်ကြိုက်အချိန်ညှိ၍ လက်တွေ့ Lab များနှင့် လေ့လာနိုင်သည်) |
| **တက်လှမ်းရမည့် အဆင့်များ** | **အဓိက အဆင့် ၆ ဆင့်** (Underlay → BGP Core → SR-MPLS → AI/EVPN Fabrics → Telemetry → Capstone) |
| **Lab နည်းပညာ Framework** | **Containerlab + Arista cEOS** (macOS OrbStack သို့မဟုတ် Linux Docker ပေါ်တွင် ၁၀၀% အခမဲ့ run နိုင်သည်) |
| **ဦးတည်သော အလုပ်အကိုင်များ** | Architect - Network for AI, Hyperscale Infrastructure Architect, Principal Network Engineer, Core Backbone Architect |
| **ပစ်မှတ်ထားသော ကုမ္ပဏီကြီးများ** | Hyperscalers (Google, Meta, AWS, Microsoft), AI Supercomputing Labs (NVIDIA, OpenAI, Anthropic), OEM Titans (HPE/Aruba, Arista, Cisco), နှင့် Tier-1 Service Providers |

---

## 🎯 လုပ်ငန်းခွင် လိုအပ်ချက်နှင့် ချိတ်ဆက်မှု- AI & Hyperscale တော်လှန်ရေး

ယနေ့ခေတ် AI Training Clusters များ (LLM pre-training, Mixture-of-Experts, Distributed GPU Compute) ကြောင့် ရိုးရာ Enterprise ကွန်ရက်ဒီဇိုင်းများမှသည် **Packet Drop လုံးဝမရှိသော (Lossless)၊ High-Radix၊ Ultra-Low-Latency Fabrics** များဆီသို့ မဖြစ်မနေ ပြောင်းလဲလာရပါသည်။

ဤသင်ယူမှုလမ်းကြောင်းသည် ကမ္ဘာ့ထိပ်တန်း ကွန်ရက်ဗိသုကာ ရာထူးများ (ဥပမာ *HPE Architect - Network for AI, Routing and Automation* နှင့် *Meta Production Network Architect*) တွင် တောင်းဆိုသော လက်တွေ့ကျွမ်းကျင်မှုများကို တိုက်ရိုက် ထင်ဟပ်စေရန် ဖန်တီးထားပါသည်:

<div class="grid cards" markdown>

-   ⚡ **AI Fabric & Lossless Transport**

    ---

    - **Zero Packet Drop**: GPU Buffer များ မလျှံကျစေရန် Priority Flow Control (PFC 802.1Qbb) စနစ် သုံးခြင်း
    - **Congestion Avoidance**: Pause Storm များ မဖြစ်ပေါ်မီ ကြိုတင်အချက်ပြသည့် ECN (RFC 3168) & WRED marking
    - **Ultra-Low Latency**: GPU Memory သို့ တိုက်ရိုက်ဝင်ရောက်နိုင်သော RDMA over Converged Ethernet (RoCEv2)
    - **Buffer Sizing**: Incast ပြဿနာများကို ဖြေရှင်းခြင်းနှင့် Dynamic Headroom Partition တွက်ချက်ခြင်း

-   🌐 **Hyperscale Clos Datacenter Fabrics**

    ---

    - **Non-Blocking Scale**: GPU ပေါင်း ၁၆,၃၈၄+ ကို ချိတ်ဆက်နိုင်သော 5-Stage Clos Topology သင်္ချာ
    - **Overlay Routing**: Symmetric IRB ပါဝင်သော EVPN-VXLAN (RFC 8365 / RFC 7432) စနစ်
    - **Open Multihoming**: Vendor Lock-in (MLAG/vPC) ကို အစားထိုးသည့် Standard ESI All-Active Multihoming
    - **Multi-Pod Interconnect**: Data Centers အချင်းချင်း ချောမွေ့စွာ ချိတ်ဆက်နိုင်သော VXLAN DCI စနစ်

-   🛣️ **High-Radix Routing & Backbone**

    ---

    - **Datacenter BGP**: Tier တစ်ခုချင်းစီအတွက် Private ASN သတ်မှတ်သော RFC 7938 Leaf-Spine BGP ဒီဇိုင်း
    - **BGP Unnumbered**: IPv6 Link-Local ပေါ်တွင် IPv4 Peering ပြုလုပ်သော RFC 5549 စံနှုန်း
    - **Segment Routing**: SRGB `16000–23999` နှင့် Node/Prefix SIDs သုံးသည့် SR-MPLS စနစ်
    - **Sub-50ms Protection**: Topology-Independent LFA (Ti-LFA) Fast Reroute ဖြင့် မီလီစက္ကန့်အတွင်း လမ်းကြောင်းလွှဲခြင်း

-   🤖 **NetDevOps & Telemetry Automation**

    ---

    - **Push Observability**: gRPC HTTP/2 ပေါ်မှ Sub-second gNMI Streaming Telemetry စနစ်
    - **Standardized Schemas**: Multi-vendor သုံးနိုင်သော OpenConfig YANG Telemetry Models
    - **Time-Series Monitoring**: Prometheus ဖြင့် ဒေတာစုဆောင်းပြီး Grafana Dashboard တွင် အချိန်နှင့်တပြေးညီ ကြည့်ရှုခြင်း
    - **Automated Verification**: Cisco PyATS/Genie ဖြင့် Maintenance မတိုင်မီနှင့် ပြီးနောက် အလိုအလျောက် စစ်ဆေးခြင်း

</div>

---

## 🗺️ အဆင့် ၆ ဆင့်ပါ တိုးတက်မှု လမ်းပြမြေပုံ (6-Stage Roadmap)

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-underlay-routing-high-performance-fabrics">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · Underlay Routing & High-Performance Fabrics</h4>
        <span class="nf-badge ok">အခြေခံအုတ်မြစ်</span>
      </div>
      <p class="nf-step-desc">Deterministic ECMP load-balancing၊ မီလီစက္ကန့်အတွင်း convergence ရရှိမှုနှင့် DR/BDR ရွေးချယ်မှုကြန့်ကြာမှုမရှိသော Point-to-point link-state fabrics များကို တည်ဆောက်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">OSPFv2/v3 Area 0</span>
        <span class="nf-chip">IS-IS Wide Metrics</span>
        <span class="nf-chip">RFC 5305</span>
        <span class="nf-chip">ECMP Hashing</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-enterprise-edge-hyperscale-bgp-4-core">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Enterprise Edge & Hyperscale BGP-4 Core</h4>
        <span class="nf-badge ok">Control Plane</span>
      </div>
      <p class="nf-step-desc">ဧရာမ Leaf-Spine Fabrics များတစ်လျှောက် Blast-radius ကို ကန့်သတ်ခြင်း၊ BGP 10-step path selection နှင့် iBGP Route Reflectors များဖြင့် Control Plane ကို ချဲ့ထွင်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">RFC 7938 BGP</span>
        <span class="nf-chip">Route Reflectors</span>
        <span class="nf-chip">10-Step Decision</span>
        <span class="nf-chip">BGP Communities</span>
        <span class="nf-chip">Dual-Homed DIA</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-backbone-transport-segment-routing-sr-mpls">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · Backbone Transport & Segment Routing</h4>
        <span class="nf-badge ok">Transport Core</span>
      </div>
      <p class="nf-step-desc">Source Routing နည်းပညာဖြင့် LDP နှင့် RSVP-TE ရှုပ်ထွေးမှုများကို ဖယ်ရှားပါ၊ Multi-tenant MP-BGP VPNv4 ကို တည်ဆောက်ပြီး 50ms အောက် လမ်းကြောင်းလွှဲနိုင်မှုကို အာမခံပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">SR-MPLS</span>
        <span class="nf-chip">SRGB 16000-23999</span>
        <span class="nf-chip">Prefix SIDs</span>
        <span class="nf-chip">Ti-LFA Sub-50ms</span>
        <span class="nf-chip">MP-BGP VPNv4</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-ai-datacenter-fabrics-evpn-vxlan-lossless-ethernet">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · AI & Datacenter Fabrics (EVPN-VXLAN + Lossless)</h4>
        <span class="nf-badge ok">AI အထူးပြု</span>
      </div>
      <p class="nf-step-desc">High-radix leaf-spine fabrics ပေါ်တွင် Distributed Symmetric IRB၊ Vendor-neutral ESI multihoming နှင့် GPU cluster များအတွက် Lossless RoCEv2/PFC စနစ်များကို ဖြန့်ကျက်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">RoCEv2 Lossless</span>
        <span class="nf-chip">PFC 802.1Qbb</span>
        <span class="nf-chip">ECN RFC 3168</span>
        <span class="nf-chip">EVPN-VXLAN</span>
        <span class="nf-chip">ESI Multihoming</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-netdevops-real-time-streaming-telemetry">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · NetDevOps & Real-Time Streaming Telemetry</h4>
        <span class="nf-badge ok">Observability</span>
      </div>
      <p class="nf-step-desc">၅ မိနစ်ကြာမှ ဒေတာရသော ရိုးရာ SNMP ကို အစားထိုး၍ မီလီစက္ကန့် gRPC Push streams၊ OpenConfig YANG models၊ Prometheus alerting နှင့် PyATS automated verification ကို အသုံးချပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">gNMI gRPC Protobuf</span>
        <span class="nf-chip">OpenConfig YANG</span>
        <span class="nf-chip">Prometheus</span>
        <span class="nf-chip">Grafana</span>
        <span class="nf-chip">PyATS Assertions</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-6-capstone-system-design-failure-triage-drills">
    <div class="nf-step-num">06</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 6 · Capstone System Design & Failure Triage Drills</h4>
        <span class="nf-badge ok">အဆင့်မြင့် ဗိသုကာ</span>
      </div>
      <p class="nf-step-desc">GPU ပေါင်း ၁၆,၃၈၄+ Fabric တွက်ချက်မှုများ၊ အသံတိတ် packet drop နှင့် PFC Deadlock ပြဿနာဖြေရှင်းမှုများနှင့် Staff-level စနစ်ဒီဇိုင်း အင်တာဗျူး အမေးအဖြေများကို လက်တွေ့လေ့ကျင့်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">5-Stage Clos Sizing</span>
        <span class="nf-chip">PFC Deadlock Mitigation</span>
        <span class="nf-chip">CoPP Defense</span>
        <span class="nf-chip">BGP Unnumbered RFC 5549</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 လက်တွေ့သင်ခန်းစာများ ဇယား (Interactive Lesson Directory)

| အဆင့် (Stage) | အဓိက Protocol များ | လက်တွေ့လေ့ကျင့်ခန်း သင်ခန်းစာများ | Runnable Lab | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Underlay Routing` | OSPFv2/v3, IS-IS Wide Metrics, Point-to-Point Adjacencies, ECMP | • [01 · Link-State Routing Foundations](../courses/00-igp-fundamentals/01-link-state.md)<br/>• [02 · OSPF Multi-Area Core Architecture](../courses/00-igp-fundamentals/02-ospf.md)<br/>• [03 · IS-IS Backbone Engineering](../courses/00-igp-fundamentals/03-isis.md)<br/>• [05 · IGPs at Hyper-Scale](../courses/00-igp-fundamentals/05-at-scale.md) | `labs/igp-lab` | [Stage 1 စတင်ရန် →](../courses/00-igp-fundamentals/02-ospf.md) |
| **Stage 2**<br/>`BGP-4 Core & Edge` | RFC 7938 BGP Clos, 10-Step Decision, Route Reflectors, Multi-Homing | • [Lab 01 · eBGP, iBGP & next-hop-self](../courses/01-bgp/lab-01-ebgp-ibgp.md)<br/>• [Lab 02 · iBGP over IS-IS Underlay](../courses/01-bgp/lab-02-isis-underlay.md)<br/>• [Lab 03 · Scalable Route Reflectors](../courses/01-bgp/lab-03-route-reflectors.md)<br/>• [Lab 04 · Multihomed BGP Edge](../courses/01-bgp/lab-04-dual-homed-edge.md)<br/>• [DIA Lab 01 · Multi-Provider Transit](../courses/02-bgp-dia/lab-01-dia-multihoming.md) | `labs/bgp-lab` | [Stage 2 စတင်ရန် →](../courses/01-bgp/lab-01-ebgp-ibgp.md) |
| **Stage 3**<br/>`Backbone & SR-MPLS` | MP-BGP VPNv4, SRGB 16000–23999, Prefix SIDs, Sub-50ms Ti-LFA | • [MPLS Lab 01 · MPLS + LDP Underlay](../courses/03-mpls-l3vpn/lab-01-mpls-ldp.md)<br/>• [MPLS Lab 02 · Single-AS L3VPN & VRF](../courses/03-mpls-l3vpn/lab-02-l3vpn-option-a.md)<br/>• [SR Lab 01 · SR-MPLS Node & Prefix SIDs](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)<br/>• [SR Lab 02 · Ti-LFA Sub-50ms FRR](../courses/035-segment-routing/lab-02-ti-lfa-frr.md)<br/>• [SR Lab 03 · BGP Color Traffic Steering](../courses/035-segment-routing/lab-03-sr-pce-te.md) | `labs/segment-routing-lab` | [Stage 3 စတင်ရန် →](../courses/035-segment-routing/lab-01-sr-mpls-sids.md) |
| **Stage 4**<br/>`AI & EVPN Fabrics` | Lossless RoCEv2, PFC 802.1Qbb, ECN, Symmetric IRB, ESI Multihoming | • [EVPN Lab 01 · Pure Layer-2 VNI](../courses/04-evpn/lab-01-pure-l2vni.md)<br/>• [EVPN Lab 02 · Symmetric IRB Routing](../courses/04-evpn/lab-02-symmetric-irb.md)<br/>• [EVPN Lab 03 · ESI All-Active Multihoming](../courses/04-evpn/lab-03-esi-multihoming.md)<br/>• [EVPN Lab 04 · EVPN-VPWS & E-LAN](../courses/04-evpn/lab-04-evpn-vpws-elan.md)<br/>• [EVPN Lab 05 · EVPN DCI Multi-Site](../courses/04-evpn/lab-05-evpn-dci-multisite.md) | `labs/evpn-datacenter-lab` | [Stage 4 စတင်ရန် →](../courses/04-evpn/lab-01-pure-l2vni.md) |
| **Stage 5**<br/>`NetDevOps & Telemetry` | gNMI Streaming Protobuf, OpenConfig YANG, Prometheus, PyATS Assertions | • [NetDevOps Lab 01 · Jinja2/YAML Modeling](../courses/05-netdevops/lab-01-jinja2-yaml.md)<br/>• [NetDevOps Lab 02 · PyATS Assertions](../courses/05-netdevops/lab-02-pyats-verification.md)<br/>• [Telemetry Lab 01 · gNMI & OpenConfig](../courses/07-telemetry/lab-01-gnmi-openconfig.md)<br/>• [Telemetry Lab 02 · pygnmi Python Streams](../courses/07-telemetry/lab-02-pygnmi-python.md)<br/>• [Telemetry Lab 04 · Real-Time Grafana](../courses/07-telemetry/lab-04-grafana-observability.md) | `labs/telemetry-lab` | [Stage 5 စတင်ရန် →](../courses/07-telemetry/lab-01-gnmi-openconfig.md) |
| **Stage 6**<br/>`Capstone System Design` | 5-Stage Clos Sizing, Buffer Exhaustion, CoPP Defense, BGP Unnumbered | • [System Design Masterclass & Scenario Drills](../interview-prep/google-system-design.md)<br/>• [Security Lab 01 · CoPP CPU Protection](../courses/08-security/lab-01-copp-cpu-protection.md)<br/>• [IPv6 Lab 02 · BGP Unnumbered (RFC 5549)](../courses/09-ipv6/lab-02-bgp-unnumbered-rfc5549.md) | `labs/security-lab` | [Stage 6 စတင်ရန် →](../interview-prep/google-system-design.md) |

---

## 🧪 အသေးစိတ် Milestone အဆင့်များနှင့် Verification Gates

### 📍 Stage 1: Underlay Routing & High-Performance Fabrics
- **အဓိက အလေးပေးမှု**: Deterministic equal-cost multi-pathing (ECMP)၊ မီလီစက္ကန့်အတွင်း convergence ရရှိမှုနှင့် Carrier-grade link-state protocols များ။
- **Protocol Mechanics**: OSPFv2 LSA types 1/2/3/5၊ Point-to-Point network types (DR/BDR ရွေးချယ်မှု ကြန့်ကြာမှုကို ကျော်လွှားနိုင်ခြင်း)၊ IS-IS Level-1/Level-2 hierarchy၊ နှင့် TLV-based wide metric extensions (RFC 5305)။
- **လက်တွေ့ Lab သင်ခန်းစာများ**:
    - [Phase 0: IGP Fundamentals Overview](../courses/00-igp-fundamentals/index.md)
    - [OSPFv2 Multi-Area Core](../courses/00-igp-fundamentals/02-ospf.md)
    - [IS-IS Backbone Engineering](../courses/00-igp-fundamentals/03-isis.md)
- **Local Runner**:
    ```bash
    cd labs/igp-lab
    ./run.sh --guided
    ```
- **Milestone Gate**: Loopback အားလုံးအကြား အပြန်အလှန် ချိတ်ဆက်မိပြီး ECMP Load-balancing အလုပ်လုပ်ကြောင်း အလိုအလျောက် စစ်ဆေးအတည်ပြုနိုင်ရမည်။

---

### 📍 Stage 2: Enterprise Edge & Hyperscale BGP-4 Core
- **အဓိက အလေးပေးမှု**: Autonomous System နယ်နိမိတ်များ၊ Multi-homed transit edge နှင့် RFC 7938 အခြေပြု ဒေတာစင်တာ လမ်းကြောင်းသတ်မှတ်မှုများ။
- **Protocol Mechanics**: BGP 10-step decision algorithm (Weight → Local Pref → AS-PATH → Origin → MED → eBGP over iBGP)၊ Route Reflectors (`cluster-id`, `originator-id`) ဖြင့် iBGP Full-mesh ရှုပ်ထွေးမှုကို ရှင်းထုတ်ခြင်း၊ Traffic engineering အတွက် BGP communities သုံးခြင်း၊ နှင့် IPv6 Link-Local ပေါ်မှ BGP Unnumbered (RFC 5549)။
- **လက်တွေ့ Lab သင်ခန်းစာများ**:
    - [Phase 1: BGP Fundamentals & Policy Routing](../courses/01-bgp/index.md)
    - [Lab 01: eBGP Peering & Policy Enforcement](../courses/01-bgp/lab-01-ebgp-ibgp.md)
    - [Lab 02: IS-IS Underlay Core](../courses/01-bgp/lab-02-isis-underlay.md)
    - [Lab 03: Scalable iBGP Route Reflectors](../courses/01-bgp/lab-03-route-reflectors.md)
    - [Phase 2: BGP Dual-Homed Internet Access (DIA)](../courses/02-bgp-dia/index.md)
- **Local Runners**:
    ```bash
    cd labs/bgp-lab && ./run.sh --guided
    cd labs/bgp-dia-lab && ./run.sh --guided
    ```
- **Milestone Gate**: Route Reflectors များမှ လမ်းကြောင်း loops မဖြစ်ဘဲ သတင်းအချက်အလက်များကို မှန်ကန်စွာ ဖြန့်ဝေနိုင်ခြင်းနှင့် ISP တစ်ခု ပြတ်တောက်သွားပါက အလိုအလျောက် လမ်းကြောင်းလွှဲနိုင်ခြင်း။

---

### 📍 Stage 3: Backbone Transport & Segment Routing (SR-MPLS)
- **အဓိက အလေးပေးမှု**: Source Routing နည်းပညာဖြင့် Control Plane ရှုပ်ထွေးမှု (LDP နှင့် RSVP-TE) ကို ဖယ်ရှားခြင်း၊ Multi-tenant VRF သီးသန့်ခွဲထုတ်ခြင်းနှင့် 50ms အောက် အလိုအလျောက် လမ်းကြောင်းလွှဲနိုင်မှု အာမခံခြင်း။
- **Protocol Mechanics**: MPLS label stacks၊ Penultimate Hop Popping (PHP, Implicit Null label 3)၊ MP-BGP VPNv4 (RD နှင့် RT)၊ Segment Routing Global Block (SRGB `16000–23999`)၊ Node SIDs၊ Adjacency SIDs၊ နှင့် Topology-Independent Loop-Free Alternate (Ti-LFA)။
- **လက်တွေ့ Lab သင်ခန်းစာများ**:
    - [Phase 3: MPLS L3VPN Backbones](../courses/03-mpls-l3vpn/index.md)
    - [Phase 3.5: Segment Routing (SR-MPLS) & Ti-LFA](../courses/035-segment-routing/index.md)
    - [SR Lab 01: SRGB & Node SID Transport](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)
    - [SR Lab 02: Ti-LFA Sub-50ms Fast Reroute](../courses/035-segment-routing/lab-02-ti-lfa-frr.md)
    - [SR Lab 03: Color-Based SLA Traffic Steering](../courses/035-segment-routing/lab-03-sr-pce-te.md)
- **Local Runners**:
    ```bash
    cd labs/mpls-l3vpn-lab && ./run.sh --guided
    cd labs/segment-routing-lab && ./run.sh --guided
    ```
- **Milestone Gate**: Core link ပြတ်တောက်ချိန်တွင် 50ms ထက်မပိုဘဲ Packet drop မရှိ လမ်းကြောင်းလွှဲနိုင်ခြင်းကို Forwarding plane တွင် အတည်ပြုစစ်ဆေးနိုင်ရမည်။

---

### 📍 Stage 4: AI & Datacenter Fabrics (EVPN-VXLAN + Lossless Ethernet)
- **အဓိက အလေးပေးမှု**: High-radix leaf-spine Clos fabrics၊ Multi-tenant overlay routing နှင့် GPU cluster များအတွက် Lossless RoCEv2 စနစ်များ။
- **Protocol Mechanics**:
    - **EVPN-VXLAN**: Symmetric Integrated Routing & Bridging (IRB)၊ Anycast Virtual Gateway၊ Ethernet Segment Identifier (ESI) Type-0/Type-1 All-Active Multihoming (vendor-locked MLAG/vPC ကို ဖယ်ရှားခြင်း)၊ EVPN Route Types 2 (MAC/IP), 3 (Inclusive Multicast), 4 (Ethernet Segment), နှင့် 5 (IP Prefix)။
    - **Lossless AI Transport**: GPU Ingress Buffers များတွင် packet drop မရှိစေရန် Priority Flow Control (PFC, IEEE 802.1Qbb) သုံးခြင်း၊ Buffer မပြည့်မီ အချက်ပြသည့် ECN (RFC 3168) နှင့် WRED marking။
- **လက်တွေ့ Lab သင်ခန်းစာများ**:
    - [Phase 4: EVPN-VXLAN Datacenter Fabrics](../courses/04-evpn/index.md)
    - [EVPN Lab 01: Pure Layer-2 VNI Bridging](../courses/04-evpn/lab-01-pure-l2vni.md)
    - [EVPN Lab 02: Symmetric IRB Distributed Routing](../courses/04-evpn/lab-02-symmetric-irb.md)
    - [EVPN Lab 03: ESI All-Active Multihoming](../courses/04-evpn/lab-03-esi-multihoming.md)
    - [EVPN Lab 04: EVPN-VPWS & E-LAN Service](../courses/04-evpn/lab-04-evpn-vpws-elan.md)
    - [EVPN Lab 05: EVPN DCI Multi-Site](../courses/04-evpn/lab-05-evpn-dci-multisite.md)
- **Local Runner**:
    ```bash
    cd labs/evpn-datacenter-lab
    ./run.sh --guided
    ```
- **Milestone Gate**: Dual-homed servers များသည် ESI ဖြင့် Loop မဖြစ်ဘဲ Independent Leaf switches များထံ Traffic မျှဝေပို့ဆောင်နိုင်ခြင်းနှင့် Failover တွင် Packet မကျခြင်း။

---

### 📍 Stage 5: NetDevOps & Real-Time Streaming Telemetry
- **အဓိက အလေးပေးမှု**: ရိုးရာ CLI ရိုက်နှိပ်ခြင်းနှင့် ၅ မိနစ် SNMP polling စနစ်များမှသည် Infrastructure-as-Code နှင့် Sub-second Push Telemetry သို့ အဆင့်မြှင့်တင်ခြင်း။
- **Protocol Mechanics**: gNMI (gRPC Network Management Interface) streaming over HTTP/2 with Protocol Buffers၊ OpenConfig standardized YANG schemas၊ Prometheus time-series scraping၊ Grafana dashboards နှင့် Cisco PyATS/Genie automated state assertions။
- **လက်တွေ့ Lab သင်ခန်းစာများ**:
    - [Phase 5: Network Automation & CI/CD](../courses/05-netdevops/index.md)
    - [Phase 7: Streaming Telemetry & Observability](../courses/07-telemetry/index.md)
    - [Telemetry Lab 01: gNMI Basics & OpenConfig](../courses/07-telemetry/lab-01-gnmi-openconfig.md)
    - [Telemetry Lab 02: pygnmi Python Integration](../courses/07-telemetry/lab-02-pygnmi-python.md)
    - [Telemetry Lab 03: Prometheus Metric Exporter](../courses/07-telemetry/lab-03-prometheus-time-series.md)
    - [Telemetry Lab 04: Real-Time Grafana Dashboards](../courses/07-telemetry/lab-04-grafana-observability.md)
- **Local Runners**:
    ```bash
    cd labs/netdevops-lab && ./run.sh --guided
    cd labs/telemetry-lab && ./run.sh --guided
    ```
- **Milestone Gate**: Interface microburst traffic မြင့်တက်မှုများကို ၂၅၀ မီလီစက္ကန့်အတွင်း Grafana တွင် မြင်တွေ့နိုင်ခြင်းနှင့် PyATS automated test suite အောင်မြင်ခြင်း။

---

### 📍 Stage 6: Capstone System Design & Failure Triage Drills
- **အဓိက အလေးပေးမှု**: အလုံးစုံ စနစ်ပေါင်းစပ်မှု၊ စွမ်းဆောင်ရည် တွက်ချက်မှုနှင့် ပြင်းထန်သော စနစ်ပြိုလဲမှု ပြဿနာဖြေရှင်းခြင်း။
- **အဓိက အကြောင်းအရာများ**:
    - Port ၆၄ ခုပါ 800G switches များကိုသုံး၍ GPU ၁၆,၃၈၄ လုံးပါ AI Cluster အတွက် Oversubscription ratios တွက်ချက်ခြင်း (5-stage Clos scaling math)။
    - eBGP Private AS numbering ဖြင့် Blast-radius ထိန်းချုပ်ရေး နယ်နိမိတ်များ ရေးဆွဲခြင်း။
    - PFC deadlock နှင့် Microburst buffer ပြည့်လျှံမှုကြောင့် ဖြစ်သော Silent packet drop ပြဿနာများကို ရှာဖွေဖြေရှင်းခြင်း။
    - System design interview drills များနှင့် နည်းပညာ ရွေးချယ်မှု အားသာချက်/အားနည်းချက်များ (RoCEv2 vs InfiniBand vs Ultra Ethernet Consortium)။
- **ကိုးကား သင်ရိုးများ**:
    - [Google & Hyperscale System Design Masterclass](../interview-prep/google-system-design.md)
    - [NetForge Master Curriculum Architecture Roadmap](../roadmap.md)

---

## 🛠️ စတင်အသုံးပြုနိုင်သော Local Lab ပတ်ဝန်းကျင်

NetForge Labs တွင် အလိုအလျောက် Guided Step Runner စနစ် ပါရှိသောကြောင့် ရှည်လျားသော Syntax များကို လက်ဖြင့် လိုက်ကူးထည့်ရန် မလိုပါ (CLI ရိုက်လေ့ကျင့်လိုပါကလည်း စိတ်ကြိုက်ရွေးချယ်နိုင်ပါသည်)။

```bash
# ၁။ မည်သည့် lab directory သို့မဆို သွားပါ
cd labs/evpn-datacenter-lab

# ၂။ Guided interactive runner ကို စတင် run ပါ
./run.sh --guided

# သို့မဟုတ် အတည်ပြုပြီးသား topology အပြည့်အစုံကို တစ်ကြောင်းတည်းဖြင့် deploy ပြုလုပ်ပါ
./run.sh --all
```

Runner တိုင်းတွင် ပါဝင်သော အထောက်အကူများ:
1. **Config Previews**: မ execute မီ Arista cEOS command အတိအကျကို ကြိုတင်ကြည့်ရှုနိုင်ခြင်း။
2. **Manual Practice Guidance**: `clab exec` ဖြင့် ကိုယ်တိုင်ရိုက်လေ့ကျင့်လိုသူများအတွက် ရှင်းလင်းသော ညွှန်ကြားချက်များ။
3. **Automated Verifiers**: Operational state tables, routes, နှင့် ping test များကို ချက်ချင်းစစ်ဆေးပေးသည့် စနစ်။

---

## 🎓 အလုပ်အကိုင် အင်တာဗျူးတွင် ပြသနိုင်သော Portfolio Projects ၃ ခု

ဤသင်ယူမှုလမ်းကြောင်းကို ပြီးဆုံးပါက ထိပ်တန်းနည်းပညာကုမ္ပဏီကြီးများ၏ Staff-Level အင်တာဗျူးများတွင် ကိုယ်တိုင် လက်တွေ့ရှင်းပြနိုင်သော Project ၃ ခုကို ပိုင်ဆိုင်သွားမည်ဖြစ်ပါသည်:

1. **Non-Blocking 5-Stage Clos Datacenter Fabric**:
   - BGP ASN scheme (RFC 7938)၊ BGP Unnumbered ဒီဇိုင်းနှင့် ECMP hash symmetry တို့ကို အခိုင်အမာ ရှင်းလင်းတင်ပြနိုင်ခြင်း။
   - ESI All-Active multihoming ဒီဇိုင်းဖြင့် Proprietary vendor lock-in (MLAG/vPC) ကို အမြစ်ပြတ် ဖယ်ရှားခဲ့ပုံကို ရှင်းပြနိုင်ခြင်း။

2. **Lossless RoCEv2 AI Transport Architecture**:
   - Distributed model all-reduce တွက်ချက်မှုများအတွင်း Packet loss လုံးဝမဖြစ်စေရန် လိုအပ်သော Buffer thresholds၊ Headroom sizing math၊ နှင့် PFC/ECN tuning တို့ကို အင်တာဗျူးသူများအား အဆင့်ဆင့် ပြသနိုင်ခြင်း။

3. **Autonomous Sub-Second Fast Reroute Backbone**:
   - အဟောင်းဖြစ်သော RSVP-TE မှ Segment Routing (SR-MPLS) with Ti-LFA သို့ ပြောင်းလဲကာ Core router များတွင် ရှုပ်ထွေးမှုမရှိဘဲ 50ms အောက် အလိုအလျောက် လမ်းကြောင်းလွှဲနိုင်ခဲ့ပုံကို သရုပ်ပြနိုင်ခြင်း။
