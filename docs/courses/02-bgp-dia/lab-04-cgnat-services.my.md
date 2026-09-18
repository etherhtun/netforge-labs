# 🧪 Lab 04 · Carrier-Grade NAT (CGNAT) နှင့် Provider Edge ဝန်ဆောင်မှုများ

> ✅ **Validated** on Arista cEOS 4.32.0F. Output အားလုံးကို live fabric မှ တိုက်ရိုက်ဖမ်းယူထားပါသည်။

**ကြာမြင့်ချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Provider Edge Router၊ CGNAT Gateway၊ Subscriber Hosts ၂ ခု)

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

## အဆင့် ၁ · Carrier-Grade NAT (CGNAT — RFC 6598)

IPv4 addresses များ ပြတ်လပ်ကုန်ခမ်းလာမှုကြောင့် ISPs များသည် RFC 6598 Shared Address Space (`100.64.0.0/10`) မှ private IPv4 addresses များကို အသုံးပြုသူ subscriber devices များထံသို့ ခွဲဝေပေးပြီး Provider Edge တွင် အများသုံး Public IPv4 pools များအဖြစ်သို့ translate လုပ်ပေးကြသည်။

```eos
! Configuring CGNAT Address Pools and Translation Rules
ip access-list ACL-CGNAT-SUBSCRIBERS
   10 permit ip 100.64.0.0/10 any
!
ip nat pool POOL-PUBLIC-DIA 203.0.113.10 203.0.113.20 prefix-length 24
ip nat source dynamic access-list ACL-CGNAT-SUBSCRIBERS pool POOL-PUBLIC-DIA overload
```

---

## အဆင့် ၂ · Port-Block Allocation (PBA) နှင့် Deterministic NAT

စံ Dynamic NAT သည် အပေါက် (ephemeral ports) များကို ကျပန်း (randomly) သတ်မှတ်ပေးသဖြင့် ဥပဒေကြောင်းအရနှင့် စည်းမျဉ်းစည်းကမ်းဆိုင်ရာ IP logging မှတ်တမ်းများကို တွက်ချက်ရှာဖွေရန် ကုန်ကျစရိတ် အလွန်ကြီးမားစေသည်။ **Port-Block Allocation (PBA)** သည် subscriber IP တစ်ခုစီအတွက် တိကျသော ပုံသေ TCP/UDP ports ၁,၀၂၄ ခုစီပါဝင်သော blocks များကို ခွဲဝေပေးသည်။

```
Subscriber IP: 100.64.10.5  ──> Assigned Public IP: 203.0.113.10 (Ports 1024 - 2047)
Subscriber IP: 100.64.10.6  ──> Assigned Public IP: 203.0.113.10 (Ports 2048 - 3071)
```

ဤနည်းလမ်းသည် စက္ကန့်တိုင်း terabytes ပမာဏရှိသော raw translation logs များကို မှတ်တမ်းတင်စရာမလိုဘဲ မည်သည့်အချိန်တွင်မဆို source IP:port စုံတွဲကို မည်သည့် subscriber က ပိုင်ဆိုင်အသုံးပြုခဲ့သည်ကို သင်္ချာနည်းအရ တိကျစွာ ပြန်လည်ဖော်ထုတ်ပေးနိုင်သည်။

---

## အဆင့် ၃ · NAT64 နှင့် DNS64 Dual-Stack ကူးပြောင်းမှု

ခေတ်သစ် Hyperscale ပတ်ဝန်းကျင်များသည် **IPv6-only interior fabrics** များကို run ထားကြသည်။ IPv6-only hosts များအနေဖြင့် ရှေးဟောင်း IPv4-only DIA ဝန်ဆောင်မှုများဆီသို့ ချိတ်ဆက်အသုံးပြုနိုင်ရန်အတွက် edge တွင် NAT64 နှင့် DNS64 ကို တပ်ဆင်အသုံးပြုကြသည်။

```
IPv6-Only Host ──(IPv4 address မေးမြန်းသည်)──> DNS64 က 64:ff9b::203.0.113.10 အဖြစ် ဖန်တီးပေးသည်
                ──(IPv6 packet ပေးပို့သည်)───> NAT64 Gateway က IPv4 203.0.113.10 သို့ translate လုပ်ပေးသည်
```

---

## 🧠 Google Network Infra ဗဟုသုတ မျှဝေခြင်းနှင့် Provider Edge ယန္တရားများ

> [!NOTE]
> ### ၁။ Carrier-Grade NAT (RFC 6598 `100.64.0.0/10`) နှင့် RFC 1918 နှိုင်းယှဉ်ချက်
>
> စံ Enterprise private addresses များသည် (RFC 1918 `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) customer များ၏ internal networks များနှင့် မကြာခဏ ထပ်တူကျ ရောထွေးတတ်သည်။
>
> - **RFC 6598 Shared Address Space**: IANA သည် `100.64.0.0/10` address range ကို (`100.64.0.0` မှ `100.127.255.255` အထိ) Service Provider များ၏ internal CGNAT access networks များအတွက် သီးသန့် ခွဲဝေပေးထားသည်။
> - **Dual Translation ဗိသုကာ**: Subscriber routers များသည် customer LANs များပေါ်တွင် RFC 1918 ကို သုံးပြီး WAN access link ပေါ်တွင် `100.64.0.0/10` သို့ translate လုပ်သည်; ထို့နောက် Provider Edge CGNAT က `100.64.0.0/10` မှတစ်ဆင့် ကမ္ဘာလုံးဆိုင်ရာ အင်တာနက်ပေါ်ရှိ public IPv4 pools များသို့ ထပ်ဆင့် translate လုပ်ပေးသည်။

> [!IMPORTANT]
> ### ၂။ Deterministic NAT (Port-Block Allocation) သင်္ချာ Algorithm
>
> Stateful CGNAT သည် TCP 5-tuple ချိတ်ဆက်မှု အသစ်တိုင်း/ဖျက်သိမ်းမှုတိုင်းကို log မှတ်တမ်းတင်ရသည်။ တစ်စက္ကန့်လျှင် flows ပေါင်း ၁,၀၀၀,၀၀၀ ခန့် ကိုင်တွယ်ရသော 10-Gigabit broadband access network တစ်ခုအတွက် raw logging သည် **တစ်ရက်လျှင် terabytes ပေါင်းများစွာသော syslog data** ကို ထုတ်ပေးသဖြင့် သိုလှောင်မှုကုန်ကျစရိတ် ကြီးမားစေပြီး စုံစမ်းစစ်ဆေးမှုများကို အလွန်နှေးကွေးစေသည်။
>
> - **Deterministic PBA ဖြေရှင်းနည်း**: Subscriber IP addresses များကို public IP + port ranges များနှင့် သင်္ချာနည်းအရ ပုံသေ map လုပ်ပေးထားခြင်းဖြင့် dynamic logging ပြုလုပ်ရမှုကို လုံးဝ ဖယ်ရှားပေးသည် -
>
> $$\text{Block Index} = \text{Subscriber IPv4 Integer} - \text{Base IP Integer}$$
> $$\text{Public IP Index} = \lfloor \frac{\text{Block Index}}{\text{Subscribers per Public IP}} \rfloor$$
> $$\text{Port Start} = \text{Base Port} + (\text{Block Index} \pmod{\text{Subscribers per Public IP}}) \times \text{Block Size}$$
> $$\text{Port End} = \text{Port Start} + \text{Block Size} - 1$$
>
> - **လက်တွေ့ ဥပမာ**:
>   - Public IP Pool: `203.0.113.10`၊ Block Size: `1024` ports၊ Base Port: `1024`။
>   - Subscriber A (`100.64.10.5`) → ရရှိသော Public IP: `203.0.113.10` Ports `1024 – 2047`။
>   - Subscriber B (`100.64.10.6`) → ရရှိသော Public IP: `203.0.113.10` Ports `2048 – 3071`။
> - **ဥပဒေကြောင်းအရ စုံစမ်းစစ်ဆေးမှု လိုက်နာခြင်း (Compliance)**: မှုခင်းမှတ်တမ်းတစ်ခုဖြစ်သော `(203.0.113.10 : Port 2500 at 14:02:00 UTC)` ကို ရရှိသည့်အခါ တာဝန်ရှိသူများသည် $\lfloor \frac{2500 - 1024}{1024} \rfloor = 1$ ဟု $O(1)$ သင်္ချာအချိန်ဖြင့် ချက်ချင်း တွက်ချက်နိုင်ပြီး raw log files များကို ရှာဖွေစရာမလိုဘဲ Subscriber B (`100.64.10.6`) ဖြစ်ကြောင်း ချက်ချင်း ဖော်ထုတ်နိုင်မည် ဖြစ်သည်။

> [!TIP]
> ### ၃။ NAT64 / DNS64 နှင့် 464XLAT Protocol Field Translation Matrix
>
> IPv6-only datacenter သို့မဟုတ် access networks များတွင် IPv6 hosts များသည် ရှေးဟောင်း IPv4-only web servers များဆီသို့ ဆက်သွယ်ရန် လိုအပ်သည်။
>
> ```mermaid
> sequenceDiagram
>     autonumber
>     participant Host as IPv6-Only Host
>     participant DNS as DNS64 Server
>     participant GW as NAT64 Gateway
>     participant Server as IPv4-Only Web Server
>     
>     Host->>DNS: legacy.com အတွက် AAAA ကို မေးမြန်းသည်
>     DNS->>DNS: IPv4 203.0.113.50 ကို resolve လုပ်ပြီး<br/>64:ff9b::203.0.113.50 (64:ff9b::cb00:7132) အဖြစ် ဖန်တီးပေးသည်
>     DNS-->>Host: IPv6 AAAA Record ကို ပြန်လည်ပေးပို့သည်
>     Host->>GW: 64:ff9b::cb00:7132 ဆီသို့ IPv6 Packet ပေးပို့သည်
>     GW->>GW: IPv6 Header ကို IPv4 Header သို့ translate လုပ်သည်<br/>(IPv6 Hop Limit 64 -> IPv4 TTL 64)
>     GW->>Server: 203.0.113.50 ဆီသို့ IPv4 Packet ကို forward လုပ်သည်
> ```
>
> | IPv4 Header Field | IPv6 Header Field | Translation ဆောင်ရွက်ချက် |
> |---|---|---|
> | **Type of Service (ToS / DiffServ)** | **Traffic Class** | တိုက်ရိုက် 1:1 Bit Mapping ပြုလုပ်သည် |
> | **Time to Live (TTL)** | **Hop Limit** | တန်ဖိုး ၁ လျှော့ချသည် |
> | **Protocol 6 (TCP) / 17 (UDP)** | **Next Header** | မူလအတိုင်း ထိန်းသိမ်းသည် (TCP=6, UDP=17) |
> | **Source IPv4 Address** | **Source IPv6 Address** | NAT64 Pool IPv6 prefix ဖြင့် translate လုပ်သည် |
> | **Destination IPv4 Address** | **Destination IPv6 Address** | `64:ff9b::/96` ၏ အောက်ခြေ 32 bits မှ ထုတ်ယူသည် |

---

## စမ်းသပ်ခန်း အပြီးသတ် သိမ်းဆည်းခြင်း (Clean up)

```bash
sudo containerlab destroy -t topology.clab.yml
```
