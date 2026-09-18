# 🧪 Lab 01 · Active/Standby နှင့် Active/Active Dual-ISP eBGP {: #lab-01-dual-isp-ebgp }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၄၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (WAN Edge Router ၂ လုံး၊ ISP Router ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/wan-edge-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/wan-edge-lab
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
          docker exec -it clab-wan-edge-lab-wan-edge1 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Dual-ISP Multihoming လုပ်ဆောင်ချက်များ {: #technology-deep-dive-dual-isp-multihoming-mechanics }

လုပ်ငန်းသုံး WAN edge ဗိသုကာများတွင် ISP တစ်ခုတည်းနှင့်သာ ချိတ်ဆက်ခြင်းသည် Single Point of Failure (SPOF) ကို ဖြစ်ပေါ်စေသည်။ **Dual-ISP eBGP Multihoming** သည် သီးခြားလွတ်လပ်သော Autonomous Systems နှစ်ခုဆီသို့ သီးခြား eBGP session များကို တည်ဆောက်ပေးပါသည်:

```
                      +-------------------+
                      |   PRIMARY ISP     |
                      |   (ASN 65100)     |
                      +---------+---------+
                                |  eBGP
                                |  198.51.100.0/30
                      +---------+---------+
                      |    wan-edge1      |
                      |   (ASN 65000)     |
                      +---------+---------+
                                |  iBGP 10.0.0.0/30
                      +---------+---------+
                      |    wan-edge2      |
                      |   (ASN 65000)     |
                      +---------+---------+
                                |  eBGP
                                |  203.0.113.0/30
                      +---------+---------+
                      |    BACKUP ISP     |
                      |   (ASN 65200)     |
                      +-------------------+
```

---

## အဆင့် ၁ · Dual ISPs ဆီသို့ eBGP Session များ ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-configure-ebgp-sessions-to-dual-isps }

`wan-edge1` (Primary ISP) နှင့် `wan-edge2` (Backup ISP) ပေါ်တွင် eBGP session များကို ချိန်ညှိပါ။

=== "wan-edge1"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-wan-edge1-ebgp.cfg"
    ```

=== "wan-edge2"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-wan-edge2-ebgp.cfg"
    ```

=== "isp-primary"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-isp-primary-ebgp.cfg"
    ```

=== "isp-backup"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-isp-backup-ebgp.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-production-verification }

`wan-edge1` ပေါ်တွင် eBGP neighbor အခြေအနေကို စစ်ဆေးပါ:

```bash
docker exec -i clab-wan-edge-lab-wan-edge1 Cli -p 15 <<'EOF'
enable
show bgp summary
EOF
```

```
BGP summary information for VRF default
Router identifier 10.255.0.1, local AS number 65000
Neighbor        V  AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd
10.0.0.2        4  65000             15        15    0    0 00:02:10 Estab   1
198.51.100.2    4  65100             15        15    0    0 00:02:10 Estab   1
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show bgp summary` တွင် `198.51.100.2` (Primary ISP) သည် `Estab` အခြေအနေဖြင့် ပြသရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
