# Host Setup 1 — Nested Virtualization ပါဝင်သော GCP Instance ဖန်တီးခြင်း

vJunos-switch သည် containerlab container *အတွင်း၌* VM (KVM) အပြည့်အစုံအဖြစ် အလုပ်လုပ်ပါသည်။ ထို့ကြောင့် GCP VM ကိုယ်တိုင်သည် **Nested Virtualization** (VM တစ်ခုအတွင်း အခြား VMs များကို ဆင့်ပွား run နိုင်ခြင်း) ကို ခွင့်ပြုထားရပါမည်။ ၎င်းသည် အရေးအကြီးဆုံး host သတ်မှတ်ချက် ဖြစ်ပါသည်; ဤအချက် လွဲချော်ပါက nodes များ မည်သည့်အခါမျှ boot တက်မည် မဟုတ်ပါ။

```
GCP VM (KVM guest)  →  containerlab container  →  vJunos VM (KVM ထပ်မံ လိုအပ်သည်)
        └────────── Nested Virtualization ကို ON ထားရမည် ──────────┘
```

---

## ၁။ ကြိုတင် လိုအပ်ချက်များ (Prerequisites)

- Billing ဖွင့်ထားသော **Google Cloud အကောင့်** နှင့် **Project** တစ်ခု။
- မိမိ laptop ပေါ်တွင် `gcloud` CLI ရှိရန် လိုအပ်သည်၊ **သို့မဟုတ်** Browser အတွင်းရှိ **Cloud Shell** ကို အသုံးပြုနိုင်ပါသည် (မည်သည့် software မှ သွင်းစရာမလိုဘဲ `gcloud` ပါဝင်ပြီး ဖြစ်သည်)။

> 💡 အကယ်၍ သင်၏ project သည် Organization အောက်တွင် ရှိပါက nested virt ကို org policy `constraints/compute.disableNestedVirtualization` ဖြင့် ပိတ်ပင်ထားတတ်ပါသည်။ ဤအကြောင်းကြောင့် VM ဆောက်မရပါက [ပြဿနာဖြေရှင်းနည်း](#troubleshooting) ကို ကြည့်ပါ။

## ၂။ `gcloud` ပါဝင်သော Shell ရယူခြင်း

**နည်းလမ်း က — Cloud Shell (အလွယ်ကူဆုံး၊ မည်သည့်အရာမှ install ပြုလုပ်ရန် မလို):**
<https://console.cloud.google.com> သို့ ဝင်ရောက်ပြီး ညာဘက်အပေါ်ထောင့်ရှိ **`>_`** terminal icon ကို နှိပ်ပါ။ သင်၏ Google account ဖြင့် authenticate ဖြစ်ပြီးသား shell ရရှိပါမည်။

**နည်းလမ်း ခ — မိမိ Mac ပေါ်တွင် gcloud CLI သွင်းခြင်း:**
```bash
# Install ပြုလုပ်ရန် (Homebrew)
brew install --cask google-cloud-sdk

# Login ဝင်ရောက်ရန် — browser ပွင့်လာပြီး authenticate လုပ်ပါမည်
gcloud auth login
```

## ၃။ Project နှင့် Region ကို သတ်မှတ်ခြင်း

```bash
# Project ID မသေချာပါက project စာရင်း ကြည့်ရန်
gcloud projects list

# အသုံးပြုမည့် project နှင့် defaults များကို သတ်မှတ်ပါ
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/zone asia-southeast1-b
gcloud config set compute/region asia-southeast1
```
`YOUR_PROJECT_ID` နေရာတွင် မိမိ၏ တကယ့် project ID ကို အစားထိုးပါ။

## ၄။ VM Instance ကို ဖန်တီးခြင်း

```bash
gcloud compute instances create clab-lab \
  --zone=asia-southeast1-b \
  --machine-type=n2-standard-16 \
  --enable-nested-virtualization \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=100GB \
  --boot-disk-type=pd-ssd
```

> ⚠️ **Image family အမည်သတ်မှတ်ချက်:** Ubuntu 24.04 ၏ family အမည်တွင် architecture suffix ပါဝင်ပါသည် — `ubuntu-2404-lts-amd64` ဖြစ်ပြီး `ubuntu-2404-lts` *မဟုတ်ပါ*။ အတိအကျ စစ်ဆေးလိုပါက အောက်ပါအတိုင်း ကြည့်နိုင်သည်:
> ```bash
> gcloud compute images list --project=ubuntu-os-cloud --filter="family~ubuntu-2404"
> ```

Flag တစ်ခုချင်းစီ၏ အသုံးဝင်ပုံ:

| Flag | အကြောင်းရင်း |
|---|---|
| `--machine-type=n2-standard-16` | 16 vCPU / 64 GB — 2×2 vJunos အတွက် လုံလောက်သည် (node တစ်ခုလျှင် ~4 GB)။ N2 (Intel Cascade Lake) သည် nested virt ကို ထောက်ပံ့ပေးသည်။ |
| `--enable-nested-virtualization` | **အရေးအကြီးဆုံး flag ဖြစ်သည်။** KVM အလုပ်လုပ်နိုင်စေရန် VT-x ကို guest စက်ထံ ဖွင့်ပေးသည်။ |
| `--image-family=ubuntu-2404-lts-amd64` | Ubuntu 24.04 LTS — containerlab နှင့် အဆင်ပြေစွာ တွဲဖက်သုံးနိုင်သည်။ |
| `--boot-disk-size=100GB` `--boot-disk-type=pd-ssd` | vJunos images နှင့် Docker layers များသည် ကြီးမားပါသည်; SSD သည် boot တက်ခြင်းကို ပိုမိုမြန်ဆန်စေသည်။ |

## ၅။ VM သို့ ချိတ်ဆက်ခြင်း

**gcloud မှတစ်ဆင့် SSH ဝင်ရောက်ခြင်း (အကြံပြုချက် — keys များကို အလိုအလျောက် စီမံပေးသည်):**
```bash
gcloud compute ssh clab-lab --zone=asia-southeast1-b
```
ပထမဆုံးအကြိမ်တွင် SSH key ကို အလိုအလျောက် ထုတ်လုပ်ပေးမည်ဖြစ်ပြီး instance ဆီသို့ ပို့ဆောင်ပေးပါမည်။ VM ၏ shell သို့ ရောက်ရှိသွားမည်ဖြစ်ပြီး ဤနေရာတွင် [containerlab setup](containerlab.md) နှင့် `./scripts/*` commands များကို run ရန် ဖြစ်ပါသည်။

## ၆။ Nested Virtualization အမှန်တကယ် ပွင့်မပွင့် အတည်ပြုခြင်း

VM ပေါ်သို့ ရောက်ရှိပါက အောက်ပါ command ကို run ပါ:
```bash
grep -cw vmx /proc/cpuinfo     # > 0  → Intel VT-x ပွင့်နေသည် ✅
```
အကယ်၍ `0` ဟု ပြပါက nested virt ပိတ်နေခြင်း ဖြစ်ပါသည် — containerlab မသွင်းမီ ၎င်းကို အရင် ဖြေရှင်းရပါမည်; သို့မဟုတ်ပါက vJunos nodes များ boot တက်ချိန်တွင် ရပ်တန့်နေပါလိမ့်မည်။

KVM tools သွင်းပြီး ပိုမိုနက်ရှိုင်းစွာ စစ်ဆေးရန်:
```bash
sudo apt install -y cpu-checker && sudo kvm-ok
# "KVM acceleration can be used" ဟု ပြသရမည်
```

## ၇။ ပြဿနာ ဖြေရှင်းနည်းများ (Troubleshooting) {: #troubleshooting }

| ပြဿနာလက္ခဏာ | အကြောင်းရင်း / ဖြေရှင်းနည်း |
|---|---|
| `create` fail ဖြစ်ခြင်း: *nested virtualization disabled by policy* | Org policy `constraints/compute.disableNestedVirtualization` သတ်မှတ်ထားခြင်းကြောင့် ဖြစ်သည်။ Org admin က ၎င်းကို *not enforced* အဖြစ် ပြင်ဆင်ပေးရမည်။ |
| `grep vmx /proc/cpuinfo` က 0 ဟု ပြနေခြင်း | Instance ဖန်တီးစဉ် `--enable-nested-virtualization` မထည့်မိခြင်း သို့မဟုတ် မထောက်ပံ့သော machine type ဖြစ်နေခြင်း။ Flag ထည့်သွင်း၍ N1/N2 စက်ဖြင့် ပြန်ဖန်တီးပါ။ |
| `Quota 'CPUS' exceeded` ပြခြင်း | သက်ဆိုင်ရာ region အတွက် CPU quota တိုးပေးရန် တောင်းဆိုပါ သို့မဟုတ် ပိုသေးငယ်သော machine type / အခြား region ရွေးချယ်ပါ။ |
| vJunos nodes များ boot တက်စဉ် ရပ်တန့်နေခြင်း | Nested virt ပိတ်နေခြင်း သို့မဟုတ် RAM မလုံလောက်ခြင်းကြောင့် အများဆုံး ဖြစ်တတ်သည်။ |

## ၈။ ကုန်ကျစရိတ် ထိန်းချုပ်ခြင်း — အမြဲတမ်း ဖွင့်မထားပါနှင့်

16-vCPU VM သည် **စက်ပွင့်နေစဉ် စက္ကန့်နှင့်အမျှ ကျသင့်ငွေ တက်နေပါသည်**။ တစ်နေ့တာ သုံးပြီးပါက စက်ကို ရပ်တန့် (stop) ထားပါ:

```bash
gcloud compute instances stop  clab-lab --zone=asia-southeast1-b   # ရပ်တန့်ရန် (သက်သာသည်)
gcloud compute instances start clab-lab --zone=asia-southeast1-b   # ပြန်လည်စတင်ရန်
gcloud compute instances delete clab-lab --zone=asia-southeast1-b  # လုံးဝဖျက်သိမ်းရန်
```

---

ဆက်လက်လေ့လာရန်: [Host setup 2 — Docker, containerlab, နှင့် vJunos image](containerlab.md)။
