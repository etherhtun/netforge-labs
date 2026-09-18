# 🧪 Lab 01 · gNMI နှင့် OpenConfig YANG Data Models ကို ဖွင့်လှစ်အသုံးပြုခြင်း {: #lab-01-gnmi-openconfig }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၄၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Spine ၂ လုံး၊ Leaf ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/telemetry-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/telemetry-lab
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
          docker exec -it clab-telemetry-lab-leaf1 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: gNMI & OpenConfig YANG ဗိသုကာ {: #technology-deep-dive-gnmi-openconfig-yang-architecture }

### ၁။ gNMI ဆိုသည်မှာ အဘယ်နည်း {: #1-what-is-gnmi }
**gNMI (gRPC Network Management Interface)** သည် OpenConfig consortium မှ တည်ဆောက်ထားသော network management protocol တစ်ခု ဖြစ်သည်။ ၎င်းသည် **gRPC** (Google Remote Procedure Call) နှင့် **HTTP/2** ပေါ်တွင် လည်ပတ်ပြီး လုံခြုံစိတ်ချရသော မြန်နှုန်းမြင့် streaming telemetry စနစ်ကို ထောက်ပံ့ပေးပါသည်။

---

### ၂။ OpenConfig YANG Data Paths {: #2-openconfig-yang-data-paths }
နားလည်ရခက်ခဲသော ရှေးဟောင်း SNMP OID များအစား gNMI သည် ရှင်းလင်းစနစ်ကျသော **OpenConfig YANG paths** များကို အသုံးပြုပါသည်:

```
openconfig-interfaces:interfaces/interface[name=Ethernet1]/state/counters/in-octets
```

---

## အဆင့် ၁ · Arista cEOS ပေါ်တွင် gNMI Management ကို ချိန်ညှိပြင်ဆင်ခြင်း {: #step-1-configure-gnmi-management-on-arista-ceos }

`spine1`၊ `spine2`၊ `leaf1`၊ နှင့် `leaf2` ပေါ်တွင် gNMI management service ကို ဖွင့်လှစ်ပါ။

=== "leaf1"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-leaf1-gnmi.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-leaf2-gnmi.cfg"
    ```

=== "spine1"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-spine1-gnmi.cfg"
    ```

=== "spine2"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-spine2-gnmi.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-production-verification }

`leaf1` ပေါ်တွင် gNMI service အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-telemetry-lab-leaf1 Cli -p 15 <<'EOF'
enable
show management api gnmi
EOF
```

```
Enabled: Yes
Transport: gRPC default (Port 6030)
SSL Profile: None (Insecure for local container testing)
Provider: EOS Native / OpenConfig
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** gNMI management API တွင် `Port 6030` ပေါ်၌ `Enabled: Yes` ဟု ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
