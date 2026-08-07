# 7 · Layer 1 optics & physical infrastructure

At hyperscale network sites (Google, AWS, Meta), over 40% of intermittent link flaps,
silent packet drops, and degraded latency stem directly from physical layer issues.
This module covers optical transceivers, fiber physics, Digital Optical Monitoring (DOM),
Forward Error Correction (FEC), and physical link diagnostics.

---

## Form Factors & Transceiver Optics

Modern data centers use standardized pluggable optical transceivers.

| Form Factor | Max Speed | Typical Use Case | Connector Type |
|---|---|---|---|
| **SFP+** | 10 Gbps | Legacy top-of-rack host links | LC Duplex |
| **SFP28** | 25 Gbps | Server NIC to Leaf switch links | LC Duplex |
| **QSFP28** | 100 Gbps | Leaf-to-Spine links, 100G host connections | LC / MPO-12 |
| **QSFP-DD** | 400 Gbps | High-density Spine & Fabric interconnects | MPO-16 / CS / SN |
| **OSFP** | 400G / 800G | Next-gen hyperscale & AI/ML cluster fabrics | MPO-16 / Dual LC |

---

## Transceiver Optical Specifications & Designations

Selecting the proper transceiver requires matching optical reach, fiber type, modulation, connector type, and multiplexing standard.

| Designation | Reach | Wavelength (\(\lambda\)) | Fiber Type | Connector | Optical Mux / Modulation | Typical Application |
|---|---|---|---|---|---|---|
| **SR / SR4 / SR8** | Short Reach (70m–100m) | 850 nm | MMF (OM3/OM4) | MPO-12 / MPO-16 / LC | Parallel VCSEL lasers | Host-to-Leaf, intra-rack patching |
| **DR / DR4** | Data Center Reach (500m) | 1310 nm | SMF (OS2) | MPO-12 / SN / CS | Parallel PAM4 (1 lane/fiber pair) | Leaf-to-Spine intra-datacenter |
| **FR / FR4** | Fiber Reach (2 km) | 1271–1331 nm | SMF (OS2) | LC Duplex | CWDM4 (4 wavelengths on 1 pair) | Campus & inter-building fabric |
| **LR / LR4 / LR8** | Long Reach (10 km) | 1295–1309 nm | SMF (OS2) | LC Duplex | LAN-WDM (Tight 800GHz grid) | Metro & inter-facility link |
| **ER / ER4** | Extended Reach (40 km) | 1550 nm / LAN-WDM | SMF (OS2) | LC Duplex | EML Laser + APD Receiver | Regional DCI backbone links |
| **ZR / ZR4** | Zephyr Reach (80 km) | 1550 nm | SMF (OS2) | LC Duplex | Amplified SMF / High Sensitivity | Long-haul regional transit |
| **400G ZR / OpenZR+** | Coherent (80km–120km+) | C-Band (1550 nm) | SMF (OS2) | LC Duplex | Coherent DSP / QPSK & 16-QAM | IP-over-DWDM direct router-to-router DCI |
| **BiDi (Bidirectional)** | Single-Strand (100m–10km) | 1270nm / 1330nm | MMF / SMF | Simplex LC | WDM Tx/Rx split on single strand | Doubling fiber density on legacy cable runs |
| **CWDM / DWDM** | Multi-Channel (10km–80km+) | 1270–1610nm (CWDM)<br>1528–1565nm (DWDM) | SMF (OS2) | LC Duplex | 20nm spacing (CWDM) / 50-100GHz grid (DWDM) | Passive optical multiplexing |

---

### Optical Technology & Wavelength Multiplexing Mechanics

Understanding how light is multiplexed and modulated dictates cost and optic compatibility:

1. **Multi-Mode VCSEL (SR / SR4)**:
   - Uses vertical-cavity surface-emitting lasers operating at **850nm**.
   - Requires wider 50µm core Multi-Mode Fiber (OM3/OM4).
   - High speed (100G/400G) uses **parallel ribbon fibers** via MPO connectors (e.g., 4 Tx + 4 Rx fibers for 100GBASE-SR4).

2. **Uncooled CWDM4 (FR4 / CWDM)**:
   - Coarse Wavelength Division Multiplexing uses 4 distinct wavelengths spaced 20nm apart (**1271nm, 1291nm, 1311nm, 1331nm**).
   - Combines 4 optical channels inside the transceiver onto a **single duplex LC Single-Mode Fiber pair**, saving structured cabling.
   - Uncooled lasers reduce power consumption and module cost.

3. **Precision LAN-WDM (LR4 / ER4)**:
   - Uses tighter 800GHz (~4.5nm) channel spacing around the zero-dispersion 1310nm window (**1295.56nm, 1300.05nm, 1304.58nm, 1309.14nm**).
   - Requires TEC (Thermoelectric Cooler) inside the optic to maintain exact laser temperature and prevent channel overlap across 10km+ distances.

4. **Coherent IP-over-DWDM (400G ZR / OpenZR+)**:
   - Replaces intensity modulation with **Coherent Phase Modulation** (QPSK or 16-QAM) driven by an onboard Digital Signal Processor (DSP).
   - Allows 400Gbps interfaces to plug directly into switch/router QSFP-DD ports and bridge 120km+ over DWDM line systems **without external transponder boxes**.

!!! warning "Never mix MMF and SMF"
    Multi-mode fiber uses a wider 50 µm core for LED/VCSEL transmitters; Single-mode uses a
    narrow 9 µm core for precision lasers. Connecting an MMF patch cable to an SMF optic
    causes severe insertion loss, optical reflection, and complete link failure.

---

## Digital Optical Monitoring (DOM / DDM)

DOM allows switches and hosts to read internal optical metrics in real time via I2C bus.

Key DOM metrics:
1. **Tx Power (Transmitter)**: Optical power emitted by laser (in dBm or µW).
2. **Rx Power (Receiver)**: Optical power received at local optic (in dBm or µW).
3. **Laser Bias Current**: Electrical current driving the laser diode (mA). High bias signals laser degradation.
4. **Temperature**: Operating temperature of optical module (°C).

### Optical Power Math: mW to dBm

Optical power is measured logarithmically in **dBm** (decibel-milliwatts):

\[
P_{\text{dBm}} = 10 \cdot \log_{10}\left(\frac{P_{\text{mW}}}{1\text{ mW}}\right)
\]

- **\(0\text{ dBm}\)** = \(1.0\text{ mW}\)
- **\(-3\text{ dBm}\)** = \(0.5\text{ mW}\) (3 dB loss = 50% power drop)
- **\(-10\text{ dBm}\)** = \(0.1\text{ mW}\)

### Reading DOM in EOS and Linux

```bash
# Arista cEOS CLI: Inspect optical DOM metrics and alarm thresholds
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
# Linux host CLI: Query EEPROM and DOM from host NIC
ethtool -m eth0
```

---

## Forward Error Correction (FEC) & Bit Error Rate (BER)

At speeds of 100G and 400G, high frequency electrical signals experience inter-symbol
interference. **FEC** adds parity bits to correct random bit errors in real time.

### Correctable vs Uncorrectable FEC Errors

- **Correctable FEC Errors**: Bit flips detected and successfully repaired by the receiver hardware. Low rates are normal.
- **Uncorrectable FEC Errors**: Packet corruption too severe for FEC algorithms to repair. **Result: Frame dropped at PHY layer.**

```bash
# Inspecting FEC statistics on Arista EOS
show interfaces Ethernet1/1 phy detail
```

```
Ethernet1/1:
  FEC Mode: RS-FEC (Reed-Solomon)
  Correctable Codewords:   142850
  Uncorrectable Codewords: 0
```

!!! danger "Uncorrectable FEC = Physical Degradation"
    If `Uncorrectable Codewords` is incrementing, the link is dropping packets before
    IP routing or TCP can see them. Check for dirty optical connectors, bent fiber patch cables, or degrading transceivers.

---

## Channelization & Port Breakouts

High-density switch ports can be broken out into multiple lower-speed interfaces using MPO breakout cables.

```
                 ┌─── Ethernet1/1/1 (25G)
                 ├─── Ethernet1/1/2 (25G)
QSFP28 100G Port ┼─── Ethernet1/1/3 (25G)
                 └─── Ethernet1/1/4 (25G)
```

```bash
# Configuring 100G port breakout into 4x 25G ports on EOS
configure
interface Ethernet1/1
  speed forced 4x25gfull
```

---

**Next:** [Interview Questions →](interview-questions.md) — test your overall knowledge on Linux, Shell, SSH, Kernel Networking, and Layer 1 Physical Optics.
