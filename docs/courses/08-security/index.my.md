# 🔒 Phase 8 · Network Security & Datacenter Segmentation

> 🚀 **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော Enterprise Security မာစတာတန်း**: Control Plane Policing (CoPP)၊ VRF microsegmentation၊ Infrastructure ACLs (iACLs)၊ နှင့် MACsec 802.1AE line-rate encryption အပါအဝင် Defense-in-depth လုံခြုံရေး ဗိသုကာများကို စနစ်တကျ လေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် လုံခြုံရေး လမ်းပြမြေပုံ

ခေတ်မီ Data Center ကွန်ရက်များသည် တင်းကျပ်သော control plane အကာအကွယ်၊ multi-tenant workload သီးခြားခွဲထုတ်မှု၊ နှင့် edge access control များကို လိုအပ်ပါသည်။ Phase 8 သည် **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော network security architectures** များကို မည်သို့ဒီဇိုင်းဆွဲ၊ တည်ဆောက်ရမည်ကို လေ့ကျင့်ပေးပါသည်:

```
Phase 8 · Network Security & Datacenter Segmentation
├── 🧪 Lab 01 · Control Plane Policing (CoPP) နှင့် CPU အကာအကွယ်ပေးခြင်း
├── 🧪 Lab 02 · VRF Microsegmentation နှင့် ACLs ပါဝင်သော Inter-VRF Route Leaking
├── 🧪 Lab 03 · Infrastructure ACLs (iACLs) နှင့် Core Router ကာကွယ်ခြင်း
└── 🧪 Lab 04 · MACsec Line-Rate Encryption နှင့် Port Security စနစ်များ
```

---

## 🧠 Data Center လုံခြုံရေး အခြေခံမူများ

| ခြိမ်းခြောက်မှု ပုံစံ (Threat Vector) | ခုခံကာကွယ်ရေး ဗိသုကာ (Defense Architecture) |
|---|---|
| Routing Engine CPU DoS / Protocol SYN Floods | **Control Plane Policing (CoPP)** ဖြင့် bandwidth rate-limit ချမှတ်ခြင်း |
| ခွင့်ပြုချက်မရှိဘဲ Host အချင်းချင်း ဘေးတိုက်ကူးပြောင်းခြင်း (Lateral Movement) | **VRF Microsegmentation & Stateful ACLs** ဖြင့် တားဆီးခြင်း |
| Core Loopbacks များသို့ ခွင့်ပြုချက်မရှိဘဲ probe စစ်ဆေးခြင်း | **Infrastructure ACLs (iACLs)** ဖြင့် filter ပြုလုပ်ခြင်း |
| Physical Fiber လိုင်းများကို ကြားဖြတ်ခိုးယူနားထောင်ခြင်း / MITM | **802.1AE MACsec Line-Rate Encryption** ဖြင့် ကာကွယ်ခြင်း |
