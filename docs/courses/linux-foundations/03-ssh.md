# 3 · SSH properly

Every automation tool — Ansible, Netmiko, NAPALM, your own scripts — is SSH
underneath. Setting it up properly is the difference between automation that runs
unattended and automation that stops to ask for a password.

---

## Keys, not passwords

A key pair is two files: a **private key** that never leaves your machine, and a
**public key** you copy to every device. The device challenges you to prove you hold
the private one.

```bash
ssh-keygen -t ed25519 -C "netops@example.com"
```

Use **ed25519** — shorter, faster and stronger than RSA, supported by anything
modern. Fall back to `-t rsa -b 4096` only for genuinely old gear.

```bash
ssh-copy-id user@10.0.0.1        # installs the public key
ssh user@10.0.0.1                # no password
```

If `ssh-copy-id` isn't available, append `~/.ssh/id_ed25519.pub` to the device's
`~/.ssh/authorized_keys` by hand.

!!! warning "Permissions are enforced, and the error doesn't say so"
    SSH refuses to use keys with loose permissions and often fails without
    explaining why:

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519          # private key
    chmod 644 ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/authorized_keys
    ```

    **Private key `600`, directory `700`.** When key auth "just doesn't work,"
    check this first — then run `ssh -v` and read where it gives up.

---

## The agent: unlock once

A passphrase-protected key is the right choice, but you don't want to type the
passphrase on every connection. The agent holds the decrypted key in memory:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l                        # what's loaded
```

**Agent forwarding** (`-A`) lets a remote host use your local keys to connect
onward — convenient for jump hosts, but anyone with root on that host can use your
agent while you're connected. Prefer `ProxyJump` below.

---

## ~/.ssh/config — where the real gain is

Stop typing connection details. This file is read by ssh, scp, rsync, Ansible and
most tooling:

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
    # old gear that needs deprecated algorithms
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
```

Now `ssh r1` works — correct user, correct key, automatically via the bastion.

| Setting | Why |
|---|---|
| `ProxyJump` | reach devices through a bastion, no agent forwarding |
| `ServerAliveInterval` | stop idle sessions being dropped by firewalls |
| `IdentityFile` | which key for which device |
| `ControlMaster` | reuse one connection for many commands — big speedup |

**Connection multiplexing** is worth enabling when scripting against the same host
repeatedly:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 10m
```

The first connection authenticates; subsequent ones reuse the open channel and start
instantly. Ansible gets noticeably faster.

---

## Jump hosts

```bash
ssh -J jump user@10.0.0.1        # one hop
ssh -J jump1,jump2 user@target   # chained
```

`ProxyJump` beats agent forwarding because your private key never reaches the
bastion — the traffic is tunnelled, the authentication stays local.

---

## Running commands remotely

```bash
ssh r1 "show ip bgp summary"                    # one command, then exit
ssh r1 "show running-config" > r1.cfg           # capture output
ssh r1 <<'EOF'                                  # multiple commands
configure
router bgp 65001
EOF
```

At scale, in parallel, with a timeout so one dead device can't stall the run:

```bash
cat devices.txt | xargs -P8 -I{} timeout 10 ssh -o BatchMode=yes {} "show version"
```

**`BatchMode=yes` belongs in every script.** It makes SSH fail immediately rather
than prompting for a password — otherwise an unattended job hangs forever waiting
for input nobody will type.

---

## Host keys

On first connection SSH asks you to verify the host's fingerprint, then stores it in
`~/.ssh/known_hosts`. If it later changes, you get:

```
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

Usually that's a rebuilt or replaced device. Occasionally it's genuinely someone
intercepting the connection.

```bash
ssh-keygen -R 10.0.0.1        # remove the stale entry, then reconnect
```

!!! danger "Don't reach for StrictHostKeyChecking=no"
    It's the common workaround in lab scripts and it disables the protection
    entirely — you'll connect to anything claiming to be that address.

    For genuinely disposable lab devices, scope it narrowly:

    ```
    Host clab-*
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    ```

    Never apply that to `Host *`, and never to anything in production.

---

## When it doesn't work

```bash
ssh -v r1        # verbose; -vvv for more
```

Read for the line where it stops. The useful ones:

| Message | Means |
|---|---|
| `Permission denied (publickey)` | key not accepted — check permissions and `authorized_keys` |
| `Connection refused` | nothing listening — service down or wrong port |
| `Connection timed out` | filtered or unreachable — firewall or routing |
| `no matching key exchange method` | old device, modern client — add `KexAlgorithms` |
| `Host key verification failed` | key changed — `ssh-keygen -R` if expected |

The distinction between **refused** and **timed out** is worth internalising:
refused means something answered and said no (host reachable, service down); timed
out means nothing answered at all (routing or firewall). They point at completely
different problems.

---

**Next:** [Processes, services and logs →](04-services.md).
