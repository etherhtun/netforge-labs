# Junos EVPN-VXLAN စစ်ဆေးမှု အကိုးအကား (Verification Cheatsheet) {: #junos-evpn-vxlan-verification-cheatsheet }

Lab တိုင်းတွင် ပြန်လည်အသုံးပြုလေ့ရှိသော `show` command များကို အလွှာအလိုက် စုစည်းဖော်ပြထားခြင်း ဖြစ်ပါသည်။

## Underlay {: #underlay }
```
show ospf neighbor
show route <loopback>
ping <remote-lo> source <local-lo>
```

## Overlay (BGP) {: #overlay-bgp }
```
show bgp summary
show bgp neighbor <peer>
```

## EVPN / VXLAN {: #evpn-vxlan }
```
show evpn database
show route table bgp.evpn.0
show ethernet-switching vxlan-tunnel-end-point remote
```

## Data plane {: #data-plane }
```
show ethernet-switching table
show interfaces terse
```

## Config စစ်ဆေးခြင်း (Config inspection) {: #config-inspection }
```
show configuration | display set
show configuration | display set | match <string>
```

> မှတ်ချက် — ပထမဆုံး စစ်ဆေးပြီးစီးပြီးနောက် "ကောင်းမွန်သော output ပုံစံ" များကို ဖြည့်စွက်သွားပါမည်။
