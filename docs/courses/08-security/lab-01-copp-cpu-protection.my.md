# 🧪 Lab 01 · Control Plane Policing (CoPP) နှင့် CPU ကာကွယ်မှု {: #lab-01-copp-cpu-protection }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၄၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Spine ၂ လုံး၊ Leaf ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/security-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/security-lab
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
          docker exec -it clab-security-lab-spine1 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Control Plane Policing (CoPP) {: #technology-deep-dive-control-plane-policing-copp }

Control Plane Policing (CoPP) သည် router ၏ Central Processing Unit (CPU) အား ရုတ်တရက် traffic များပြားလာမှု၊ BGP SYN floods၊ နှင့် အန္တရာယ်ရှိသော ARP floods တိုက်ခိုက်မှုများမှ ကာကွယ်ပေးပါသည်။

CoPP သည် CPU သို့ ဦးတည်ဝင်ရောက်လာသော packet များကို `class-map` စည်းမျဉ်းများဖြင့် အမျိုးအစားခွဲခြားပြီး routing protocol daemon ထံသို့ packet များ မရောက်ရှိမီ switch ASIC အဆင့်တွင် hardware rate-limiters (`policy-map type copp`) ကို အသုံးချ၍ ကာကွယ်ပေးပါသည်:

```
+-------------------+      +-------------------+      +-------------------+
|  အဝင် TRAFFIC     |      |  COPP HARDWARE    |      |  ROUTING ENGINE   |
|  BGP / OSPF / ICMP| +===>|  ASIC RATE-LIMIT  | +===>|  CPU PROCESS      |
|  (100,000 pps)    |      |  (Policed 1000pps)|      |  (ဘေးကင်းစွာကာကွယ်)|
+-------------------+      +-------------------+      +-------------------+
```

---

## အဆင့် ၁ · Control Plane Policing ကို ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-configure-control-plane-policing }

`spine1`၊ `spine2`၊ `leaf1`၊ နှင့် `leaf2` ပေါ်တွင် CoPP policy map များကို ထည့်သွင်းပါ။

=== "spine1"

    ```eos
    --8<-- "labs/security-lab/steps/01-spine1-copp.cfg"
    ```

=== "spine2"

    ```eos
    --8<-- "labs/security-lab/steps/01-spine2-copp.cfg"
    ```

=== "leaf1"

    ```eos
    --8<-- "labs/security-lab/steps/01-leaf1-copp.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/security-lab/steps/01-leaf2-copp.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-production-verification }

`spine1` ပေါ်တွင် CoPP policy အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-security-lab-spine1 Cli -p 15 <<'EOF'
enable
show policy-map type copp
EOF
```

```
Service Policy input: POLICY-COPP
  Class-map: CLASS-COPP-BGP (match-all)
    10 permit tcp any any eq bgp
    Police: 1000 pps, burst 1000 packets
    Conformed: 1420 packets, Action: transmit
    Exceeded: 0 packets, Action: drop
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show policy-map type copp` တွင် `POLICY-COPP` သည် control plane traffic များကို တက်ကြွစွာ police လုပ်ဆောင်နေကြောင်း ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
