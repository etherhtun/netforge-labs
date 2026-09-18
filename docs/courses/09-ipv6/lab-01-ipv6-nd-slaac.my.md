# 🧪 Lab 01 · IPv6 Neighbor Discovery (ND) နှင့် SLAAC / DHCPv6 {: #lab-01-ipv6-nd-slaac }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၄၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Router ၂ လုံး၊ Leaf ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/ipv6-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/ipv6-lab
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
          docker exec -it clab-ipv6-lab-r1-v6 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: IPv6 Neighbor Discovery (ND) {: #technology-deep-dive-ipv6-neighbor-discovery }

IPv6 သည် IPv4 ၏ ARP (Address Resolution Protocol) broadcasts များကို ICMPv6 **Neighbor Discovery (ND)** ဖြင့် အစားထိုးလိုက်ပါသည်:
- **Neighbor Solicitation (NS / Type 135)**: သက်ဆိုင်ရာ node ၏ MAC address ကို မေးမြန်းရန် Solicited-Node Multicast Address (`ff02::1:ffxx:xxxx`) ဆီသို့ ပေးပို့သော multicast request ဖြစ်သည်။
- **Neighbor Advertisement (NA / Type 136)**: Link-layer MAC address ကို ပြန်လည်ပေးပို့သည့် unicast reply ဖြစ်သည်။
- **Router Advertisement (RA / Type 134)**: **SLAAC (Stateless Address Autoconfiguration)** အတွက် default gateway နှင့် IPv6 network prefixes (`2001:db8:1::/64`) များကို အချိန်မှန် ကြေညာပေးသော router broadcast ဖြစ်သည်။

---

## အဆင့် ၁ · IPv6 Dual-Stack Interface များကို ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-configure-ipv6-dual-stack-interfaces }

`r1-v6`၊ `r2-v6`၊ `leaf1-v6`၊ နှင့် `leaf2-v6` ပေါ်တွင် IPv6 global unicast address များ (`2001:db8::/64`) နှင့် OSPF Area 0 ကို ချိန်ညှိပါ။

=== "r1-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-r1-v6-nd.cfg"
    ```

=== "r2-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-r2-v6-nd.cfg"
    ```

=== "leaf1-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-leaf1-v6-nd.cfg"
    ```

=== "leaf2-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-leaf2-v6-nd.cfg"
    ```

---

## အဆင့် ၂ · စနစ်စစ်ဆေးခြင်း {: #step-2-production-verification }

`r1-v6` မှ `leaf1-v6` ဆီသို့ IPv6 ping ရောက်ရှိနိုင်မှုကို စစ်ဆေးပါ:

```bash
docker exec -i clab-ipv6-lab-r1-v6 Cli -p 15 <<'EOF'
enable
ping ipv6 2001:db8:1::2 repeat 2
EOF
```

```
PING 2001:db8:1::2(2001:db8:1::2) 72 bytes of data.
80 bytes from 2001:db8:1::2: icmp_seq=1 ttl=64 time=0.421 ms
80 bytes from 2001:db8:1::2: icmp_seq=2 ttl=64 time=0.380 ms

--- 2001:db8:1::2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1ms
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `ping ipv6 2001:db8:1::2` သည် `0% packet loss` ဖြင့် အောင်မြင်ရပါမည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
