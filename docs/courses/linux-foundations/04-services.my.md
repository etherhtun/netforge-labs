# ၄ · Processes, Services နှင့် Logs များ

မနက် ၃ နာရီတွင် Automation job များ ရုတ်တရက် fail ဖြစ်ပါက ဤစာမျက်နှာသည် အဓိက အထောက်အကူပြုပါမည်။ အောက်ပါ outputs များကို lab host ပေါ်တွင် တိုက်ရိုက် စမ်းသပ်ရယူထားခြင်း ဖြစ်သည်။

---

## Processes (လုပ်ငန်းစဉ်များ) စီမံခန့်ခွဲခြင်း

```bash
ps aux | grep ssh          # Process တစ်ခုကို ရှာဖွေသည်
pgrep -a python            # ပိုမိုသန့်ရှင်းသည်: PID + command ပြသည်
kill <pid>                 # ရပ်တန့်ရန် ယဉ်ကျေးစွာ တောင်းဆိုသည် (SIGTERM)
kill -9 <pid>              # အတင်းအကျပ် ရပ်တန့်စေသည် (SIGKILL) — နောက်ဆုံးနည်းလမ်း
top / htop                 # အချိန်နှင့်တစ်ပြေးညီ CPU/RAM သုံးစွဲမှု ကြည့်သည်
```

`kill -9` သည် process အား ဖိုင်သိမ်းဆည်းရန်နှင့် သန့်ရှင်းရေးလုပ်ရန် အခွင့်အရေး မပေးပါ — ရေးမပြီးသေးသော ဖိုင်များ ပျက်စီးကျန်ရစ်တတ်သည်။ သာမန် `kill` ကို အရင်သုံးပြီး စက္ကန့်အနည်းငယ် စောင့်ဆိုင်းကြည့်ပါ။

```bash
uptime                     # Load average ကို ကြည့်သည်
free -h                    # RAM သုံးစွဲမှုကို လူဖတ်ရလွယ်အောင် ကြည့်သည်
df -h                      # Disk ပမာဏ — အကြောင်းမဲ့ fail ဖြစ်ပါက ဤအချက်ကို အရင်စစ်ပါ
du -sh * | sort -h         # မည်သည့် folder က နေရာအများဆုံး ယူနေသည်ကို စစ်သည်
```

**Disk ပြည့်သွားခြင်းသည် ထူးဆန်းသော၊ ဆက်စပ်မှုမရှိဟု ထင်ရသော ပြဿနာများကို ဖြစ်ပေါ်စေတတ်သည်။** အမြဲတမ်း `df -h` ကို အစောဆုံး စစ်ဆေးပါ။

---

## systemd (Service စီမံခန့်ခွဲမှု)

ယနေ့ခေတ် Linux services အားလုံးနီးပါးကို systemd ဖြင့် စီမံခန့်ခွဲထားပါသည်။

```bash
systemctl status docker           # လည်ပတ်နေခြင်း ရှိမရှိနှင့် မကြာသေးမီက logs များကို ပြသည်
systemctl start|stop|restart docker
systemctl enable docker           # စက်စတင်ဖွင့်ချိန် (boot) တွင် အလိုအလျောက် ပွင့်စေသည်
systemctl is-active docker
```

```bash
systemctl is-active docker
```
```
active
```

```bash
systemctl --type=service --state=running
```
```
  UNIT                     LOAD   ACTIVE SUB     DESCRIPTION
  console-getty.service    loaded active running Console Getty
  containerd.service       loaded active running containerd container runtime
  cron.service             loaded active running Regular background program processing
  dbus.service             loaded active running D-Bus System Message Bus
```

!!! tip "`enable` နှင့် `start` သည် မတူညီပါ"
    `start` သည် ယခုလက်ရှိ run ပေးခြင်း ဖြစ်သည်။ `enable` သည် စက် reboot တက်တိုင်း အလိုအလျောက် စတင်စေခြင်း ဖြစ်သည်။ တစ်ခုလုပ်ရုံဖြင့် နောက်တစ်ခု အလိုအလျောက် မဖြစ်ပါ — `start` သာ လုပ်ပြီး `enable` မလုပ်ထားသော service သည် reboot ပြီးနောက် ပျောက်ကွယ်သွားပါမည်။ နှစ်ခုစလုံးကို တစ်ပြိုင်နက် လုပ်လိုပါက `enable --now` ကို သုံးပါ။

---

## journalctl (System Logs ကြည့်ရှုခြင်း)

```bash
journalctl -u docker              # Service တစ်ခုတည်း၏ logs များကို ကြည့်သည်
journalctl -u docker -f           # Logs အသစ်များကို တိုက်ရိုက် စောင့်ကြည့်သည် (tail -f ကဲ့သို့)
journalctl -u docker --since "10 min ago"
journalctl -p err --since today   # ယနေ့အတွင်း ဖြစ်ပေါ်သော Errors များကိုသာ စစ်ထုတ်သည်
journalctl -u docker -n 50        # နောက်ဆုံး စာကြောင်း ၅၀ ကို ကြည့်သည်
journalctl --disk-usage
```

`-p err` သည် priority အလိုက် စစ်ထုတ်ပေးပြီး ရှုပ်ထွေးနေသော log ဖိုင်ကြီးများထဲမှ အမှားများကို အမြန်ဆုံး ရှာဖွေပေးနိုင်သော နည်းလမ်း ဖြစ်သည်။ ပြဿနာ စတင်ဖြစ်ပွားချိန်ကို `--since` ဖြင့် ကန့်သတ်ရှာဖွေနိုင်ပါသည်:

```bash
journalctl -p err --since "2026-08-03 08:00" --until "2026-08-03 09:00"
```

ရှေးရိုးစနစ်များနှင့် application အချို့သည် `/var/log/` အောက်ရှိ ရိုးရိုးဖိုင်များကို ဆက်လက် သုံးစွဲကြသည်:

```bash
tail -f /var/log/syslog
grep -i error /var/log/syslog | tail -20
```

---

## Host ပိုင်းဆိုင်ရာ ကွန်ရက်သုံး Tools များ

### ss — မည်သည့် Port များ ဖွင့်ထားပြီး မည်သူနှင့် ချိတ်ဆက်နေသနည်း

`netstat` နေရာတွင် အစားထိုး အသုံးပြုသည်:

```bash
ss -tlnp                   # TCP, listening ဖြစ်နေသော ports များ, numeric, process အမည်ပါ ပြသည်
ss -tn state established   # လက်ရှိ ချိတ်ဆက်ထားသော connections များ
ss -tn dport = :179        # BGP sessions များကို သီးသန့်ကြည့်သည်
```

| Flag | အဓိပ္ပာယ် |
|---|---|
| `-t` / `-u` | TCP / UDP |
| `-l` | Listening (စောင့်ဆိုင်းနေသော) ports များသာ ပြသည် |
| `-n` | Numeric — IP/Port များကို နာမည်အဖြစ် မပြောင်းလဲပါ |
| `-p` | ပိုင်ဆိုင်သော Process ကို ပြသည် (root အခွင့်အရေး လိုအပ်သည်) |

"Service သည် အမှန်တကယ် port ဖွင့်ထားရဲ့လား၊ မည်သည့် IP address ပေါ်တွင် နားထောင်နေသနည်း" ကို ဤနေရာတွင် သိရှိနိုင်သည်။ `0.0.0.0` အစား `127.0.0.1` တွင်သာ bind လုပ်ထားသော service သည် စက်ပြင်ပမှ လှမ်းဆက်သွယ်၍ မရနိုင်ပါ — "Port ပွင့်နေသော်လည်း ချိတ်မရပါ" ဟူသော ပြဿနာများ၏ အဖြစ်အများဆုံး အကြောင်းရင်း ဖြစ်သည်။

### curl — HTTP နှင့် APIs စစ်ဆေးခြင်း

ခေတ်မီ NOS APIs များသည် HTTP ဖြစ်လာသောကြောင့် ကွန်ရက်အင်ဂျင်နီယာတစ်ဦး မဖြစ်မနေ သုံးတတ်ရမည့် tool ဖြစ်လာပါသည်:

```bash
curl -s -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" https://api.github.com
```
```
http_code=200 time=0.062238s
```

```bash
curl -s https://api.example.com/devices | jq '.'          # JSON API
curl -sk https://device/restconf/data/...                 # -k: Cert check ကို ကျော်သည် (Labs သာ)
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"test"}' https://api.example.com/x
curl -u admin:pass https://device/api                     # Basic authentication
```

### ဆက်သွယ်နိုင်မှု (Reachability) နှင့် လမ်းကြောင်း စစ်ဆေးခြင်း

```bash
ping -c4 10.0.12.1
mtr -rwc 10 8.8.8.8        # Traceroute နှင့် Ping ကို ပေါင်းစပ်ထားသော အကောင်းဆုံး tool
traceroute 10.0.12.1
nc -zv 10.0.12.1 179       # TCP/179 (BGP) port ပွင့်မပွင့် စစ်ဆေးသည်
nc -zvu 10.0.12.1 4789     # UDP (VXLAN) port စစ်ဆေးသည်
```

`mtr` သည် ပြတ်တောင်းပြတ်တောင်း ဖြစ်တတ်သော ပြဿနာများအတွက် အသင့်တော်ဆုံး ဖြစ်သည် — အဆက်မပြတ် စမ်းသပ်ပေးပြီး hop တစ်ခုချင်းစီ၏ packet loss ရာခိုင်နှုန်းကို တိကျစွာ ပြသပေးပါသည်။

`nc -zv` သည် protocol client မလိုဘဲ "အဆိုပါ port သို့ ရောက်မရောက်" ကို ချက်ချင်း အတည်ပြုပေးနိုင်သည်။

### DNS စစ်ဆေးခြင်း

```bash
dig example.com                # အသေးစိတ် အဖြေအပြည့်အစုံ
dig +short example.com         # IP လိပ်စာ သက်သက်သာ ပြသည်
dig @8.8.8.8 example.com       # သီးခြား DNS server တစ်ခုကို သတ်မှတ်မေးမြန်းသည်
dig -x 8.8.8.8                 # Reverse DNS lookup
host example.com               # ရိုးရှင်းသော အခြားနည်းလမ်း
```

---

## အလိုအလျောက် အချိန်ဇယားဆွဲခြင်း (Scheduling with cron)

```bash
crontab -e                 # Crontab ကို ပြင်ဆင်သည်
crontab -l                 # လက်ရှိ ဇယားများကို ကြည့်သည်
```

```
# m h dom mon dow  command
*/5 * * * *  /home/netops/check-bgp.sh >> /var/log/bgp-check.log 2>&1
0 2 * * *    /home/netops/backup-configs.sh
```

အကွက် ၅ ကွက် ပါဝင်ပါသည်: Minute (မိနစ်), Hour (နာရီ), Day-of-month (ရက်စွဲ), Month (လ), Day-of-week (ရက်သတ္တပတ်နေ့)။

!!! warning "cron တွင် Environment မရှိသလောက် နည်းပါးပါသည်"
    စနစ်တကျ သတ်မှတ်ထားသော `PATH` မရှိပါ၊ shell profile မရှိပါ၊ working directory ကွဲပြားပါသည်။ Terminal တွင် ပုံမှန် run နိုင်သော script သည် cron အောက်တွင် မကြာခဏ fail ဖြစ်တတ်သည်။

    **ဖိုင်လမ်းကြောင်းအားလုံးကို Absolute Path (အပြည့်အစုံ) ဖြင့် ရေးပါ**၊ streams နှစ်ခုစလုံးကို log ထဲ ထည့်ပါ (`>> log 2>&1`)။

---

## အလုပ်ဖြစ်သော ပြဿနာ စစ်ဆေးမှု အစီအစဉ် (Diagnostic Order)

တစ်ခုခု ချို့ယွင်းနေပြီး မည်သည့်နေရာမှ စတင်ရမည် မသိပါက ဤအစဉ်အတိုင်း စစ်ဆေးပါ:

```mermaid
graph LR
    A["၁ · Resources<br/>df -h, free -h"] --> B["၂ · Service<br/>systemctl status"]
    B --> C["၃ · Logs<br/>journalctl -p err"]
    C --> D["၄ · Listening<br/>ss -tlnp"]
    D --> E["၅ · Reachable<br/>nc -zv, mtr"]
    classDef s fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px;
    classDef r fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:14px;
    class A,B,C,D s; class E r;
```

Resources များကို အရင်ဆုံး စစ်ဆေးပါ၊ အကြောင်းမှာ disk ပြည့်ခြင်း သို့မဟုတ် memory ပြတ်လပ်ခြင်းသည် အခြားမည်သည့် ပြဿနာပုံစံနှင့်မဆို ဆင်တူစွာ ထွက်ပေါ်တတ်သောကြောင့် ဖြစ်သည်။ ထို့နောက် service လည်ပတ်နေခြင်း ရှိမရှိ၊ logs တွင် အဘယ်အရာပြနေသနည်း၊ port နားထောင်နေသနည်း၊ နှင့် အပြင်မှ လှမ်းဆက်သွယ်နိုင်သနည်းတို့ကို အဆင့်ဆင့် ဆက်လက် စစ်ဆေးပါ။

---

**ဆက်လက်လေ့လာရန်:** [ကွန်ရက် အင်ဂျင်နီယာများအတွက် Git →](05-git.md)
