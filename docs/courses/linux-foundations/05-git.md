# 5 · Git for network engineers

Configuration is code. The moment you accept that, every question about change
control has an answer that already exists.

Git isn't optional before automation — Ansible playbooks, Python scripts and CI
pipelines all live in it.

---

## What it gives you

| Question | Without git | With git |
|---|---|---|
| What changed last night? | compare backup files by hand | `git diff HEAD~1` |
| Who changed this, and why? | ask around | `git log -p` / `git blame` |
| Roll back that change | find the old file, hope it's right | `git revert` |
| Try something risky | copy the whole directory | `git checkout -b` |
| Review before it ships | email a diff | pull request |

The last row is the real prize: **changes get reviewed before they reach the
network**, and the review has the exact diff attached.

---

## The model

Three places a change can be:

```mermaid
graph LR
    A["Working tree<br/>your edits"] -->|"git add"| B["Staging area<br/>ready to commit"]
    B -->|"git commit"| C["Repository<br/>permanent history"]
    C -->|"git push"| D["Remote<br/>shared"]
    classDef s fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px;
    classDef r fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:14px;
    class A,B,C s; class D r;
```

The **staging area** is what confuses newcomers. It exists so you can commit *some*
of your changes — fix a typo and change a BGP policy in one session, commit them
separately with honest messages.

---

## Daily commands

```bash
git status                  # what's changed — run this constantly
git diff                    # unstaged changes
git diff --staged           # what you're about to commit
git add configs/r1.cfg      # stage one file
git add -p                  # stage selected hunks — very useful
git commit -m "message"
git log --oneline -10
git push
```

`git add -p` walks you through each change and asks whether to stage it. It's also
the best review of your own work before committing.

---

## Config backups in git

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /opt/network-configs

for n in r1 r2 r3; do
  docker exec "clab-bgp-lab-$n" Cli -p 15 -c "show running-config" \
    | sed -e '/^! device:/d' -e '/Last configuration change/d' \
    > "configs/$n.cfg"
done

if ! git diff --quiet; then
  git add configs/
  git commit -m "config snapshot $(date -Iseconds)"
  git push
fi
```

Two details make it work:

**Strip volatile lines.** Timestamps and uptime counters change every poll. Without
the `sed`, every run produces a diff and you stop reading them.

**`git diff --quiet` before committing.** Exit code 0 means no changes — skip the
commit. Otherwise you get an empty commit every five minutes and the history becomes
useless.

Run it from cron and you have automatic change tracking with full history and blame.

---

## Reading history

```bash
git log --oneline --graph --all      # visual history
git log -p configs/r1.cfg            # every change to one file, with diffs
git log --since="1 week ago"
git blame configs/r1.cfg             # who last touched each line
git show <commit>                    # one commit in full
```

```bash
git diff HEAD~1                      # since last commit
git diff main..feature               # between branches
git diff --stat                      # summary of what changed
```

`git blame` on a config file answers "why is this here?" — which is otherwise
unanswerable once the person who added it has left.

---

## Branches

```bash
git checkout -b add-bgp-community    # create and switch
git checkout main                    # switch back
git merge add-bgp-community
git branch -d add-bgp-community      # delete when merged
```

For network work the useful pattern is a branch per change: build it, review the
diff, merge when approved. The branch *is* the change request.

---

## Undoing things

The commands people get wrong under pressure — worth knowing cold:

| Situation | Command | Safe? |
|---|---|---|
| Unstage a file | `git restore --staged <file>` | ✅ |
| Discard local edits | `git restore <file>` | ⚠️ loses your changes |
| Fix the last commit message | `git commit --amend` | ⚠️ not if pushed |
| Undo a pushed commit | `git revert <commit>` | ✅ **the safe one** |
| Move the branch back | `git reset --hard <commit>` | ❌ destroys work |

!!! warning "revert, not reset, on anything shared"
    `git revert` creates a **new** commit undoing the old one. History is preserved
    and everyone else's clone stays consistent.

    `git reset --hard` rewrites history. On a shared branch it breaks every other
    clone, and any commits you dropped are hard to recover.

    In network terms: revert is a rollback change with a change record. Reset is
    editing the logs to pretend it never happened.

---

## .gitignore

**Never commit credentials.** Once pushed, assume they're compromised — removing
them later doesn't remove them from history.

```
# .gitignore
*.key
*.pem
secrets.yml
.env
inventory/passwords.yml
__pycache__/
.venv/
```

For secrets that must live alongside the repo, use `ansible-vault`, SOPS, or a
secrets manager — not a file you hope nobody commits.

!!! danger "If you do commit a secret"
    Rotate it. Immediately. Rewriting history with `filter-repo` or BFG removes it
    from the repo but not from anyone's existing clone, and not from any mirror,
    fork or CI cache that already pulled it.

    Treat the credential as burned and change it. That's the only reliable fix.

---

## Writing commit messages that help

A year later, `git log` is the only record of *why*. Compare:

```
✗ update config
✗ fix
✗ changes

✓ r1: set next-hop-self on iBGP peer to 2.2.2.2
✓ Fixes routes resolving via management interface instead of Ethernet1.
✓ Symptom was a valid-looking BGP route with an unreachable next hop.
```

First line short and specific. Then, if the change isn't obvious, **why** — the
diff already shows *what*.

---

## Interview relevance

Git comes up in every automation-adjacent interview, usually as:

- *"How do you track configuration changes?"* — config in git, automated snapshots,
  diffs reviewed
- *"How would you roll back a bad change?"* — `git revert`, and why not `reset`
- *"How do you review network changes?"* — branch, pull request, diff attached
- *"Where do you keep credentials?"* — never in the repo; vault or secrets manager

Answering these fluently signals you've worked somewhere with real change control.

---

**Next:** [Interview questions →](interview-questions.md).
