# စစ်ဆေးအတည်ပြုမှု လုပ်ငန်းစဉ်မှတ်တမ်း (Validation Runbook) {: #validation-runbook }

တကယ့် vJunos fabric ပေါ်တွင် **မူကြမ်း (draft)** lab များကို စနစ်တကျ စမ်းသပ်စစ်ဆေးပြီး တွေ့ရှိချက်များကို မှတ်တမ်းတင်နိုင်မည့် နည်းလမ်းဖြစ်ပါသည်။ အောက်ပါ အစီအစဉ်အတိုင်း စမ်းသပ်ပါ — နောက်ပိုင်း lab များသည် ရှေ့ပိုင်း lab များ၏ pattern များကို **အမွေဆက်ခံ (inherit)** ထားသောကြောင့် အခြေခံကို ပြင်ဆင်လိုက်ခြင်းက အန္တရာယ်အများစုကို ကြိုတင်ဖယ်ရှားပေးပါသည်။

> လက်ရှိတွင် **Lab 01** ကိုသာ စမ်းသပ်အတည်ပြုပြီးဖြစ်သည်။ Labs 02–05 တို့သည် မူကြမ်းများ ဖြစ်ကြသည်။ Lab တစ်ခုစီ မပြောင်းမီ RAM သက်သာစေရန် `destroy` ဦးစွာ ပြုလုပ်ပါ။

## အသုံးပြုနည်း {: #how-to-use-this }
Lab တစ်ခုစီအတွက်: deploy → apply → စစ်ဆေးချက်များ run ပါ → **PASS/FAIL** မှတ်တမ်းတင်ပြီး commit error သို့မဟုတ် မမျှော်လင့်သော `show` output များကို သိမ်းဆည်းပါ။ တွေ့ရှိချက်များကို ပေးပို့ပါက စနစ်တကျ ပြင်ဆင်ပေးပါမည်။ **⚠️ ဖြစ်နိုင်ခြေရှိသော ပြင်ဆင်ချက်များ (likely-fix)** သည် ပြဿနာများ အများဆုံး ပုန်းအောင်းနေတတ်သော နေရာများ ဖြစ်သည်။

---

## အစီအစဉ်နှင့် အမွေဆက်ခံမှု (အထက်မှ အောက်သို့ စမ်းသပ်ရန်) {: #order-inheritance }

| အစီအစဉ် | Lab | မိတ်ဆက်ပေးသည့် အကြောင်းအရာ | အမွေဆက်ခံမည့် နေရာ |
|-------|-----|------------|--------------|
| ၁ | **02 · RR** | spine route-reflectors | 03, 04, 05, (eBGP, L3out, MS) |
| ၂ | **03 · L3VNI** | anycast IRB, L3VNI, Type-5 | 04 |
| ၃ | **04 · Multi-tenancy** | 2nd VRF, route leak | — |
| ၄ | **05 · ESI** | Ethernet Segment, LACP bond | — |

02 နှင့် 03 ကို အရင်ဆုံး စစ်ဆေးပါ — အဆိုပါ pattern များ မှန်ကန်ပါက 04/05 သည် အလွယ်တကူ ပြီးမြောက်နိုင်ပါသည်။

---

## Lab 02 — Route reflectors {: #lab-02-route-reflectors }
```bash
./scripts/reset.sh 02-ospf-ibgp-rr && ./scripts/apply.sh 02-ospf-ibgp-rr all
```
စစ်ဆေးရန် အချက်များ:
- [ ] leaf1 `show bgp summary` → **Spines နှစ်ခုလုံးနှင့်** `Establ` ဖြစ်ရမည်
- [ ] spine1 `show bgp summary` → **Leaves နှစ်ခုလုံးနှင့်** `Establ` ဖြစ်ရမည်
- [ ] ⭐ **spine1 `show route table bgp.evpn.0` → route များ တည်ရှိနေရမည်** (RR က retain/reflect လုပ်သည်)
- [ ] leaf1 `show route table bgp.evpn.0 extensive | match "Protocol next hop"` → Spine မဟုတ်ဘဲ **Leaf** loopback ဖြစ်ရမည်
- [ ] host1 → host2 ping (host setup ပြီးနောက်) → 0% loss ဖြစ်ရမည်

⚠️ **ဖြစ်နိုင်ခြေရှိသော ပြင်ဆင်ချက်:** အကယ်၍ Spine ၏ `bgp.evpn.0` သည် **အလွတ်ဖြစ်နေပါက**၊ RR သည် ၎င်းတွင် RT မရှိသော route များကို drop ပစ်နေခြင်း ဖြစ်နိုင်သည် → Spine များပေါ်တွင် keep-all/retain knob လိုအပ်နိုင်သည်။

## Lab 03 — L3VNI + anycast gateway {: #lab-03-l3vni-anycast-gateway }
```bash
./scripts/destroy.sh 02-ospf-ibgp-rr ; ./scripts/deploy.sh 03-l3vni-anycast && ./scripts/apply.sh 03-l3vni-anycast all
```
စစ်ဆေးရန် အချက်များ:
- [ ] node အားလုံးတွင် `apply.sh` သည် **error လုံးဝမရှိဘဲ** commit ဖြစ်ရမည် (irb/routing-instance syntax ကို သတိပြုပါ)
- [ ] leaf1 `show route table TENANT.evpn.0` → leaf2 ထံမှ `10.100.20.0/24` အတွက် **Type-5** (`5:`) route ပေါ်လာရမည်
- [ ] leaf1 `show route table TENANT.inet.0 10.100.20.0/24` → L3VNI မှတစ်ဆင့် တည်ရှိနေရမည်
- [ ] host1 (VLAN100) → host2 (VLAN200) ping → အောင်မြင်ရမည်၊ **ttl လျော့သွားရမည်** (routed ဖြစ်သွားသည်)

⚠️ **ဖြစ်နိုင်ခြေရှိသော ပြင်ဆင်ချက်:** L3VNI ကို `switch-options extended-vni-list` တွင် ထည့်သွင်းရန် လိုအပ်နိုင်သည် (`50000` ထည့်ပါ)၊ `virtual-gateway-address` သည် `virtual-gateway-v4-mac` လိုအပ်နိုင်သည်၊ VRF သည် `vrf-table-label` လိုအပ်နိုင်သည်။ `show evpn instance` နှင့် commit error များကို ကူးယူစစ်ဆေးပါ။

## Lab 04 — Multi-tenancy {: #lab-04-multi-tenancy }
```bash
./scripts/destroy.sh 03-l3vni-anycast ; ./scripts/deploy.sh 04-multitenancy && ./scripts/apply.sh 04-multitenancy all
```
စစ်ဆေးရန် အချက်များ:
- [ ] သီးခြားခွဲထုတ်မှု: host1 (Tenant-A) → host2 (Tenant-B) ping သည် **မရရှိရပါ (FAIL)** (မှန်ကန်သော အပြုအမူ)
- [ ] leaf1 `show route table TENANT-A.inet.0` → Tenant-A subnet များသာ ပါရှိရမည် (`10.100.30.0/24` မပါရှိရပါ)
- [ ] လမ်းညွှန်ပါ leak policy ကို ထည့်သွင်းပြီးနောက်: ping သည် **အောင်မြင်ရမည် (SUCCEED)**၊ route လည်း ပေါ်လာရမည်

⚠️ **ဖြစ်နိုင်ခြေရှိသော ပြင်ဆင်ချက်:** `vrf-import` policy နှင့် default `vrf-target` import အကြား ဆက်သွယ်မှု — နှစ်ခုလုံး လိုအပ်နိုင်သည်၊ သို့မဟုတ် local RT အတွက်ပါ explicit import term ထည့်ရန် လိုအပ်နိုင်သည်။

## Lab 05 — ESI multihoming {: #lab-05-esi-multihoming }
```bash
./scripts/destroy.sh 04-multitenancy ; ./scripts/deploy.sh 05-esi && ./scripts/apply.sh 05-esi all
```
စစ်ဆေးရန် အချက်များ:
- [ ] `apply.sh` သန့်ရှင်းစွာ commit ဖြစ်ရမည် (`ae0` / `chassis aggregated-devices` ကို သတိပြုပါ)
- [ ] host1 bond တက်ရမည်: `docker exec clab-evpn-esi-host1 cat /proc/net/bonding/bond0 | head -5` → 802.3ad, slave နှစ်ခုလုံး up ဖြစ်ရမည်
- [ ] leaf နှစ်ခုလုံး `show evpn ethernet-segment` → တူညီသော ESI, `all-active`, DF ရွေးချယ်ပြီး ဖြစ်ရမည်
- [ ] host2 → host1 ping ရမည်; **uplink တစ်ခုကို ဖြတ်တောက်ကြည့်ပါ** (leaf1 တွင် `deactivate interfaces ge-0/0/2`) → ping မပြတ်ဘဲ ဆက်သွားရမည်

⚠️ **ဖြစ်နိုင်ခြေရှိသော ပြင်ဆင်ချက်:** `ae0` အတွက် `chassis aggregated-devices ethernet device-count ≥1` လိုအပ်သည်; sysfs မှတစ်ဆင့် host bond mode သတ်မှတ်မှု; DF timing။

---

## တွေ့ရှိချက် ပုံစံခွက် (Findings template) {: #findings-template }

```
LAB 02: PASS / FAIL
  - spine bgp.evpn.0 has routes? Y/N
  - host ping: ___
  - errors/output: ___
LAB 03: PASS / FAIL
  - Type-5 route present? Y/N
  - inter-subnet ping: ___
  - errors: ___
LAB 04: ...
LAB 05: ...
```
အဆိုပါ အချက်အလက်များနှင့် commit error များ သို့မဟုတ် `show` output များကို မှတ်တမ်းတင်ကာ မူကြမ်းများကို အတည်ပြုပြီး lab များအဖြစ် အသွင်ပြောင်းလဲနိုင်ပါသည်။
