# ⚡ Phase 5 · Network Automation & CI/CD Pipelines

> 🚀 **Infrastructure-as-Code & NetDevOps အထူးပြု မာစတာတန်း**: ရိုးရာ CLI ကွန်ရက်အင်ဂျင်နီယာ အလုပ်ပုံစံမှသည် ခေတ်မီဆော့ဖ်ဝဲအခြေပြု network automation၊ automated testing၊ နှင့် CI/CD pipelines များဆီသို့ လက်တွေ့ ကူးပြောင်းလေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် NetDevOps လမ်းပြမြေပုံ

ရိုးရာ လက်ဖြင့်ရိုက်နှိပ်ရသော CLI ကွန်ရက်စီမံခန့်ခွဲမှုသည် နှေးကွေးပြီး လူသားမှားယွင်းမှုများပြားကာ scale ချဲ့၍ မရပါ။ Phase 5 တွင် Hyperscale network teams များ (Google, Meta) ကွန်ရက်ကို code ကဲ့သို့ မည်သို့စီမံခန့်ခွဲပုံ (IaC)၊ configurations များကို program နည်းကျ ထုတ်လုပ်ပုံ၊ စက်ပေါ်မတင်မီ network policies များကို ကြိုတင်စစ်ဆေးပုံ၊ နှင့် GitHub Actions ပေါ်တွင် automated test pipelines များကို run ပုံတို့ကို လက်တွေ့ လေ့လာရမည် ဖြစ်ပါသည်:

```
Phase 5 · Network Automation & CI/CD Pipelines
├── 🧪 Lab 01 · Data-Driven Config Generation (Jinja2 & YAML Data Models)
├── 🧪 Lab 02 · Automated Network Verification (Cisco PyATS / Genie Framework)
├── 🧪 Lab 03 · Pre-Deployment Policy Verification (Batfish Pre-Flight Analysis)
├── 🧪 Lab 04 · Programmatic Telemetry & State Parsing (gNMI / pygnmi)
└── 🧪 Lab 05 · Containerlab CI/CD Pipelines in GitHub Actions
```

---

## 🧠 ကွန်ရက် အင်ဂျင်နီယာများအတွက် NetDevOps သည် အဘယ်ကြောင့် အရေးပါသနည်း

အကယ်၍ သင်သည် CLI commands များကို လက်ဖြင့်ရိုက်နှိပ်ခြင်းဖြင့်သာ အချိန်ကုန်ခဲ့ပါက (`configure terminal`, `interface Ethernet1`, `ip address ...`) ဆော့ဖ်ဝဲ automation သည် စတင်ရာတွင် ခက်ခဲနက်နဲသည်ဟု ထင်ရနိုင်ပါသည်။ Phase 5 သည် **အခြေခံ အုတ်မြစ်များမှ စတင်ပြီး** သဘောတရားတစ်ခုချင်းစီကို အဆင့်ဆင့် ရှင်းပြပေးပါသည်:

| ရိုးရာ CLI ကွန်ရက် အင်ဂျင်နီယာ ပုံစံ | ခေတ်မီ NetDevOps ဆော့ဖ်ဝဲ အင်ဂျင်နီယာ ပုံစံ |
|---|---|
| Router တစ်ခုချင်းစီအတွက် လက်ဖြင့်ရိုက်သော CLI commands | **Data Models (YAML)** + **Templates (Jinja2)** |
| အခြေအနေ စစ်ဆေးရန် လက်ဖြင့် ရိုက်ရသော `show` commands | **အလိုအလျောက် စစ်ဆေးသည့် Test Suites (PyATS / Genie)** |
| လုပ်ငန်းခွင် စက်များပေါ်တွင် တိုက်ရိုက် စမ်းသပ်ခြင်း | **စက်ပေါ်မတင်မီ ပြင်ပတွင် ကြိုတင်စစ်ဆေးခြင်း (Batfish)** |
| ပုံမှန် အချိန်ခြား SNMP polling (`UDP 161`) | **အချိန်နှင့်တစ်ပြေးညီ ဒေတာစီးဆင်းမှု (gNMI / gRPC)** |
| လက်ဖြင့် တောင်းဆိုရသော Change requests & maintenance windows | **အလိုအလျောက် အတည်ပြုပေးသော CI/CD Pipelines (GitHub Actions)** |
