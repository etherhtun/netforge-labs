# 🧪 Lab 02 · BGP လုံခြုံရေး — RPKI ROV နှင့် Bogon Filtering

> ✅ **Validated** on Arista cEOS 4.32.0F. Output အားလုံးကို live fabric မှ တိုက်ရိုက်ဖမ်းယူထားပါသည်။

**ကြာမြင့်ချိန်:** ~၄၅ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (Edge Routers ၂ ခု၊ Transit/Peer Routers ၂ ခု)

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

## အဆင့် ၁ · RPKI Route Origin Validation (ROV)

RPKI သည် IP prefix တစ်ခုအား ကြေညာနေသော Origin AS သည် အဆိုပါ IP address space ပိုင်ရှင်အစစ်အမှန်က တရားဝင်ခွင့်ပြုထားသော AS ဟုတ်မဟုတ်ကို cryptographic နည်းပညာဖြင့် စစ်ဆေးအတည်ပြုပေးသည်။

### RPKI Validation States အဆင့် ၃ ဆင့်:
၁။ **`Valid`**: Prefix နှင့် Origin AS သည် လက်မှတ်ရေးထိုးထားသော Route Origin Authorization (ROA) object နှင့် ထပ်တူ ကိုက်ညီသည်။
၂။ **`Invalid`**: ထို prefix အတွက် ROA ရှိနေသော်လည်း ကြေညာသော AS သို့မဟုတ် prefix length သည် ကိုက်ညီမှု **မရှိပါ**။ **ဆောင်ရွက်ချက်: DROP (ချက်ချင်း ပယ်ဖျက်သည်)။**
၃။ **`NotFound`**: Global RPKI cache repositories များတွင် မည်သည့် ROA မျှ မတွေ့ရှိပါ။ **ဆောင်ရွက်ချက်: PERMIT (ဦးစားပေး local preference လျှော့ချ၍ လက်ခံသည်)။**

```eos
! Configuring RPKI Origin Validation Policy on Arista EOS Edge Router
router bgp 65001
   rpki cache ROUTINATOR-1
      host 10.0.100.50 port 3323
   !
   address-family ipv4
      bgp origin-as validation enable
```

Route-maps အသုံးပြု၍ Invalid routes များကို Filter ပြုလုပ်ခြင်း -

```eos
route-map RM-RPKI-IN deny 10
   match rpki validity invalid
!
route-map RM-RPKI-IN permit 20
   match rpki validity valid
   set local-preference 120
!
route-map RM-RPKI-IN permit 30
   match rpki validity not-found
   set local-preference 100
```

---

## အဆင့် ၂ · Remotely Triggered Blackhole (RTBH — `65535:666`)

IP address တစ်ခုသည် ကြီးမားသော volumetric DDoS တိုက်ခိုက်မှုအောက်သို့ ကျရောက်လာသည့်အခါ RTBH သည် တိုက်ခိုက်မှု traffic များကို ISP edge တွင် drop ပစ်နိုင်ရန် လူသိများသော well-known community `65535:666` (RFC 7999) ကို အသုံးပြုသည်။

```eos
! Configuring RTBH Blackhole route map
ip route 192.168.10.99/32 Null0
!
ip community-list CL-RTBH permit 65535:666
!
route-map RM-RTBH-IN permit 10
   match community CL-RTBH
   set ip next-hop 192.0.2.1
   set local-preference 200
```

Upstream ISP တစ်ခုသည် `65535:666` ကို လက်ခံရရှိသည့်အခါ Next-hop ကို `Null0` discard interface သို့ rewrite ပြုလုပ်ပြီး WAN bandwidth ကို မကုန်ခမ်းမီ DDoS attack ကို အမြန်ဆုံး ရှင်းထုတ်ပစ်သည်။

---

## အဆင့် ၃ · Bogon နှင့် Transit Leak Filtering

Internet သို့ မျက်နှာမူထားသော eBGP sessions များပေါ်တွင် Private address spaces (RFC 1918)၊ CGNAT space (RFC 6598 `100.64.0.0/10`) နှင့် Loopbacks များကို ပိတ်ဆို့ပါမည်။

```eos
ip prefix-list PL-BOGON-DENY seq 10 deny 10.0.0.0/8 le 32
ip prefix-list PL-BOGON-DENY seq 20 deny 172.16.0.0/12 le 32
ip prefix-list PL-BOGON-DENY seq 30 deny 192.168.0.0/16 le 32
ip prefix-list PL-BOGON-DENY seq 40 deny 100.64.0.0/10 le 32
ip prefix-list PL-BOGON-DENY seq 50 permit 0.0.0.0/0 le 24
```

---

## 🧠 Google Network Infra ဗဟုသုတ မျှဝေခြင်းနှင့် ကာကွယ်ရေး လုံခြုံရေး ယန္တရားများ

> [!NOTE]
> ### ၁။ End-to-End RPKI ROV ဗိသုကာနှင့် RTR Protocol (RFC 8210)
>
> RPKI Origin Validation သည် IP prefix ပိုင်ဆိုင်မှုကို စစ်ဆေးရန် out-of-band cryptographic trust hierarchy ကို အသုံးပြုသည် -
>
> ```mermaid
> graph LR
>     RIR["RIR Repositories<br/>(ARIN, RIPE, APNIC)<br/>X.509 TAL Certificates"] --->|Sync via RRDP / Rsync| Validator["RPKI Cache Validator<br/>(Routinator / StayRtr / Fort)"]
>     Validator --->|RTR Protocol<br/>TCP Port 3323| EdgeRouter["Arista EOS Edge Router<br/>(BGP Origin-AS Validation Engine)"]
>     EdgeRouter --->|Evaluate Inbound BGP UPDATE| Decision{"ROA Table Lookup<br/>(Prefix + Length + Origin ASN)"}
>     Decision --->|Match| Valid["Valid<br/>(Permit, Set LP=120)"]
>     Decision --->|Length / ASN Mismatch| Invalid["Invalid<br/>(DROP Route!)"]
>     Decision --->|No ROA Found| NotFound["NotFound<br/>(Permit, Set LP=100)"]
>     
>     classDef rir fill:#1565c0,stroke:#90caf9,color:#ffffff;
>     classDef val fill:#f57c00,stroke:#ffe0b2,color:#ffffff;
>     classDef edge fill:#2e7d32,stroke:#a5d6a7,color:#ffffff;
>     class RIR rir; class Validator val; class EdgeRouter edge;
> ```
>
> - **Routers များသည် RIRs များထံ တိုက်ရိုက် အဘယ်ကြောင့် Query မလုပ်ကြသနည်း**: သန်းပေါင်းများစွာသော ROA objects များပေါ်ရှိ cryptographic X.509 signatures များကို စစ်ဆေးခြင်းသည် CPU နှင့် RAM ဝန်ထုပ်ဝန်ပိုး အလွန်ကြီးမားသည်။ သီးသန့် validator servers များက (Routinator, StayRtr) စစ်ဆေးပြီးနောက် ပေါ့ပါးသော binary RTR PDUs (RFC 8210) အသုံးပြု၍ `(IPv4/IPv6 Prefix, MaxLength, Origin ASN)` ဇယားအဖြစ် edge routers များထံသို့ ပေးပို့ပေးသည်။

> [!IMPORTANT]
> ### ၂။ `maxLength` ဖြင့် Prefix De-aggregation Hijacks များကို ကာကွယ်ခြင်း
>
> အဖြစ်များသော BGP hijacking နည်းလမ်းတစ်ခုမှာ aggregate `/16` (`1.1.0.0/16`) သာ ကြေညာထားသော ပစ်မှတ်တစ်ခုအတွက် ပိုမိုတိကျသော subnet (ဥပမာ `1.1.1.0/24`) ကို ခိုးယူကြေညာခြင်း ဖြစ်သည်။ BGP longest-prefix matching စည်းမျဉ်းကြောင့် ကမ္ဘာလုံးဆိုင်ရာ traffic များသည် တိုက်ခိုက်သူ၏ `/24` ဆီသို့ အလိုအလျောက် လမ်းကြောင်းလွဲသွားသည်။
>
> - **ROA ၏ ကာကွယ်မှု**: လက်မှတ်ရေးထိုးထားသော ROA တွင် တရားဝင်ခွင့်ပြုထားသော `Origin ASN` သာမက ခွင့်ပြုသည့် `maxLength` ကိုပါ တိကျစွာ ဖော်ပြထားသည်။
>   - ဥပမာ ROA: `Prefix: 203.0.113.0/20`၊ `maxLength: 24`၊ `ASN: 65001`။
>   - အကယ်၍ တိုက်ခိုက်သူက `203.0.113.0/25` ကို ကြေညာပါက (`maxLength 24` ထက် ကျော်လွန်နေသောကြောင့်) RPKI ROV က ထိုကြေညာချက်အား **`Invalid`** အဖြစ် သတ်မှတ်ပြီး edge routers များက ချက်ချင်း drop ပစ်လိုက်မည် ဖြစ်သည်။

> [!TIP]
> ### ၃။ BGP Route Leak Prevention (RFC 9234) နှင့် Remotely Triggered Blackhole (RTBH) & Flowspec
>
> - **BGP Open Policy Roles နှင့် OTC (RFC 9234)**:
>   - Multi-homed customer တစ်ဦးသည် Transit ISP A ထံမှ routes များကို ရရှိပြီး Transit ISP B ထံသို့ မတော်တဆ ပြန်လည်ကြေညာမိသည့်အခါ Route leaks များ ဖြစ်ပေါ်ပြီး customer အား မလိုလားအပ်သော transit network ဖြစ်စေသည်။
>   - RFC 9234 သည် **Only to Customer (OTC)** BGP attribute ကို မိတ်ဆက်ခဲ့သည်။ Customer သို့မဟုတ် Peer ဆီသို့ route ကြေညာသည့်အခါ router သည် OTC attribute ကို မိမိကိုယ်ပိုင် ASN အဖြစ် သတ်မှတ်ပေးသည်။ အကယ်၍ customer က ထို route ကို အခြား Provider သို့မဟုတ် Peer ထံ ထပ်ဆင့်ကြေညာပါက လက်ခံရရှိသော router က route ကို drop ပစ်သည်။
>
> - **RTBH (RFC 7999 `65535:666`) နှင့် BGP Flowspec (RFC 8955) နှိုင်းယှဉ်ချက်**:
>   - **RTBH**: သတ်မှတ်ထားသော `/32` IP address ဆီသို့ သွားမည့် **traffic ၁၀၀% လုံးကို** ISP edge တွင် drop ပစ်သည်။ WAN link ပြည့်ကျပ်မှုကို ရပ်တန့်စေသော်လည်း ထို host ဆီသို့ သွားမည့် ပုံမှန် users များ၏ ဝန်ဆောင်မှုကိုပါ ရပ်တန့်သွားစေသည်။
>   - **BGP Flowspec (RFC 8955)**: တိကျသော 5-tuple filtering rules များကို (Source IP, Destination IP, L4 Protocol, TCP Flags, Port Range) provider ၏ hardware ACLs များထဲသို့ တိုက်ရိုက် ကြေညာပေးနိုင်သဖြင့် တိုက်ခိုက်မှု traffic ကိုသာ ရွေးချယ် drop ပစ်ပြီး ပုံမှန် host ဝန်ဆောင်မှုများကို ဆက်လက်ရှင်သန်စေသည်။

---

## စမ်းသပ်ခန်း အပြီးသတ် သိမ်းဆည်းခြင်း (Clean up)

```bash
sudo containerlab destroy -t topology.clab.yml
```
