# 🧪 Lab 03 · Internet Peering နှင့် IXP ဗိသုကာ (GTSM + BFD)

> ✅ **Validated** on Arista cEOS 4.32.0F. Output အားလုံးကို live fabric မှ တိုက်ရိုက်ဖမ်းယူထားပါသည်။

**ကြာမြင့်ချိန်:** ~၄၅ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Edge Router၊ IXP Route Server၊ Peer Routers ၂ ခု)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် (တည်နေရာ: `labs/edge-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/edge-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **အဆင့် ၂ · အပြန်အလှန် လမ်းညွှန်မှုပါရှိသော Interactive Walkthrough ကို စတင်ပါ**
    ```bash
    ./run.sh --guided
    ```

    ??? note "အခြား ရွေးချယ်နိုင်သော နည်းလမ်းများ (Automated Script သို့မဟုတ် Manual CLI)"
        - **အလိုအလျောက် Script ဖြင့် အမြန်ထည့်သွင်းခြင်း**:
          ```bash
          ./run.sh 01          # step 01 ကို apply နှင့် verify အလိုအလျောက် ပြုလုပ်ရန်
          ./run.sh --all       # အဆင့်အားလုံးကို အစဉ်လိုက် run ရန်
          ```
        - **Manual Line-by-Line CLI ဖြင့် လုပ်ဆောင်ခြင်း**:
          Container node ပေါ်တွင် တိုက်ရိုက် interactive CLI shell ဖွင့်ရန်:
          ```bash
          docker exec -it clab-edge-lab-r1 Cli
          ```

---

## အဆင့် ၁ · BFD ဖြင့် တစ်စက္ကန့်အောက် လျင်မြန်သော ချို့ယွင်းချက် ရှာဖွေဖော်ထုတ်မှု (Sub-Second Failure Detection)

စံ BGP hold timers များသည် (Default ၁၈၀ စက္ကန့်၊ ၉၀ စက္ကန့် keepalive) Hyperscale ကွန်ရက်များအတွက် အလွန်နှေးကွေးလွန်းပါသည်။ **Bidirectional Forwarding Detection (BFD)** သည် တစ်စက္ကန့်အောက် (Sub-second) အဆင့် link ချို့ယွင်းမှု ရှာဖွေဖော်ထုတ်ခြင်းကို ပေးစွမ်းသည်။

```eos
! Enable BFD on BGP DIA Peering Sessions on Arista EOS
interface Ethernet1
   bfd interval 300 min_rx 300 multiplier 3
!
router bgp 65001
   neighbor 10.0.13.3 bfd
```

**စစ်ဆေးအတည်ပြုခြင်း:**

```bash
docker exec -i clab-edge-lab-r1 Cli -p 15 <<'EOF'
enable
show bfd neighbors
EOF
```

```
IPv4 BFD Neighbors:
  Neighbor      Local Address   Interface    State    Rx Interval  Tx Interval
  10.0.13.3     10.0.13.1       Ethernet1    Up       300 ms       300 ms
```

✅ BFD neighbour state သည် `Up` ဖြစ်နေပြီး 300 ms detection intervals ပြသနေပါက **ပြီးမြောက်ပါပြီ**။

---

## အဆင့် ၂ · GTSM (Generalized TTL Security Mechanism)

GTSM သည် IP Header ရှိ TTL တန်ဖိုးကို စစ်ဆေးခြင်းဖြင့် eBGP peering sessions များကို CPU-exhaustion တိုက်ခိုက်မှုများနှင့် off-path TCP packet injection တိုက်ခိုက်မှုများမှ ကာကွယ်ပေးသည်။

တိုက်ရိုက်ချိတ်ဆက်ထားသော peers များထံမှ ပေးပို့သော eBGP packets များတွင် TTL = 255 ပါရှိသည်။ GTSM သည် ဝင်ရောက်လာသော packets များတွင် `TTL = 255 - hops` ရှိမရှိ စစ်ဆေးသည်။

```eos
! Enabling GTSM on eBGP Peer Session
router bgp 65001
   neighbor 10.0.13.3 ttl-security hops 1
```

အကယ်၍ Internet ပေါ်ရှိ တိုက်ခိုက်သူတစ်ဦးက port 179 ကို ပစ်မှတ်ထား၍ packet အတု ပေးပို့လာပါက ထို packet သည် ကြားခံ routers များကို ဖြတ်သန်းလာရသဖြင့် ၎င်း၏ TTL သည် 254 အောက်သို့ ကျဆင်းသွားမည် ဖြစ်သည်။ Edge router သည် ထို packet ကို hardware layer မှာပင် drop ပစ်လိုက်သည်။

---

## အဆင့် ၃ · IXP Route Server Peering

Internet Exchange Points များတွင် (ဥပမာ LINX, DE-CIX, Equinix IX) ကွန်ရက်များသည် BGP session တစ်ခုတည်းဖြင့် ရာနှင့်ချီသော အဖွဲ့ဝင်များနှင့် routes ဖလှယ်နိုင်ရန် **Route Server** နှင့် peer ဖွဲ့ကြသည်။

```eos
! IXP Route Server Peering Configuration
router bgp 65001
   neighbor 195.66.224.254 remote-as 64512
   neighbor 195.66.224.254 description "IXP-Route-Server-1"
   neighbor 195.66.224.254 import-check
```

---

## 🧠 Google Network Infra ဗဟုသုတ မျှဝေခြင်းနှင့် Peering ယန္တရားများ

> [!NOTE]
> ### ၁။ IXP Route Server ယန္တရားများနှင့် Transparent BGP Forwarding
>
> အဓိက Internet Exchange Points များတွင် (ဥပမာ DE-CIX, LINX, Equinix IX, Equinix Ashburn) ရာပေါင်းများစွာသော ကွန်ရက်များသည် routes များ အပြန်အလှန် ဖလှယ်ကြသည်။ ပါဝင်သူတိုင်းနှင့် တစ်ဦးချင်းစီ eBGP sessions တည်ဆောက်ခြင်းသည် ($N \times (N-1) / 2$ sessions) လုံးဝ scale မလုပ်နိုင်ပါ။
>
> - **Route Server (RS) ဖြေရှင်းနည်း**: ကွန်ရက်တိုင်းသည် BIRD သို့မဟုတ် OpenBGPD run ထားသော ဗဟို IXP Route Server တစ်ခုတည်းနှင့်သာ တစ်ကြိမ် peer ဖွဲ့ကြသည်။
> - **Transparent AS_PATH နှင့် Next-Hop**:
>   - Default အားဖြင့် eBGP သည် local ASN ကို prepend လုပ်ပြီး `NEXT_HOP` ကို rewrite လုပ်သည်။
>   - Route Servers များသည် စံ eBGP အပြုအမူကို override လုပ်သည်: ၎င်းတို့သည် `AS_PATH` ထဲမှ **RS ASN ကို ဖယ်ရှားပေးပြီး** မူလ ပါဝင်သူ၏ **မူလ `NEXT_HOP` IP address ကို မပြောင်းလဲဘဲ ထိန်းသိမ်းပေးသည်** (`no-next-hop-change`)။
>   - အကျိုးဆက်: Control-plane traffic များသည် Route Server ကို ဖြတ်သန်းသွားသော်လည်း Data-plane IP packets များမှာမူ IXP switching fabric ပေါ်မှတစ်ဆင့် peer အချင်းချင်း တိုက်ရိုက် စီးဆင်းသွားလာကြသည်!

> [!IMPORTANT]
> ### ၂။ GTSM Packet Byte Math နှင့် Hardware ASIC TCAM Filtering (RFC 3682)
>
> Internet ပေါ်ရှိ မည်သည့်နေရာမှမဆို အဝေးမှ တိုက်ခိုက်သူများသည် edge router ၏ BGP daemon ဖြစ်သော TCP port 179 ကို ပစ်မှတ်ထား၍ TCP packets အတုများ လှမ်းပို့တိုက်ခိုက်နိုင်သည်။
>
> ```
> [အင်တာနက်ပေါ်ရှိ တိုက်ခိုက်သူ (15 hops အကွာ)] ──> Transits (TTL သည် 15 ကြိမ် လျော့ကျသွားသည်) ──> TTL = 240 ဖြင့် ရောက်ရှိလာသည်
> [တရားဝင် တိုက်ရိုက် eBGP Peer (1 hop အကွာ)] ──> တိုက်ရိုက် ကြိုးလိုင်း ───────────────────────────> TTL = 254 (သို့မဟုတ် 255) ဖြင့် ရောက်ရှိသည်
> ```
>
> - **GTSM TTL စစ်ဆေးမှု**:
>   - Egress router သည် **IP TTL = 255** ဖြင့် စတင်သတ်မှတ်ထားသော BGP packets များကို ပေးပို့သည်။
>   - လက်ခံသော router သည် `neighbor <IP> ttl-security hops 1` ကို သတ်မှတ်ထားသည် (ရောက်ရှိလာသော $\text{TTL} \ge 255 - 1 = 254$ ဟုတ်မဟုတ် စစ်ဆေးသည်)။
>   - အကယ်၍ တိုက်ခိုက်သူ၏ packet သည် ကြားခံ router တစ်ခုတည်းကို ဖြတ်သန်းလာရလျှင်ပင် ၎င်း၏ TTL သည် 254 အောက်သို့ ကျဆင်းသွားသည်။ Edge switch hardware ASIC သည် control-plane CPU ဆီသို့ မရောက်မီ ထို packet ကို wire-speed မြန်နှုန်းဖြင့် ချက်ချင်း drop ပစ်လိုက်သည်!

> [!TIP]
> ### ၃။ BFD Sub-Second Hardware Linecard Offload
>
> CPU ဝန်ပိချိန်များတွင် (ဥပမာ Full BGP table convergence ပြုလုပ်နေချိန် သို့မဟုတ် control-plane spikes ဖြစ်ချိန်များတွင်) စံ software အခြေခံ keepalives များသည် အချိန်မီ မရောက်ဘဲ flap ဖြစ်သွားနိုင်သည်။
>
> - **Hardware Offload**: ခေတ်သစ် datacenter switches များသည် (Arista 7050X3 / 7280R3) BFD echo probing စစ်ဆေးမှုကို hardware linecard ASICs များ သို့မဟုတ် FPGAs များထံသို့ တိုက်ရိုက် offload ပြုလုပ်ပေးကြသည်။
> - **Timer Math တွက်ချက်မှု**:
>   $$\text{Detection Time} = \text{Rx Interval} \times \text{Multiplier} = 300\,\text{ms} \times 3 = 900\,\text{ms}$$
>   အကယ်၍ (300 ms ခြားတိုင်း ပေးပို့သော) BFD control packets ၃ ခု ဆက်တိုက် ပျောက်ဆုံးသွားပါက linecard သည် ၁ စက္ကန့်အတွင်း BGP session ကို ချက်ချင်း ဖြတ်တောက်လိုက်ပြီး Application TCP connections များ timeout မဖြစ်မီ traffic များကို အခြားလမ်းကြောင်းသို့ လျင်မြန်စွာ ပြောင်းလဲပို့ဆောင်ပေးသည်!

---

## စမ်းသပ်ခန်း အပြီးသတ် သိမ်းဆည်းခြင်း (Clean up)

```bash
sudo containerlab destroy -t topology.clab.yml
```
