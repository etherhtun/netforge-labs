<div class="nf-hud-tag">TRACK 06 / 06 &bull; TPM & SYSTEM DESIGN (မြန်မာဗားရှင်း)</div>

# 📋 Technical Program Manager (TPM) & System Design သင်ယူမှုလမ်းကြောင်း

> 🚀 **Hyperscale Architecture & Technical Leadership**: 5-Stage Clos fabric တွက်ချက်မှုသင်္ချာ၊ eBGP နှင့် iBGP ဗိသုကာဆိုင်ရာ trade-offs များ၊ blast radius ထိန်းချုပ်မှု၊ SLA / convergence budget တွက်ချက်မှုများနှင့် multi-vendor RFP စီမံခန့်ခွဲမှုများကို ကျွမ်းကျင်စွာ လေ့လာနိုင်ပါသည်။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အချက်အလက် (Metric) | သတ်မှတ်ချက် (Target Specification) |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၂၀ – ၂၅ နာရီ** (ဗိသုကာဆိုင်ရာ သုံးသပ်ချက်၊ system design drills နှင့် case studies များ) |
| **တက်လှမ်းရမည့် အဆင့်များ** | **အဓိက အဆင့် ၅ ဆင့်** (Clos Scaling Math → Routing Architecture → SLA & Convergence Budgets → Overlay Virtualization → Vendor RFPs & Telemetry) |
| **ဦးတည်သော အလုပ်အကိုင်များ** | Technical Program Manager (TPM) - Infrastructure, Network Solutions Architect, Infrastructure Program Lead, Engineering Director |
| **ပစ်မှတ်ထားသော ကုမ္ပဏီကြီးများ** | Google, Meta, Apple, AWS, Microsoft, ByteDance, NVIDIA, Global Financial Institutions, နှင့် Cloud Infrastructure Consultancies |

---

## 🧠 TPM အဓိက အင်ဂျင်နီယာနှင့် ခေါင်းဆောင်မှု မဏ္ဍိုင်ကြီးများ (Core Pillars)

| နယ်ပယ် (Program Domain) | အဓိက ဗိသုကာဆိုင်ရာ ဆုံးဖြတ်ချက်များ | ခေါင်းဆောင်မှုနှင့် ပရိုဂရမ် လုပ်ဆောင်ချက် (Function) |
|---|---|---|
| **Fabric Scaling Math** | **5-Stage Clos vs. 2-Tier Spine-Leaf** | ASIC port-density တွက်ချက်ခြင်း၊ oversubscription ratios များနှင့် modular pod တိုးချဲ့မှု စီစဉ်ခြင်း |
| **Routing Protocol Selection** | **eBGP (RFC 7938) vs. iBGP + RRs** | Blast-radius ထိန်းချုပ်ခြင်း၊ routing loop များကို ဖယ်ရှားခြင်းနှင့် global ASN သတ်မှတ်မှု စည်းမျဉ်းများ |
| **Convergence SLAs** | **Sub-50ms Ti-LFA vs. IGP Timers** | လုပ်ငန်းခွင် availability budgets (99.999%)၊ link failover SLAs နှင့် error budgets များ ချမှတ်ခြင်း |
| **Overlay Virtualization** | **EVPN-VXLAN ESI vs. Proprietary MLAG** | Physical underlay မှ tenant overlays များကို သီးခြားခွဲထုတ်ပြီး vendor hardware lock-in ကို ဖယ်ရှားခြင်း |
| **Telemetry Standardization** | **gNMI Streaming vs. SNMP Polling** | Arista, Cisco, နှင့် whitebox switches များအကြား OpenConfig schemas များကို စံသတ်မှတ်ခြင်း |

---

## 🗺️ အဆင့် ၅ ဆင့် တိုးတက်မှု Milestone လမ်းပြမြေပုံ (Roadmap)

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-5-stage-clos-fabric-sizing-capacity-math">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · 5-Stage Clos Fabric Sizing & Capacity Math</h4>
        <span class="nf-badge ok">Fabric Math</span>
      </div>
      <p class="nf-step-desc">Tier-1 Leaf၊ Tier-2 Spine နှင့် Tier-3 Super-Spine switches များအကြား Non-blocking Clos port radix formulas နှင့် oversubscription ratios များကို တွက်ချက်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">5-Stage Clos</span>
        <span class="nf-chip">Port Radix Formulas</span>
        <span class="nf-chip">Oversubscription Ratios</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-routing-architecture-blast-radius-design">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Routing Architecture & Blast Radius Design</h4>
        <span class="nf-badge ok">Governance</span>
      </div>
      <p class="nf-step-desc">Routing loops များကို ဖယ်ရှားရန်နှင့် failure blast radiuses များကို ထိန်းချုပ်ရန် RFC 7938 eBGP leaf-spine fabrics နှင့် IGP+iBGP တို့ကို နှိုင်းယှဉ်သုံးသပ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">RFC 7938 eBGP</span>
        <span class="nf-chip">ASN Allocation Strategy</span>
        <span class="nf-chip">Failure Domain Isolation</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-high-availability-convergence-sla-budgets">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · High-Availability & Convergence SLA Budgets</h4>
        <span class="nf-badge ok">99.999% SLAs</span>
      </div>
      <p class="nf-step-desc">လုပ်ငန်းခွင် availability budgets များကို တွက်ချက်ပြီး 50ms အောက် Ti-LFA fast reroute နှင့် ရိုးရာ IGP convergence timers တို့ကို နှိုင်းယှဉ်သုံးသပ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Ti-LFA Sub-50ms</span>
        <span class="nf-chip">Error Budgeting</span>
        <span class="nf-chip">BFD Hardware Offload</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-multi-tenant-overlays-open-standards">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · Multi-Tenant Overlays & Open Standards</h4>
        <span class="nf-badge ok">Open Standards</span>
      </div>
      <p class="nf-step-desc">Vendor-specific MLAG/vPC lock-in ကို ရှောင်ရှားပြီး ESI multihoming ပါဝင်သော EVPN-VXLAN ဖြင့် physical fabrics မှ tenant services များကို သီးခြားခွဲထုတ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">EVPN-VXLAN</span>
        <span class="nf-chip">ESI Multihoming</span>
        <span class="nf-chip">Multi-Vendor Interop</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-telemetry-governance-vendor-rfp-delivery">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · Telemetry Governance & Vendor RFP Delivery</h4>
        <span class="nf-badge ok">Vendor RFPs</span>
      </div>
      <p class="nf-step-desc">Multi-vendor OpenConfig telemetry စံသတ်မှတ်ချက်များကို ရေးဆွဲပြီး hardware ဝယ်ယူတင်သွင်းမှုများအတွက် အလိုအလျောက် PyATS acceptance tests များကို သတ်မှတ်ချမှတ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">OpenConfig YANG</span>
        <span class="nf-chip">gNMI Governance</span>
        <span class="nf-chip">Automated RFP Acceptance</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 အပြန်အလှန် လေ့လာနိုင်သော သင်ခန်းစာလမ်းညွှန် (Interactive Lesson Directory)

| Milestone Stage | ဗိသုကာနှင့် ပရိုဂရမ် အဓိကအချက် | ကလစ်နှိပ်၍ လေ့လာနိုင်သော သင်ခန်းစာ & စနစ်ဒီဇိုင်းများ | နည်းပညာ အဓိကအချက် | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Clos Sizing Math` | ASIC Port Radix Math, Oversubscription Ratios, Super-Spine Pods | • [EVPN-VXLAN Clos Fabric ဒီဇိုင်း](../courses/04-evpn/index.md)<br/>• [Hyperscale System Design Masterclass](../interview-prep/google-system-design.md) | Pod Math | [Stage 1 စတင်ရန် →](../interview-prep/google-system-design.md) |
| **Stage 2**<br/>`BGP Governance` | RFC 7938 eBGP Clos Design, Blast Radius, ASN Allocation Policies | • [Phase 1 · BGP အခြေခံနှင့် ဗိသုကာ](../courses/01-bgp/index.md)<br/>• [Phase 1 · Lab 03: Route Reflector Hierarchy](../courses/01-bgp/lab-03-route-reflectors.md) | ASN Model | [Stage 2 စတင်ရန် →](../courses/01-bgp/index.md) |
| **Stage 3**<br/>`SLA & FRR Budgets` | Sub-50ms Ti-LFA Fast Reroute, BFD Hardware Offload, Error Budgets | • [Segment Routing (SR-MPLS) Ti-LFA ဗိသုကာ](../courses/035-segment-routing/lab-02-ti-lfa-frr.md)<br/>• [WAN Edge BFD Sub-Second Failover](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) | 99.999% SLAs | [Stage 3 စတင်ရန် →](../courses/035-segment-routing/lab-02-ti-lfa-frr.md) |
| **Stage 4**<br/>`Multi-Tenant Overlays` | RFC 8365/7432 EVPN-VXLAN, ESI All-Active Multihoming vs MLAG Lock-in | • [EVPN Lab 03: ESI All-Active Multihoming](../courses/04-evpn/lab-03-esi-multihoming.md)<br/>• [EVPN Lab 05: Multi-Site DCI Architecture](../courses/04-evpn/lab-05-evpn-dci-multisite.md) | Open Standards | [Stage 4 စတင်ရန် →](../courses/04-evpn/lab-03-esi-multihoming.md) |
| **Stage 5**<br/>`Vendor RFP Delivery` | OpenConfig YANG Governance, gNMI Telemetry SLAs, PyATS Pre-Checks | • [Phase 7 · Streaming Telemetry & Observability](../courses/07-telemetry/index.md)<br/>• [Phase 5 · Automated Network Testing with PyATS](../courses/05-netdevops/lab-02-pyats-verification.md) | RFP Criteria | [Stage 5 စတင်ရန် →](../courses/07-telemetry/index.md) |

---

## 🧪 အသေးစိတ် Milestone သင်ရိုးညွှန်းတမ်း (Detailed Milestone Curricula)

### 📍 Stage 1: 5-Stage Clos Fabric Sizing & Capacity Math
- **အဓိက အလေးထားချက် (Core Focus)**: စီးပွားရေးဆိုင်ရာ compute လိုအပ်ချက်များကို non-blocking သို့မဟုတ် တိကျစွာ သတ်မှတ်ထားသော oversubscribed network topologies အဖြစ်သို့ ပြောင်းလဲတွက်ချက်ခြင်း။
- **ဖော်မြူလာများနှင့် ချိန်ညှိချက်များ (Formulas & Trade-offs)**:
    - Spine $S$ ခုမှ ချိတ်ဆက်ပေးနိုင်သော အများဆုံး leaf အရေအတွက်: $N_{leaf} = S \times \text{uplinks per leaf}$။
    - $k$-port switches များ အသုံးပြုထားသော Non-blocking server capacity: $N_{servers} = \frac{k^2}{2}$။
    - Tier-1 (Leaf), Tier-2 (Spine), နှင့် Tier-3 (Super-Spine) အလွှာများအကြား bandwidth oversubscription ratios ($1:1$, $2:1$, $3:1$) များကို တွက်ချက်ခြင်း။

### 📍 Stage 2: Routing Architecture & Blast Radius Design
- **အဓိက အလေးထားချက် (Core Focus)**: Multi-pod datacenters များတွင် ဆင့်ကဲပြိုလဲမှု (cascade failures) မဖြစ်စေသော control plane protocols များကို ရွေးချယ်ခြင်း။
- **အဓိက နှိုင်းယှဉ်ချက်များ (Key Comparisons)**:
    - **RFC 7938 eBGP**: Tier/rack တစ်ခုချင်းစီအတွက် သီးခြား ASN သတ်မှတ်ခြင်း၊ AS-PATH ဖြင့် loops များကို အလိုအလျောက် ပယ်ဖျက်ခြင်း၊ routing policy ကို AS နယ်နိမိတ်များတွင် ကျင့်သုံးခြင်း။
    - **iBGP + Route Reflectors**: IGP underlay တစ်ခုလုံး လိုအပ်ခြင်း၊ cluster-id hierarchy သေချာမစီမံပါက route oscillations ဖြစ်နိုင်ခြေရှိခြင်း။

### 📍 Stage 3: High-Availability & Convergence SLA Budgets
- **အဓိက အလေးထားချက် (Core Focus)**: စာချုပ်ပါ SLAs များအတွက် downtime risk များကို တွက်ချက်ပြီး တင်းကျပ်သော failover parameters များကို သတ်မှတ်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**:
    - 50ms အောက် Topology-Independent Loop-Free Alternate (Ti-LFA)။
    - BFD timer aggregation နှင့် ASIC CPU load ချိန်ဆမှု။
    - သုံးလပတ်အလိုက် 99.99% ("four nines") နှင့် 99.999% ("five nines") error budgets များ သတ်မှတ်ခြင်း။

### 📍 Stage 4: Multi-Tenant Overlays & Open Standards
- **အဓိက အလေးထားချက် (Core Focus)**: ဒေါ်လာသန်းပေါင်းများစွာတန်သော switch hardware ဝယ်ယူတင်သွင်းမှုများတွင် vendor lock-in ဖြစ်ပေါ်မှုကို ရှောင်ရှားခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**:
    - Vendor-specific multi-chassis link aggregation (Cisco vPC, Arista MLAG) များသည် dual-control-plane bugs များကို မည်သို့ ဖြစ်ပေါ်စေပုံ။
    - RFC 8365/7432 EVPN-VXLAN with ESI (Ethernet Segment Identifier) သည် multi-vendor, all-active multihoming ကို မည်သို့ ထောက်ပံ့ပေးပုံ။

### 📍 Stage 5: Telemetry Governance & Vendor RFP Delivery
- **အဓိက အလေးထားချက် (Core Focus)**: Hardware RFPs များနှင့် carrier acceptance များအတွက် နည်းပညာဆိုင်ရာ သတ်မှတ်ချက်များနှင့် automated validation gates များကို ရေးဆွဲခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**:
    - Vendor contracts များတွင် OpenConfig YANG schemas နှင့် gNMI streaming telemetry support ကို မဖြစ်မနေ ထည့်သွင်းစေခြင်း။
    - Network hardware ပစ္စည်းများ လက်ခံခြင်းမပြုမီ automated PyATS / Batfish pre-deployment gate checks များကို သတ်မှတ်တောင်းဆိုခြင်း။

---

## 📁 System Design Drills & ကိုးကားချက်များ (Reference)

- **[Google & Hyperscale System Design Masterclass](../interview-prep/google-system-design.md)**: Scenario အခြေပြု အင်တာဗျူး drills များနှင့် ဗိသုကာဆိုင်ရာ trade-offs များ။
- **[Curriculum Architecture Roadmap](../roadmap.md)**: ကွန်ရက် အဆင့် ၁၀ ဆင့်စလုံးရှိ ပြီးပြည့်စုံသော protocol dependency matrix။
- **[EVPN-VXLAN Clos Fabric သင်တန်း](../courses/04-evpn/index.md)**: Leaf-spine fabric တည်ဆောက်မှု လက်တွေ့သင်ခန်းစာ။
- **[Streaming Telemetry သင်တန်း](../courses/07-telemetry/index.md)**: gNMI/OpenConfig telemetry pipeline လက်တွေ့သင်ခန်းစာ။

---

## 🎯 TPM များအတွက် System Design အင်တာဗျူး မေးခွန်းနှင့် အဖြေများ (Interview Drills)

### ❓ Question 1: 64-port 800G switches များကို အသုံးပြု၍ GPU servers ၁၆,၃၈၄ လုံးအတွက် non-blocking fabric တစ်ခုကို မည်သို့ ဒီဇိုင်းဆွဲမည်နည်း။
**အဖြေ (Answer):**
64-port switches များကို သုံးထားသော 2-tier spine-leaf fabric သည် အများဆုံး non-blocking ချိတ်ဆက်နိုင်မှုမှာ $32 \times 32 = 1,024$ nodes သာ ဖြစ်ပါသည် (leaf တစ်ခုစီတွင် GPUs များသို့ downlinks ၃၂ ခုနှင့် spines များသို့ uplinks ၃၂ ခု ရှိပါသည်)။ GPU ပေါင်း ၁၆,၃၈၄ လုံးအထိ ချိတ်ဆက်ရန်အတွက် **3-tier (5-stage Clos) architecture** လိုအပ်ပါသည်:
1. **Tier-1 (Leaf / ToR)**: Leaf switches ၅၁၂ လုံး လိုအပ်ပြီး တစ်ခုချင်းစီတွင် GPUs များသို့ downlinks ၃၂ ခု (စုစုပေါင်း ၁၆,၃၈၄ GPUs) နှင့် Tier-2 spines များသို့ uplinks ၃၂ ခု ချိတ်ဆက်ရပါမည်။
2. **Tier-2 (Spine / Fabric)**: Pods များအဖြစ် စုစည်းထားပြီး pod တစ်ခုချင်းစီရှိ leaves များသည် spines ၃၂ လုံးနှင့် ချိတ်ဆက်ထားပါသည်။
3. **Tier-3 (Super-Spine / Core)**: Cluster တစ်ခုလုံးရှိ inter-pod traffic များကို စုစည်းပေးပြီး 1:1 non-blocking bisectional bandwidth ကို ထိန်းသိမ်းပေးပါသည်။

### ❓ Question 2: Datacenter fabric control planes အတွက် Hyperscalers များသည် IGP+iBGP ထက် eBGP (RFC 7938) ကို အဘယ်ကြောင့် ပိုမို ဦးစားပေး အသုံးပြုကြသနည်း။
**အဖြေ (Answer):**
1. **Loop Prevention (ကွင်းပတ်ကာကွယ်ခြင်း)**: BGP သည် loop prevention အတွက် `AS-PATH` ကို အလိုအလျောက် အသုံးပြုပါသည်။ အကယ်၍ update တစ်ခုသည် မိမိ AS ထံသို့ ပြန်လည်ရောက်ရှိလာပါက ရှုပ်ထွေးသော graph computations များကို မလိုဘဲ ချက်ချင်း ပယ်ဖျက်ပေးပါသည်။
2. **Blast Radius Containment (ပြိုလဲမှုဧရိယာကို ကန့်သတ်ခြင်း)**: Rack သို့မဟုတ် pod တစ်ခုတွင် route flapping ဖြစ်ပေါ်ပါက AS နယ်နိမိတ်များတွင် damp ပြုလုပ်ပြီး filter တားဆီးထားနိုင်သဖြင့် link-state IGPs (OSPF/IS-IS) များတွင် ဖြစ်ပေါ်တတ်သော fabric တစ်ခုလုံး SPF recalculation storms ဖြစ်ပွားခြင်းမှ ကာကွယ်ပေးပါသည်။
3. **Multi-Vendor Uniformity (စက်အမျိုးမျိုးနှင့် ကိုက်ညီမှု)**: BGP သည် Arista, Cisco, Juniper, နှင့် whitebox SONiC platforms များအားလုံးတွင် တူညီသော operational semantics ဖြင့် အပြည့်အဝ ထောက်ပံ့ပေးထားပါသည်။
