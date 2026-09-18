# စတင်လေ့လာရန် (Get Started)

NetForge Labs ရှိ လက်တွေ့စမ်းသပ်မှုအားလုံးသည် မိမိစက်တွင်း၌ lightweight containers များဖြင့်သာ လည်ပတ်ပါသည်။ သီးသန့် hardware မလိုပါ၊ cloud ကျသင့်ငွေ မရှိပါ၊ စက်ကို ဝန်ပိစေခြင်း (background idle overhead) လုံးဝ မရှိပါ။

တစ်ကြိမ်သာ setup ပြုလုပ်ထားရုံဖြင့် Phase အားလုံးရှိ lab များကို ချောမောစွာ စမ်းသပ်မောင်းနှင်နိုင်မည် ဖြစ်ပါသည်။

---

<div class="grid cards" markdown>

-   **၁ · macOS တွင် Lab စတင် တပ်ဆင်ခြင်း** &nbsp; <span class="nf-badge ok">ဤနေရာမှ စတင်ပါ</span>

    ---

    Apple Silicon (M1/M2/M3/M4) ပေါ်တွင် OrbStack၊ Docker၊ containerlab နှင့် Arista cEOS တို့ကို တပ်ဆင်ခြင်း။ ၁၅ မိနစ်ခန့်သာ ကြာမြင့်မည်ဖြစ်ပြီး တစ်ကြိမ်သာ ပြုလုပ်ရန် လိုအပ်ပါသည်။

    [Lab စတင် တပ်ဆင်ရန် →](lab-setup-macos.md)

-   **၂ · Docker & containerlab အခြေခံ**

    ---

    Topology ဖိုင်များ (`topology.clab.yml`) အလုပ်လုပ်ပုံနှင့် lab တိုင်းတွင် အသုံးပြုသော deploy / destroy commands များ။

    [ဖတ်ရှုရန် →](containerlab.md)

</div>

<div class="grid cards" markdown>

-   **၃ · Lab နည်းပညာ အလုပ်လုပ်ပုံ**

    ---

    Containerlab topologies များကို မောင်းနှင်ပေးထားသော Linux network namespaces များနှင့် virtual ethernet (veth) pairs များအကြောင်း အသေးစိတ် လေ့လာခြင်း။

    [ဖတ်ရှုရန် →](how-the-lab-works.md)

-   **၄ · ပေါင်းစပ် မောင်းနှင်မှု ပုံစံ (Hybrid Execution Model)**

    ---

    အလိုအလျောက် စစ်ဆေးပေးသော `./run.sh` step runners များ၊ တစ်ကြောင်းချင်းစီ CLI copy-paste ပြုလုပ်နည်းနှင့် သန့်ရှင်းစွာ containers များ ဖျက်သိမ်းနည်း (`docker rm -f`)။

    [ဖတ်ရှုရန် →](team-quickstart.md)

</div>

---

!!! tip "macOS setup ကို ဦးစွာ ပြုလုပ်ပါ"
    အခြားစာမျက်နှာများသည် အသင့်သုံးနိုင်သော containerlab host ရှိထားပြီးဖြစ်သည်ဟု ယူဆထားပါသည်။ [Lab setup](lab-setup-macos.md) ပြီးစီးပါက [Courses](../courses/index.md) မှ မည်သည့် phase ကိုမဆို စတင်လေ့လာနိုင်ပါသည်။

တပ်ဆင်ပြီးပါက အောက်ပါ အဓိက labs များသို့ တိုက်ရိုက် ဝင်ရောက်လေ့လာနိုင်ပါသည်:
- **[Phase 4 · VXLAN-EVPN Datacenter Fabrics](../courses/04-evpn/lab-01-pure-l2vni.md)**
- **[Phase 3.5 · Segment Routing & Ti-LFA](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)**
- **[Phase 5 · Network Automation & CI/CD Pipelines](../courses/05-netdevops/lab-01-jinja2-yaml.md)**
