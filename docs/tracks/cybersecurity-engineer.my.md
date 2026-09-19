<div class="nf-hud-tag">TRACK 03 / 06 &bull; CYBERSECURITY & DEVSECOPS</div>

# 🔒 Cybersecurity & DevSecOps သင်ယူမှုလမ်းကြောင်း

> 🚀 **လက်တွေ့ ကျင့်သုံးရသော ဆိုက်ဘာလုံခြုံရေးနှင့် အခြေခံအဆောက်အအုံ ကာကွယ်ရေး**: Control Plane Policing (CoPP) နှင့် VRF microsegmentation မှသည် Web Application Firewalls (WAF)၊ Zero-Trust Identity (IAM/mTLS)၊ Container Security (Falco eBPF) နှင့် SIEM Incident Response စနစ်များအထိ လက်တွေ့ကျွမ်းကျင်စွာ လေ့လာနိုင်ပါသည်။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အချက်အလက် (Metric) | သတ်မှတ်ချက် (Target Specification) |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၃၀ – ၃၅ နာရီ** (လက်တွေ့ labs များနှင့် scenario အခြေပြု drills များ) |
| **တက်လှမ်းရမည့် အဆင့်များ** | **အဓိက အဆင့် ၆ ဆင့်** (Packet Analysis → AppSec/WAF → Zero-Trust → Network & CoPP Defense → Container Security → SIEM & IR) |
| **Lab နည်းပညာ Framework** | **Containerlab + Arista cEOS + Linux Security Tools** (macOS OrbStack သို့မဟုတ် Linux Docker ပေါ်တွင် ၁၀၀% အခမဲ့ run နိုင်သည်) |
| **ဦးတည်သော အလုပ်အကိုင်များ** | Cybersecurity Engineer, DevSecOps Engineer, Security Operations (SecOps) Lead, Cloud Security Architect |
| **ပစ်မှတ်ထားသော ကုမ္ပဏီကြီးများ** | Hyperscalers, Financial Tech (FinTech), Healthcare, Defense Contractors, နှင့် Security Operations Centers (SOC) |

---

## 🧠 အဓိက ဆိုက်ဘာလုံခြုံရေး နယ်ပယ်များနှင့် အင်ဂျင်နီယာသုံး Tools များ (Core Domains & Real Tools)

| လုံခြုံရေးနယ်ပယ် (Security Domain) | လက်တွေ့အင်ဂျင်နီယာသုံး Tool | အဓိက နည်းပညာဆိုင်ရာ လုပ်ဆောင်ချက် (Key Technical Mechanics) |
|---|---|---|
| **Network & Switch Defense** | **Arista cEOS / CoPP / iACLs** | CPU control plane rate-limiting ချမှတ်ခြင်း၊ BGP TTL security နှင့် VRF microsegmentation စနစ်များ |
| **AppSec & WAF** | **OWASP Top 10 / ModSecurity** | SQLi, XSS, CSRF တိုက်ခိုက်မှုများကို ကာကွယ်ခြင်းနှင့် API rate-limiting စည်းမျဉ်းများ သတ်မှတ်ခြင်း |
| **IAM & Zero-Trust Auth** | **OAuth2 / OIDC / mTLS / Vault** | Secret lifecycle စီမံခန့်ခွဲခြင်း၊ mTLS client certificates နှင့် scoped JWT validation စနစ်များ |
| **Cloud & Container Sec** | **Trivy / Falco / K8s RBAC** | Static container image vulnerability scanning နှင့် eBPF ဖြင့် runtime kernel call များကို ကြားဖြတ်စစ်ဆေးခြင်း |
| **IDS / IPS & Detection** | **Suricata / Snort / Zeek** | Deep packet inspection, signature matching ဖြင့် ခြိမ်းခြောက်မှုများကို အလိုအလျောက် ပိတ်ဆို့တားဆီးခြင်း |
| **SIEM & SecOps** | **Wazuh / Elastic SIEM / PCAP** | ဗဟိုချုပ်ကိုင်မှုရှိသော security log ingestion၊ forensic စစ်ဆေးမှုနှင့် automated triage playbooks များ |

---

## 🗺️ အဆင့် ၆ ဆင့် တိုးတက်မှု Milestone လမ်းပြမြေပုံ (Roadmap)

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-packet-forensics-traffic-inspection">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · Packet Forensics & Traffic Inspection</h4>
        <span class="nf-badge ok">Deep Packet Inspection</span>
      </div>
      <p class="nf-step-desc">Wireshark နှင့် tcpdump တို့ကို အသုံးပြု၍ ပုံမှန်မဟုတ်သော raw TCP 3-way handshake၊ TCP window exhaustion နှင့် protocol evasion နည်းလမ်းများကို အသေးစိတ် ခွဲခြမ်းစိတ်ဖြာ စစ်ဆေးပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Wireshark</span>
        <span class="nf-chip">tcpdump PCAPs</span>
        <span class="nf-chip">Layer 2-7 Forensics</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-application-security-edge-waf">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Application Security & Edge WAF</h4>
        <span class="nf-badge ok">AppSec</span>
      </div>
      <p class="nf-step-desc">Web Application Firewall (WAF) စည်းမျဉ်းများနှင့် rate-limiting ကန့်သတ်ချက်များကို တပ်ဆင်ကာ microservices နှင့် APIs များကို OWASP Top 10 တိုက်ခိုက်မှုများမှ အကာအကွယ်ပေးပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">OWASP Top 10</span>
        <span class="nf-chip">ModSecurity</span>
        <span class="nf-chip">API Rate Limiting</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-zero-trust-identity-secrets-management">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · Zero-Trust Identity & Secrets Management</h4>
        <span class="nf-badge ok">Zero-Trust</span>
      </div>
      <p class="nf-step-desc">Mutual TLS (mTLS)၊ scoped OAuth2/OIDC JWT tokens များနှင့် automated HashiCorp Vault secret rotation တို့ဖြင့် cryptographic identity စည်းမျဉ်းများကို တင်းကျပ်စွာ ချမှတ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Mutual TLS (mTLS)</span>
        <span class="nf-chip">OAuth2 / OIDC</span>
        <span class="nf-chip">HashiCorp Vault</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-network-fabric-hardening-copp-defense">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · Network Fabric Hardening & CoPP Defense</h4>
        <span class="nf-badge ok">Switch Hardening</span>
      </div>
      <p class="nf-step-desc">Control Plane Policing (CoPP)၊ Infrastructure ACLs (iACL) နှင့် VRF microsegmentation တို့ကို အသုံးပြု၍ switch Supervisor CPUs များကို DDoS floods တိုက်ခိုက်မှုများမှ ကာကွယ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">CoPP CPU Protection</span>
        <span class="nf-chip">Infrastructure ACLs</span>
        <span class="nf-chip">VRF Route Leaking</span>
        <span class="nf-chip">MACsec AES-256</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-container-cloud-devsecops">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · Container & Cloud DevSecOps</h4>
        <span class="nf-badge ok">eBPF Security</span>
      </div>
      <p class="nf-step-desc">Falco ဖြင့် eBPF system call filtering ပြုလုပ်ခြင်းနှင့် Trivy ဖြင့် static image scanning ပြုလုပ်ခြင်းဖြင့် container breakout များနှင့် privilege escalation များကို real-time ထောက်လှမ်းဖော်ထုတ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Falco eBPF</span>
        <span class="nf-chip">Trivy Vulnerability Scanner</span>
        <span class="nf-chip">Linux Capabilities</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-6-siem-ingestion-incident-response-playbooks">
    <div class="nf-step-num">06</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 6 · SIEM Ingestion & Incident Response Playbooks</h4>
        <span class="nf-badge ok">SecOps</span>
      </div>
      <p class="nf-step-desc">လုံခြုံရေးဆိုင်ရာ telemetry ဒေတာများကို Wazuh / Elastic SIEM ထဲသို့ စုစည်းထည့်သွင်းပြီး multi-stage attack vectors များကို စစ်ဆေးသုံးသပ်ကာ containment playbooks များကို အကောင်အထည်ဖော်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Wazuh SIEM</span>
        <span class="nf-chip">Log Correlation</span>
        <span class="nf-chip">Incident Response</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 အပြန်အလှန် လေ့လာနိုင်သော သင်ခန်းစာလမ်းညွှန် (Interactive Lesson Directory)

| Milestone Stage | လုံခြုံရေးနယ်ပယ် (Domain) | ကလစ်နှိပ်၍ လေ့လာနိုင်သော သင်ခန်းစာ & လက်တွေ့ Labs | စမ်းသပ်နိုင်သော Lab | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Packet Forensics` | Wireshark Dissection, TCP Handshake Anomalies, tcpdump PCAPs | • [Linux Networking & Packet Diagnostics](../courses/linux-foundations/06-kernel-networking.md) | Local Terminal | [Stage 1 စတင်ရန် →](../courses/linux-foundations/06-kernel-networking.md) |
| **Stage 2**<br/>`AppSec & WAF` | OWASP Top 10 Defenses, ModSecurity Rules, Rate-Limiting | • [Application Security & Reverse Proxy Architecture](../courses/02-bgp-dia/lab-04-cgnat-services.md) | Local Container | [Stage 2 စတင်ရန် →](../courses/02-bgp-dia/lab-04-cgnat-services.md) |
| **Stage 3**<br/>`Zero-Trust Auth` | OAuth2 Scopes, OIDC Claims, mTLS Client Certs, HashiCorp Vault | • [Zero-Trust ဗိသုကာနှင့် Interview Drills](#question-2-explain-the-difference-between-oauth2-oidc-and-mtls-in-a-zero-trust-architecture) | Local Terminal | [မေးခွန်းများ လေ့လာရန် →](#question-2-explain-the-difference-between-oauth2-oidc-and-mtls-in-a-zero-trust-architecture) |
| **Stage 4**<br/>`Network Defense` | Control Plane Policing (CoPP), Infrastructure ACLs, VRF Isolation, MACsec | • [Phase 8 · Lab 01: CoPP CPU Protection](../courses/08-security/lab-01-copp-cpu-protection.md)<br/>• [Phase 8 · Lab 02: VRF Microsegmentation](../courses/08-security/lab-02-vrf-route-leaking-acls.md)<br/>• [Phase 8 · Lab 03: Infrastructure ACLs (iACL)](../courses/08-security/lab-03-infrastructure-acls.md)<br/>• [Phase 8 · Lab 04: MACsec Line-Rate Security](../courses/08-security/lab-04-macsec-line-rate-security.md) | `labs/security-lab` | [Stage 4 စတင်ရန် →](../courses/08-security/lab-01-copp-cpu-protection.md) |
| **Stage 5**<br/>`Container Security` | Trivy Image Scanning, Linux Namespaces, Falco eBPF System Call Filters | • [Container Security & eBPF Drills](#question-1-how-does-ebpf-runtime-detection-falco-catch-container-breakouts-without-adding-latency) | Local Docker | [Drills များ လေ့လာရန် →](#question-1-how-does-ebpf-runtime-detection-falco-catch-container-breakouts-without-adding-latency) |
| **Stage 6**<br/>`SIEM & IR Playbooks` | Wazuh SIEM Ingestion, Alert Correlation, Incident Containment | • [Telemetry Alerting & Anomaly Detection](../courses/07-telemetry/lab-05-telemetry-alerting.md) | `labs/telemetry-lab` | [Stage 6 စတင်ရန် →](../courses/07-telemetry/lab-05-telemetry-alerting.md) |

---

## 🧪 အသေးစိတ် Milestone သင်ရိုးညွှန်းတမ်း (Detailed Milestone Curricula)

### 📍 Stage 1: Packet Forensics & Traffic Inspection
- **အဓိက အလေးထားချက် (Core Focus)**: Layer 2 မှ Layer 7 အထိ raw packet capture analysis နှင့် protocol များ၏ အပြုအမူကို ကျွမ်းကျင်ပိုင်နိုင်စွာ စစ်ဆေးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: TCP 3-way handshake ပုံမှန်မဟုတ်မှုများ၊ TCP window exhaustion၊ ARP poisoning ထောက်လှမ်းခြင်းနှင့် ICMP tunneling နည်းစနစ်များ။

### 📍 Stage 2: Application Security & Edge WAF
- **အဓိက အလေးထားချက် (Core Focus)**: Web APIs များနှင့် microservices များကို OWASP Top 10 web application အားနည်းချက်များမှ ကာကွယ်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: SQL injection ပုံစံများ၊ Cross-Site Scripting (XSS)၊ request rate-limiting ချမှတ်ခြင်းနှင့် ModSecurity တွင် CRS စည်းမျဉ်းများကို ပြင်ဆင်ချိန်ညှိခြင်း။

### 📍 Stage 3: Zero-Trust Identity & Secrets Management
- **အဓိက အလေးထားချက် (Core Focus)**: Cryptographic mutual authentication စနစ်နှင့် လိုအပ်ချိန်မှ ထုတ်ပေးသော dynamic secrets စနစ်။
- **အဓိက သဘောတရားများ (Key Concepts)**: Public Key Infrastructure (PKI)၊ TLS 1.3 handshakes၊ client certs သုံးသည့် mutual TLS (mTLS)၊ OAuth2 scopes နှင့် HashiCorp Vault transit secrets များ။

### 📍 Stage 4: Network Fabric Hardening & CoPP Defense
- **အဓိက အလေးထားချက် (Core Focus)**: Network switches နှင့် routers များကို control-plane exhaustion ဒဏ်နှင့် ခွင့်ပြုချက်မရှိဘဲ ကွန်ရက်အတွင်း ဘေးတိုက်ကူးပြောင်းခြင်း (unauthorized lateral movement) များမှ အကာအကွယ်ပေးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Modular QoS CLI (MQC) Control Plane Policing (CoPP)၊ လိမ်လည် traffic များကို ပိတ်ဆို့သော Infrastructure ACLs (iACLs)၊ BGP Generalized TTL Security Mechanism (GTSM RFC 5082) နှင့် VRF microsegmentation။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 8: Network Security & Microsegmentation](../courses/08-security/index.md)
    - [Lab 01: Control Plane Policing (CoPP)](../courses/08-security/lab-01-copp-cpu-protection.md)
    - [Lab 02: VRF Microsegmentation](../courses/08-security/lab-02-vrf-route-leaking-acls.md)
    - [Lab 03: Infrastructure ACLs (iACL)](../courses/08-security/lab-03-infrastructure-acls.md)
    - [Lab 04: MACsec Line-Rate Encryption](../courses/08-security/lab-04-macsec-line-rate-security.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/security-lab
    ./run.sh --guided
    ```

### 📍 Stage 5: Container & Cloud DevSecOps
- **အဓိက အလေးထားချက် (Core Focus)**: Cloud-native containers များကို CI/CD build ပြုလုပ်ချိန်မှသည် cluster runtime အတွင်းအထိ အပြည့်အဝ လုံခြုံမှုရှိစေရန် ဆောင်ရွက်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Static vulnerability scanners (Trivy)၊ Linux kernel capabilities နှင့် Falco သုံး၍ eBPF system call tracing ပြုလုပ်ခြင်း။

### 📍 Stage 6: SIEM Ingestion & Incident Response Playbooks
- **အဓိက အလေးထားချက် (Core Focus)**: တိကျခိုင်မာသော audit trails များဖြင့် လုံခြုံရေးဆိုင်ရာ ပြဿနာများကို ထောက်လှမ်းခြင်း၊ အဆင့်ခွဲခြားစစ်ဆေးခြင်းနှင့် အရေးယူတုံ့ပြန်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Syslog/gNMI telemetry ingestion၊ correlation rules၊ PCAP အသေးစိတ်စစ်ဆေးမှုနှင့် automated quarantine scripts များ။

---

## 🛠️ စမ်းသပ်မောင်းနှင်နိုင်သော Local Lab ပတ်ဝန်းကျင် (Executable Local Lab Environment)

တိုက်ရိုက်လည်ပတ်နေသော Arista cEOS containers များပေါ်တွင် ကွန်ရက်လုံခြုံရေး policies များကို လက်တွေ့ စမ်းသပ်နိုင်ပါသည်:

```bash
# ၁။ Security & Microsegmentation lab လမ်းကြောင်းသို့ သွားပါ
cd labs/security-lab

# ၂။ Guided interactive runner ကို စတင်ဖွင့်လှစ်ပါ
./run.sh --guided

# သို့မဟုတ် အတည်ပြုစစ်ဆေးပြီးသား topology တစ်ခုလုံးကို command တစ်ခုတည်းဖြင့် deploy လုပ်ပါ
./run.sh --all
```

---

## 🎯 Cybersecurity Engineer နည်းပညာ အင်တာဗျူး မေးခွန်းနှင့် အဖြေများ (Interview Drills)

### ❓ Question 1: eBPF runtime detection (Falco) သည် latency မတက်စေဘဲ container breakouts များကို မည်သို့ ဖမ်းယူစစ်ဆေးနိုင်သနည်း။ {: #question-1-how-does-ebpf-runtime-detection-falco-catch-container-breakouts-without-adding-latency }
**အဖြေ (Answer):**
ရိုးရာ security agents များသည် user space တွင် အလုပ်လုပ်ပြီး process tables များကို အမြဲတမ်းလှမ်းမေး (poll) နေရသဖြင့် switch/server CPU ကို အလွန်ဝန်ပိစေပါသည်။ **Falco သည် eBPF (Extended Berkeley Packet Filter)** program များကို Linux kernel အတွင်းသို့ တိုက်ရိုက် load လုပ်ထားပြီး system calls (`execve`, `clone`, `openat`) များကို အချိန်နှင့်တစ်ပြေးညီ ကြားဖြတ်စစ်ဆေးပေးပါသည်။ အကယ်၍ container တစ်ခုသည် ခွင့်ပြုချက်မရှိဘဲ shell (`/bin/sh`) တစ်ခုကို run လာပါက သို့မဟုတ် အရေးကြီးသော host paths (`/etc/shadow`) ကို ပြင်ဆင်လာပါက Falco သည် user-space context switching overhead လုံးဝမရှိဘဲ ချက်ချင်း alert ထုတ်ပေးပါသည်။

### ❓ Question 2: Zero-Trust ဗိသုကာစနစ်တွင် OAuth2, OIDC, နှင့် mTLS တို့၏ ခြားနားချက်ကို ရှင်းပြပါ။ {: #question-2-explain-the-difference-between-oauth2-oidc-and-mtls-in-a-zero-trust-architecture }
**အဖြေ (Answer):**
- **OAuth2**: Third-party applications များအတွက် scoped access tokens (`Bearer JWT`) ထုတ်ပေးသော **Authorization (ခွင့်ပြုချက်ဆိုင်ရာ) Framework** ဖြစ်သည်။
- **OIDC (OpenID Connect)**: OAuth2 ပေါ်တွင် တည်ဆောက်ထားသော **Identity (အထောက်အထားဆိုင်ရာ) Layer** (`id_token`) ဖြစ်ပြီး cryptographically လက်မှတ်ရေးထိုးထားသော user authentication claims များကို ထုတ်ပေးသည်။
- **mTLS (Mutual TLS)**: Client နှင့် Server နှစ်ဖက်စလုံးမှ X.509 cryptographic certificates များကို တင်ပြပြီး application payload bytes များ မလဲလှယ်မီ အပြန်အလှန် အတည်ပြုစစ်ဆေးပေးသော **Transport-Layer လုံခြုံရေးစနစ်** ဖြစ်သည်။

### ❓ Question 3: မြန်နှုန်းမြင့် Datacenter Switches များတွင် Control Plane Policing (CoPP) ကို အဘယ်ကြောင့် မဖြစ်မနေ ထည့်သွင်းရသနည်း။
**အဖြေ (Answer):**
Switch ASICs များသည် data plane packets များကို သီးသန့် TCAM ဖြင့် terabit နှုန်းထားဖြင့် လျင်မြန်စွာ ပို့ဆောင်ပေးနိုင်ပါသည်။ သို့သော် switch CPU သို့ ဦးတည်သော packets များ (BGP keepalives, OSPF hellos, ARP, ICMP, SSH) သည် switch အတွင်းရှိ bandwidth နည်းပါးသော PCIe bus ကို ဖြတ်သန်းရပါသည်။ **CoPP rate-limiters** မပါရှိပါက သာမန် ping flood သို့မဟုတ် SYN flood ရောက်ရှိလာရုံဖြင့် Supervisor CPU မှာ ဝန်ပိသွားပြီး BGP sessions များ timeout ဖြစ်ကာ datacenter fabric တစ်ခုလုံး ပြိုလဲသွားနိုင်ပါသည်။
