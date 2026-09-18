# 🧪 Lab 04 · MACsec Line-Rate Encryption နှင့် Port လုံခြုံရေး {: #lab-04-macsec-line-rate-security }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - 802.1AE MACsec specification ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** IEEE 802.1AE MACsec, MKA (MACsec Key Agreement)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/security-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/security-lab
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
          docker exec -it clab-security-lab-leaf1 Cli
          ```

---
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: IEEE 802.1AE MACsec လုပ်ဆောင်ချက်များ {: #technology-deep-dive-ieee-802-1ae-macsec-mechanics }

**MACsec (Media Access Control Security)** သည် ရုပ်ပိုင်းဆိုင်ရာ fiber link များတစ်လျှောက် line-rate point-to-point encryption၊ data integrity၊ နှင့် replay protection တို့ကို ပေးဆောင်ရန် Layer 2 (Ethernet) တွင် အလုပ်လုပ်ပါသည်။ Layer 3 တွင် အလုပ်လုပ်သော IPsec နှင့် မတူဘဲ MACsec သည် VLAN tag များ အပါအဝင် Ethernet payload တစ်ခုလုံးကို encrypt ပြုလုပ်ပေးပါသည်:

```
+-------------------+-------------------+-------------------+-------------------+
|  MACsec Header    |  Encrypted 802.1Q | Encrypted IP      | ICV Integrity     |
|  (SecTAG)         |  VLAN Tag         | Payload           | Check Value       |
+-------------------+-------------------+-------------------+-------------------+
```

```eos
macsec profile MACSEC-PROFILE-DC
   cipher aes256-gcm
   key-server priority 16
!
interface Ethernet1
   macsec profile MACSEC-PROFILE-DC
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show macsec status` တွင် တက်ကြွနေသော 802.1AE AES-256-GCM hardware encryption session များကို အောင်မြင်စွာ ပြသရပါမည်။
