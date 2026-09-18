# 🧪 Lab 02 · Integrated Routing & Bridging (Symmetric IRB နှင့် Anycast Gateway) {: #lab-02-symmetric-irb }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၆ ခု (Spine ၂ လုံး၊ Leaf ၂ လုံး၊ Customer Host ၂ လုံး)

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

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Symmetric IRB vs. Asymmetric IRB {: #technology-deep-dive-symmetric-vs-asymmetric-irb }

### ၁။ Inter-Subnet Routing ၏ စိန်ခေါ်ချက် {: #1-the-inter-subnet-routing-challenge }
Pure L2VNI (Lab 01) သည် Layer 2 bridging ကိုသာ တိုးချဲ့ပေးသော်လည်း မတူညီသော IP subnet များတွင်ရှိသော host များ (ဥပမာ VLAN 10 ရှိ `10.10.10.0/24` နှင့် VLAN 20 ရှိ `10.20.20.0/24`) အချင်းချင်း ဆက်သွယ်ရန် လိုအပ်လာသောအခါ traffic ကို Layer 3 တွင် မဖြစ်မနေ route လုပ်ပေးရပါမည်။

EVPN-VXLAN တွင် **Integrated Routing and Bridging (IRB)** သည် ဗိသုကာချဉ်းကပ်မှု ပုံစံနှစ်မျိုးဖြင့် Leaf အလွှာတွင် ၎င်းကို ကိုင်တွယ်ဖြေရှင်းပေးပါသည်:

---

### ၂။ Asymmetric IRB (ရှေးဟောင်းပုံစံ / Scale အကန့်အသတ်ရှိမှု) {: #2-asymmetric-irb }
Asymmetric IRB တွင်:
- **Ingress Leaf က route လုပ်ပေးသည်** (source VLAN မှ destination VLAN သို့ route လုပ်ပြီးနောက် destination L2 VNI ပေါ်သို့ packet အား **bridge** လုပ်ပေးသည်)။
- **အဓိက အားနည်းချက်**: ထို leaf ပေါ်တွင် local host လုံးဝမရှိစေကာမူ fabric ထဲရှိ Leaf router တိုင်းသည် VLAN တိုင်းနှင့် L2 VNI တိုင်းကို မဖြစ်မနေ configure လုပ်ထားရပါမည်! ၎င်းသည် fabric VLAN စကေးချဲ့နိုင်စွမ်းကို အလွန်အမင်း ကန့်သတ်စေပါသည်။

---

### ၃။ Symmetric IRB (Hyperscale ထုတ်လုပ်မှု စံနှုန်း) {: #3-symmetric-irb }
Symmetric IRB တွင်:
- **Ingress Leaf ရော Egress Leaf ပါ နှစ်ဖက်စလုံးတွင် Routing ဖြစ်ပွားသည်**:
  1. Ingress Leaf သည် source VRF မှ မျှဝေသုံးစွဲထားသော **Layer 3 VNI (`50001`)** သို့ route လုပ်ပေးသည်။
  2. Packet သည် fabric ကို ဖြတ်၍ L3 VNI header (`VNI 50001`) ဖြင့် ခရီးသွားသည်။
  3. Egress Leaf သည် L3 VNI `50001` ပေါ်တွင် packet ကို လက်ခံရရှိပြီး destination tenant VRF ထဲသို့ route လုပ်ပေးသည်။
- **အဓိက အားသာချက်**: Leaf များသည် မိမိတို့နှင့် တိုက်ရိုက်ချိတ်ဆက်ထားသော local host များအတွက် VLAN များကိုသာ configure လုပ်ရန် လိုအပ်သည်။ စကေးချဲ့နိုင်စွမ်းကို hardware routing table စွမ်းရည်ဖြင့်သာ ကန့်သတ်ထားပြီး VLAN mapping ကန့်သတ်ချက်များ မရှိတော့ပါ!

```
+---------------------------------------------------------------------------------------------------+
| SYMMETRIC IRB PACKET စီးဆင်းမှု လမ်းကြောင်း                                                          |
+---------------------------------------------------------------------------------------------------+
| 1. Host1 (VLAN 10) သည် Frame အား local Anycast Gateway (10.10.10.1, MAC 00:1c:73:00:00:01) ဆီသို့ ပို့သည် |
| 2. Leaf1 သည် Packet အား VRF TENANT-A ထဲသို့ route လုပ်ပြီး destination host IP (10.20.20.20) ကို ရှာဖွေသည် |
| 3. Leaf1 သည် Frame အား L3 VNI 50001 အတွင်း Encapsulate လုပ်သည် (Outer Dst IP: Leaf2 VTEP 10.255.1.12) |
| 4. Leaf2 သည် L3 VNI 50001 အား Decapsulate လုပ်ပြီး VRF TENANT-A ထဲသို့ route ကာ VLAN 20 ရှိ Host2 သို့ ပို့သည် |
+---------------------------------------------------------------------------------------------------+
```

---

### ၄။ Anycast Virtual Gateway {: #4-anycast-virtual-gateway }
Default gateway setting များကို ပြောင်းလဲစရာမလိုဘဲ virtual machine များနှင့် container များ leaf များကြား ချောမွေ့စွာ ရွှေ့ပြောင်းနိုင်စေရန်အတွက်:
- **တူညီသော Virtual IP (`10.10.10.1/24`)** နှင့် **တူညီသော Virtual MAC (`00:1c:73:00:00:01`)** ကို Leaf switch အားလုံးပေါ်တွင် သတ်မှတ်ထားသည်။
- Host များသည် ၎င်းတို့၏ default gateway အတွက် ARP ခေါ်ယူသည့်အခါ မည်သည့် leaf switch နှင့် ချိတ်ဆက်ထားသည်ဖြစ်စေ တူညီသော MAC address response ကိုသာ တိကျစွာ လက်ခံရရှိကြသည်!

---

## အဆင့် ၁ · Underlay IP နှင့် MP-iBGP EVPN ပြင်ဆင်ခြင်း {: #step-1-underlay-ip-and-mp-ibgp-evpn-setup }

Spines နှင့် Leafs များအကြား OSPF underlay နှင့် MP-iBGP EVPN session များ ကောင်းမွန်စွာ အလုပ်လုပ်နေစေရန် သေချာပါစေ။

=== "spine1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/01-spine1-underlay.cfg"
    ```

=== "leaf1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/01-leaf1-underlay.cfg"
    ```

---

## အဆင့် ၂ · Symmetric IRB နှင့် Anycast Gateway ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-2-symmetric-irb-and-anycast-gateway-configuration }

L2 VNI `10100`၊ L3 VNI `50001` (VRF `TENANT-A`)၊ Anycast Gateway IP (`10.10.10.1/24`)၊ နှင့် Virtual Router MAC (`00:1c:73:00:00:01`) တို့ကို ပြင်ဆင်ချိန်ညှိပါ။

=== "leaf1 (Symmetric IRB)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/03-leaf1-vxlan-irb.cfg"
    ```

=== "leaf2 (Symmetric IRB)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/03-leaf2-vxlan-irb.cfg"
    ```

---

## အဆင့် ၃ · အစအဆုံး စစ်ဆေးခြင်းနှင့် Route Type 5 ခွဲခြမ်းစိတ်ဖြာခြင်း {: #step-3-end-to-end-verification-route-type-5 }

### ၁။ EVPN Route Type 5 (L3 Prefix Routes) စစ်ဆေးခြင်း {: #1-verify-evpn-route-type-5 }
`leaf1` သည် `leaf2` ထံမှ L3 VNI `50001` prefix route များကို လက်ခံရရှိခြင်း ရှိမရှိ စစ်ဆေးပါ:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type prefix-segment
EOF
```

### ၂။ Inter-Subnet Routing စမ်းသပ်ခြင်း {: #2-test-inter-subnet-routing }
Symmetric IRB fabric ကို ဖြတ်၍ host workload များ ဆက်သွယ်မှုကို ping ဖြင့် စမ်းသပ်ပါ:

```bash
docker exec -i clab-evpn-datacenter-lab-host1 Cli -p 15 <<'EOF'
enable
ping 10.10.10.20 repeat 5
EOF
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `host1` သည် `host2` သို့ **Symmetric IRB L3 VNI `50001`** ကို ဖြတ်၍ အောင်မြင်စွာ ping နိုင်ရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
