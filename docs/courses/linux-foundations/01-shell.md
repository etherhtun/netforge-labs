# 1 · Shell fluency

The shell is the network engineer's force multiplier. Everything here builds toward
one thing: **doing something to every device at once, and being told only about the
ones that are wrong.**

---

## Pipes: the whole idea

A pipe sends one command's output into the next as input. Small tools, chained.

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | grep Estab | wc -l
```

Three trivial tools — run a command, filter lines, count them — answering "how many
BGP peers are up." No tool knows about the others, and none of them knows about BGP.

That's the Unix bargain: nothing does much alone, and combinations do almost
anything.

---

## Redirection and the two output streams

Every command writes to **stdout** (normal output) and **stderr** (errors). They're
separate on purpose, so you can keep one and discard the other.

| Syntax | Does |
|---|---|
| `> file` | stdout to file, **overwriting** |
| `>> file` | stdout to file, appending |
| `2> file` | stderr to file |
| `2>&1` | stderr into stdout — merge them |
| `> file 2>&1` | both to file |
| `2>/dev/null` | discard errors |
| `\| tee file` | to file **and** the screen |

```bash
# capture configs, log errors separately
for n in r1 r2 r3; do
  docker exec clab-bgp-lab-$n Cli -p 15 -c "show running-config" \
    > configs/$n.cfg 2>> errors.log
done
```

!!! warning "`>` destroys the file before the command runs"
    `sort file.txt > file.txt` gives you an empty file. The shell truncates the
    target *first*, then runs the command against nothing. Write to a new file and
    move it.

---

## Exit codes: how a script knows it worked

Every command returns a status. **`0` means success**, anything else is a failure —
backwards from what most people expect, but it lets different failures have
different numbers.

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" >/dev/null
echo $?      # 0
```

This is what makes conditionals work. `grep` returns 0 when it finds something,
1 when it doesn't:

```bash
if docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | grep -q Estab; then
  echo "BGP is up"
else
  echo "BGP is DOWN"
fi
```

`-q` means quiet — print nothing, just set the exit code. That's the idiom for
"test whether this appears."

**Chaining on success or failure:**

```bash
command_a && command_b     # b only if a succeeded
command_a || command_b     # b only if a failed
command_a ; command_b      # b regardless
```

```bash
mkdir -p backups && cp *.cfg backups/     # don't copy if mkdir failed
ping -c1 10.0.12.1 >/dev/null || echo "10.0.12.1 unreachable"
```

---

## Variables and quoting

```bash
DEVICE="clab-bgp-lab-r1"
docker exec "$DEVICE" Cli -p 15 -c "show version"
```

**Quote your variables.** Unquoted, the shell splits on spaces and expands `*`:

```bash
FILE="my config.txt"
rm $FILE      # ✗ tries to delete "my" AND "config.txt"
rm "$FILE"    # ✓
```

| Quoting | Behaviour |
|---|---|
| `"$VAR"` | expands the variable — **the default choice** |
| `'$VAR'` | literal `$VAR`, no expansion |
| `$(command)` | run it, substitute the output |

```bash
PEERS=$(docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | grep -c Estab)
echo "r1 has $PEERS peers"
```

!!! tip "Heredocs, and the trap you already met"
    A heredoc feeds a block of text to a command:

    ```bash
    docker exec -i clab-bgp-lab-r1 Cli -p 15 <<'EOF'
    configure
    router bgp 65001
    EOF
    ```

    **Quoting the delimiter matters.** `<<'EOF'` passes the text literally;
    `<<EOF` expands `$variables` inside it. Use quoted unless you specifically want
    substitution — device configs are full of `$` characters.

    And a heredoc into `docker exec` needs **`-i`**, or stdin is never attached and
    nothing runs. See [lab troubleshooting](../../getting-started/lab-troubleshooting.md).

---

## Loops: where it stops being typing

```bash
for n in r1 r2 r3; do
  printf "%-4s " "$n"
  docker exec clab-bgp-lab-$n Cli -p 15 -c "show ip bgp summary" | grep -c Estab
done
```

Run against the live Phase 1 fabric:

```
r1   2
r2   1
r3   1
```

Loop over a file of device names instead and the same code handles a thousand:

```bash
while read -r host; do
  echo "=== $host ==="
  ssh "$host" "show ip bgp summary"
done < devices.txt
```

`read -r` stops backslashes being interpreted — always use it.

---

## Report only what's broken

Listing everything doesn't scale: nobody reads three hundred lines of "ok." A useful
check is **silent when healthy**.

```bash
for n in r1 r2 r3; do
  if docker exec clab-bgp-lab-$n Cli -p 15 -c "show ip bgp summary" 2>/dev/null \
     | grep -qE "Idle|Active"; then
    echo "$n: DOWN PEER"
  else
    echo "$n: ok"
  fi
done
```

```
r1: ok
r2: ok
r3: ok
```

Drop the `else` branch and it prints nothing at all when the fabric is healthy —
which is what you want in cron or CI. Silence means fine; output means look.

!!! warning "Match every failure state, not just the good one"
    `grep -q Estab` tests that *something* is established. It stays quiet when a
    second peer is down. Test for the **bad** states — `Idle|Active` — or count and
    compare against what you expect.

    A check that only recognises success is silent during an outage, and silence
    looks identical to healthy.

---

## Writing it as a script

```bash
#!/usr/bin/env bash
set -euo pipefail

# check-bgp.sh — report devices with any peer not established
DEVICES=("r1" "r2" "r3")
FAILED=0

for n in "${DEVICES[@]}"; do
  out=$(docker exec "clab-bgp-lab-$n" Cli -p 15 -c "show ip bgp summary" 2>/dev/null) || {
    echo "$n: UNREACHABLE"; FAILED=1; continue
  }
  if grep -qE "Idle|Active" <<<"$out"; then
    echo "$n: DOWN PEER"; FAILED=1
  fi
done

exit $FAILED
```

```bash
chmod +x check-bgp.sh
./check-bgp.sh
```

**`set -euo pipefail` belongs at the top of every script you write:**

| Flag | Effect |
|---|---|
| `-e` | exit on any command failure |
| `-u` | error on undefined variables — catches typos |
| `-o pipefail` | a pipeline fails if **any** stage fails, not just the last |

Without `pipefail`, `false \| true` succeeds. That's how a broken backup script
reports success for months.

The script **exits non-zero when anything is wrong**, which is what lets CI, cron
or Ansible act on it.

---

## Worth knowing

| Command | Use |
|---|---|
| `history \| grep ssh` | find that command you ran last week |
| `!!` / `sudo !!` | repeat last command, optionally with sudo |
| `Ctrl-R` | search history interactively |
| `cmd1 \| tee out.txt \| cmd2` | tap a pipeline mid-flow |
| `watch -n5 'cmd'` | re-run every 5s |
| `timeout 10 cmd` | give up after 10s — **essential** for unreachable devices |
| `xargs -P8` | run 8 in parallel |

```bash
# poll a fabric in parallel, 8 at a time, none hanging longer than 10s
cat devices.txt | xargs -P8 -I{} timeout 10 ssh {} "show ip bgp summary"
```

---

**Next:** [Parsing device output →](02-text-processing.md) — turning `show` output
into data.
