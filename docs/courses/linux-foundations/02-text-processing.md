# 2 · Parsing device output

Network devices emit text designed for humans. Automation needs data. This page is
about the gap between the two.

---

## grep — find the lines

```bash
grep Estab summary.txt              # lines containing Estab
grep -v Estab summary.txt           # lines NOT containing it
grep -i estab summary.txt           # case-insensitive
grep -c Estab summary.txt           # count matches
grep -q Estab summary.txt           # silent; exit code only
grep -E "Idle|Active" summary.txt   # regex alternation
grep -A2 -B1 "Ethernet1" cfg.txt    # 2 lines after, 1 before
```

The two that matter most in scripts:

- **`-q`** — no output, just an exit code. The idiom for "does this appear?"
- **`-E`** — extended regex, so you can write `Idle|Active` and catch every failure
  state in one pass.

```bash
# every interface stanza in a config
grep -A5 "^interface" running-config.txt
```

---

## awk — pick out fields

`awk` splits each line into fields on whitespace and lets you print or test them.
`$1` is the first field, `$2` the second, `$0` the whole line.

Run against the live Phase 1 fabric:

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" \
  | awk '/Estab/ {print $1, $3, $9}'
```

```
2.2.2.2 65001 Estab
10.0.13.3 65002 Estab
```

That's the whole pattern: **`/match/ { action }`**. Only lines matching the pattern
get the action.

More that earns its keep:

```bash
awk '{print $1}'                        # first column
awk -F: '{print $1}'                    # split on ':' instead
awk '$3 > 100 {print $1}'               # numeric comparison
awk '/Estab/ {n++} END {print n+0}'     # count matches
awk 'NF'                                # drop blank lines
awk '{print NR": "$0}'                  # number the lines
```

A practical one — flag peers that aren't established:

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" \
  | awk '$1 ~ /^[0-9]+\./ && $9 != "Estab" {print "DOWN: " $1}'
```

`$1 ~ /^[0-9]+\./` restricts it to lines starting with an IP, skipping headers.

!!! tip "Why awk beats cut"
    `cut -d' ' -f3` treats every space as a separator, so runs of spaces produce
    empty fields — and device output is full of aligned columns. `awk` collapses
    whitespace automatically, which is almost always what you want.

---

## sed — edit the stream

Mostly for substitution:

```bash
sed 's/old/new/'          # first occurrence per line
sed 's/old/new/g'         # all occurrences
sed 's|10.0.12|10.0.99|g' # alternative delimiter — no escaping slashes
sed -n '5,10p'            # print lines 5-10 only
sed '/^!/d'               # delete comment lines
sed -i.bak 's/a/b/g' f    # edit in place, keeping f.bak
```

Cleaning a config for diffing — strip comments, blanks and timestamps:

```bash
sed -e '/^!/d' -e '/^$/d' -e '/Last configuration change/d' running-config.txt
```

That matters: without it, every diff shows a changed timestamp and you learn to
ignore diffs. See [git](05-git.md).

!!! warning "`sed -i` without a suffix"
    On GNU/Linux `sed -i` edits in place. On macOS/BSD it requires an argument, so
    `sed -i 's/a/b/'` consumes your next argument as the suffix and fails
    confusingly. `sed -i.bak` works on both — and keeps a backup.

---

## jq — for JSON

Modern NOSes speak JSON, which is far better than scraping text. EOS takes
`| json` on most show commands, and REST/gNMI APIs return it natively.

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary | json" \
  | jq '.vrfs.default.peers | keys'
```

```bash
jq '.'                          # pretty-print
jq -r '.name'                   # raw output, no quotes
jq '.items[]'                   # iterate an array
jq '.items[] | select(.up)'     # filter
jq -r '.peers | to_entries[] | "\(.key) \(.value.peerState)"'
```

`-r` is important in scripts — without it strings keep their quotes and comparisons
fail.

!!! tip "Prefer JSON to text whenever the device offers it"
    Text output is formatted for humans and **changes between software versions** —
    column widths shift, headers get reworded, and your `awk $9` silently becomes
    the wrong field.

    JSON keys are part of the API and far more stable. If a device supports
    `| json`, use it and parse with `jq`. Reserve `awk` for devices that don't.

---

## sort, uniq, and counting

```bash
sort file                  # alphabetical
sort -u file               # sorted, deduplicated
sort -n file               # numeric
sort -k3 file              # by third column
uniq -c                    # count runs — input must be sorted
```

The classic combination — find the most common thing in a log:

```bash
grep ERROR app.log | awk '{print $5}' | sort | uniq -c | sort -rn | head
```

Read right to left: extract field 5, sort so identical values are adjacent, count
each run, sort numerically descending, show the top few. That's a frequency table in
one line, and it works on any log you'll ever meet.

---

## Comparing two devices

```bash
diff <(ssh r1 "show running-config") <(ssh r2 "show running-config")
```

`<(...)` is **process substitution** — it makes a command's output look like a file.
No temporary files, and it works with any tool expecting filenames.

```bash
# ignore whitespace and comment lines
diff -w <(sed '/^!/d' r1.cfg) <(sed '/^!/d' r2.cfg)
```

---

## Putting it together

A config drift check — grab the config, normalise it, compare against the
last-known-good:

```bash
#!/usr/bin/env bash
set -euo pipefail

for n in r1 r2 r3; do
  docker exec "clab-bgp-lab-$n" Cli -p 15 -c "show running-config" \
    | sed -e '/^!/d' -e '/^$/d' \
    > "current/$n.cfg"

  if ! diff -q "baseline/$n.cfg" "current/$n.cfg" >/dev/null 2>&1; then
    echo "=== $n DRIFTED ==="
    diff "baseline/$n.cfg" "current/$n.cfg" || true
  fi
done
```

Silent when nothing changed. `|| true` stops `set -e` killing the script, since
`diff` exits 1 when files differ — a normal outcome here, not an error.

---

**Next:** [SSH properly →](03-ssh.md) — the transport all of this runs over.
