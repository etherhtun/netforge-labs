# ၇ · Layer 1 Optics & Physical Infrastructure

Hyperscale ကွန်ရက်စင်တာကြီးများတွင် (Google, AWS, Meta) ရံဖန်ရံခါဖြစ်တတ်သော link flaps များ၊ အသံတိတ် packet drops များနှင့် latency တက်ခြင်း ပြဿနာများ၏ ၄၀% ကျော်သည် Physical Layer (အလွှာ ၁) ပြဿနာများမှ တိုက်ရိုက် အခြေခံဖြစ်ပွားလေ့ရှိပါသည်။
ဤသင်ခန်းစာသည် optical transceivers များ၊ fiber physics၊ Digital Optical Monitoring (DOM)၊ Forward Error Correction (FEC)၊ နှင့် physical link စစ်ဆေးခြင်း နည်းလမ်းများကို လွှမ်းခြုံထားပါသည်။

---

## Form Factors နှင့် Transceiver Optics အမျိုးအစားများ

ခေတ်မီ Data Centers များတွင် အောက်ပါ စံသတ်မှတ်ချက် optical transceivers များကို အသုံးပြုကြပါသည်:

| Form Factor | အမြင့်ဆုံး မြန်နှုန်း | အသုံးများသော နေရာ | Connector အမျိုးအစား |
|---|---|---|---|
| **SFP+** | 10 Gbps | ရိုးရာ top-of-rack host links များ | LC Duplex |
| **SFP28** | 25 Gbps | Server NIC မှ Leaf switch သို့ ချိတ်ဆက်မှုများ | LC Duplex |
| **QSFP28** | 100 Gbps | Leaf-to-Spine links များ၊ 100G host ချိတ်ဆက်မှုများ | LC / MPO-12 |
| **QSFP-DD** | 400 Gbps | High-density Spine & Fabric ချိတ်ဆက်မှုများ | MPO-16 / CS / SN |
| **OSFP** | 400G / 800G | မျိုးဆက်သစ် hyperscale & AI/ML cluster fabrics များ | MPO-16 / Dual LC |

---

## Transceiver သတ်မှတ်ချက်များနှင့် သင်္ကေတများ (Optical Specifications)

မှန်ကန်သော transceiver ကို ရွေးချယ်ရာတွင် optical reach၊ fiber အမျိုးအစား၊ modulation၊ connector၊ နှင့် multiplexing standard တို့ကို ကိုက်ညီအောင် တွဲဖက်ရန် လိုအပ်ပါသည်:

| သင်္ကေတ | အကွာအဝေး (Reach) | လှိုင်းအလျား (\(\lambda\)) | Fiber အမျိုးအစား | Connector | Optical Mux / Modulation | အသုံးများသော နေရာ |
|---|---|---|---|---|---|---|
| **SR / SR4 / SR8** | Short Reach (70m–100m) | 850 nm | MMF (OM3/OM4) | MPO-12 / MPO-16 / LC | Parallel VCSEL lasers | Host-to-Leaf, intra-rack patching |
| **DR / DR4** | Data Center Reach (500m) | 1310 nm | SMF (OS2) | MPO-12 / SN / CS | Parallel PAM4 (1 lane/fiber pair) | Leaf-to-Spine intra-datacenter |
| **FR / FR4** | Fiber Reach (2 km) | 1271–1331 nm | SMF (OS2) | LC Duplex | CWDM4 (4 wavelengths on 1 pair) | Campus & inter-building fabric |
| **LR / LR4 / LR8** | Long Reach (10 km) | 1295–1309 nm | SMF (OS2) | LC Duplex | LAN-WDM (Tight 800GHz grid) | Metro & inter-facility link |
| **ER / ER4** | Extended Reach (40 km) | 1550 nm / LAN-WDM | SMF (OS2) | LC Duplex | EML Laser + APD Receiver | Regional DCI backbone links |
| **ZR / ZR4** | Zephyr Reach (80 km) | 1550 nm | SMF (OS2) | LC Duplex | Amplified SMF / High Sensitivity | Long-haul regional transit |
| **400G ZR / OpenZR+** | Coherent (80km–120km+) | C-Band (1550 nm) | SMF (OS2) | LC Duplex | Coherent DSP / QPSK & 16-QAM | IP-over-DWDM direct DCI |
| **BiDi (Bidirectional)** | Single-Strand (100m–10km) | 1270nm / 1330nm | MMF / SMF | Simplex LC | WDM Tx/Rx split on single strand | ကေဘယ်ကြိုးအရေအတွက် ချွေတာခြင်း |
| **CWDM / DWDM** | Multi-Channel (10km–80km+) | 1270–1610nm (CWDM)<br>1528–1565nm (DWDM) | SMF (OS2) | LC Duplex | 20nm spacing (CWDM) / 50-100GHz grid (DWDM) | Passive optical multiplexing |

---

### Optical နည်းပညာနှင့် Wavelength Multiplexing အလုပ်လုပ်ပုံ

၁။ **Multi-Mode VCSEL (SR / SR4)**:
   - **850nm** တွင် အလုပ်လုပ်သော vertical-cavity surface-emitting lasers များကို သုံးသည်။
   - ပိုမိုကျယ်ပြန့်သော 50µm core ရှိသည့် Multi-Mode Fiber (OM3/OM4) လိုအပ်သည်။
   - အမြန်နှုန်းမြင့်မားမှု (100G/400G) အတွက် MPO connectors သုံးပြီး **parallel ribbon fibers** များဖြင့် ချိတ်ဆက်ရသည် (ဥပမာ 100GBASE-SR4 အတွက် 4 Tx + 4 Rx fibers)။

၂။ **Uncooled CWDM4 (FR4 / CWDM)**:
   - Coarse Wavelength Division Multiplexing သည် 20nm ခြားနားသော လှိုင်းအလျား ၄ ခုကို အသုံးပြုသည် (**1271nm, 1291nm, 1311nm, 1331nm**)။
   - Transceiver အတွင်း၌ optical channels ၄ ခုကို ပေါင်းစပ်ပြီး **single duplex LC Single-Mode Fiber pair** ပေါ်တွင် ပို့ဆောင်သဖြင့် ကေဘယ်ကြိုးကုန်ကျစရိတ်ကို အလွန်သက်သာစေသည်။

၃။ **Precision LAN-WDM (LR4 / ER4)**:
   - Zero-dispersion 1310nm ဝန်းကျင်တွင် ပိုမိုတင်းကျပ်သော 800GHz (~4.5nm) channel spacing ကို သုံးသည် (**1295.56nm, 1300.05nm, 1304.58nm, 1309.14nm**)။
   - Laser အပူချိန်ကို အတိအကျ ထိန်းညှိပေးပြီး channel overlap မဖြစ်စေရန် optic အတွင်း၌ TEC (Thermoelectric Cooler) ပါဝင်သည်။

၄။ **Coherent IP-over-DWDM (400G ZR / OpenZR+)**:
   - Onboard Digital Signal Processor (DSP) ဖြင့် မောင်းနှင်သော **Coherent Phase Modulation** (QPSK သို့မဟုတ် 16-QAM) ကို အသုံးပြုသည်။
   - ပြင်ပ transponder boxes များ မလိုဘဲ 400Gbps interfaces များကို switch/router QSFP-DD ports များတွင် တိုက်ရိုက်တပ်ဆင်ပြီး DWDM line systems ပေါ်မှ 120km ကျော်အထိ ချိတ်ဆက်နိုင်သည်။

!!! warning "MMF နှင့် SMF ကြိုးများကို ဘယ်တော့မျှ မရောနှောပါနှင့်"
    Multi-mode fiber (MMF) သည် LED/VCSEL အတွက် ပိုမိုကျယ်သော 50 µm core ကို သုံးပြီး၊ Single-mode (SMF) သည် precision lasers အတွက် သေးငယ်သော 9 µm core ကို သုံးပါသည်။ MMF ကြိုးကို SMF optic နှင့် တွဲဖက်တပ်ဆင်မိပါက ပြင်းထန်သော insertion loss နှင့် optical reflection ဖြစ်ပေါ်ကာ link လုံးဝ ကျသွားပါလိမ့်မည်။

---

## Digital Optical Monitoring (DOM / DDM)

DOM သည် switches များနှင့် hosts များအား I2C bus မှတစ်ဆင့် အတွင်းပိုင်း optical metrics များကို အချိန်နှင့်တစ်ပြေးညီ ဖတ်ရှုနိုင်စေပါသည်:

၁။ **Tx Power (Transmitter)**: Laser မှ ထုတ်လွှတ်သော optical စွမ်းအင်ပမာဏ (dBm သို့မဟုတ် µW)။
၂။ **Rx Power (Receiver)**: ဖမ်းယူရရှိသော optical စွမ်းအင်ပမာဏ (dBm သို့မဟုတ် µW)။
၃။ **Laser Bias Current**: Laser diode ကို မောင်းနှင်နေသော လျှပ်စီးကြောင်း (mA)။ Bias မြင့်မားနေပါက laser ပျက်စီးယိုယွင်းနေပြီဟု ညွှန်ပြသည်။
၄။ **Temperature**: Optical module ၏ အပူချိန် (°C)။

### Optical Power သင်္ချာတွက်ချက်ပုံ: mW မှ dBm သို့

Optical power ကို **dBm** (decibel-milliwatts) ဖြင့် တိုင်းတာပါသည်:

\[
P_{\text{dBm}} = 10 \cdot \log_{10}\left(\frac{P_{\text{mW}}}{1\text{ mW}}\right)
\]

- **\(0\text{ dBm}\)** = \(1.0\text{ mW}\)
- **\(-3\text{ dBm}\)** = \(0.5\text{ mW}\) (3 dB ဆုံးရှုံးမှု = စွမ်းအင် ၅၀% ကျဆင်းသွားခြင်း)
- **\(-10\text{ dBm}\)** = \(0.1\text{ mW}\)

### EOS နှင့် Linux ပေါ်တွင် DOM ဖတ်ရှုနည်း

```bash
# Arista cEOS CLI: Transceiver အချက်အလက်နှင့် alarm thresholds များကို ကြည့်သည်
show interfaces transceiver
show interfaces Ethernet1/1 transceiver detail
```

```
Ethernet1/1:
  Parameter                 Value        High Alarm   High Warn    Low Warn     Low Alarm
  ------------------------- ------------ ------------ ------------ ------------ ------------
  Temperature               34.21 C      75.00 C      70.00 C      -5.00 C      -10.00 C
  Tx Power                  -1.20 dBm    3.00 dBm     2.00 dBm     -6.00 dBm    -7.00 dBm
  Rx Power                  -3.85 dBm    3.00 dBm     2.00 dBm     -10.00 dBm   -11.00 dBm
  Tx Bias Current           6.45 mA      15.00 mA     12.00 mA     2.00 mA      1.00 mA
```

```bash
# Linux host CLI: Host NIC မှတစ်ဆင့် EEPROM နှင့် DOM ကို မေးမြန်းသည်
ethtool -m eth0
```

---

## Forward Error Correction (FEC) နှင့် Bit Error Rate (BER)

100G နှင့် 400G အမြန်နှုန်းများတွင် ကြိမ်နှုန်းမြင့်မားသော လျှပ်စစ်အချက်ပြလှိုင်းများသည် inter-symbol interference ကြုံတွေ့ရတတ်သည်။ **FEC** သည် parity bits များကို ထည့်သွင်းပေးခြင်းဖြင့် ဖြစ်ပေါ်လာသော bit errors များကို အချိန်နှင့်တစ်ပြေးညီ အလိုအလျောက် ပြန်လည်ပြင်ဆင်ပေးပါသည်။

### ပြင်ဆင်နိုင်သော အမှားများ (Correctable) နှင့် မပြင်ဆင်နိုင်သော အမှားများ (Uncorrectable)

- **Correctable FEC Errors**: Receiver hardware က ရှာဖွေတွေ့ရှိပြီး အောင်မြင်စွာ ပြန်လည်ပြင်ဆင်လိုက်သော bit flips များ ဖြစ်သည်။ အနည်းငယ် ဖြစ်ပေါ်ခြင်းသည် ပုံမှန်သာ ဖြစ်သည်။
- **Uncorrectable FEC Errors**: FEC algorithms က ပြင်ဆင်နိုင်သည့် အတိုင်းအတာထက် ပိုမိုဆိုးရွားစွာ ပျက်စီးသွားသော packets များ ဖြစ်သည်။ **ရလဒ်: Frame သည် PHY layer တွင် ချက်ချင်း drop ဖြစ်သွားသည်။**

```bash
# Arista EOS ပေါ်တွင် FEC စာရင်းအင်းများကို စစ်ဆေးခြင်း
show interfaces Ethernet1/1 phy detail
```

```
Ethernet1/1:
  FEC Mode: RS-FEC (Reed-Solomon)
  Correctable Codewords:   142850
  Uncorrectable Codewords: 0
```

!!! danger "Uncorrectable FEC = Physical Degradation"
    အကယ်၍ `Uncorrectable Codewords` အရေအတွက် ဆက်တိုက်တိုးပွားနေပါက အဆိုပါ link သည် IP routing သို့မဟုတ် TCP မသိရှိမီ အောက်ခြေ physical layer တွင် packets များကို drop ဖြစ်နေပြီ ဖြစ်သည်။ ဖုန်ပေနေသော optical connectors များ၊ ခေါက်ချိုးဖြစ်နေသော fiber patch cables များ သို့မဟုတ် ပျက်စီးနေသော transceivers များကို ချက်ချင်း စစ်ဆေးပါ။

---

## Channelization နှင့် Port Breakouts

High-density switch ports များကို MPO breakout cables များ အသုံးပြု၍ မြန်နှုန်းနိမ့် interfaces အများအပြားအဖြစ် ခွဲထုတ်နိုင်ပါသည်:

```
                 ┌─── Ethernet1/1/1 (25G)
                 ├─── Ethernet1/1/2 (25G)
QSFP28 100G Port ┼─── Ethernet1/1/3 (25G)
                 └─── Ethernet1/1/4 (25G)
```

```bash
# EOS ပေါ်တွင် 100G port တစ်ခုကို 4x 25G ports များအဖြစ် breakout ပြုလုပ်ခြင်း
configure
interface Ethernet1/1
  speed forced 4x25gfull
```

---

**ဆက်လက်လေ့လာရန်:** [အင်တာဗျူး မေးခွန်းများ →](interview-questions.md) — Linux Shell၊ Text Parsing၊ SSH၊ Kernel Networking၊ နှင့် Layer 1 Physical Optics ဆိုင်ရာ စုစည်းထားသော မေးခွန်းဘဏ်။
