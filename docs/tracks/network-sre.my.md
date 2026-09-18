<div class="nf-hud-tag">TRACK 02 / 06 &bull; PRODUCTION RELIABILITY (မြန်မာဗားရှင်း)</div>

# 🤖 Network SRE & Observability သင်ယူမှုလမ်းကြောင်း

> 🚀 **Production Reliability & Automated Operations**: စစ်မှန်သော Arista cEOS fabrics များပေါ်တွင် လုပ်ငန်းခွင် အရေးပေါ်ပြဿနာ ဖြေရှင်းခြင်း (incident mitigation)၊ ၃၀၀ မီလီစက္ကန့်အောက် BFD sub-second failover၊ gNMI အချိန်နှင့်တစ်ပြေးညီ streaming telemetry၊ Prometheus ဖြင့် anomaly detection ပြုလုပ်ခြင်းနှင့် Cisco PyATS ဖြင့် အလိုအလျောက် health gate checks များကို ကျွမ်းကျင်စွာ တည်ဆောက်မောင်းနှင်ပါ။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အချက်အလက် (Metric) | သတ်မှတ်ချက် (Target Specification) |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၃၀ – ၃၅ နာရီ** (လက်တွေ့ lab-driven, scenario-based လေ့ကျင့်မှု) |
| **တက်လှမ်းရမည့် အဆင့်များ** | **အဓိက အဆင့် ၅ ဆင့်** (Convergence → Automated Assertions → Telemetry → Control Plane Hardening → Incident Drills) |
| **Lab နည်းပညာ Framework** | **Containerlab + Arista cEOS** (macOS OrbStack သို့မဟုတ် Linux Docker ပေါ်တွင် ၁၀၀% အခမဲ့ run နိုင်သည်) |
| **ဦးတည်သော အလုပ်အကိုင်များ** | Network SRE, Production Infrastructure Engineer, Network Observability Lead, Cloud Network SRE |
| **ပစ်မှတ်ထားသော ကုမ္ပဏီကြီးများ** | Google, Meta, Apple, AWS, Microsoft, ByteDance, Netflix, Stripe, နှင့် High-Scale SaaS Platforms |

---

## 🧠 Network SRE အဓိက အင်ဂျင်နီယာ မဏ္ဍိုင်ကြီးများ (Core Engineering Pillars)

| SRE Pillar | အဓိကနည်းပညာများ (Key Production Technologies) | အင်ဂျင်နီယာ ရည်မှန်းချက် (Engineering Objective) |
|---|---|---|
| **Sub-Second Failover** | **BFD (Bidirectional Forwarding Detection)** | နှေးကွေးသော IGP keepalives များကို မစောင့်ဘဲ optical/physical link ပြတ်တောက်မှုကို ၃၀၀ မီလီစက္ကန့် (300ms) အတွင်း အလိုအလျောက် သိရှိစေရန် |
| **Push-Based Observability** | **gNMI / OpenConfig / Prometheus / Grafana** | ရှေးဟောင်း ၅ မိနစ်တစ်ကြိမ် SNMP polling အစား gRPC HTTP/2 ပေါ်မှ high-cardinality time-series metrics များကို real-time stream ပြုလုပ်ရန် |
| **Automated Testing Gates** | **Cisco PyATS / Genie / Robot Framework** | ပြုပြင်ထိန်းသိမ်းမှု မတိုင်မီနှင့် ပြီးနောက် အလိုအလျောက် pre/post-change state assertions များဖြင့် လူသားမှားယွင်းမှု (human CLI error) ကို အမြစ်ပြတ်ဖယ်ရှားရန် |
| **Control Plane Resilience** | **CoPP (Control Plane Policing) & Rate Limits** | Switch Supervisor engine / CPU ကို route table exhaustion နှင့် broadcast storms များဒဏ်မှ အကာအကွယ်ပေးရန် |
| **Error Budgets & SLOs** | **SLI/SLO Management & Blast Radius** | တိကျစွာ တိုင်းတာနိုင်သော ရရှိနိုင်စွမ်းပစ်မှတ်များ (99.99% availability) သတ်မှတ်ပြီး ပျက်စီးဆုံးရှုံးမှုဧရိယာ (failure domains) ကို သီးသန့်ခွဲထုတ်ရန် |

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
      <p class="nf-step-desc">Hardware-offloaded BFD ဖြင့် sub-second link fault detection ကို ရယူပြီး BGP flap dampening ဖြင့် routing churn ဖြစ်ပေါ်မှုကို ထိန်းချုပ်ကာကွယ်ပါ။</p>
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
      <p class="nf-step-desc">Cisco PyATS နှင့် Genie structured parsers များကို အသုံးပြု၍ လူသားတို့၏ CLI မှားယွင်းမှုများကို အလိုအလျောက် စစ်ဆေးသည့် pre- နှင့် post-maintenance test suites များဖြင့် အစားထိုးပါ။</p>
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
      <p class="nf-step-desc">gNMI streaming telemetry၊ OpenConfig YANG data models နှင့် Prometheus scraping တို့ကို တပ်ဆင်အသုံးပြုခြင်းဖြင့် monitoring စနစ်ရှိ ကွယ်ပျောက်နေသော အချက်အလက် (blind spots) များကို အပြည့်အဝ ဖယ်ရှားပါ။</p>
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
      <p class="nf-step-desc">Control Plane Policing (CoPP) နှင့် VRF microsegmentation များကို အသုံးပြု၍ switch Supervisor engines များကို denial of service (DoS) တိုက်ခိုက်မှုများမှ အကာအကွယ်ပေးပါ။</p>
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
      <p class="nf-step-desc">လက်တွေ့လည်ပတ်နေသော ကွန်ရက်တွင် link drop storms များကို simulate စမ်းသပ်ခြင်း၊ ဖိအားများအောက်တွင် routing oscillations များကို စစ်ဆေးဖော်ထုတ်ခြင်းနှင့် blameless post-mortem triage ပြုလုပ်ခြင်းတို့ကို လေ့ကျင့်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Link Flap Injection</span>
        <span class="nf-chip">BGP Churn Triage</span>
        <span class="nf-chip">MTTR Optimization</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 အပြန်အလှန် လေ့လာနိုင်သော သင်ခန်းစာလမ်းညွှန် (Interactive Lesson Directory)

| Milestone Stage | SRE Pillar အဓိကအချက် | ကလစ်နှိပ်၍ လေ့လာနိုင်သော သင်ခန်းစာ & လက်တွေ့ Labs | စမ်းသပ်နိုင်သော Lab | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Fast Convergence` | BFD Sub-Second Failover, BGP Flap Dampening, Graceful Restart | • [Phase 2 · Lab 03: Sub-Second BFD Peering](../courses/02-bgp-dia/lab-03-ixp-peering.md)<br/>• [Phase 6 · Lab 03: WAN Edge BFD Failover](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) | `labs/wan-edge-lab` | [Stage 1 စတင်ရန် →](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) |
| **Stage 2**<br/>`Automated Gates` | PyATS Testbeds, Genie Parsers, Pre/Post-Maintenance State Diffing | • [Phase 5 · Lab 02: PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md)<br/>• [Phase 5 · Lab 05: CI/CD Pipeline Automation](../courses/05-netdevops/lab-05-github-actions-cicd.md) | `labs/netdevops-lab` | [Stage 2 စတင်ရန် →](../courses/05-netdevops/lab-02-pyats-verification.md) |
| **Stage 3**<br/>`Observability` | gNMI Streaming Protobuf, OpenConfig YANG, Prometheus, Grafana | • [Phase 7 · Lab 01: gNMI & OpenConfig YANG](../courses/07-telemetry/lab-01-gnmi-openconfig.md)<br/>• [Phase 7 · Lab 02: pygnmi Python Streams](../courses/07-telemetry/lab-02-pygnmi-python.md)<br/>• [Phase 7 · Lab 03: Prometheus Metric Collectors](../courses/07-telemetry/lab-03-prometheus-time-series.md)<br/>• [Phase 7 · Lab 04: Real-Time Grafana Dashboards](../courses/07-telemetry/lab-04-grafana-observability.md) | `labs/telemetry-lab` | [Stage 3 စတင်ရန် →](../courses/07-telemetry/lab-01-gnmi-openconfig.md) |
| **Stage 4**<br/>`Control Plane Defense` | CoPP CPU Protection, MQC Rate-Limiting, VRF Microsegmentation | • [Phase 8 · Lab 01: CoPP CPU Protection](../courses/08-security/lab-01-copp-cpu-protection.md)<br/>• [Phase 8 · Lab 02: VRF Microsegmentation](../courses/08-security/lab-02-vrf-route-leaking-acls.md)<br/>• [Phase 8 · Lab 03: Infrastructure ACLs (iACL)](../courses/08-security/lab-03-infrastructure-acls.md) | `labs/security-lab` | [Stage 4 စတင်ရန် →](../courses/08-security/lab-01-copp-cpu-protection.md) |
| **Stage 5**<br/>`Incident Drills` | Link Flaps, BGP Churn, MTTR Reduction & Blameless Post-Mortems | • [Phase 1 · Lab 04: Multihomed Edge Failure Triage](../courses/01-bgp/lab-04-dual-homed-edge.md)<br/>• [System Design Incident Response Drills](../interview-prep/google-system-design.md) | `labs/bgp-lab` | [Stage 5 စတင်ရန် →](../interview-prep/google-system-design.md) |

---

## 🧪 အသေးစိတ် Milestone သင်ရိုးညွှန်းတမ်း (Detailed Milestone Curricula)

### 📍 Stage 1: Fast Convergence & Link Resilience
- **အဓိက အလေးထားချက် (Core Focus)**: အသံတိတ် physical link degradation ဖြစ်ပေါ်ခြင်း သို့မဟုတ် နှေးကွေးသော routing protocol keepalives များကြောင့် ဖြစ်ပေါ်တတ်သည့် downtime များကို အပြီးတိုင် ဖယ်ရှားခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: BFD microsecond timers များ၊ ASICs သို့ hardware offload ပြုလုပ်ခြင်း၊ BGP route flap dampening နှင့် graceful restart (RFC 4724)။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 2: BGP Dual-Homed Internet Access](../courses/02-bgp-dia/index.md)
    - [Phase 6: Enterprise WAN Edge & BFD](../courses/06-hybrid-cloud/index.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/wan-edge-lab
    ./run.sh --guided
    ```

### 📍 Stage 2: Automated Testing & Verification Gates
- **အဓိက အလေးထားချက် (Core Focus)**: လက်ဖြင့် manual ရိုက်နှိပ်ရသော CLI `show` commands များအစား automated deployments များကို ထိန်းကျောင်းပေးသည့် codified assertion suites များဖြင့် အစားထိုးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: PyATS testbeds များ၊ Genie parsers များ၊ ပြုပြင်မှုမပြုမီနှင့် ပြုပြီး operational state diff များကို နှိုင်းယှဉ်စစ်ဆေးခြင်းနှင့် routing table integrity checks များ။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Network Automation & CI/CD](../courses/05-netdevops/index.md)
    - [Lab 02: PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 3: Real-Time Telemetry & Observability
- **အဓိက အလေးထားချက် (Core Focus)**: ဝန်ပိစေပြီး တုံ့ပြန်မှုနှေးကွေးသော SNMP polling မှသည် sub-second gRPC push streams သို့ ကူးပြောင်းအဆင့်မြှင့်တင်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: gNMI Subscribe RPC (`STREAM`, `SAMPLE`, `ON_CHANGE`)၊ OpenConfig interface နှင့် BGP schemas၊ Prometheus metric scraping နှင့် Grafana dashboards ဖြင့် ပြသခြင်း။
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
- **အဓိက အလေးထားချက် (Core Focus)**: Data plane ရှိ ပုံမှန်မဟုတ်သော ယာဉ်ကြောပမာဏ သို့မဟုတ် ရည်ရွယ်ချက်ရှိရှိ တိုက်ခိုက်မှုများကြောင့် device control plane ပြိုလဲမသွားစေရန် အကာအကွယ်ပေးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: CoPP MQC policies (BGP, OSPF, SSH, ICMP အလိုက် traffic ခွဲခြားခြင်း)၊ bandwidth rate limits များ ချမှတ်ခြင်းနှင့် hardware TCAM allocation။
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
- **အဓိက အလေးထားချက် (Core Focus)**: Monitoring alerts များ၊ automated failovers များနှင့် incident response playbooks များကို စစ်ဆေးရန် လက်တွေ့ production outages များကို simulate ပြုလုပ်၍ စမ်းသပ်ခြင်း။
- **အဓိက အကြောင်းအရာများ (Topics)**: Link degradation ဖြစ်ပေါ်အောင် စမ်းသပ်ခြင်း၊ leaf switch ရုတ်တရက် reboot ဖြစ်ခြင်းကို simulate လုပ်ခြင်း၊ BGP convergence နှောင့်နှေးမှုများကို စစ်ဆေးသုံးသပ်ခြင်းနှင့် blameless post-mortems ရေးသားခြင်း။

---

## 🛠️ စမ်းသပ်မောင်းနှင်နိုင်သော Local Lab ပတ်ဝန်းကျင် (Executable Local Lab Environment)

NetForge Labs သည် topologies များကို မိမိစက်တွင်း၌ ချက်ချင်းတည်ဆောက်ပြီး စမ်းသပ်စစ်ဆေးနိုင်ရန် automated step runners များကို အသုံးပြုထားပါသည်။

```bash
# ၁။ Telemetry & Observability lab လမ်းကြောင်းသို့ သွားပါ
cd labs/telemetry-lab

# ၂။ Guided interactive runner ကို စတင်ဖွင့်လှစ်ပါ
./run.sh --guided

# သို့မဟုတ် အတည်ပြုစစ်ဆေးပြီးသား topology တစ်ခုလုံးကို command တစ်ခုတည်းဖြင့် deploy လုပ်ပါ
./run.sh --all
```

---

## 🎓 အသက်မွေးဝမ်းကျောင်းဆိုင်ရာ လက်တွေ့ Portfolio Projects (Career Defense)

1. **Sub-Second BFD Failover Fabric**:
   - BGP Peers ၁,၀၀၀ ကျော်ရှိသော ကွန်ရက်တွင် BFD timers သတ်မှတ်ချက်နှင့် switch CPU utilization အကြား ချိန်ဆရသော ဒီဇိုင်းဆိုင်ရာ trade-offs များကို အင်တာဗျူးများတွင် ယုံကြည်မှုရှိရှိ ရှင်းပြကာကွယ်နိုင်မည်။
2. **End-to-End gNMI Observability Pipeline**:
   - ရှေးရိုး SNMP စနစ်ဖြင့် လုံးဝမသိရှိနိုင်သော microsecond အဆင့် switch queue buffer congestion ပြဿနာများကို gNMI ဖြင့် မည်သို့တိကျစွာ ဖမ်းယူစောင့်ကြည့်ခဲ့ပုံကို လက်တွေ့ သက်သေပြနိုင်မည်။
3. **Automated CI/CD Maintenance Gate**:
   - Router OS upgrade ပြုလုပ်စဉ် traffic shift အတွင်း packet drop များ စတင်ဖြစ်ပေါ်ပါက လုပ်ငန်းစဉ်ကို အလိုအလျောက် ရပ်တန့် (abort/rollback) ပေးသည့် PyATS testbed စနစ်ကို တင်ပြနိုင်မည်။
