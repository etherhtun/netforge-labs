<div class="nf-hud-tag">TRACK 02 / 06 &bull; PRODUCTION RELIABILITY</div>

# 🤖 Network SRE & Observability သင်ယူမှုလမ်းကြောင်း

> 🚀 **Production Reliability & Automated Operations** - လက်တွေ့ Arista cEOS fabrics ပတ်ဝန်းကျင်ပေါ်တွင် လုပ်ငန်းခွင်တွင်း ဖြစ်ပေါ်တတ်သည့် အရေးပေါ်စနစ်ပြဿနာများကို ကိုင်တွယ်ဖြေရှင်းခြင်း (incident mitigation)၊ စက္ကန့်ပိုင်းအတွင်း အလိုအလျောက် လမ်းကြောင်းပြောင်းပေးနိုင်သည့် BFD sub-second failover၊ gNMI streaming telemetry ဖြင့် real-time စောင့်ကြည့်ခြင်း၊ Prometheus ဖြင့် မူမမှန်မှုများကို ထောက်လှမ်းခြင်း (anomaly detection) နှင့် Cisco PyATS ဖြင့် စနစ်ကျန်းမာရေးကို အလိုအလျောက် စစ်ဆေးသည့် health gate checks များကို ကျွမ်းကျင်ပိုင်နိုင်စွာ တည်ဆောက်မောင်းနှင်ပါ။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အကြောင်းအရာ | သတ်မှတ်ချက် |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၃၀ မှ ၃၅ နာရီခန့်** (လက်တွေ့ lab-driven, scenario-based လေ့ကျင့်မှု) |
| **သင်ယူရမည့် အဓိကအဆင့်များ** | **၅ ဆင့်** (Convergence → Automated Assertions → Telemetry → Control Plane Hardening → Incident Drills) |
| **Lab စနစ်** | **Containerlab + Arista cEOS** (macOS OrbStack သို့မဟုတ် Linux Docker ပေါ်တွင် ၁၀၀% မိမိစက်တွင်း၌ run နိုင်သည်) |
| **ဦးတည်သည့် ရာထူးများ** | Network SRE, Production Infrastructure Engineer, Network Observability Lead, Cloud Network SRE |
| **ရည်ရွယ်သော လုပ်ငန်းနယ်ပယ်များ** | Google, Meta, Apple, AWS, Microsoft, ByteDance, Netflix, Stripe နှင့် High-Scale SaaS Platform များ |

---

## 🧠 Network SRE အဓိက အင်ဂျင်နီယာ မဏ္ဍိုင်ကြီးများ (Core Engineering Pillars)

| SRE မဏ္ဍိုင် (Pillar) | အဓိကနည်းပညာများ | ရည်ရွယ်ချက် (Engineering Objective) |
|---|---|---|
| **Sub-Second Failover** | **BFD (Bidirectional Forwarding Detection)** | နှေးကွေးသည့် IGP keepalive များကို စောင့်မနေဘဲ optical သို့မဟုတ် physical link ပြတ်တောက်မှုကို ၃၀၀ မီလီစက္ကန့် (300ms) အတွင်း အလိုအလျောက် သိရှိပြီး လမ်းကြောင်းပြောင်းလဲနိုင်စေရန် |
| **Push-Based Observability** | **gNMI / OpenConfig / Prometheus / Grafana** | မိနစ်အနည်းငယ်ကြာမှ အချက်အလက်ယူသည့် ရှေးရိုး SNMP polling စနစ်ဟောင်းအစား gRPC HTTP/2 ကိုသုံး၍ အသေးစိတ် metrics များကို real-time stream လုပ်ယူရန် |
| **Automated Testing Gates** | **Cisco PyATS / Genie / Robot Framework** | ပြုပြင်ထိန်းသိမ်းမှု (maintenance) မတိုင်မီနှင့် ပြီးနောက် အလိုအလျောက် စစ်ဆေးသည့် test assertions များ အသုံးပြုပြီး လူ့အမှားကြောင့် ဖြစ်ပေါ်တတ်သည့် CLI မှားယွင်းမှုများကို အပြီးတိုင် ဖယ်ရှားရန် |
| **Control Plane Resilience** | **CoPP (Control Plane Policing) & Rate Limits** | Route table ပြည့်လျှံခြင်းနှင့် broadcast storm များဒဏ်မှ Switch Supervisor engine / CPU ကို အကာအကွယ်ပေးရန် |
| **Error Budgets & SLOs** | **SLI/SLO Management & Blast Radius** | စနစ်အမြဲလည်ပတ်နိုင်မှု ပစ်မှတ်များ (99.99% availability) ကို တိကျစွာ သတ်မှတ်ပြီး ပြဿနာဖြစ်ပေါ်ပါက ထိခိုက်မှုနယ်ပယ် (failure domain) ကျဉ်းမြောင်းစေရန် သီးသန့်ခွဲထုတ်ထားရှိရန် |

---

## 🗺️ အဆင့် ၅ ဆင့် တိုးတက်မှု Milestone လမ်းပြမြေပုံ (Roadmap)

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-fast-convergence-link-resilience">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · Fast Convergence & Link Resilience</h4>
        <span class="nf-badge ok">Sub-Second Failover</span>
      </div>
      <p class="nf-step-desc">Hardware-offloaded BFD ကို အသုံးချ၍ sub-second link fault detection စနစ်ကို တည်ဆောက်ပြီး BGP flap dampening ဖြင့် မတည်ငြိမ်သော routing ပြောင်းလဲမှုများကို ထိန်းချုပ်ကာကွယ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">BFD Hardware Offload</span>
        <span class="nf-chip">BGP Flap Dampening</span>
        <span class="nf-chip">Graceful Restart RFC 4724</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-automated-testing-verification-gates">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Automated Testing & Verification Gates</h4>
        <span class="nf-badge ok">Codified Assertions</span>
      </div>
      <p class="nf-step-desc">Cisco PyATS နှင့် Genie structured parsers များကို အသုံးပြုကာ ပြုပြင်ထိန်းသိမ်းမှု မတိုင်မီနှင့် ပြီးနောက် အခြေအနေများကို အလိုအလျောက် စစ်ဆေးသည့် test suites များဖြင့် လူ့အမှားအယွင်းများကို လျှော့ချပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">PyATS Testbeds</span>
        <span class="nf-chip">Genie JSON Parsers</span>
        <span class="nf-chip">Operational State Diffs</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-real-time-telemetry-observability">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · Real-Time Telemetry & Observability</h4>
        <span class="nf-badge ok">Streaming Metrics</span>
      </div>
      <p class="nf-step-desc">gNMI streaming telemetry၊ OpenConfig YANG data models နှင့် Prometheus metric scraping တို့ကို ပေါင်းစပ်အသုံးပြုခြင်းဖြင့် စောင့်ကြည့်စစ်ဆေးမှုမှ လွတ်ထွက်နေသော ကွက်လပ်များ (monitoring blind spots) ကို အပြည့်အဝ ဖယ်ရှားရှင်းလင်းပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">gNMI gRPC Protobuf</span>
        <span class="nf-chip">OpenConfig YANG</span>
        <span class="nf-chip">Prometheus</span>
        <span class="nf-chip">Grafana</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-control-plane-defense-blast-radius-isolation">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · Control Plane Defense & Blast Radius Isolation</h4>
        <span class="nf-badge ok">Switch Hardening</span>
      </div>
      <p class="nf-step-desc">Control Plane Policing (CoPP) နှင့် VRF microsegmentation တို့ကို အသုံးပြုပြီး switch ၏ Supervisor engines များကို denial-of-service (DoS) တိုက်ခိုက်မှုများမှ အကာအကွယ်ပေးပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">CoPP CPU Protection</span>
        <span class="nf-chip">MQC Rate Limiting</span>
        <span class="nf-chip">VRF Route Leaking</span>
        <span class="nf-chip">iACLs</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-chaos-engineering-incident-drills">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · Chaos Engineering & Incident Drills</h4>
        <span class="nf-badge ok">Production Drills</span>
      </div>
      <p class="nf-step-desc">လက်တွေ့လည်ပတ်နေသော ကွန်ရက်တွင် link drop storm များကို simulation ပြုလုပ်စမ်းသပ်ခြင်း၊ ဝန်ပိနေချိန်တွင် routing မတည်ငြိမ်မှုများကို ရှာဖွေဖော်ထုတ်ခြင်းနှင့် အချင်းချင်း အပြစ်တင်မှုမရှိသော blameless post-mortem triage ပြုလုပ်ခြင်းတို့ကို လက်တွေ့ လေ့ကျင့်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Link Flap Injection</span>
        <span class="nf-chip">BGP Churn Triage</span>
        <span class="nf-chip">MTTR Optimization</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 တိုက်ရိုက် လေ့လာနိုင်သော သင်ခန်းစာလမ်းညွှန် (Interactive Lesson Directory)

| Milestone Stage | SRE Pillar အဓိကအချက် | တိုက်ရိုက်လေ့လာနိုင်သော သင်ခန်းစာ & Labs များ | လက်တွေ့စမ်းသပ်ရန် Lab | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Fast Convergence` | BFD Sub-Second Failover, BGP Flap Dampening, Graceful Restart | • [Phase 2 · Lab 03: Sub-Second BFD Peering](../courses/02-bgp-dia/lab-03-ixp-peering.md)<br/>• [Phase 6 · Lab 03: WAN Edge BFD Failover](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) | `labs/wan-edge-lab` | [Stage 1 စတင်ရန် →](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) |
| **Stage 2**<br/>`Automated Gates` | PyATS Testbeds, Genie Parsers, Pre/Post-Maintenance State Diffing | • [Phase 5 · Lab 02: PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md)<br/>• [Phase 5 · Lab 05: CI/CD Pipeline Automation](../courses/05-netdevops/lab-05-github-actions-cicd.md) | `labs/netdevops-lab` | [Stage 2 စတင်ရန် →](../courses/05-netdevops/lab-02-pyats-verification.md) |
| **Stage 3**<br/>`Observability` | gNMI Streaming Protobuf, OpenConfig YANG, Prometheus, Grafana | • [Phase 7 · Lab 01: gNMI & OpenConfig YANG](../courses/07-telemetry/lab-01-gnmi-openconfig.md)<br/>• [Phase 7 · Lab 02: pygnmi Python Streams](../courses/07-telemetry/lab-02-pygnmi-python.md)<br/>• [Phase 7 · Lab 03: Prometheus Metric Collectors](../courses/07-telemetry/lab-03-prometheus-time-series.md)<br/>• [Phase 7 · Lab 04: Real-Time Grafana Dashboards](../courses/07-telemetry/lab-04-grafana-observability.md) | `labs/telemetry-lab` | [Stage 3 စတင်ရန် →](../courses/07-telemetry/lab-01-gnmi-openconfig.md) |
| **Stage 4**<br/>`Control Plane Defense` | CoPP CPU Protection, MQC Rate-Limiting, VRF Microsegmentation | • [Phase 8 · Lab 01: CoPP CPU Protection](../courses/08-security/lab-01-copp-cpu-protection.md)<br/>• [Phase 8 · Lab 02: VRF Microsegmentation](../courses/08-security/lab-02-vrf-route-leaking-acls.md)<br/>• [Phase 8 · Lab 03: Infrastructure ACLs (iACL)](../courses/08-security/lab-03-infrastructure-acls.md) | `labs/security-lab` | [Stage 4 စတင်ရန် →](../courses/08-security/lab-01-copp-cpu-protection.md) |
| **Stage 5**<br/>`Incident Drills` | Link Flaps, BGP Churn, MTTR Reduction & Blameless Post-Mortems | • [Phase 1 · Lab 04: Multihomed Edge Failure Triage](../courses/01-bgp/lab-04-dual-homed-edge.md)<br/>• [System Design Incident Response Drills](../interview-prep/google-system-design.md) | `labs/bgp-lab` | [Stage 5 စတင်ရန် →](../interview-prep/google-system-design.md) |

---

## 🧪 အသေးစိတ် Milestone သင်ရိုးညွှန်းတမ်း (Detailed Milestone Curricula)

### 📍 Stage 1: Fast Convergence & Link Resilience
- **အဓိက အလေးထားချက် (Core Focus)**: တိတ်တဆိတ် ဖြစ်ပေါ်တတ်သော physical link ပျက်စီးမှုများ သို့မဟုတ် နှေးကွေးသည့် routing protocol keepalives များကြောင့် စနစ်ပြတ်တောက်ရသည့် downtime ပြဿနာများကို အပြီးတိုင် ဖယ်ရှားခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: BFD microsecond timers များ၊ ASIC chips များပေါ်သို့ hardware offload ပြုလုပ်ခြင်း၊ BGP route flap dampening နှင့် graceful restart (RFC 4724)။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 2: BGP Dual-Homed Internet Access](../courses/02-bgp-dia/index.md)
    - [Phase 6: Enterprise WAN Edge & BFD](../courses/06-hybrid-cloud/index.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/wan-edge-lab
    ./run.sh --guided
    ```

### 📍 Stage 2: Automated Testing & Verification Gates
- **အဓိက အလေးထားချက် (Core Focus)**: လက်ဖြင့် manual တစ်ကြောင်းချင်း စစ်ဆေးရသည့် CLI `show` commands များအစား စနစ်အပြောင်းအလဲများကို စိတ်ချလက်ချ deploy ပြုလုပ်နိုင်စေရန် အလိုအလျောက် စစ်ဆေးပေးသည့် codified assertion suites များဖြင့် အစားထိုးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: PyATS testbeds များ၊ Genie parsers များ၊ စနစ်မပြင်ဆင်မီနှင့် ပြင်ဆင်ပြီးနောက် operational state အခြေအနေများကို အလိုအလျောက် နှိုင်းယှဉ်စစ်ဆေးခြင်း (diffing) နှင့် routing table တည်ငြိမ်မှု စစ်ဆေးခြင်း။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Network Automation & CI/CD](../courses/05-netdevops/index.md)
    - [Lab 02: PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 3: Real-Time Telemetry & Observability
- **အဓိက အလေးထားချက် (Core Focus)**: စက်ပစ္စည်းကို ဝန်ပိစေပြီး အချိန်ကြန့်ကြာတတ်သည့် SNMP polling စနစ်ဟောင်းမှသည် စက္ကန့်ပိုင်းအတွင်း အချိန်နှင့်တစ်ပြေးညီ ပို့ဆောင်ပေးသည့် sub-second gRPC push streams စနစ်သစ်သို့ ကူးပြောင်းအဆင့်မြှင့်တင်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: gNMI Subscribe RPC (`STREAM`, `SAMPLE`, `ON_CHANGE`)၊ OpenConfig interface နှင့် BGP schemas၊ Prometheus metric scraping နှင့် Grafana dashboards ဖြင့် စောင့်ကြည့်စစ်ဆေးခြင်း။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 7: Streaming Telemetry & Observability](../courses/07-telemetry/index.md)
    - [Telemetry Lab 01: gNMI Basics & OpenConfig](../courses/07-telemetry/lab-01-gnmi-openconfig.md)
    - [Telemetry Lab 02: pygnmi Python Integration](../courses/07-telemetry/lab-02-pygnmi-python.md)
    - [Telemetry Lab 03: Prometheus Metric Exporter](../courses/07-telemetry/lab-03-prometheus-time-series.md)
    - [Telemetry Lab 04: Real-Time Grafana Dashboards](../courses/07-telemetry/lab-04-grafana-observability.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/telemetry-lab
    ./run.sh --guided
    ```

### 📍 Stage 4: Control Plane Defense & Blast Radius Isolation
- **အဓိက အလေးထားချက် (Core Focus)**: Data plane ပေါ်တွင် ပုံမှန်မဟုတ်သော traffic ပမာဏများပြားလာခြင်း သို့မဟုတ် တိုက်ခိုက်မှုများကြောင့် device ၏ control plane ပြိုလဲမသွားစေရန် ခိုင်မာစွာ ကာကွယ်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: CoPP MQC policies (BGP, OSPF, SSH, ICMP အလိုက် traffic သီးသန့်ခွဲခြားခြင်း)၊ bandwidth rate limits များ သတ်မှတ်ခြင်းနှင့် hardware TCAM allocation ကို စီမံခန့်ခွဲခြင်း။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 8: Network Security & Microsegmentation](../courses/08-security/index.md)
    - [Security Lab 01: Control Plane Policing (CoPP)](../courses/08-security/lab-01-copp-cpu-protection.md)
    - [Security Lab 02: VRF Microsegmentation](../courses/08-security/lab-02-vrf-route-leaking-acls.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/security-lab
    ./run.sh --guided
    ```

### 📍 Stage 5: Chaos Engineering & Incident Drills
- **အဓိက အလေးထားချက် (Core Focus)**: Monitoring alerts များ၊ automated failover စနစ်များနှင့် incident response လုပ်ထုံးလုပ်နည်းများကို စစ်ဆေးရန် လက်တွေ့ production ပြဿနာများကို simulate ပြုလုပ်၍ စမ်းသပ်လေ့ကျင့်ခြင်း။
- **အဓိက အကြောင်းအရာများ (Topics)**: Link degradation ကို ဖန်တီးစမ်းသပ်ခြင်း၊ leaf switch ရုတ်တရက် restart ဖြစ်သွားပုံကို simulate လုပ်ခြင်း၊ BGP convergence ကြာမြင့်ချိန်များကို စစ်ဆေးသုံးသပ်ခြင်းနှင့် blameless post-mortem အစီရင်ခံစာ ရေးသားခြင်း။

---

## 🛠️ မိမိစက်တွင်း၌ စမ်းသပ်မောင်းနှင်နိုင်သော Local Lab ပတ်ဝန်းကျင် (Executable Local Lab Environment)

NetForge Labs ရှိ topologies များကို မိမိစက်တွင်း၌ ချက်ချင်းလက်ငင်း စတင်လေ့ကျင့်နိုင်ရန် automated step runner script များကို ထည့်သွင်းပေးထားပါသည်။

```bash
# ၁။ Telemetry & Observability lab လမ်းကြောင်းသို့ သွားပါ
cd labs/telemetry-lab

# ၂။ Guided interactive runner ကို စတင်ဖွင့်လှစ်ပါ
./run.sh --guided

# သို့မဟုတ် အတည်ပြုစစ်ဆေးပြီးသား topology တစ်ခုလုံးကို command တစ်ခုတည်းဖြင့် deploy လုပ်ပါ
./run.sh --all
```

---

## 🎓 အလုပ်အင်တာဗျူးများတွင် ထုတ်ပြဆွေးနွေးနိုင်မည့် လက်တွေ့ Portfolio Projects (Career Defense)

1. **Sub-Second BFD Failover Fabric**:
   - BGP Peers ၁,၀၀၀ ကျော်ရှိသော ကွန်ရက်ကြီးများတွင် BFD timers သတ်မှတ်ချက်နှင့် switch CPU ဝန်ပိမှုအကြား ချိန်ဆရသည့် ဒီဇိုင်းဆိုင်ရာ trade-offs များကို အင်တာဗျူးများတွင် နည်းပညာအရ ယုံကြည်ချက်ရှိရှိ ရှင်းလင်းတင်ပြနိုင်မည်။
2. **End-to-End gNMI Observability Pipeline**:
   - ရှေးရိုး SNMP စနစ်ဖြင့် ဘယ်လိုမှ မသိနိုင်သည့် microsecond အဆင့် switch queue buffer ပိတ်ဆို့မှု (congestion) ပြဿနာများကို gNMI streaming ဖြင့် မည်သို့တိကျစွာ ဖမ်းယူစောင့်ကြည့်ခဲ့ပုံကို လက်တွေ့ ထုတ်ပြနိုင်မည်။
3. **Automated CI/CD Maintenance Gate**:
   - Router OS upgrade လုပ်နေစဉ် traffic လမ်းကြောင်းပြောင်းချိန် packet drop များ စတင်ဖြစ်ပေါ်သည်နှင့် တစ်ပြိုင်နက် လုပ်ငန်းစဉ်တစ်ခုလုံးကို အလိုအလျောက် ရပ်တန့်ပေးသည့် (abort/rollback) PyATS testbed စနစ်ကို တည်ဆောက်ပြသနိုင်မည်။
