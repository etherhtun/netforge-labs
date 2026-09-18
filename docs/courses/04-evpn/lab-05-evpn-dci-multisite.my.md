# 5️⃣ Lab 05 · VXLAN-EVPN DCI နှင့် Multi-Site (Border Gateway VTEPs) {: #lab-05-vxlan-evpn-dci-multisite }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၈ ခု (Datacenter Site ၂ ခုအကြား Spine/BGW ၄ လုံး၊ Leaf ၄ လုံး)

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: EVPN Multi-Site DCI ဗိသုကာ {: #technology-deep-dive-evpn-multi-site-dci-architecture }

ပထဝီဝင်အနေအထားအရ ကွဲပြားသော data center များကို ချိတ်ဆက်ခြင်း (Data Center Interconnect / DCI) သည် EVPN အား single IP underlay domain တစ်ခုတည်းထက် ကျော်လွန်၍ စကေးချဲ့ရန် လိုအပ်ပါသည်:

```
+---------------------------------------------------------------------------------------------------+
| EVPN MULTI-SITE DCI ဗိသုကာ                                                                         |
+---------------------------------------------------------------------------------------------------+
| 1. Border Gateway (BGW) VTEPs: Site များကြား control-plane နှင့် data-plane ဆုံမှတ်အဖြစ် လုပ်ဆောင်သည်။   |
| 2. Overlay Index & Path Decoupling: အတွင်းပိုင်း leaf VTEP များကို Border Gateway ၏ နောက်ကွယ်တွင် ဖုံးကွယ်ထားသည်။|
| 3. Distributed Anycast Gateway Across Sites: DC1 နှင့် DC2 ကြား live VM migration ကို ဖြစ်မြောက်စေသည်။   |
+---------------------------------------------------------------------------------------------------+
```

---

### ၁။ Border Gateway (BGW) VTEP လုပ်ဆောင်ချက်များ {: #1-border-gateway-vtep-mechanics }
- **အတွင်းပိုင်း Fabric**: Leaf VTEP များသည် local Spines/BGWs များနှင့် BGP EVPN peering ကို ပြုလုပ်ကြသည်။
- **Site အချင်းချင်းကြား WAN**: Border Gateways များ (`DC1 ရှိ bgw1` ↔ `DC2 ရှိ bgw2`) သည် eBGP EVPN (AFI 25 / SAFI 70) ပေါ်တွင် peer ပြုလုပ်ကြသည်။
- **NLRI Re-Origination**: Border Gateways များသည် EVPN Route Types အားလုံး (2, 3, 5) ပေါ်ရှိ BGP Next-Hop ကို ၎င်းတို့၏ local Border VTEP IP သို့ ပြန်လည်ရေးသားပေးသဖြင့် အတွင်းပိုင်း VTEP IP များ WAN ထဲသို့ ပေါက်ကြားသွားခြင်း မရှိစေရန် ကာကွယ်ပေးသည်။

---

## အဆင့် ၁ · Border Gateway (BGW) ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-border-gateway-configuration }

`bgw1` (DC1) နှင့် `bgw2` (DC2) ပေါ်တွင် Multi-Site Border Gateway ကို ချိန်ညှိပါ။

=== "bgw1 (DC1 Border Gateway)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/06-bgw1-dci.cfg"
    ```

=== "bgw2 (DC2 Border Gateway)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/06-bgw2-dci.cfg"
    ```

---

## အဆင့် ၂ · Multi-Site စစ်ဆေးခြင်း {: #step-2-multi-site-verification }

`bgw1` ပေါ်တွင် Inter-Site EVPN peering အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-evpn-datacenter-lab-spine1 Cli -p 15 <<'EOF'
enable
show bgp evpn summary
EOF
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `bgw1` နှင့် `bgw2` အကြား inter-site eBGP EVPN session သည် **Established** ဟု ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
