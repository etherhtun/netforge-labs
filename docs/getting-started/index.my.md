# စတင်လေ့လာရန် (Get Started)

NetForge Labs ရှိ လက်တွေ့စမ်းသပ်မှုအားလုံးသည် lightweight containers များဖြင့် မိမိ laptop ပေါ်တွင်သော်လည်းကောင်း၊ cloud virtual machine ပေါ်တွင်သော်လည်းကောင်း ချောမောစွာ လည်ပတ်ပါသည်။ သီးသန့် hardware ပစ္စည်းကြီးများ ဝယ်ယူရန် မလိုအပ်ဘဲ မိမိစိတ်ကြိုက် လေ့ကျင့်နိုင်ပါသည်။

အောက်ပါတို့မှ မိမိအသုံးပြုမည့် Host ပတ်ဝန်းကျင်ကို ရွေးချယ်ပြီးနောက်၊ Containerlab ဖြင့် network fabrics များ မောင်းနှင်ပုံ အဆင့်ဆင့်ကို စတင်လေ့လာနိုင်ပါသည်:

---

## 🛠️ အဆင့် ၁ · မိမိ အသုံးပြုမည့် Host ပတ်ဝန်းကျင်ကို ရွေးချယ်ပါ

<div class="grid cards" markdown>

-   **၁က · macOS ပေါ်တွင် Lab တပ်ဆင်ခြင်း** &nbsp; <span class="nf-badge ok">Local Laptop</span>

    ---

    Apple Silicon (M1/M2/M3/M4) သို့မဟုတ် Intel Mac ပေါ်တွင် OrbStack၊ Docker၊ Containerlab နှင့် Arista cEOS တို့ကို ၁၀၀% မိမိစက်တွင်း၌ အခမဲ့ run ခြင်း (၁၅ မိနစ်ခန့်သာ ကြာမြင့်မည်)။

    [macOS တွင် တပ်ဆင်ရန် →](lab-setup-macos.md)

-   **၁ခ · Google Cloud (GCP) ပေါ်တွင် Lab တပ်ဆင်ခြင်း** &nbsp; <span class="nf-badge ok">Cloud VM</span>

    ---

    Google Cloud Compute Engine VM (Ubuntu 24.04) ပေါ်တွင် အစအဆုံး တည်ဆောက်ပြီး မိမိ Laptop မှ ချိတ်ဆက်လေ့ကျင့်ခြင်း။ မိမိ Laptop တွင် RAM/CPU အကန့်အသတ်ရှိသူများအတွက် အထူးသင့်လျော်ပါသည်။

    [GCP တွင် တပ်ဆင်ရန် →](cloud-vm.md)

</div>

---

## ⚡ အဆင့် ၂ · Platform နည်းပညာနှင့် စံသုံး CLI များကို ကျွမ်းကျင်အောင် လေ့လာပါ

<div class="grid cards" markdown>

-   **၂ · Docker & Containerlab CLI အခြေခံ**

    ---

    Topology ဖိုင်များ (`topology.clab.yml`) ရေးဖွဲ့ပုံနှင့် lab များ deploy / inspect / graph / destroy ပြုလုပ်ရာတွင် အသုံးပြုသော မဖြစ်မနေ သိထားရမည့် CLI commands များ။

    [CLI လမ်းညွှန် ဖတ်ရှုရန် →](containerlab.md)

-   **၃ · Lab နည်းပညာ အလုပ်လုပ်ပုံ (Architecture)**

    ---

    Containerlab topologies များကို နောက်ကွယ်မှ မောင်းနှင်ပေးထားသော Linux network namespaces များနှင့် virtual ethernet (veth) pairs များအကြောင်း အသေးစိတ် လေ့လာခြင်း။

    [နည်းပညာ အလုပ်လုပ်ပုံ ဖတ်ရှုရန် →](how-the-lab-works.md)

</div>

<div class="grid cards" markdown>

-   **၄ · ပေါင်းစပ် မောင်းနှင်မှု ပုံစံ (Hybrid Execution Model)**

    ---

    အလိုအလျောက် စစ်ဆေးပေးသော `./run.sh` step runners များ၊ တစ်ကြောင်းချင်း CLI copy-paste ပြုလုပ်နည်းနှင့် သန့်ရှင်းစွာ containers များ ဖျက်သိမ်းနည်း။

    [အဖွဲ့လိုက် မောင်းနှင်နည်း ဖတ်ရှုရန် →](team-quickstart.md)

-   **၅ · ပြဿနာ ဖြေရှင်းနည်းများ (Lab Troubleshooting)**

    ---

    cEOS ၏ သဘာဝကို နားလည်ခြင်း — Boot-Race ကို `--max-workers 1` ဖြင့် တားဆီးပုံ၊ Namespace သက်တမ်းနှင့် interface အမည်ပေးစည်းမျဉ်းများ။

    [Troubleshooting ဖတ်ရှုရန် →](lab-troubleshooting.md)

</div>

---

!!! tip "Host ပတ်ဝန်းကျင်ကို ဦးစွာ အသင့်ပြင်ဆင်ပါ"
    **[macOS စနစ်](lab-setup-macos.md)** သို့မဟုတ် **[GCP Cloud စနစ်](cloud-vm.md)** တစ်ခုခုကို ဦးစွာ တပ်ဆင်ပြီးစီးပါက [Courses](../courses/index.md) မှ မည်သည့် အဆင့်မြင့် Lab ကိုမဆို တိုက်ရိုက် စတင်လေ့လာနိုင်ပါသည်:
    - **[Phase 4 · VXLAN-EVPN Datacenter Fabrics](../courses/04-evpn/lab-01-pure-l2vni.md)**
    - **[Phase 3.5 · Segment Routing & Ti-LFA](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)**
    - **[Phase 5 · Network Automation & CI/CD Pipelines](../courses/05-netdevops/lab-01-jinja2-yaml.md)**
