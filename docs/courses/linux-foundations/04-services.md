# 4 · Processes, services and logs

When automation fails at 3am, this is the page. Output below was captured from the
lab host.

---

## Processes

```bash
ps aux | grep ssh          # find a process
pgrep -a python            # cleaner: PID + command
kill <pid>                 # ask it to stop (SIGTERM)
kill -9 <pid>              # force (SIGKILL) — last resort
top / htop                 # live view
```

`kill -9` gives the process no chance to clean up — unwritten files stay unwritten,
locks stay held. Try plain `kill` first and give it a few seconds.

```bash
uptime                     # load average
free -h                    # memory
df -h                      # disk — check this when things fail mysteriously
du -sh * | sort -h         # what's using the space
```

**A full disk causes weird, unrelated-looking failures.** `df -h` early.

---

## systemd

Almost every Linux service is managed by systemd now.

```bash
systemctl status docker           # is it running, recent log lines
systemctl start|stop|restart docker
systemctl enable docker           # start at boot
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

!!! tip "`enable` and `start` are different"
    `start` runs it now. `enable` makes it run at boot. Neither implies the other —
    a service you started but never enabled disappears after a reboot, which is a
    genuinely common surprise. `enable --now` does both.

---

## journalctl

```bash
journalctl -u docker              # logs for one unit
journalctl -u docker -f           # follow, like tail -f
journalctl -u docker --since "10 min ago"
journalctl -p err --since today   # errors only
journalctl -u docker -n 50        # last 50 lines
journalctl --disk-usage
```

`-p err` filters by priority and is the fastest way into a noisy log. Combine with
`--since` to scope to when the problem started:

```bash
journalctl -p err --since "2026-08-03 08:00" --until "2026-08-03 09:00"
```

Older systems and application logs still use plain files in `/var/log/`:

```bash
tail -f /var/log/syslog
grep -i error /var/log/syslog | tail -20
```

---

## Host-side network tools

### ss — what's listening, what's connected

Replaces `netstat`.

```bash
ss -tlnp                   # TCP, listening, numeric, with process
ss -tn state established   # current connections
ss -tn dport = :179        # BGP sessions
```

| Flag | Means |
|---|---|
| `-t` / `-u` | TCP / UDP |
| `-l` | listening only |
| `-n` | numeric — don't resolve names |
| `-p` | show the owning process (needs root) |

"Is the service actually listening, and on which address?" is answered here. A
service bound to `127.0.0.1` rather than `0.0.0.0` is reachable only from the host
itself — a frequent cause of "the port is open but I can't connect."

### curl — HTTP and APIs

Increasingly the network engineer's tool, since NOS APIs are HTTP.

```bash
curl -s -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" https://api.github.com
```
```
http_code=200 time=0.062238s
```

```bash
curl -s https://api.example.com/devices | jq '.'          # JSON API
curl -sk https://device/restconf/data/...                 # -k: skip cert check (labs only)
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"test"}' https://api.example.com/x
curl -u admin:pass https://device/api                     # basic auth
```

| Flag | Use |
|---|---|
| `-s` | silent — no progress bar, good in scripts |
| `-o /dev/null -w` | discard body, print just the metrics you asked for |
| `-k` | ignore TLS validation — **lab only** |
| `-i` | include response headers |
| `-X` / `-d` / `-H` | method, body, header |

### Reachability and path

```bash
ping -c4 10.0.12.1
mtr -rwc 10 8.8.8.8        # traceroute + ping combined, best of both
traceroute 10.0.12.1
nc -zv 10.0.12.1 179       # is TCP/179 open?
nc -zvu 10.0.12.1 4789     # UDP check
```

`mtr` is the one to reach for on intermittent problems — it runs continuously and
shows loss per hop, which a single traceroute can't.

`nc -zv` answers "is this port reachable" without needing a client for the protocol.
Useful for confirming a BGP or VXLAN port is open before blaming the protocol.

### DNS

```bash
dig example.com                # full answer
dig +short example.com         # just the address
dig @8.8.8.8 example.com       # ask a specific server
dig -x 8.8.8.8                 # reverse lookup
host example.com               # quick alternative
```

!!! note "`dig` may not be installed"
    On the lab host it isn't:

    ```
    -bash: line 1: dig: command not found
    ```

    Install with `apt install dnsutils` (Debian/Ubuntu) or `dnf install bind-utils`
    (RHEL family). `getent hosts example.com` works without it and uses the system
    resolver, which is sometimes what you actually want to test.

---

## Scheduling

```bash
crontab -e                 # edit your crontab
crontab -l                 # list
```

```
# m h dom mon dow  command
*/5 * * * *  /home/netops/check-bgp.sh >> /var/log/bgp-check.log 2>&1
0 2 * * *    /home/netops/backup-configs.sh
```

Five fields: minute, hour, day-of-month, month, day-of-week.

!!! warning "cron has almost no environment"
    No `PATH` to speak of, no shell profile, a different working directory. A script
    that runs fine interactively frequently fails under cron.

    **Use absolute paths for everything**, redirect both streams to a log
    (`>> log 2>&1`), and test with `env -i /bin/sh -c '/path/to/script.sh'` to
    approximate cron's bare environment.

---

## A diagnostic order that works

When something is broken and you don't know where to start:

```mermaid
graph LR
    A["1 · Resources<br/>df -h, free -h"] --> B["2 · Service<br/>systemctl status"]
    B --> C["3 · Logs<br/>journalctl -p err"]
    C --> D["4 · Listening<br/>ss -tlnp"]
    D --> E["5 · Reachable<br/>nc -zv, mtr"]
    classDef s fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px;
    classDef r fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:14px;
    class A,B,C,D s; class E r;
```

Resources first, because a full disk or exhausted memory produces failures that look
like anything else. Then whether the service is even running, then what it said
before it failed, then whether it's listening, then whether you can reach it.

---

**Next:** [Git for network engineers →](05-git.md).
