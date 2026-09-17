# 🎯 အထူးပြု သင်ယူမှုလမ်းကြောင်းများ (Learning Paths)

<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 1.5rem; flex-wrap:wrap; gap:0.5rem;">
  <span class="nf-hud-tag" style="margin-bottom:0;">// CAREER TRACKS OVERVIEW</span>
  <a href="../tracks/" class="nf-chip" style="color:var(--nf-accent-emerald); font-weight:700; text-decoration:none; padding: 0.35rem 0.8rem; border: 1px solid var(--nf-accent-emerald);">🌐 Switch to English Version →</a>
</div>

> မိမိတက်လှမ်းလိုသော အင်ဂျင်နီယာ အသက်မွေးဝမ်းကျောင်း လမ်းကြောင်းကို ရွေးချယ်ပါ - **AI & Hyperscale Infrastructure Architecture**၊ **Network SRE & Observability**၊ **Cybersecurity & DevSecOps**၊ **NetDevOps & Automation**၊ **Low-Latency Financial Engineering** သို့မဟုတ် **Technical Program Management (TPM)**။
>
> လမ်းကြောင်းတိုင်းကို အဆင့်ဆင့် တက်လှမ်းရသော Milestone အဆင့်များဖြင့် စနစ်တကျ ဖွဲ့စည်းထားပြီး၊ တိုက်ရိုက် run နိုင်သော Containerlab topologies၊ အလိုအလျောက် စစ်ဆေးသည့် Guided runners (`./run.sh --guided`) နှင့် Live verification tests များ ပါဝင်ပါသည်။

---

## 🗺️ မိမိ၏ အသက်မွေးဝမ်းကျောင်း လမ်းကြောင်းကို ရွေးချယ်ပါ

<div class="grid cards" markdown>

-   🌐 **1. Network for AI & Hyperscale Architect** &nbsp; <span class="nf-badge ok">၄၀–၅၀ နာရီ</span>

    ---

    **နောက်မျိုးဆက်သစ် AI Clusters များနှင့် Cloud Backbones များကို တည်ဆောက်လိုသော အင်ဂျင်နီယာများအတွက်။**

    - **Lossless AI Transport**: RoCEv2၊ PFC (802.1Qbb)၊ ECN & Buffer tuning
    - **Datacenter Fabrics**: 5-Stage Clos၊ EVPN-VXLAN၊ ESI All-Active Multihoming
    - **Routing & Backbone**: RFC 7938 BGP၊ MP-BGP VPNv4၊ SR-MPLS & Ti-LFA

    [AI & Hyperscale လမ်းကြောင်း စတင်ရန် →](network-engineer.md)

-   🤖 **2. Network SRE & Observability** &nbsp; <span class="nf-badge ok">၃၀–၃၅ နာရီ</span>

    ---

    **Five-nines (99.999%) အမြဲတစေ လည်ပတ်နိုင်မှုနှင့် အချိန်နှင့်တပြေးညီ မြင်သာမှုကို တည်ဆောက်လိုသူများအတွက်။**

    - **Sub-Second Convergence**: BFD hardware offload & route flap dampening
    - **Push Telemetry**: gNMI gRPC Protobuf၊ OpenConfig YANG၊ Prometheus & Grafana
    - **Reliability Engineering**: CoPP CPU protection၊ PyATS assertions & incident drills

    [Network SRE လမ်းကြောင်း စတင်ရန် →](../tracks/network-sre.md)

-   🔒 **3. Cybersecurity & DevSecOps** &nbsp; <span class="nf-badge ok">၃၀–၃၅ နာရီ</span>

    ---

    **ကွန်ရက်အခြေခံအဆောက်အအုံများနှင့် Cloud-Native စနစ်များကို ကာကွယ်လိုသူများအတွက်။**

    - **Network Hardening**: Control Plane Policing (CoPP)၊ iACLs၊ VRF microsegmentation
    - **Zero-Trust Identity**: OAuth2၊ OIDC၊ mutual TLS (mTLS) နှင့် HashiCorp Vault
    - **Runtime & AppSec**: OWASP Top 10 WAF၊ Falco eBPF kernel detection နှင့် SIEM

    [Cybersecurity လမ်းကြောင်း စတင်ရန် →](../tracks/cybersecurity-engineer.md)

-   🤖 **4. NetDevOps & Infrastructure Automation** &nbsp; <span class="nf-badge ok">၃၅–၄၀ နာရီ</span>

    ---

    **ကွန်ရက်အခြေခံအဆောက်အအုံကို Software Code ကဲ့သို့ အလိုအလျောက် စီမံခန့်ခွဲလိုသူများအတွက်။**

    - **Data Modeling**: YAML Single Source of Truth & Jinja2 template rendering
    - **Pre-Flight Static Analysis**: Batfish AST simulation ဖြင့် မ run မီ reachability အတည်ပြုခြင်း
    - **CI/CD Automation**: GitHub Actions၊ Containerlab headless testbeds နှင့် PyATS

    [NetDevOps လမ်းကြောင်း စတင်ရန် →](../tracks/netdevops-engineer.md)

-   ⚡ **5. Low-Latency Financial Network Engineer** &nbsp; <span class="nf-badge ok">၂၅–၃၀ နာရီ</span>

    ---

    **High-Frequency Trading (HFT) နှင့် စတော့အိတ်ချိန်း Co-location ဗိသုကာများအတွက်။**

    - **Multicast Market Feeds**: PIM-SM၊ Anycast RP နှင့် IGMP fast-leave tuning
    - **Sub-50ms Failover**: အလင်းမျှင်ချိတ်ဆက်မှုများပေါ်တွင် မိုက်ခရိုစက္ကန့် BFD timers
    - **Line-Rate Security**: IEEE 802.1AE MACsec AES-256-GCM hardware encryption

    [Low-Latency လမ်းကြောင်း စတင်ရန် →](../tracks/financial-network-engineer.md)

-   📋 **6. TPM & Hyperscale System Design** &nbsp; <span class="nf-badge ok">၂၀–၂၅ နာရီ</span>

    ---

    **အခြေခံအဆောက်အအုံ စီမံကိန်းခေါင်းဆောင်များနှင့် Systems Architects များအတွက်။**

    - **Fabric Sizing Math**: Non-blocking Clos formulas နှင့် oversubscription ratios
    - **Protocol Governance**: RFC 7938 eBGP နှင့် iBGP blast-radius ထိန်းချုပ်မှု
    - **SLA & Vendor RFPs**: Sub-50ms Ti-LFA error budgets နှင့် OpenConfig စံနှုန်းများ

    [TPM System Design လမ်းကြောင်း စတင်ရန် →](../tracks/technical-program-manager.md)

</div>

---

## 📊 လမ်းကြောင်းများ နှိုင်းယှဉ်ချက် ဇယား (Comparison Matrix)

| သင်ယူမှုလမ်းကြောင်း | အဓိက အလေးပေးမှု | အဓိက နည်းပညာများ | ဦးတည်သော အလုပ်အကိုင်များ | ခန့်မှန်း ကြာမြင့်ချိန် |
|---|---|---|---|---|
| **🌐 AI & Hyperscale Architect** | Non-blocking AI fabrics & Core routing | RoCEv2, PFC/ECN, EVPN-VXLAN, BGP, SR-MPLS | Architect - Network for AI, Staff Infrastructure Architect | ၄၀–၅၀ နာရီ |
| **🤖 Network SRE & Observability** | Sub-second failover & Streaming telemetry | BFD, gNMI, OpenConfig, Prometheus, PyATS | Network SRE, Production Reliability Engineer | ၃၀–၃၅ နာရီ |
| **🔒 Cybersecurity & DevSecOps** | စနစ်လုံခြုံရေး & Zero-Trust | CoPP, iACLs, VRF, Falco eBPF, mTLS, WAF | Cybersecurity Engineer, DevSecOps Architect | ၃၀–၃၅ နာရီ |
| **🤖 NetDevOps & Automation** | Infrastructure as Code & CI/CD | YAML, Jinja2, Batfish, GitHub Actions, pygnmi | NetDevOps Engineer, Automation Architect | ၃၅–၄၀ နာရီ |
| **⚡ Low-Latency Financial** | Nanosecond HFT & Multicast market data | PIM-SM, IGMP, BFD microsecond, MACsec | Low-Latency Network Engineer, HFT Architect | ၂၅–၃၀ နာရီ |
| **📋 TPM & System Design** | Capacity math, SLAs & စီမံကိန်းစီမံခန့်ခွဲမှု | 5-Stage Clos math, BGP blast radius, RFP criteria | Technical Program Manager, Infrastructure Director | ၂၀–၂၅ နာရီ |
