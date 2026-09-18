# 📊 Phase 7 · Streaming Telemetry & Observability

> 🚀 **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော Observability မာစတာတန်း**: gNMI gRPC protobuf streams နှင့် OpenConfig YANG paths များမှသည် Prometheus time-series metric collection နှင့် real-time Grafana dashboards များအထိ စနစ်တကျ ကျွမ်းကျင်စွာ လေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် Telemetry လမ်းပြမြေပုံ

ရိုးရာ ကွန်ရက်စောင့်ကြည့်မှုသည် SNMP (`UDP 161`) ဖြင့် အမြဲတမ်း လှမ်းမေးနေရသောကြောင့် နှေးကွေးပြီး CPU ကို ဝန်ပိစေကာ encrypt မပါဝင်ပါ။ Phase 7 သည် cloud ဝန်ဆောင်မှုများ မလိုဘဲ containerlab ပေါ်တွင် **၁၀၀% မိမိစက်တွင်း တည်ဆောက်နိုင်သော real-time streaming telemetry stack** တစ်ခုကို တည်ဆောက်နည်းကို လေ့ကျင့်ပေးပါသည်:

```
Phase 7 · Streaming Telemetry & Observability
├── 🧪 Lab 01 · cEOS ပေါ်တွင် gNMI နှင့် OpenConfig YANG Data Models များ ဖွင့်လှစ်ခြင်း
├── 🧪 Lab 02 · pygnmi နှင့် Python ဖြင့် Live Telemetry ဒေတာများ ဆွဲထုတ်ခြင်း
├── 🧪 Lab 03 · Streaming Telemetry Collectors နှင့် Prometheus Metrics စနစ်
├── 🧪 Lab 04 · Real-Time Visual Grafana Network Dashboards များ တည်ဆောက်ခြင်း
└── 🧪 Lab 05 · Automated Telemetry Alerting နှင့် Anomaly Detection စနစ်များ
```

---

## 🧠 Streaming Telemetry (gNMI) သည် ရှေးဟောင်း SNMP ကို အဘယ်ကြောင့် အစားထိုးသနည်း

| ရှေးရိုး SNMP Polling (`UDP 161`) | ခေတ်မီ gNMI Streaming Telemetry (`TCP 6030`) |
|---|---|
| Pull ပုံစံဖြင့် အချိန်ခြား လှမ်းမေးရသည် (ဥပမာ ၅ မိနစ်တစ်ကြိမ်) | **Push ပုံစံဖြင့် အချိန်နှင့်တစ်ပြေးညီ စီးဆင်းသည်** (စက္ကန့်ပိုင်းအတွင်း အချက်အလက်ရရှိသည်) |
| CPU ဝန်ပိစေသော MIB tree traversal လုပ်ဆောင်ချက် | **ပေါ့ပါးမြန်ဆန်သော Google Protocol Buffers (protobuf)** |
| လုံခြုံမှုမရှိသော Unencrypted UDP ဖြင့် ပို့ဆောင်သည် | **လုံခြုံသော Encrypted HTTP/2 TLS Transport** |
| ရှုပ်ထွေးသော Proprietary MIB OID နံပါတ်များ (`1.3.6.1.2.1.2.2.1...`) | **လူဖတ်ရလွယ်ကူသော OpenConfig YANG Paths များ** |
