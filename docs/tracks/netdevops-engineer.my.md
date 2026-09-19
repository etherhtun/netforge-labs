<div class="nf-hud-tag">TRACK 04 / 06 &bull; NETDEVOPS & INFRASTRUCTURE AUTOMATION</div>

# 🤖 NetDevOps & Infrastructure Automation သင်ယူမှုလမ်းကြောင်း

> 🚀 **Infrastructure as Code (IaC) အထူးပြုသင်ရိုး**: ကွန်ရက်အခြေခံအဆောက်အအုံကို Code ကဲ့သို့ စီမံခန့်ခွဲပါ — Jinja2/YAML data modeling၊ PyATS operational assertions၊ Batfish AST static pre-flight analysis၊ gNMI OpenConfig telemetry နှင့် GitHub Actions CI/CD pipelines များကို စနစ်တကျ ကျွမ်းကျင်စွာ တည်ဆောက်မောင်းနှင်ပါ။

---

## 📊 သင်ယူမှုလမ်းကြောင်း ခြုံငုံသုံးသပ်ချက် (Overview)

| အချက်အလက် (Metric) | သတ်မှတ်ချက် (Target Specification) |
|---|---|
| **ခန့်မှန်းကြာမြင့်ချိန်** | **၃၅ – ၄၀ နာရီ** (မိမိစိတ်ကြိုက်အချိန်ညှိ၍ လက်တွေ့ lab အခြေပြု လေ့လာနိုင်သည်) |
| **တက်လှမ်းရမည့် အဆင့်များ** | **အဓိက အဆင့် ၅ ဆင့်** (Data Modeling → Automated Assertions → Offline Pre-Flight → CI/CD Automation → Telemetry) |
| **Lab နည်းပညာ Framework** | **Containerlab + Arista cEOS + Python 3** (macOS OrbStack သို့မဟုတ် Linux Docker ပေါ်တွင် ၁၀၀% အခမဲ့ run နိုင်သည်) |
| **ဦးတည်သော အလုပ်အကိုင်များ** | NetDevOps Engineer, Network Automation Developer, Cloud Network Automation Architect, Site Reliability Engineer |
| **ပစ်မှတ်ထားသော ကုမ္ပဏီကြီးများ** | Tech Enterprise Companies, Hyperscalers, Financial Tech (FinTech), Telecom Operators, နှင့် Automation Consultancies |

---

## 🧠 အဓိက NetDevOps နည်းပညာများနှင့် Toolchain (Core NetDevOps Toolchain)

| Automation Layer | လက်တွေ့သုံး Tool & Protocol | အင်ဂျင်နီယာ လုပ်ဆောင်ချက် (Engineering Function) |
|---|---|---|
| **Data Modeling & Rendering** | **YAML / Jinja2 / Python** | စက်ပစ္စည်းများ၏ CLI syntax နှင့် မသက်ဆိုင်ဘဲ သီးခြားခွဲထုတ်ထားသော Single-source-of-truth configuration templating |
| **CLI State Parsing** | **Cisco PyATS / Genie** | ပြုပြင်ပြောင်းလဲမှု ပြုလုပ်ပြီးချိန်တွင် အလိုအလျောက် စစ်ဆေးပေးသည့် operational state assertions နှင့် differential snapshots များ |
| **Pre-Flight Static Analysis** | **Batfish AST** | Hardware ထဲသို့ မထည့်သွင်းမီ ပြင်ပ offline တွင် end-to-end reachability၊ ACL policies နှင့် BGP convergence များကို သင်္ချာနည်းကျ simulation ပြုလုပ်ခြင်း |
| **Streaming Telemetry** | **gNMI / OpenConfig YANG / pygnmi** | Sub-second gRPC real-time programmatic metric streaming နှင့် push configuration စနစ်များ |
| **CI/CD Pipelines** | **GitHub Actions / Containerlab** | `git push` ပြုလုပ်တိုင်း syntax နှင့် routing regressions များကို ကြိုတင်ကာကွယ်ပေးသည့် automated gate checks များ |

---

## 🗺️ အဆင့် ၅ ဆင့် တိုးတက်မှု Milestone လမ်းပြမြေပုံ (Roadmap)

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-data-modeling-template-generation">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · Data Modeling & Template Generation</h4>
        <span class="nf-badge ok">Single Source of Truth</span>
      </div>
      <p class="nf-step-desc">YAML data schemas များနှင့် Jinja2 rendering engines များကို အသုံးပြု၍ လုပ်ငန်းခွင် ကွန်ရက်ရည်မှန်းချက်များကို စက်ပစ္စည်း CLI syntax များမှ သီးခြားခွဲထုတ် တည်ဆောက်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">YAML Data Models</span>
        <span class="nf-chip">Jinja2 Templating</span>
        <span class="nf-chip">Schema Validation</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-operational-state-assertions">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Operational State Assertions</h4>
        <span class="nf-badge ok">Automated Testing</span>
      </div>
      <p class="nf-step-desc">Cisco PyATS testbeds နှင့် Genie operational state parsers များကို အသုံးပြု၍ အမှားများတတ်သော text scraping စနစ်မှ ခိုင်မာသော JSON assertions စနစ်သို့ ပြောင်းလဲပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Cisco PyATS</span>
        <span class="nf-chip">Genie Parsers</span>
        <span class="nf-chip">State Diffs</span>
        <span class="nf-chip">Route Table Assertions</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-offline-pre-flight-verification-with-batfish">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · Offline Pre-Flight Verification</h4>
        <span class="nf-badge ok">Digital Twin</span>
      </div>
      <p class="nf-step-desc">ပြောင်းလဲမှုများကို စက်များပေါ်သို့ မတင်မီ Batfish AST simulation ဖြင့် routing policies၊ ACL safety နှင့် end-to-end reachability များကို သင်္ချာနည်းကျ ကြိုတင်အတည်ပြုပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">Batfish AST</span>
        <span class="nf-chip">Symbolic Reachability</span>
        <span class="nf-chip">ACL Simulation</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-automated-cicd-deployment-pipelines">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · Automated CI/CD Deployment Pipelines</h4>
        <span class="nf-badge ok">GitOps</span>
      </div>
      <p class="nf-step-desc">GitHub Actions runners အတွင်း headless containerlab testbeds များကို တည်ဆောက်ပြီး စစ်ဆေးမှုများ အောင်မြင်မှသာ Pull Requests များကို merge ခွင့်ပြုသည့် gate checks များ ချမှတ်ပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">GitHub Actions</span>
        <span class="nf-chip">Containerlab Headless</span>
        <span class="nf-chip">PR Gate Checks</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-programmable-telemetry-feedback-loops">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · Programmable Telemetry & Feedback Loops</h4>
        <span class="nf-badge ok">gNMI Automation</span>
      </div>
      <p class="nf-step-desc">OpenConfig streaming paths များကို subscribe ပြုလုပ်ပြီး ပြဿနာဖြစ်ပေါ်ချိန်တွင် ပြုပြင်မှုအစီအစဉ်များကို အလိုအလျောက် trigger ပေးသည့် closed-loop automation scripts များကို ရေးသားပါ။</p>
      <div class="nf-chips">
        <span class="nf-chip">pygnmi Python Client</span>
        <span class="nf-chip">OpenConfig YANG</span>
        <span class="nf-chip">Event-Driven Automation</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 အပြန်အလှန် လေ့လာနိုင်သော သင်ခန်းစာလမ်းညွှန် (Interactive Lesson Directory)

| Milestone Stage | Automation Layer | ကလစ်နှိပ်၍ လေ့လာနိုင်သော သင်ခန်းစာ & လက်တွေ့ Labs | စမ်းသပ်နိုင်သော Lab | စတင်ရန် |
|---|---|---|---|---|
| **Stage 1**<br/>`Data Modeling` | YAML Single Source of Truth & Jinja2 Network Templates | • [Phase 5 · Lab 01: Jinja2 & YAML Data Modeling](../courses/05-netdevops/lab-01-jinja2-yaml.md) | `labs/netdevops-lab` | [Stage 1 စတင်ရန် →](../courses/05-netdevops/lab-01-jinja2-yaml.md) |
| **Stage 2**<br/>`State Assertions` | Cisco PyATS & Genie Structured Testbed Validation | • [Phase 5 · Lab 02: PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md) | `labs/netdevops-lab` | [Stage 2 စတင်ရန် →](../courses/05-netdevops/lab-02-pyats-verification.md) |
| **Stage 3**<br/>`Pre-Flight Verification` | Batfish Abstract Syntax Tree Reachability & ACL Simulation | • [Phase 5 · Lab 03: Batfish Simulation](../courses/05-netdevops/lab-03-batfish-simulation.md) | `labs/netdevops-lab` | [Stage 3 စတင်ရန် →](../courses/05-netdevops/lab-03-batfish-simulation.md) |
| **Stage 4**<br/>`CI/CD Pipelines` | GitHub Actions Workflows & Ephemeral Containerlab Testbeds | • [Phase 5 · Lab 05: GitHub Actions CI/CD](../courses/05-netdevops/lab-05-github-actions-cicd.md) | `labs/netdevops-lab` | [Stage 4 စတင်ရန် →](../courses/05-netdevops/lab-05-github-actions-cicd.md) |
| **Stage 5**<br/>`Programmable Telemetry` | pygnmi Python Library, OpenConfig YANG Schemas, gRPC | • [Phase 7 · Lab 01: gNMI Basics & OpenConfig](../courses/07-telemetry/lab-01-gnmi-openconfig.md)<br/>• [Phase 7 · Lab 02: pygnmi Python Client Integration](../courses/07-telemetry/lab-02-pygnmi-python.md) | `labs/telemetry-lab` | [Stage 5 စတင်ရန် →](../courses/07-telemetry/lab-01-gnmi-openconfig.md) |

---

## 🧪 အသေးစိတ် Milestone သင်ရိုးညွှန်းတမ်း (Detailed Milestone Curricula)

### 📍 Stage 1: Data Modeling & Template Generation
- **အဓိက အလေးထားချက် (Core Focus)**: တည်ဆောက်ထားသော YAML ဖိုင်များကို အသုံးပြု၍ Single Source of Truth (SSOT) တည်ဆောက်ခြင်းနှင့် Jinja2 templates များဖြင့် network configurations များကို render ပြုလုပ်ခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Variable scoping၊ loops ဆောက်လုပ်ပုံ၊ conditional blocks များ၊ YAML validation schemas များနှင့် syntax errors မဖြစ်ပေါ်စေရန် ကြိုတင်ကာကွယ်ခြင်း။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Network Automation Overview](../courses/05-netdevops/index.md)
    - [Lab 01: Jinja2 & YAML Data Modeling](../courses/05-netdevops/lab-01-jinja2-yaml.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 2: Operational State Assertions
- **အဓိက အလေးထားချက် (Core Focus)**: လူသားမျက်စိဖြင့် စစ်ဆေးခြင်းမှသည် ကွန်ပျူတာ machine-parsable စနစ်ဖြင့် အလိုအလျောက် စစ်ဆေးအတည်ပြုခြင်းသို့ ကူးပြောင်းခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Cisco Genie CLI parsers များ၊ PyATS testbeds များ၊ structured JSON data ထုတ်ယူခြင်း၊ routing table convergence စစ်ဆေးခြင်းနှင့် BGP peer state checks များ။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Lab 02 - PyATS State Verification](../courses/05-netdevops/lab-02-pyats-verification.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 3: Offline Pre-Flight Verification with Batfish
- **အဓိက အလေးထားချက် (Core Focus)**: Symbolic execution နှင့် AST analysis တို့ကို အသုံးပြု၍ ကွန်ရက်ပြောင်းလဲမှုများကို စက်များပေါ် မတင်မီ *ကြိုတင်၍* ပြင်ပတွင် စစ်ဆေးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Batfish snapshot ingestion၊ routing table simulation၊ ACL reachability စမ်းသပ်ခြင်းနှင့် မရည်ရွယ်သော network blackholes များကို offline ရှာဖွေဖော်ထုတ်ခြင်း။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Lab 03 - Batfish Simulation](../courses/05-netdevops/lab-03-batfish-simulation.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 4: Automated CI/CD Deployment Pipelines
- **အဓိက အလေးထားချက် (Core Focus)**: Containerlab နှင့် network testing စနစ်များကို GitHub Actions CI/CD workflows များအတွင်းသို့ ပေါင်းစပ်ထည့်သွင်းခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: Ephemeral containerized testbeds များ၊ automated linting၊ pre-merge gate checks များနှင့် automated rollback triggers များ။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 5: Lab 05 - GitHub Actions CI/CD](../courses/05-netdevops/lab-05-github-actions-cicd.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/netdevops-lab
    ./run.sh --guided
    ```

### 📍 Stage 5: Programmable Telemetry & Feedback Loops
- **အဓိက အလေးထားချက် (Core Focus)**: Python client libraries (`pygnmi`) ကို အသုံးပြု၍ gRPC endpoints များနှင့် ချိတ်ဆက်ကာ OpenConfig paths များကို subscribe လုပ်ခြင်းနှင့် automated remediations များကို trigger ပေးခြင်း။
- **အဓိက သဘောတရားများ (Key Concepts)**: gNMI Get/Set/Subscribe RPCs၊ ProtoBuf encoding၊ OpenConfig interface models များနှင့် event-driven automation။
- **လက်တွေ့ အပြန်အလှန်လေ့လာနိုင်သော Labs**:
    - [Phase 7: Streaming Telemetry Overview](../courses/07-telemetry/index.md)
    - [Lab 01: gNMI Subscriptions & OpenConfig](../courses/07-telemetry/lab-01-gnmi-openconfig.md)
    - [Lab 02: pygnmi Python Client Integration](../courses/07-telemetry/lab-02-pygnmi-python.md)
- **Local Runner ဖြင့် Run ရန်**:
    ```bash
    cd labs/telemetry-lab
    ./run.sh --guided
    ```

---

## 🛠️ စမ်းသပ်မောင်းနှင်နိုင်သော Local Lab ပတ်ဝန်းကျင် (Executable Local Lab Environment)

NetForge Labs သည် ရှုပ်ထွေးသော virtual machines များကို စီမံခန့်ခွဲစရာမလိုဘဲ NetDevOps pipelines များကို မိမိစက်တွင်း၌ လွယ်ကူစွာ လေ့ကျင့်နိုင်ရန် automated guided runners များကို ထောက်ပံ့ပေးထားပါသည်။

```bash
# ၁။ NetDevOps lab လမ်းကြောင်းသို့ သွားပါ
cd labs/netdevops-lab

# ၂။ Guided interactive runner ကို စတင်ဖွင့်လှစ်ပါ
./run.sh --guided

# သို့မဟုတ် pipeline အဆင့်အားလုံးကို တစ်ပြိုင်နက် end-to-end စမ်းသပ်ပါ
./run.sh --all
```

---

## 🎓 အသက်မွေးဝမ်းကျောင်းဆိုင်ရာ လက်တွေ့ Portfolio Projects (Career Defense)

1. **Multi-Vendor Network Template Engine**:
   - High-level data models များကို လက်ခံပြီး Arista နှင့် Cisco စက်များအတွက် စစ်ဆေးပြီးသား configurations များကို အလိုအလျောက် ထုတ်လုပ်ပေးသော Jinja2/YAML engine တစ်ခုကို တည်ဆောက်ပြသနိုင်မည်။
2. **Offline Pre-Flight Change Gating (Batfish)**:
   - တင်သွင်းမည့် BGP route-map အပြောင်းအလဲများကို Batfish ဖြင့် simulate စမ်းသပ်ကာ စက်ပေါ်သို့ မရောက်မီ ရည်ရွယ်ချက်ရှိရှိ ဖန်တီးထားသော routing loop ကို ကြိုတင်ဖမ်းယူပြသသည့် pipeline တစ်ခုကို တင်ပြနိုင်မည်။
3. **Automated Ephemeral CI/CD Test Matrix**:
   - Containerlab အတွင်း 4-node Arista cEOS topology ကို ချက်ချင်း boot တက်စေကာ PyATS test suites များကို run ပြီး စက္ကန့် ၉၀ အတွင်း lab ကို အပြီးသတ် ဖျက်သိမ်းပေးသည့် GitHub Actions workflow တစ်ခုကို တင်ဆက်နိုင်မည်။
