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

## Fiber Media & Wavelengths

Light travels down fiber optic cables via total internal reflection. Choosing the correct
media depends on reach and transceiver optical wavelength.

```
Multi-Mode Fiber (MMF)    ── 850nm (Short Reach, SR / SR4) ──≤ 100m
Single-Mode Fiber (SMF)   ── 1310nm / 1550nm (Longer Reach, LR4 / FR4 / DR4) ──≤ 10km+
```

| Type | Core Diameter | Wavelength | Standard | Max Distance |
|---|---|---|---|---|
| **MMF (OM3 / OM4)** | 50 µm | 850 nm | 100GBASE-SR4 | 70m - 100m |
| **SMF (Single-Mode)** | 9 µm | 1310 nm | 100GBASE-CWDM4 / LR4 | 2km - 10km |
| **SMF (Single-Mode)** | 9 µm | 1310 nm | 400GBASE-DR4 / FR4 | 500m - 2km |

!!! warning "Never mix MMF and SMF"
    Multi-mode fiber uses a wider core for LED/VCSEL transmitters; Single-mode uses a
    narrow 9 µm core for precision lasers. Connecting an MMF patch cable to an SMF optic
    causes severe insertion loss and link failure.

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
