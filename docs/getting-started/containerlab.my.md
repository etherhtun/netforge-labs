# Host Setup 2 — Docker, containerlab, နှင့် vJunos Image

ဤနေရာရှိ လုပ်ဆောင်ချက်များအားလုံးကို **GCP VM ပေါ်တွင်** run ရန် ဖြစ်ပါသည် ([host setup 1](cloud-vm.md) မှ SSH ဖြင့် ဝင်ရောက်ပြီးနောက်)။ ဤအဆင့်ပြီးဆုံးချိန်တွင် containerlab ကို install ပြုလုပ်ပြီးဖြစ်မည်ဖြစ်ပြီး `topology.clab.yml` က ညွှန်းဆိုထားသော boot တက်နိုင်သည့် `vJunos-switch` image တစ်ခု အသင့်ရှိနေမည် ဖြစ်ပါသည်။

အဓိက ဂရုတစိုက် ပြုလုပ်ရမည့် အဆင့်မှာ အဆင့် (၄) ဖြစ်ပါသည် — vJunos-switch သည် raw VM disk အဖြစ် ထွက်ရှိပြီး ၎င်းကို containerlab run နိုင်စေရန် **vrnetlab** ဖြင့် container image တစ်ခုအဖြစ် wrap လုပ်ပေးရမည် ဖြစ်ပါသည်။ ကျန်ရှိသော အဆင့်များမှာ ရိုးရှင်းပါသည်။

---

## ၁။ Docker ကို Install ပြုလုပ်ခြင်း

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
```
> `usermod` ပြီးနောက် သင်၏ shell သည် `docker` group ကို သိရှိစေရန် **log out ပြုလုပ်ပြီး ပြန်လည်ဝင်ရောက်ပါ** (သို့မဟုတ် `newgrp docker` ကို run ပါ) — သို့မဟုတ်ပါက `docker` command တိုင်းတွင် `sudo` ခံရိုက်နေရပါမည်။ အတည်ပြုရန်:
> ```bash
> docker run --rm hello-world     # "Hello from Docker!" ဟု ပြသရမည်
> ```

## ၂။ Containerlab ကို Install ပြုလုပ်ခြင်း

```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
containerlab version
```

## ၃။ Repo Scripts များအတွက် လိုအပ်သော Tools များကို သွင်းခြင်း

```bash
sudo apt update && sudo apt install -y sshpass tcpdump make git
```
- `sshpass` — `switch.sh` က SSH မှတစ်ဆင့် configs များကို ပို့ဆောင်ရာတွင် သုံးသည်
- `tcpdump` — `capture.sh` က `.pcap` packet capture ပြုလုပ်ရာတွင် သုံးသည်
- `make` / `git` — vJunos image ကို build ပြုလုပ်ရာတွင် လိုအပ်သည်

## ၄။ vJunos-switch Image ကို Build ပြုလုပ်ခြင်း (vrnetlab)

vJunos-switch ကို Juniper ဝဘ်ဆိုက်မှ အခမဲ့ ဒေါင်းလုဒ်ရယူနိုင်ပါသည် (**အကောင့်တစ်ခု လိုအပ်သည်**)။ ၎င်းသည် `.qcow2` VM disk ဖိုင်ဖြစ်ပြီး vrnetlab က containerlab run နိုင်သော Docker image အဖြစ် ပြောင်းလဲတည်ဆောက်ပေးပါသည်။

> ⚠️ ကျွန်ုပ်တို့ လိုအပ်သည်မှာ **vJunos-switch** (L2 / EVPN-VXLAN switching) ဖြစ်ပြီး vJunosEvolved (routing/PTX) *မဟုတ်ပါ*။ Switch image ကို ရွေးချယ်ဒေါင်းလုဒ်ဆွဲရန် သတိပြုပါ။

### ၄က။ Image ဖိုင်ကို VM ပေါ်သို့ ပို့ဆောင်ခြင်း
Juniper support site မှ `.qcow2` ဖိုင်ကို မိမိ laptop ပေါ်သို့ ဦးစွာ download ရယူပြီး VM ပေါ်သို့ copy ကူးတင်ပါ:
```bash
# မိမိ laptop ပေါ်မှ ရိုက်ရန်:
gcloud compute scp ~/Downloads/vJunos-switch-23.2R1.14.qcow2 \
    clab-lab:~/ --zone=asia-southeast1-b
```
> 🔒 `.qcow2` ဖိုင်သည် လိုင်စင်ပါဝင်သဖြင့် VM ပေါ်တွင်သာ ထားရှိပါ။ Git ထဲသို့ မတော်တဆ မရောက်စေရန် `.gitignore` ထဲတွင် ထည့်သွင်းထားပြီး ဖြစ်သည်။

### ၄ခ။ Containerlab သုံးသော vrnetlab fork ကို Clone လုပ်ခြင်း
```bash
git clone https://github.com/hellt/vrnetlab.git
cd vrnetlab
```
> လက်ရှိ Juniper build recipes များ ပါဝင်သော **`hellt/vrnetlab`** fork ကို အသုံးပြုပါ။

### ၄ဂ။ Image ဖိုင်ကို ထည့်သွင်းပြီး Build လုပ်ခြင်း
`23.2R1` release တွင် directory အမည်မှာ **`vjunosswitch`** ဖြစ်ပါသည်:
```bash
cp ~/vJunos-switch-23.2R1.14.qcow2 juniper/vjunosswitch/
cd juniper/vjunosswitch
make
```
`make` သည် VM ကို တစ်ကြိမ် boot တက်စေကာ defaults များကို သတ်မှတ်ပြီး Docker image အဖြစ် ထုတ်လုပ်ပေးမည် ဖြစ်ပါသည်။

### ၄ဃ။ တိကျသော Image Tag ကို ရယူခြင်း
```bash
docker images | grep -i vjunos
```
`23.2R1.14` တွင် အောက်ပါအတိုင်း ပြသမည်ဖြစ်ပါသည်:
```
vrnetlab/juniper_vjunos-switch   23.2R1.14   <id>   7.27GB
```
**`REPOSITORY:TAG`** (`vrnetlab/juniper_vjunos-switch:23.2R1.14`) ကို သတိပြုမှတ်သားထားပါ။

## ၅။ Topology ဖိုင်တွင် မိမိ၏ Image ကို ညွှန်ပြခြင်း

Lab ၏ `topology.clab.yml` သည် ဤ default tag အတိုင်း အတိအကျ သတ်မှတ်ထားပြီး ဖြစ်ပါသည် — အကယ်၍ `23.2R1.14` ကို build ခဲ့ပါက **မည်သည့်အရာမှ ပြင်ဆင်ရန် မလိုပါ။** အောက်ပါ command ဖြင့် စစ်ဆေးပါ:
```bash
grep image labs/01-ospf-ibgp/topology.clab.yml
# → vrnetlab/juniper_vjunos-switch:23.2R1.14
```
အကယ်၍ သင်၏ tag သည် Junos version ကွဲပြားနေပါက `image:` စာကြောင်းကို ကိုက်ညီအောင် ပြင်ဆင်ပါ:
```yaml
  kinds:
    juniper_vjunosswitch:                       # vJunos-switch အတွက် containerlab kind
      image: vrnetlab/juniper_vjunos-switch:23.2R1.14   # ← အဆင့် ၄ဃ မှ သင်၏ tag
```

## ၆။ Lab Repo ကို Clone ပြုလုပ်ခြင်း

Image build ပြုလုပ်ခြင်းကို **vrnetlab** repo အတွင်း ပြုလုပ်ခဲ့ခြင်း ဖြစ်သည်။ လက်တွေ့ labs များသည် **သီးခြား** repo တစ်ခုတွင် တည်ရှိပါသည်:
```bash
cd ~
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs
ls labs/                    # → 01-ospf-ibgp
```
အောက်ပါ `./scripts/*` နှင့် `labs/*` commands အားလုံးကို **ဤ directory ထဲမှ** run ရန် ဖြစ်ပါသည်။

## ၇။ စမ်းသပ်မောင်းနှင်ခြင်း (Smoke Test)

Repo root (`~/netforge-labs`) မှ run ပါ:
```bash
./scripts/deploy.sh 01-ospf-ibgp
```
ပထမဆုံးအကြိမ် boot တက်ခြင်းသည် အနည်းငယ် နှေးကွေးနိုင်ပါသည် — **vJunos node တစ်ခုလျှင် ~၅–၈ မိနစ်ခန့်** ကြာမြင့်မည်။ Node တစ်ခု boot တက်နေမှုကို ကြည့်ရှုရန်:
```bash
docker logs -f clab-evpn-lab-spine1
```
ပြီးဆုံးပါက lab အခြေအနေကို စစ်ဆေးပြီး node ထဲသို့ SSH ဖြင့် ဝင်ရောက်ပါ:
```bash
containerlab inspect -t labs/01-ospf-ibgp/topology.clab.yml
ssh admin@clab-evpn-lab-spine1        # ပထမဆုံး login တွင် credentials စစ်ဆေးပါ
```

## ၈။ ပြဿနာ ဖြေရှင်းနည်းများ (Troubleshooting)

| ပြဿနာလက္ခဏာ | အကြောင်းရင်း / ဖြေရှင်းနည်း |
|---|---|
| `docker` သုံးတိုင်း `sudo` လိုအပ်နေခြင်း | Group မဝင်သေးခြင်းကြောင့်ဖြစ်သည် — log out/in ပြုလုပ်ပါ သို့မဟုတ် `newgrp docker` ကို run ပါ။ |
| `make` fail ဖြစ်ခြင်း / Build စဉ် VM boot မတက်ခြင်း | VM တွင် Nested virtualization မပွင့်သေးခြင်းကြောင့်ဖြစ်သည် — `grep -cw vmx /proc/cpuinfo` ဖြင့် ပြန်စစ်ပါ။ |
| `permission denied: /dev/kvm` | မိမိ user ကို kvm group ထဲ ထည့်ပါ: `sudo usermod -aG kvm "$USER"`၊ ပြီးလျှင် re-login ပြုလုပ်ပါ။ |
| `unknown kind juniper_vjunosswitch` | containerlab ဗားရှင်းဟောင်းနေခြင်းဖြစ်သည် — နောက်ဆုံးဗားရှင်းသို့ reinstall ပြုလုပ်ပါ (အဆင့် ၂)။ |
| Nodes များ boot တက်သော်လည်း mgmt SSH ဝင်မရခြင်း | အနည်းငယ် ထပ်မံစောင့်ဆိုင်းပါ (Junos mgmt သည် နောက်ကျမှ တက်ပါသည်)၊ ပြီးနောက် credentials စစ်ဆေးပါ။ |
| Build လုပ်စဉ် Disk ပြည့်သွားခြင်း | `.qcow2` နှင့် Docker layers များသည် ကြီးမားပါသည် — 100 GB SSD disk သတ်မှတ်ထားရန် လိုအပ်ပါသည်။ |

## ၉။ 💰 အသုံးပြုပြီးပါက VM ကို ရပ်တန့်ထားပါ (ကုန်ကျစရိတ် သက်သာစေရန်)

GCP VM သည် **စက်ပွင့်နေချိန်တွင် စက္ကန့်နှင့်အမျှ ကျသင့်ငွေ တက်နေပါသည်**။ တစ်နေ့တာ အသုံးပြုပြီးပါက **စက်ကို ရပ်တန့် (stop) ထားပါ** — သင်၏ disk (image, repo, configs) များ ပျက်စီးမသွားဘဲ သိုလှောင်မှုစရိတ် အနည်းငယ်သာ ကျသင့်မည် ဖြစ်ပါသည်။

**အလွယ်ကူဆုံးနည်းလမ်း — VM အတွင်းမှ တိုက်ရိုက် ရပ်တန့်ခြင်း**:
```bash
sudo poweroff        # (သို့မဟုတ်: sudo shutdown -h now)
```
Guest OS သည် shutdown ဖြစ်သွားမည်ဖြစ်ပြီး GCP က instance ကို **TERMINATED** အဖြစ် သတ်မှတ်ကာ compute billing ရပ်တန့်သွားပါမည်။ SSH session ပြတ်တောက်သွားမည်ဖြစ်ပြီး ၎င်းမှာ ပုံမှန်သာ ဖြစ်ပါသည်။ ပြန်လည်ဖွင့်လိုပါက Console သို့မဟုတ် `gcloud` command ကို သုံးပါ။

**Laptop သို့မဟုတ် Cloud Shell မှ ရပ်တန့်ခြင်း**:
```bash
gcloud compute instances stop   clab-lab --zone=asia-southeast1-b   # ရပ်တန့်ရန် — ကုန်ကျစရိတ် သက်သာသည်
gcloud compute instances start  clab-lab --zone=asia-southeast1-b   # နောက်တစ်ကြိမ် ပြန်လည်စတင်ရန်
gcloud compute instances delete clab-lab --zone=asia-southeast1-b   # လုံးဝဖျက်သိမ်းရန်
```

> ⚠️ **လည်ပတ်နေသော containerlab fabric သည် VM stop/start ပြုလုပ်မှုကို မခံနိုင်ပါ။** VM ကို ပြန်လည် `start` လုပ်ပြီးနောက် vJunos containers များ ပျောက်ကွယ်သွားနိုင်သဖြင့် `./scripts/deploy.sh <lab>` ဖြင့် ပြန်လည် deploy ပြုလုပ်ပြီး `./scripts/apply.sh <lab> all` ဖြင့် rebuild ပြုလုပ်ပေးပါ။ Git ထဲတွင် ဖိုင်များ လုံခြုံစွာ ရှိနေသဖြင့် မည်သည့်အရာမှ ဆုံးရှုံးမည် မဟုတ်ပါ။

---

ဆက်လက်လေ့လာရန်: [Lab 01 သို့ ပြန်သွားပါ](../archive/juniper-vxlan-evpn/labs/lab-01-fullmesh.md)။
