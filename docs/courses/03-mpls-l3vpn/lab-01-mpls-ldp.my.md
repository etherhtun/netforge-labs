# Lab 01 — MPLS + LDP Underlay {: #lab-01-mpls-ldp-underlay }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F (Apple Silicon, OrbStack) ပေါ်တွင် လက်တွေ့ run ထားသော output အစစ်အမှန်များ ဖြစ်ပါသည်။

Provider ကွန်ရက်တစ်ခုပေါ်တွင် customer VPN များကို မသယ်ဆောင်မီ၊ provider ကွန်ရက်ကိုယ်တိုင်သည် label များကို မည်သို့ရွှေ့ပြောင်းရမည်ကို ဦးစွာ သိရှိထားရပါမည်။ ဤ lab သည် ၎င်းအတွက် ဖြစ်သည်: router သုံးလုံး၊ OSPF underlay တစ်ခုနှင့် အပေါ်တွင် label များကို ဖြန့်ဝေပေးသော LDP တို့ ပါဝင်ပါသည်။

**သင်ရရှိလာမည့် ရလဒ်:** Core router (`p1`) ကို ဖြတ်သန်း၍ အချင်းချင်း ချိတ်ဆက်နိုင်ပြီး ၎င်းတို့ကြားတွင် label-switched path (LSP) တစ်ခု အပြည့်အဝ တည်ဆောက်ထားသော edge router နှစ်လုံး (`pe1`, `pe2`)။

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/mpls-l3vpn-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/mpls-l3vpn-lab
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
          docker exec -it clab-mpls-l3vpn-lab-pe1 Cli
          ```

---

## ၁။ Lab တည်ဆောက်ခြင်း (Deploy) {: #1-deploy }

```bash
mkdir -p ~/mpls-lab && cd ~/mpls-lab && cat > topology.clab.yml <<'EOF'
name: ceos-mpls-scratch
topology:
  nodes:
    p1:
      kind: arista_ceos
      image: ceos:4.32.0F
    pe1:
      kind: arista_ceos
      image: ceos:4.32.0F
    pe2:
      kind: arista_ceos
      image: ceos:4.32.0F
  links:
    - endpoints: ["p1:eth1", "pe1:eth1"]
    - endpoints: ["p1:eth2", "pe2:eth1"]
EOF
```

Node တစ်ခုချင်းစီကို တည်ဆောက်ပါ — emulated node ၃ ခုကို တစ်ပြိုင်နက် boot တက်စေခြင်းသည် boot race ပြဿနာကို ဖြစ်စေနိုင်သည်:

```bash
cd ~/mpls-lab && sudo containerlab deploy -t topology.clab.yml --max-workers 1
```

---

## ၂။ ကျန်းမာရေး စစ်ဆေးခြင်း (Health check) — မည်သည့် config မှ မထည့်မီ {: #2-health-check-before-configuring-anything }

```bash
for n in p1 pe1 pe2; do echo "===== $n ====="; docker exec clab-ceos-mpls-scratch-$n Cli -p 15 -c "show interfaces status"; done
```

**✅ အောင်မြင်မှု သတ်မှတ်ချက်:** `Et*` port တိုင်းတွင် type သည် **`EbraTestPhyPort`** ဟု ပြသရပါမည်။

Type **`Unknown`** ဟု ပြသနေသော node သည် boot race တွင် ကျရှုံးခဲ့ခြင်း ဖြစ်သည်။ ဖျက်ပစ်ပါ (destroy)၊ ပြန် deploy ပါ၊ ပြန်စစ်ပါ။ ဤအဆင့်ကို မကျော်ပါနှင့် — ပျက်ယွင်းနေသော node တစ်ခုသည် configuration ကို လက်ခံသော်လည်း adjacency ဘယ်တော့မှ မတည်ဆောက်နိုင်ဘဲ မရှိသော protocol bug ကို လိုက်ရှာနေရတတ်ပါသည်။

---

## ၃။ ပြင်ဆင်သတ်မှတ်ခြင်း (Configure) {: #3-configure }

အောက်ပါ အစိတ်အပိုင်း ၃ ခုကို အဆင့်ဆင့် ထည့်သွင်းရမည်ဖြစ်ပြီး သဘောတရားအရ အစီအစဉ်အတိုင်း ဖြစ်ရန် အရေးကြီးပါသည်:

1. **`ip routing`** — EOS သည် default အားဖြင့် L2 switch ဖြစ်သည်။ ၎င်းမပါဘဲ routed မည်သည့်အရာမှ အလုပ်မလုပ်ပါ။
2. **OSPF** — router တိုင်းအား loopback တိုင်းဆီသို့ လမ်းကြောင်းပေးသည်။ LDP သည် ၎င်းကို ဦးစွာ လိုအပ်သည်။
3. **LDP** — OSPF မှ သိရှိထားပြီးဖြစ်သော prefix များအတွက် label များကို ဖြန့်ဝေပေးသည်။

### p1 (core) {: #p1-core }

```bash
docker exec -i clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
 ip ospf area 0.0.0.0
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.1.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
interface Ethernet2
 no switchport
 no shutdown
 ip address 10.1.2.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 1.1.1.1
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

### pe1 {: #pe1 }

```bash
docker exec -i clab-ceos-mpls-scratch-pe1 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
 ip ospf area 0.0.0.0
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.1.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 2.2.2.2
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

### pe2 {: #pe2 }

```bash
docker exec -i clab-ceos-mpls-scratch-pe2 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
 ip ospf area 0.0.0.0
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.2.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 3.3.3.3
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

!!! warning "Loopback0 ပေါ်တွင် `ip ospf area` ထည့်ရန် မမေ့ပါနှင့်"
    Loopback ပေါ်တွင် IP ပေးပြီး ရပ်လိုက်ရန် လွယ်ကူသည်။ သို့သော် အကယ်၍ loopback သည် OSPF ထဲတွင် မပါဝင်ပါက အခြား router တစ်ခုမှ ၎င်းကို သိရှိမည်မဟုတ်ပါ — ထို့ကြောင့် label တပ်ရန် route မရှိဖြစ်ပြီး LDP သည် ချိတ်ဆက်စရာ (bind) မရှိဘဲ `show mpls route` သည် အလွတ်သာ ပြနေမည်ဖြစ်သည်။ ထိုတစ်ကြောင်းတည်းသော လိုအပ်ချက်သည် MPLS ပျက်စီးနေသကဲ့သို့ ထင်ယောင်ထင်မှား ဖြစ်စေပါသည်။

`Copy completed successfully` ပြသပါက config ရေးသားပြီးစီးခြင်း ဖြစ်သည်။ မည်သည့် output မှ မထွက်ဘဲ ပြီးသွားပါက config မဝင်ခဲ့ခြင်း ဖြစ်သည်။

---

## ၄။ စစ်ဆေးခြင်း (Verify) — အဆင့်တစ်ခုချင်းစီသည် နောက်တစ်ခုအတွက် လိုအပ်ချက်ဖြစ်သည် {: #4-verify }

### အဆင့် ၁ · OSPF Adjacency စစ်ဆေးခြင်း {: #step-1-ospf-adjacency }

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show ip ospf neighbor"
```

```
Neighbor ID     Instance VRF      Pri State      Dead Time   Address     Interface
3.3.3.3         1        default  0   FULL       00:00:34    10.1.2.2    Ethernet2
2.2.2.2         1        default  0   FULL       00:00:33    10.1.1.2    Ethernet1
```

**✅ အောင်မြင်မှု သတ်မှတ်ချက်:** Neighbor နှစ်ခုလုံးတွင် **`FULL`** ဟု ပြသရပါမည်။

!!! tip "`show` command များကို တစ်ကြိမ်လျှင် တစ်ခုစီသာ run ပါ"
    cEOS တွင် `-c` flag များကို တန်းစီတွဲသုံးပါက **နောက်ဆုံး** command ၏ output ကိုသာ ပြသတတ်ပြီး ကောင်းမွန်နေသော protocol ကို အလုပ်မလုပ်သလို ထင်မှားစေနိုင်ပါသည်။

### အဆင့် ၂ · Loopback များ ရောက်ရှိနိုင်မှု (Reachable) {: #step-2-loopbacks-reachable }

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "show ip route"
```

```
 O        1.1.1.1/32 [110/20]
           via 10.1.1.1, Ethernet1
 C        2.2.2.2/32
           directly connected, Loopback0
 O        3.3.3.3/32 [110/30]
           via 10.1.1.1, Ethernet1
```

**✅ အောင်မြင်မှု သတ်မှတ်ချက်:** pe1 တွင် **`3.3.3.3/32`** ဆီသို့ `O` (OSPF) route ရှိရပါမည်။ မရှိပါက loopback သည် OSPF ထဲ မရောက်သေးပါ — ပြန်စစ်ဆေးပါ။

### အဆင့် ၃ · LDP Session အခြေအနေ {: #step-3-ldp-session }

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls ldp neighbor"
```

```
Peer LDP ID: 2.2.2.2:0; Local LDP ID: 1.1.1.1:0
   TCP Connection: 2.2.2.2:42337 - 1.1.1.1:646
   State: oper; Msgs sent/rcvd: 23/24; downstream unsolicited
```

**✅ အောင်မြင်မှု သတ်မှတ်ချက်:** Peer နှစ်ခုလုံးနှင့် **`State: oper`** ဖြစ်နေရပါမည်။ LDP သည် TCP/646 ပေါ်တွင် အလုပ်လုပ်ပြီး routed path ပေါ်မှ peer ပြုလုပ်သောကြောင့် အဆင့် ၁ အောင်မြင်မှသာ ၎င်းသည် အလုပ်လုပ်နိုင်ပါမည်။

### အဆင့် ၄ · Label များ ပေးပို့ဖြန့်ဝေမှု (Distributed) {: #step-4-labels-distributed }

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "show mpls ldp bindings"
```

```
1.1.1.1/32
   Local binding:  Label: 100000
   Remote binding: Peer ID: 1.1.1.1:0, Label: imp-null
2.2.2.2/32
   Local binding:  Label: imp-null
   Remote binding: Peer ID: 1.1.1.1:0, Label: 100000
3.3.3.3/32
   Local binding:  Label: 100001
   Remote binding: Peer ID: 1.1.1.1:0, Label: 100001
```

ဤ output ကို သေချာစွာ လေ့လာပါ — ၎င်းသည် ဤ lab ၏ အဓိက သဘောတရား ဖြစ်ပါသည်:

- **`3.3.3.3/32` → remote binding `100001`** ဆိုသည်မှာ p1 က pe1 အား *"pe2 ၏ loopback သို့ ရောက်ရှိရန် ငါ့ဆီသို့ label 100001 တပ်ပြီး ပေးပို့ပါ"* ဟု ပြောခြင်း ဖြစ်သည်။
- **`imp-null`** ("implicit null") ဆိုသည်မှာ router က *"ငါသည် နောက်ဆုံး hop ဖြစ်သည် — ငါ့ဆီ မပို့မီ label ကို ဖြုတ်ပစ်ပါ (pop)"* ဟု ပြောခြင်း ဖြစ်သည်။ ၎င်းသည် **Penultimate-Hop Popping (PHP)** ဖြစ်သည်: နောက်ဆုံး router သည် lookup နှစ်ကြိမ် ပြုလုပ်စရာမလိုဘဲ သက်သာစေရန်အတွက် နောက်ဆုံးမတိုင်မီ router က label ကို ကြိုတင်ဖြုတ်ပေးခြင်း ဖြစ်သည်။

### အဆင့် ၅ · Forwarding State သတ်မှတ်ပြီးစီးမှု {: #step-5-forwarding-state-programmed }

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls route"
```

```
MPLS forwarding table (Label [metric] Vias) - 2 routes
 100000  A[1]
                via M, 10.1.1.2, pop
                    EgressACL: apply
                    directly connected, Ethernet1
                    aa:c1:ab:9e:37:05, vlan 1006
 100001  A[1]
                via M, 10.1.2.2, pop
                    EgressACL: apply
                    directly connected, Ethernet2
                    aa:c1:ab:2e:55:ee, vlan 1007
```

**✅ အောင်မြင်မှု သတ်မှတ်ချက်:** p1 တွင် **resolved next-hop MAC address** ပါဝင်သော label entry များကို ပြသရပါမည်။

ထို MAC address သည် အလွန်အရေးကြီးပါသည်။ ၎င်းသည် *"control plane တွင် နံပါတ်တစ်ခုကို သဘောတူရုံ သက်သက်"* နှင့် *"forwarding path ကို အမှန်တကယ် program ထည့်သွင်းထားပြီး packet များကို ရွှေ့ပြောင်းရန် အသင့်ဖြစ်နေခြင်း"* အကြား ခြားနားချက် ဖြစ်ပါသည်။

---

## ၅။ ဤအရာက မည်သည့်အရာကို သက်သေပြသနည်း — မည်သည့်အရာကို သက်သေမပြနိုင်သနည်း {: #5-what-this-does-and-doesnt-prove }

pe1 မှ pe2 ၏ loopback ကို ping စမ်းသပ်ကြည့်ပါ:

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "ping 3.3.3.3 source 2.2.2.2"
```

```
5 packets transmitted, 5 received, 0% packet loss, time 4ms
```

ယခုအခါ trace လိုက်ကြည့်ပါ:

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "traceroute 3.3.3.3 source 2.2.2.2"
```

```
 1  10.1.1.1 (10.1.1.1)  0.198 ms
 2  3.3.3.3 (3.3.3.3)  1.858 ms
```

**ရိုးရိုး IP hop များသာ ဖြစ်ပြီး label များ မပါရှိပါ။** Ping သည် အောင်မြင်ခဲ့သော်လည်း — သင်ယခုလေးတင် တည်ဆောက်ခဲ့သော LSP လမ်းကြောင်းကို ဘယ်တော့မှ မထိတွေ့ခဲ့ပါ။

!!! note "ဤသည်မှာ ဤ lab ၏ အရေးအကြီးဆုံး သဘောတရားဖြစ်သည်"
    LDP သည် label-switched path ကို **တည်ဆောက်ပေးသည်**။ သို့သော် ၎င်းကို အသုံးပြုရန် **အတင်းအကျပ် မလုပ်ပါ**။ သမားရိုးကျ IP traffic သည် သမားရိုးကျ IP route table ကိုသာ လိုက်နာသည်၊ အကြောင်းမှာ ၎င်းတွင် ကောင်းမွန်သော route ရှိပြီးသား ဖြစ်သောကြောင့် ဖြစ်သည်။

    Labels များကို မဖြစ်မနေ လိုအပ်သည့်အခါမှသာ အသုံးပြုသည် — global table ထဲတွင် route မရှိသော VPN သို့မဟုတ် IP လုံးဝမဟုတ်သော pseudowire ပေါ်မှ traffic များအတွက် ဖြစ်သည်။ ၎င်းကို Lab 02 တွင် ဆက်လက်လေ့လာပါမည်။

    ထို့ကြောင့် ဤနေရာတွင် ping အောင်မြင်ရုံမျှဖြင့် MPLS forwarding အလုပ်လုပ်သည်ဟု **သက်သေမပြနိုင်ပါ**။ Traffic ပေါ်တွင် label မဖြစ်မနေ တပ်ဆင်ရသည့်အချိန်အထိ အောင်မြင်နေသယောင် ထင်မှားစေတတ်သော ထောင်ချောက်ကို သတိပြုပါ။

---

## ၆။ စနစ်ပျက်ယွင်းအောင် ပြုလုပ်၍ လေ့လာခြင်း (Break & observe) {: #6-break-observe }

pe2 ၏ loopback ကို OSPF ထဲမှ ထုတ်လိုက်ပါ:

```bash
docker exec -i clab-ceos-mpls-scratch-pe2 Cli -p 15 <<'EOF'
enable
configure
interface Loopback0
 no ip ospf area 0.0.0.0
end
EOF
```

ထို့နောက် pe1 ပေါ်တွင် ကြည့်ပါ:

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "show mpls route"
```

`3.3.3.3/32` အတွက် label binding ပျောက်ကွယ်သွားပြီး ping သည် 100% ကျရှုံးပါတော့သည်။

**အကြောင်းရင်း:** LDP သည် routing table ထဲတွင် ရှိသော prefix အတွက်သာ label ကို bind လုပ်နိုင်ပါသည်။ Route မရှိလျှင် label မရှိပါ။ ဤအခြေအနေကို တမင်တကာ စမ်းသပ်ကြည့်သင့်ပါသည်၊ အဘယ်ကြောင့်ဆိုသော် ဖြစ်ပေါ်လာသော လက္ခဏာများ (MPLS table အလွတ်ဖြစ်ခြင်း၊ packet အားလုံးကျခြင်း) သည် MPLS data plane ပျက်စီးနေသကဲ့သို့ အတိအကျ ထင်ရသောကြောင့် ဖြစ်ပါသည်။

မူလအတိုင်း ပြန်ပြင်ပါ:

```bash
docker exec -i clab-ceos-mpls-scratch-pe2 Cli -p 15 <<'EOF'
enable
configure
interface Loopback0
 ip ospf area 0.0.0.0
end
write memory
EOF
```

---

## ၇။ ပြန်လည်ဖျက်သိမ်းခြင်း (Teardown) {: #7-teardown }

```bash
sudo containerlab destroy -t ~/mpls-lab/topology.clab.yml --cleanup
```

---

## ပြဿနာဖြေရှင်းခြင်း (Troubleshooting) {: #troubleshooting }

| လက္ခဏာ | အကြောင်းရင်း | ဖြေရှင်းချက် |
|---|---|---|
| `Connected 0 interfaces out of N` အမြဲဖြစ်နေခြင်း | endpoints များကို `eth1` အစား `Ethernet1` ဟု နာမည်ပေးထားခြင်း | topology ပြင်ပါ၊ destroy + redeploy လုပ်ပါ |
| `docker exec … Cli` → *executable file not found* | EOS ဘယ်တော့မှ boot မတက်ခဲ့ခြင်း — image ပြဿနာမဟုတ်ပါ | wiring ပြင်ပါ၊ redeploy လုပ်ပါ |
| Heredoc သည် ချက်ချင်းပြီးသွားပြီး config မဝင်ခြင်း | `docker exec` ပေါ်တွင် `-i` flag ကျန်ခဲ့ခြင်း | `-i` ထည့်ပါ |
| Port type `Unknown` ပြနေခြင်း | emulation အောက်တွင် boot race ဖြစ်ခြင်း | `--max-workers 1` ဖြင့် destroy + redeploy လုပ်ပါ။ **`docker restart` ဘယ်တော့မှ မလုပ်ပါနှင့်** — veth များကို ပျက်စီးစေပြီး container ထဲတွင် `reload` ကို ထောက်ပံ့မထားပါ |
| *LDP is operationally down: TransportAddr interface not configured* | ရိုးရိုး `router-id 1.1.1.1` သုံးထားပြီး source interface မပါခြင်း | `router-id interface Loopback0` + `transport-address interface Loopback0` ထည့်ပါ |
| *Change will take effect on the next agent start* | LdpAgent မ run သေးခြင်း | ပြန်စတင်ရန် `agent LdpAgent terminate` လုပ်ပါ |
| OSPF ဘယ်တော့မှ `FULL` မဖြစ်ခြင်း | port သည် L2 အဖြစ်သာ ရှိနေသေးခြင်း | routed port များပေါ်တွင် `no switchport` ထည့်ပါ |
| `show ip ospf neighbor` အလွတ်ဖြစ်နေသော်လည်း adjacency ရှိနေခြင်း | `-c` flag များစွာ သုံးထားသဖြင့် နောက်ဆုံး output သာ ပြခြင်း | command တစ်ခုလျှင် show တစ်ခုသာ run ပါ |
| `show mpls route` အလွတ်ဖြစ်ပြီး ping 100% loss ဖြစ်ခြင်း | loopback သည် OSPF ထဲ မပါဝင်ခြင်း — **MPLS ချို့ယွင်းချက် မဟုတ်ပါ** | `interface Loopback0` အောက်တွင် `ip ospf area 0.0.0.0` ထည့်ပါ |

---

## အင်တာဗျူး မေးခွန်းများ {: #interview-questions }

??? question "LDP တက်နေပြီး label များလည်း သတ်မှတ်ထားသော်လည်း traceroute တွင် label များ မတွေ့ရပါ။ တစ်ခုခု ချို့ယွင်းနေပါသလား။"
    မဟုတ်ပါ။ LDP သည် LSP ကို တည်ဆောက်ပေးခြင်းသာ ဖြစ်ပြီး traffic ကို အတင်းအကျပ် ထည့်သွင်းခြင်း မရှိပါ။ သမားရိုးကျ IP traffic သည် valid route ရှိပြီးသားဖြစ်၍ IP route table အတိုင်းသာ သွားပါသည်။ Labels များကို အခြားရွေးချယ်စရာ မရှိသည့်အခါမှသာ သုံးသည် — global table ထဲတွင် မရှိသော VPN route များ သို့မဟုတ် pseudowire ပေါ်ရှိ IP မဟုတ်သော payload များ ဖြစ်သည်။

??? question "LDP binding တွင် `imp-null` သည် အဘယ်အရာကို ဆိုလိုသနည်း၊ ၎င်းသည် အဘယ်ကြောင့် ရှိနေသနည်း။"
    Implicit null သည် အထက်ရှိ router အား **forward မလုပ်မီ label ကို ကြိုတင်ဖြုတ်ပစ်ရန် (pop)** ညွှန်ကြားခြင်း ဖြစ်သည် — penultimate-hop popping (PHP)။ ၎င်းမရှိပါက နောက်ဆုံး router သည် label တပ်ထားသော packet ကို လက်ခံရရှိပြီး label ကို အရင်ဖြုတ်ရမည်၊ ပြီးနောက် route ရန်အတွက် ဒုတိယအကြိမ် lookup ထပ်လုပ်ရမည် ဖြစ်သည်။ PHP သည် ထိုလုပ်ငန်းကို တစ်ဆင့်စော၍ ပြုလုပ်ပေးသဖြင့် နောက်ဆုံး router သည် လုပ်ငန်းနှစ်ခု လုပ်မည့်အစား single IP lookup တစ်ခုတည်းသာ လုပ်ဆောင်ရန် လိုအပ်တော့သည်။

??? question "LDP အလုပ်မလုပ်မီ OSPF သည် အဘယ်ကြောင့် ဦးစွာ converge ဖြစ်ရမည်နည်း။"
    LDP သည် neighbor ၏ transport address ဆီသို့ TCP/646 ဖြင့် peer ပြုလုပ်သောကြောင့် ဦးစွာ IP reachability လိုအပ်ပါသည်။ ထို့အပြင် LDP သည် **routing table ထဲရှိ prefix များနှင့်သာ label များကို ချိတ်ဆက် (bind)** ပေးခြင်းဖြစ်သည် — အကယ်၍ OSPF က prefix ကို မကြေညာရသေးပါက label တပ်စရာ prefix မရှိနိုင်ပါ။

??? question "Loopback တစ်ခုတွင် IP ရှိသော်လည်း `ip ospf area` မပါရှိပါ။ မည်သည့်အရာ ချို့ယွင်းသွားမည်နည်း၊ ၎င်းကို မည်သို့ ရိပ်မိနိုင်မည်နည်း။"
    မည်သည့် router ကမျှ ထို prefix ကို သိရှိမည်မဟုတ်သောကြောင့် route မရှိဘဲ label binding လည်း မရှိဖြစ်သွားမည်။ Packet 100% loss ဖြစ်မည်ဖြစ်သလို MPLS table လည်း အလွတ်ဖြစ်နေမည် — ၎င်းသည် MPLS data plane ပျက်စီးနေသကဲ့သို့ ပုံစံတူ ဖြစ်စေသည်။ သတိထားရမည့် အချက်မှာ **သမားရိုးကျ IP စမ်းသပ်မှုပါ ကျရှုံးသွားခြင်း** ဖြစ်သည်: အကယ်၍ underlay ကောင်းမွန်နေပါက loopback ping သည် label ရှိသည်ဖြစ်စေ မရှိသည်ဖြစ်စေ အောင်မြင်ရမည်ဖြစ်သည်။ ထို့ကြောင့် total loss ဖြစ်နေခြင်းသည် MPLS ကြောင့် မဟုတ်ဘဲ underlay ကြောင့်ဖြစ်ကြောင်း ညွှန်ပြနေသည်။

??? question "`show mpls route` တွင် resolved next-hop MAC address ပါရှိရန် အဘယ်ကြောင့် အရေးကြီးသနည်း။"
    ၎င်းသည် control plane နှင့် data plane ကြား မျဉ်းခြားတစ်ခု ဖြစ်သည်။ Label bindings များသည် router များအကြား နံပါတ်များကို သဘောတူညီပြီးကြောင်း သက်သေပြသည်။ Resolved adjacency (MAC, VLAN, egress interface) ပါရှိခြင်းကသာ forwarding entry ကို ASIC ထဲတွင် အမှန်တကယ် program ထည့်သွင်းထားပြီး packet များကို ရွှေ့ပြောင်းနိုင်စွမ်းရှိကြောင်း အတည်ပြုပေးသည်။

---

**နောက်ထပ်:** Lab 02 တွင် traffic ပေါ်တွင် label မဖြစ်မနေ တပ်ဆင်ရစေမည့် VRF နှင့် VPNv4 တို့ကို ထည့်သွင်းမည်ဖြစ်ပြီး MPLS forwarding သည် အစအဆုံး အမှန်တကယ် အလုပ်လုပ်ကြောင်း အတည်ပြုစမ်းသပ်ပါမည်။
