# ၃ · SSH ကို စနစ်တကျ သုံးစွဲနည်း (SSH Properly)

Automation tools တိုင်း — Ansible၊ Netmiko၊ NAPALM၊ သို့မဟုတ် သင်ကိုယ်တိုင်ရေးသော scripts များ — အားလုံးသည် အောက်ခြေတွင် SSH ပေါ်၌သာ အလုပ်လုပ်ကြပါသည်။ ၎င်းကို စနစ်တကျ တပ်ဆင်အသုံးပြုတတ်ခြင်းသည် အလိုအလျောက် အနှောင့်အယှက်ကင်းစွာ လည်ပတ်နိုင်သော automation နှင့် password တောင်းဆိုမှုကြောင့် ရပ်တန့်နေတတ်သော automation အကြား အဓိက ခြားနားချက် ဖြစ်ပါသည်။

---

## Passwords အစား Keys ကိုသာ သုံးစွဲခြင်း

Key pair တစ်ခုတွင် ဖိုင် ၂ ခု ပါဝင်ပါသည်: မိမိစက်တွင်း၌သာ အမြဲတမ်း လုံခြုံစွာထားရှိရမည့် **Private Key** နှင့် စက်ပစ္စည်းတိုင်းဆီသို့ copy ကူးတင်ရမည့် **Public Key** တို့ ဖြစ်ကြသည်။ စက်ပစ္စည်းသည် သင့်တွင် အဆိုပါ private key အမှန်တကယ် ပိုင်ဆိုင်ကြောင်း သက်သေပြရန် challenge မေးခွန်းဖြင့် အတည်ပြုစစ်ဆေးပါသည်။

```bash
ssh-keygen -t ed25519 -C "netops@example.com"
```

**ed25519** ကို သုံးပါ — RSA ထက် ပိုမိုတိုတောင်း၊ မြန်ဆန်ပြီး ခိုင်မာကာ ခေတ်မီစက်တိုင်းက ထောက်ပံ့ပေးသည်။ အလွန်ရှေးကျသော စက်ဟောင်းများအတွက်သာ `-t rsa -b 4096` ကို အသုံးပြုပါ။

```bash
ssh-copy-id user@10.0.0.1        # Public key ကို သွားရောက် install လုပ်ပေးသည်
ssh user@10.0.0.1                # Password ရိုက်ရန် မလိုတော့ပါ
```

`ssh-copy-id` မရှိပါက `~/.ssh/id_ed25519.pub` ပါ စာသားများကို စက်၏ `~/.ssh/authorized_keys` ဖိုင်အောက်ခြေသို့ လက်ဖြင့် သွားရောက် ကူးထည့်ပေးနိုင်ပါသည်။

!!! warning "File Permissions များသည် အလွန် တင်းကျပ်ပြီး Error က တိုက်ရိုက် မပြတတ်ပါ"
    SSH သည် လုံခြုံမှုမရှိသော (loose) permissions ရှိသည့် keys များကို သုံးစွဲရန် ငြင်းဆန်တတ်ပြီး အကြောင်းရင်းကိုလည်း တိုက်ရိုက် မဖော်ပြတတ်ပါ:

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519          # Private key
    chmod 644 ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/authorized_keys
    ```

    **Private key သည် `600`, directory သည် `700` ဖြစ်ရပါမည်။** Key ဖြင့် login ဝင်မရပါက ဤအချက်ကို အရင်ဆုံး စစ်ဆေးပါ — ပြီးနောက် `ssh -v` ဖြင့် အသေးစိတ် သဲလွန်စကို ဖတ်ရှုပါ။

---

## SSH Agent: Passphrase ကို တစ်ကြိမ်သာ ရိုက်နှိပ်ခြင်း

Passphrase ခတ်ထားသော key ကို သုံးခြင်းသည် အကောင်းဆုံးဖြစ်သော်လည်း အကြိမ်တိုင်း passphrase ရိုက်နေရန် မလိုလားအပ်ပါ။ SSH Agent သည် decrypt ပြုလုပ်ပြီးသား key ကို memory ထဲတွင် ယာယီ ထိန်းသိမ်းပေးထားပါသည်:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l                        # လက်ရှိ load လုပ်ထားသော keys များကို ကြည့်ရှုခြင်း
```

**Agent Forwarding** (`-A`) သည် remote host မှတစ်ဆင့် သင်၏ local keys ကိုသုံး၍ အခြားစက်များသို့ ဆက်လက်ကူးပြောင်းနိုင်စေသည် — jump hosts များတွင် အဆင်ပြေသော်လည်း အဆိုပါ host ပေါ်ရှိ root user မည်သူမဆို သင်ချိတ်ဆက်နေစဉ် သင်၏ agent ကို သုံးစွဲသွားနိုင်သည့် လုံခြုံရေးအားနည်းချက် ရှိသည်။ ထို့ကြောင့် အောက်တွင် ဖော်ပြထားသော `ProxyJump` ကိုသာ ဦးစားပေး အသုံးပြုပါ။

---

## ~/.ssh/config — အချိန်အသက်သာဆုံး နေရာ

ချိတ်ဆက်မှု အချက်အလက်များကို အကြိမ်တိုင်း ရိုက်နှိပ်မနေပါနှင့်။ ဤ config ဖိုင်ကို ssh၊ scp၊ rsync၊ Ansible နှင့် tooling အများစုက အလိုအလျောက် ဖတ်ရှုကြပါသည်:

```
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host jump
    HostName bastion.example.com
    User netops
    IdentityFile ~/.ssh/id_ed25519

Host r1 r2 r3
    User admin
    IdentityFile ~/.ssh/id_ed25519
    ProxyJump jump

Host legacy-*
    # Deprecated algorithms လိုအပ်သော စက်ဟောင်းများအတွက်
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
```

ယခုအခါ `ssh r1` ဟု ရိုက်လိုက်ရုံဖြင့် — မှန်ကန်သော user၊ မှန်ကန်သော key ဖြင့် bastion host မှတစ်ဆင့် အလိုအလျောက် ချိတ်ဆက်ပေးပါမည်။

| Setting | အကျိုးကျေးဇူး |
|---|---|
| `ProxyJump` | Agent forwarding မလိုဘဲ bastion မှတစ်ဆင့် စက်များသို့ လုံခြုံစွာ ရောက်ရှိစေသည် |
| `ServerAliveInterval` | Firewall များက idle ဖြစ်နေသော sessions များကို ဖြတ်မချစေရန် ထိန်းပေးသည် |
| `IdentityFile` | မည်သည့်စက်အတွက် မည်သည့် key ကို သုံးမည်ဟု သတ်မှတ်သည် |
| `ControlMaster` | စက်တစ်ခုတည်းသို့ ချိတ်ဆက်မှုတစ်ခုတည်းကို commands ပေါင်းများစွာအတွက် ပြန်သုံးသည် — အလွန်မြန်ဆန်သည် |

**Connection Multiplexing** သည် စက်တစ်ခုတည်းပေါ်သို့ script ဖြင့် commands များစွာ ဆက်တိုက် run လိုသည့်အခါ အလွန် အသုံးဝင်ပါသည်:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 10m
```

ပထမဆုံး ချိတ်ဆက်မှုကသာ authenticate ပြုလုပ်ရပြီး နောက်ဆက်တွဲ commands များသည် ဖွင့်ထားပြီးသား channel ကို ပြန်လည်အသုံးပြုသဖြင့် ချက်ချင်း စတင်နိုင်ပါသည်။ Ansible run သည့်အခါ သိသိသာသာ ပိုမိုမြန်ဆန်လာပါမည်။

---

## Jump Hosts သုံးစွဲခြင်း

```bash
ssh -J jump user@10.0.0.1        # တစ်ဆင့် ခုန်ကူးခြင်း
ssh -J jump1,jump2 user@target   # ဆင့်ကဲ ခုန်ကူးခြင်း
```

`ProxyJump` သည် agent forwarding ထက် ပိုမိုလုံခြုံပါသည်၊ အဘယ်ကြောင့်ဆိုသော် သင်၏ private key သည် bastion ပေါ်သို့ လုံးဝ မရောက်ရှိဘဲ traffic ကိုသာ tunnel ဖောက်ပေးကာ authentication ကို မိမိစက်တွင်း၌သာ ပြုလုပ်သောကြောင့် ဖြစ်သည်။

---

## စက်များပေါ်တွင် Commands များကို အဝေးမှ လှမ်း run ခြင်း

```bash
ssh r1 "show ip bgp summary"                    # Command တစ်ခု run ပြီး ပြန်ထွက်သည်
ssh r1 "show running-config" > r1.cfg           # Output ကို ဖိုင်ထဲ သိမ်းသည်
ssh r1 <<'EOF'                                  # Commands အများအပြားကို တစ်ပြိုင်နက် ပို့သည်
configure
router bgp 65001
EOF
```

စက်သေနေသဖြင့် အခြားစက်များ ရပ်တန့်မသွားစေရန် timeout ပါဝင်သော parallel run ပုံစံ:

```bash
cat devices.txt | xargs -P8 -I{} timeout 10 ssh -o BatchMode=yes {} "show version"
```

**`BatchMode=yes` ကို သင်၏ script တိုင်းတွင် အမြဲ ထည့်သွင်းပါ။** ၎င်းသည် password တောင်းဆိုမည့်အစား ချက်ချင်း fail ဖြစ်စေပါသည် — သို့မဟုတ်ပါက အလိုအလျောက် run နေသော job သည် မည်သူမျှ မရိုက်နှိပ်မည့် password prompt ကို စောင့်ဆိုင်းရင်း ထာဝစဉ် ရပ်တန့်နေပါလိမ့်မည်။

---

## Host Keys နှင့် လုံခြုံရေး

ပထမဆုံးအကြိမ် ချိတ်ဆက်ချိန်တွင် SSH သည် host fingerprint ကို အတည်ပြုရန် မေးမြန်းပြီး `~/.ssh/known_hosts` ထဲတွင် မှတ်သားထားပါသည်။ နောက်ပိုင်းတွင် ပြောင်းလဲသွားပါက အောက်ပါအတိုင်း သတိပေးပါသည်:

```
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

အများအားဖြင့် စက်ကို ပြန်လည်တည်ဆောက်ခြင်း သို့မဟုတ် အသစ်လဲလှယ်ခြင်းကြောင့် ဖြစ်လေ့ရှိသည်။ သို့မဟုတ် အမှန်တကယ်ပင် တစ်စုံတစ်ယောက်က ကြားဖြတ်ဝင်ရောက်နေခြင်းလည်း ဖြစ်နိုင်သည်။

```bash
ssh-keygen -R 10.0.0.1        # မူလ entry အဟောင်းကို ဖျက်ပြီး ပြန်လည်ချိတ်ဆက်ပါ
```

!!! danger "`StrictHostKeyChecking=no` ကို အလွယ်တကူ မသုံးပါနှင့်"
    ၎င်းသည် လုံခြုံရေးကာကွယ်မှုကို လုံးဝ ဖျက်ပစ်လိုက်ခြင်းဖြစ်ပြီး ထို IP ဖြစ်သည်ဟု အယောင်ဆောင်ထားသော မည်သည့်စက်နှင့်မဆို ချိတ်ဆက်သွားနိုင်ပါသည်။

    စမ်းသပ်ပြီး ပြန်ဖျက်မည့် lab စက်များအတွက်သာ သီးသန့် ကန့်သတ်သုံးပါ:

    ```
    Host clab-*
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    ```

    ၎င်းကို `Host *` တွင် သို့မဟုတ် production စက်များတွင် လုံးဝ မသုံးပါနှင့်။

---

## အလုပ်မလုပ်ပါက စစ်ဆေးနည်း

```bash
ssh -v r1        # Verbose log ပြသသည်; ပိုမိုသိလိုပါက -vvv
```

ရပ်တန့်သွားသော စာကြောင်းကို ရှာဖွေဖတ်ရှုပါ:

| အမှားသတင်းလွှာ | အဓိပ္ပာယ် |
|---|---|
| `Permission denied (publickey)` | Key ကို လက်မခံပါ — Permissions နှင့် `authorized_keys` ကို စစ်ပါ |
| `Connection refused` | စောင့်ဆိုင်းနေသော service မရှိပါ — SSH daemon ရပ်နေခြင်း သို့မဟုတ် port မှားယွင်းခြင်း |
| `Connection timed out` | ဆက်သွယ်မရပါ — Firewall ပိတ်ထားခြင်း သို့မဟုတ် Routing မှားယွင်းခြင်း |
| `no matching key exchange method` | စက်ဟောင်းဖြစ်နေပြီး client မှာ ခေတ်မီနေခြင်း — `KexAlgorithms` ကို ထည့်ပေးပါ |
| `Host key verification failed` | Key ပြောင်းလဲသွားခြင်း — မျှော်လင့်ထားပါက `ssh-keygen -R` ပြုလုပ်ပါ |

**Connection Refused** နှင့် **Connection Timed Out** အကြား ခြားနားချက်ကို သေချာနားလည်ထားပါ:
Refused ဆိုသည်မှာ တစ်ဖက်စက်သို့ ရောက်ရှိသော်လည်း ငြင်းပယ်ခံရခြင်းဖြစ်သည် (Host ရောက်သည်၊ Service ရပ်နေသည်); Timed out ဆိုသည်မှာ မည်သည့်အသံမျှ ပြန်မထွက်လာခြင်းဖြစ်သည် (Routing သို့မဟုတ် Firewall ကြောင့် လုံးဝ မရောက်ရှိခြင်း)။ ပြဿနာရှာဖွေရာတွင် လုံးဝ မတူညီသော ဦးတည်ချက်နှစ်ခု ဖြစ်သည်။

---

**ဆက်လက်လေ့လာရန်:** [Processes, Services နှင့် Logs များ →](04-services.md)
