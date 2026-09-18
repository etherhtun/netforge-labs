# 3️⃣ Lab 03 · ESI All-Active Multihoming (DF Election နှင့် Split-Horizon) {: #lab-03-esi-all-active-multihoming }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၆ ခု (Spine ၂ လုံး၊ Leaf ၂ လုံး၊ Multihomed Host ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/evpn-datacenter-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/evpn-datacenter-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **အဆင့် ၂ · အပြန်အလှန် Interactive လမ်းညွှန်ကို စတင်ပါ**
    ```bash
    ./run.sh --guided
    ```

    ??? note "အခြား Run နိုင်သော နည်းလမ်းများ (Automated Script သို့မဟုတ် Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # step 01 ကို အလိုအလျောက် config ထည့်သွင်း၍ စစ်ဆေးမည်
          ./run.sh --all       # အဆင့်အားလုံးကို အစီအစဉ်အတိုင်း run မည်
          ```
        - **Manual Line-by-Line CLI Execution**:
          Container node တစ်ခုချင်းစီသို့ CLI shell ဝင်ရောက်ရန်:
          ```bash
          docker exec -it clab-evpn-datacenter-lab-leaf1 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: EVPN ESI Multihoming လုပ်ဆောင်ချက်များ {: #technology-deep-dive-evpn-esi-multihoming-mechanics }

### ၁။ ESI Multihoming က MLAG / vPC ကို အဘယ်ကြောင့် အစားထိုးသနည်း {: #1-why-esi-multihoming-replaces-mlag-vpc }
ရိုးရာ MLAG (Multi-Chassis Link Aggregation) သည် switch အစုံကြားတွင် သီးသန့် **Peer-Link** နှင့် **Keepalive Link** တို့ လိုအပ်သည်။ ၎င်းသည် proprietary control plane များကို ဖြစ်စေပြီး multihoming ကို switch ၂ လုံးတည်းဖြင့်သာ ကန့်သတ်ထားကာ peer-link ပြတ်တောက်ပါက split-brain အန္တရာယ် ရှိစေသည်။

**EVPN ESI (Ethernet Segment Identifier) Multihoming (RFC 7432)** သည် MLAG peer-link များကို လုံးဝ ပယ်ဖျက်ပေးလိုက်ပါသည်! Leaf switch အများအပြားသည် BGP EVPN control plane message များကိုသာ သုံး၍ LACP ဖြင့် customer server သို့မဟုတ် switch တစ်ခုဆီသို့ **Active-Active multihomed group** အဖြစ် စုစည်းချိတ်ဆက်နိုင်ကြပါသည်!

---

### ၂။ EVPN Multihoming ၏ အဓိက မဏ္ဍိုင် ၃ ရပ် {: #2-the-three-pillars-of-evpn-multihoming }

```
+---------------------------------------------------------------------------------------------------+
| EVPN ESI MULTIHOMING ၏ အဓိက မဏ္ဍိုင်များ                                                             |
+---------------------------------------------------------------------------------------------------+
| 1. Ethernet Segment Identifier (ESI): Multihomed interface အတွက် သတ်မှတ်ထားသော 10-byte သီးသန့် ID |
| 2. Designated Forwarder (DF) Election (Route Type 4): BUM traffic နှစ်ခါထပ် ပေးပို့ခြင်းကို ကာကွယ်ခြင်း |
| 3. Split-Horizon Filtering (Route Type 1): Multihomed leaf များကြား local loop မဖြစ်အောင် ကာကွယ်ခြင်း|
+---------------------------------------------------------------------------------------------------+
```

#### က။ Ethernet Segment Identifier (ESI) {: #a-ethernet-segment-identifier-esi }
**ESI** သည် server တစ်ခုအား `leaf1` နှင့် `leaf2` သို့ ချိတ်ဆက်ထားသော physical interface သို့မဟုတ် Port-Channel ပေါ်တွင် သတ်မှတ်ထားသည့် 10-byte တန်ဖိုးဖြစ်သည် (ဥပမာ `00:11:22:33:44:55:66:77:88:99`)။ Leaf နှစ်ခုလုံးသည် တူညီသော ESI ကို မျှဝေထားသောကြောင့် BGP EVPN သည် ၎င်းတို့ကို single logical connection တစ်ခုအဖြစ် သဘောထားကိုင်တွယ်သည်။

#### ခ။ EVPN Route Type 4 မှတစ်ဆင့် Designated Forwarder (DF) ရွေးချယ်ခြင်း {: #b-designated-forwarder-election }
Fabric မှ multihomed host ဆီသို့ ဦးတည်သော BUM (Broadcast, Unknown Unicast, Multicast) traffic ရောက်ရှိလာသည့်အခါ `leaf1` ရော `leaf2` ပါ နှစ်ခုလုံးက server ဆီသို့ ပို့မိပါက duplicate frame များ ဖြစ်ပေါ်စေနိုင်သည်။
- **EVPN Route Type 4 (Ethernet Segment Route)**: `leaf1` နှင့် `leaf2` တို့သည် ESI segment ပေါ်တွင် အချင်းချင်း သိရှိစေရန် Route Type 4 route များကို ဖလှယ်ကြသည်။
- **DF Election**: Modulo algorithm (`VLAN ID mod N`) ကို အသုံးပြု၍ Leaf တစ်ခုတည်းကိုသာ VLAN 10 အတွက် **Designated Forwarder (DF)** အဖြစ် ရွေးချယ်ပြီး BUM traffic ကို server သို့ ပို့စေသည်။ Non-DF Leaf သည် BUM ထွက်ပေါက်ကို ပိတ်ထားပေးသည်။

#### ဂ။ EVPN Route Type 1 မှတစ်ဆင့် Split-Horizon Filtering ပြုလုပ်ခြင်း {: #c-split-horizon-filtering }
အကယ်၍ `host1` က `leaf1` ဆီသို့ broadcast frame တစ်ခု ပို့ပါက `leaf1` သည် ၎င်းအား VXLAN တွင် encapsulate လုပ်ပြီး Head-End Replication ဖြင့် `leaf2` ဆီသို့ flood လုပ်မည်ဖြစ်သည်။ အကာအကွယ်မရှိပါက `leaf2` သည် ထို frame အား ၎င်း၏ local link မှတစ်ဆင့် `host1` ဆီသို့ ပြန်ပို့မိပြီး loop ဖြစ်သွားမည်!
- **EVPN Route Type 1 (Auto-Discovery Route)**: `leaf1` သည် ၎င်း၏ Route Type 1 update တွင် **ESI Label** ကို ထည့်သွင်းပေးသည်။
- `leaf2` က packet ကို decapsulate လုပ်သည့်အခါ မိမိ၏ local ESI label ကို တွေ့ရှိပါက အဆိုပါ packet အား ESI interface သို့ ပြန်မပို့ဘဲ drop ပစ်လိုက်သည် (**Split-Horizon Filtering**)။

---

## အဆင့် ၁ · ESI Port-Channel ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-esi-port-channel-configuration }

`leaf1` နှင့် `leaf2` Ethernet3 port များပေါ်တွင် တူညီသော 10-byte ESI တန်ဖိုးများကို သတ်မှတ်ပါ။

=== "leaf1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/04-leaf1-esi.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/04-leaf2-esi.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-production-verification }

`leaf1` ပေါ်တွင် ESI အခြေအနေနှင့် Designated Forwarder (DF) ရွေးချယ်မှု အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type es
EOF
```

```
BGP routing table information for VRF default
Route type: 4 (Ethernet Segment Route)
   ESI: 00:11:22:33:44:55:66:77:88:99
   Designated Forwarder: 10.255.0.11 (Local)
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `leaf1` သည် ESI `00:11:22:33:44:55:66:77:88:99` အတွက် Designated Forwarder အခြေအနေကို မှန်ကန်စွာ ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
