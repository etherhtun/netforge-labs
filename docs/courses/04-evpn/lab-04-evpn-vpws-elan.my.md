# 4️⃣ Lab 04 · EVPN-VPWS နှင့် EVPN-ELAN (Point-to-Point VPWS & Multipoint ELAN) {: #lab-04-evpn-vpws-elan }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၆ ခု (Spine ၂ လုံး၊ Leaf ၂ လုံး၊ Customer Switch ၂ လုံး)

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: EVPN Service Modes {: #technology-deep-dive-evpn-service-modes }

စံနှုန်းမီ EVPN-VXLAN သည် Ethernet bridging နှင့် routing တို့ကို ကိုင်တွယ်သော်လည်း၊ EVPN သည် အထူးပြု Carrier Ethernet ဝန်ဆောင်မှု ဗိသုကာများကိုလည်း သတ်မှတ်ပေးထားပါသည် (RFC 8214 & RFC 7432):

```
+---------------------------------------------------------------------------------------------------+
| EVPN ဝန်ဆောင်မှု ဗိသုကာများ                                                                         |
+---------------------------------------------------------------------------------------------------+
| 1. EVPN-VPWS (E-LINE): EVPN Route Type 1 ကို သုံး၍ Point-to-Point Pseudowire အစားထိုးခြင်း။           |
| 2. EVPN-ELAN (E-LAN): VXLAN/MPLS ပေါ်တွင် Multipoint bridged Layer 2 service domain ဖွဲ့စည်းခြင်း။   |
+---------------------------------------------------------------------------------------------------+
```

---

### ၁။ EVPN-VPWS (Virtual Private Wire Service / E-LINE) {: #1-evpn-vpws }
- **သဘောတရား**: ရိုးရာ LDP Pseudowires (VPWS) နေရာတွင် BGP control-plane signaling ဖြင့် အစားထိုးသည်။
- **Protocol လုပ်ဆောင်ချက်များ**:
  - **VPWS Service ID** (`Local VPWS ID` ↔ `Remote VPWS ID`) ပါဝင်သော **EVPN Route Type 1 (VPWS NLRI)** ကို အသုံးပြုသည်။
  - MAC lookup လုပ်ဆောင်ရန် မလိုအပ်ပါ! `leaf1` port `Et3` သို့ ရောက်ရှိလာသော traffic အား encapsulate လုပ်ပြီး `leaf2` port `Et3` ဆီသို့ raw wire stream အဖြစ် တိုက်ရိုက် ပို့ဆောင်ပေးသည်။

---

### ၂။ EVPN-ELAN (E-LAN Multipoint Bridging) {: #2-evpn-elan }
- **သဘောတရား**: Fabric တစ်လျှောက်ရှိ အဝေးရောက် customer site ၃ ခု သို့မဟုတ် ထို့ထက်ပိုသော နေရာများကို ဆက်သွယ်ပေးသည့် Multipoint bridged Ethernet domain ဖြစ်သည်။
- **Protocol လုပ်ဆောင်ချက်များ**: Route Type 2 မှတစ်ဆင့် MAC learning နှင့် Route Type 3 မှတစ်ဆင့် BUM flooding တို့ကို လုပ်ဆောင်ကာ fabric တစ်လျှောက် virtual Layer 2 switch တစ်ခုသဖွယ် ဖန်တီးပေးသည်။

---

## အဆင့် ၁ · EVPN-VPWS ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-evpn-vpws-configuration }

`leaf1` နှင့် `leaf2` ကြားတွင် EVPN-VPWS VPWS Service ID `100` ကို သတ်မှတ်ပါ။

=== "leaf1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/05-leaf1-vpws.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/05-leaf2-vpws.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-verification }

`leaf1` ပေါ်တွင် EVPN-VPWS pseudo-circuit အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type vpws
EOF
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** EVPN-VPWS Service ID `100` ၏ အခြေအနေသည် **Established** ဟု ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
