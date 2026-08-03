# Interview questions — Linux

These come up in automation, NetDevOps and SRE interviews, and increasingly in plain
network-engineer ones.

---

## Shell

??? question "What does an exit code of 0 mean, and why does it matter?"
    Success. Non-zero is failure, with different numbers for different failures.
    It matters because it's how scripts make decisions — `&&`, `||`, `if`, and
    whether CI marks a job failed. A script that always exits 0 can never fail a
    pipeline, however broken it is.

??? question "What does `set -euo pipefail` do and why use it?"
    `-e` exits on any command failure; `-u` errors on undefined variables, catching
    typos; `-o pipefail` makes a pipeline fail if *any* stage fails rather than only
    the last. Without `pipefail`, `false | true` succeeds — which is how a broken
    backup script reports success for months.

??? question "Why quote variables in shell?"
    Unquoted, the shell word-splits on whitespace and expands globs. `rm $FILE`
    where FILE is `my config.txt` tries to delete two files. `"$FILE"` passes it as
    one argument. Quote by default; the exceptions are deliberate.

??? question "Difference between `>` and `>>`, and what's `2>&1`?"
    `>` overwrites, `>>` appends. `2>&1` redirects stderr into wherever stdout is
    currently going, merging the streams — so `cmd > log 2>&1` captures both. Order
    matters: `2>&1 > log` sends stderr to the *old* stdout, which is usually not
    what's intended.

??? question "You need to check BGP on 200 devices and only hear about failures. Approach?"
    Loop over a device list, run the check, and test for the **failure** states
    rather than the success one — print nothing when healthy so silence means fine.
    Add `timeout` so one dead device can't stall the run, `xargs -P` for
    parallelism, and exit non-zero if anything failed so CI or cron can act on it.

??? question "Why is testing only for the success string a bug?"
    Because it's silent during an outage. `grep -q Estab` passes if any one peer is
    up while others are down, and produces no output either way. Match every
    terminal state you'd act on, or count and compare against expected.

---

## Text processing

??? question "When would you use awk over cut?"
    Whenever fields are separated by variable whitespace — which is nearly all
    device output. `cut -d' '` treats each space as a separator, so aligned columns
    produce empty fields. `awk` collapses runs of whitespace automatically.

??? question "Parse `show ip bgp summary` for peers that aren't established."
    ```bash
    show ip bgp summary | awk '$1 ~ /^[0-9]+\./ && $9 != "Estab" {print $1}'
    ```
    The `$1 ~ /^[0-9]+\./` guard restricts processing to lines starting with an IP,
    skipping headers and banners.

??? question "Why prefer JSON output and jq over parsing text?"
    Text output is formatted for humans and changes between software versions —
    column positions shift and your `$9` silently becomes the wrong field. JSON keys
    are part of the API and far more stable. Use `| json` plus `jq` where the device
    supports it, and reserve awk for devices that don't.

??? question "Explain `grep ERROR app.log | awk '{print $5}' | sort | uniq -c | sort -rn`"
    A frequency table. Filter to error lines, extract field 5, sort so identical
    values are adjacent (required by `uniq`), count each run, then sort numerically
    descending so the most common appears first. It's the standard way to find what's
    failing most in any log.

??? question "What is `<(command)`?"
    Process substitution — it presents a command's output as if it were a file, so
    tools expecting filenames can consume it. `diff <(ssh r1 "show run") <(ssh r2
    "show run")` compares two live devices with no temporary files.

---

## SSH

??? question "Why key-based authentication rather than passwords?"
    It works unattended, which passwords can't. It's also stronger, revocable per
    key, and leaves no shared secret on the device. Any automation running from
    cron or CI requires it.

??? question "Key auth isn't working. What do you check?"
    Permissions first — SSH silently refuses keys that are too permissive:
    `~/.ssh` at 700, private key at 600, `authorized_keys` at 600. Then `ssh -v`
    and read where it stops. Then confirm the public key actually landed in the
    device's `authorized_keys`.

??? question "What's ProxyJump and why prefer it to agent forwarding?"
    `ProxyJump` tunnels the connection through a bastion while authentication stays
    on your machine. Agent forwarding exposes your agent socket on the bastion,
    where anyone with root can use your keys for as long as you're connected.

??? question "Why does BatchMode=yes belong in scripts?"
    It makes SSH fail immediately instead of prompting for a password. Without it,
    an unattended job that hits an auth problem hangs indefinitely waiting for input
    nobody will type — the job appears stuck rather than failed.

??? question "Difference between 'Connection refused' and 'Connection timed out'?"
    **Refused** means something answered and rejected the connection — the host is
    reachable and the service isn't listening. **Timed out** means nothing answered
    at all — routing, firewall, or the host is down. Completely different problems,
    and the distinction saves a lot of time.

??? question "Host key verification failed. What now?"
    Establish whether the change was expected — a rebuilt or replaced device
    legitimately has a new key. If so, `ssh-keygen -R <host>` and reconnect. If not,
    investigate before connecting; that warning is the mechanism that catches
    interception. Don't reflexively set `StrictHostKeyChecking=no`.

---

## Services and logs

??? question "Difference between systemctl start and enable?"
    `start` runs it now; `enable` makes it start at boot. Neither implies the other,
    so a service started but never enabled quietly disappears after a reboot.
    `enable --now` does both.

??? question "How do you find why a service failed?"
    `systemctl status <unit>` for state and the last few lines, then
    `journalctl -u <unit> -p err --since "<when it broke>"` to narrow to errors in
    the relevant window. Check `df -h` too — a full disk causes failures that look
    like anything else.

??? question "What does ss tell you that ping doesn't?"
    Whether the service is listening, and on which address. A daemon bound to
    `127.0.0.1` instead of `0.0.0.0` is reachable only from the host itself, so ping
    succeeds while connections fail. `ss -tlnp` shows the bind address and owning
    process.

??? question "How would you check a device's TCP/179 is reachable without a BGP client?"
    `nc -zv <host> 179`. It attempts the TCP connection and reports success or
    failure without needing to speak the protocol — separating "the port is
    blocked" from "BGP is misconfigured."

??? question "Why is mtr often better than traceroute?"
    It runs continuously and reports per-hop loss over many probes, so intermittent
    problems show up. A single traceroute is one sample and can easily miss loss —
    or show alarming ICMP de-prioritisation at intermediate hops that isn't real.

??? question "A script works interactively but fails under cron. Why?"
    cron runs with a minimal environment — almost no `PATH`, no shell profile, a
    different working directory. Use absolute paths throughout, redirect both
    streams to a log, and test with `env -i /bin/sh -c '/path/script.sh'` to
    approximate it.

---

## Git

??? question "How would you track network configuration changes?"
    Configs in git, snapshotted on a schedule. Strip volatile lines (timestamps,
    uptime) before committing, and skip the commit when `git diff --quiet` shows
    nothing changed — otherwise the history fills with noise and nobody reads the
    diffs.

??? question "Roll back a bad change that's already pushed. revert or reset?"
    **`revert`.** It creates a new commit undoing the old one, so history is intact
    and every other clone stays consistent. `reset --hard` rewrites history and
    breaks everyone else's clone. Revert is a rollback with a change record; reset
    is pretending it never happened.

??? question "What is the staging area for?"
    It lets you commit a subset of your changes. If you fixed a typo and changed a
    BGP policy in one sitting, you can stage and commit them separately with honest
    messages. `git add -p` selects individual hunks and doubles as a self-review.

??? question "You committed a password. What do you do?"
    **Rotate the credential immediately.** History rewriting removes it from the
    repo but not from existing clones, forks, mirrors or CI caches. Assume it's
    compromised — changing it is the only reliable fix. Then add the file to
    `.gitignore` and move the secret to a vault.

??? question "How does git improve network change management?"
    Changes go on a branch and get reviewed as a diff before reaching the network.
    History shows who changed what and why, `blame` explains why a line exists years
    later, and rollback is a single command rather than an archaeology exercise.
