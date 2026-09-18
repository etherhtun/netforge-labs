# အဖွဲ့လိုက် လေ့ကျင့်သူများအတွက် အမြန်စတင်နည်း (Team Quickstart)

သင်၏ Team Lead သည် containerlab နှင့် vJunos image ပါဝင်သော GCP host တစ်ခုကို ပြင်ဆင်ပြီးဖြစ်ပါက အောက်ပါအတိုင်း ချက်ချင်း စတင်လေ့ကျင့်နိုင်ပါသည်။

---

## Host သို့ SSH ဖြင့် ဝင်ရောက်ခြင်း

```bash
gcloud compute ssh clab-lab --zone=asia-southeast1-b
```
(သင်၏ host ရှိရာ zone အလိုက် ပြောင်းလဲသတ်မှတ်ပါ)

Ubuntu shell သို့ ရောက်ရှိသွားပါမည်။ Containerlab သွင်းထားပြီး ဖြစ်မဖြစ် စစ်ဆေးပါ:
```bash
containerlab version
docker images | grep -i vjunos
```

---

## Lab Repo ကို Clone ပြုလုပ်ခြင်း

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs
```

---

## Lab တစ်ခုကို Deploy ပြုလုပ်ခြင်း

```bash
./scripts/deploy.sh 01-ospf-ibgp
```

ဤ command သည် 2×2 bare fabric (config မပါသေးသော စက်များ) ကို စတင် run ပေးပါမည်။ Nodes များ အပြည့်အဝ တက်လာရန် **၅–၈ မိနစ်ခန့် စောင့်ဆိုင်းပါ**။

အခြား terminal တစ်ခုမှနေ၍ boot တက်နေမှုကို စောင့်ကြည့်နိုင်သည်:
```bash
docker logs -f clab-evpn-lab-spine1
```

---

## သင်ယူလိုသည့် ပုံစံကို ရွေးချယ်ပါ

### နည်းလမ်း ၁ · လက်ဖြင့် ကိုယ်တိုင် ရိုက်နှိပ်လေ့လာခြင်း (အကြံပြုချက်)
Lab လမ်းညွှန်ချက်အတိုင်း လိုက်နာပြီး configuration များကို ကိုယ်တိုင် ရိုက်နှိပ်ပါ။ ဤနည်းသည် စနစ်ကို အမှန်တကယ် ကျွမ်းကျင်စေပါသည်။

၁။ လမ်းညွှန်ချက် အပြည့်အစုံကို ဖွင့်ပါ: [Lab 01 လမ်းညွှန်](../archive/juniper-vxlan-evpn/labs/lab-01-fullmesh.md)
၂။ Node ထဲသို့ SSH ဖြင့် ဝင်ရောက်ပြီး အဆင့်တစ်ခုချင်းစီ၏ config ကို ထည့်သွင်းပါ:
   ```bash
   ssh admin@clab-evpn-lab-leaf1     # password: admin@123
   ```
၃။ အဆင့်တစ်ခုချင်းစီ၏ verify command ကို run ပြီး checkpoint အောင်မြင်ပါက နောက်တစ်ဆင့်သို့ ဆက်သွားပါ။

### နည်းလမ်း ၂ · Config အားလုံးကို တစ်ပြိုင်နက် ထည့်သွင်းခြင်း
ကိုယ်တိုင် မရိုက်ဘဲ အလုပ်လုပ်ပြီးသား config အပြည့်အစုံကို deploy ပြုလုပ်လိုပါက:
```bash
./scripts/switch.sh 01-ospf-ibgp
```

ထို့နောက် လည်ပတ်နေသော fabric ကို စစ်ဆေးလေ့လာပြီး failure modes များကို သိရှိစေရန် break-it လေ့ကျင့်ခန်းများကို စမ်းသပ်ပါ။

---

## Packet Traces များကို Capture လုပ်ခြင်း (စိတ်ကြိုက်)

```bash
./scripts/capture.sh leaf1 eth1 01-underlay-ospf 'ospf'
```

၎င်းသည် `labs/01-ospf-ibgp/pcaps/` ထဲတွင် `.pcap` ဖိုင်အဖြစ် သိမ်းဆည်းပေးမည်ဖြစ်သည်။ ၎င်းကို မိမိ laptop ပေါ်သို့ download ဆွဲယူပြီး Wireshark ဖြင့် ဖွင့်လှစ်ကြည့်ရှုနိုင်ပါသည်။

---

## အစမှ ပြန်လည်စတင်ခြင်း (Reset / Start Over)

```bash
./scripts/reset.sh 01-ospf-ibgp    # topology ကို ဖျက်သိမ်းပြီး အသစ်ပြန် deploy လုပ်ပါမည်
```

---

## အသုံးပြုပြီးဆုံးချိန်တွင်

ကုန်ကျစရိတ် သက်သာစေရန် GCP host ကို ရပ်တန့် (stop) ထားပါ (lab ဒေတာများ မပျက်စီးပါ):
```bash
# မိမိ laptop ပေါ်မှ ရိုက်ရန်:
gcloud compute instances stop clab-lab --zone=asia-southeast1-b
```

နောက်တစ်ကြိမ် ပြန်လည်စတင်လိုပါက:
```bash
gcloud compute instances start clab-lab --zone=asia-southeast1-b
```

---

## မေးခွန်းများ ရှိပါက

- **Lab သဘောတရားများ:** [Study track](../courses/04-evpn/concepts/index.md) ကို ဖတ်ပါ
- **Show command ကိုးကားချက်များ:** [Verification Cheatsheet](../reference/verify-cheatsheet.md)
- **ပြဿနာဖြေရှင်းနည်းများ:** Failure modes များအတွက် lab တစ်ခုချင်းစီရှိ break-it exercises များကို စစ်ဆေးပါ။
