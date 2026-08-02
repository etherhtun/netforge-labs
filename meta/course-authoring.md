# Course Authoring Standard

Internal. **Not portal content** — `meta/` is excluded from MkDocs.

How to build a NetForge course so every one feels the same. Read
[`../CLAUDE.md`](../CLAUDE.md) first.

---

## The build sequence (never skip step 0)

```
0. PROBE      → does the platform actually support this? (capability + DATA PLANE)
1. SCAFFOLD   → dirs, index.md, nav entry, task list
2. TOPOLOGY   → .clab.yml + startup configs; deploy it; health-check
3. VALIDATE   → build the target state BY HAND, capture real show output
4. WRITE      → sessions (7-part), using the real output from step 3
5. LAB GUIDE  → per-step Apply→Verify→DONE, from the validated config
6. STUDY      → primers + interview bank
7. SHIP       → mkdocs build --strict → commit → verify live portal
```

**Step 0 is non-negotiable.** We nearly committed five weeks to MPLS/SR content
before checking whether cEOS could run it. Probe first, write second.

**Step 3 before step 4 is the other non-negotiable.** Sessions quote *real* output.
Never invent `show` output — learners will diff it against their screen and every
mismatch costs you their trust.

---

## Step 0 — the capability probe

Use an **abortable config session** so the running fabric is never touched:

```bash
printf '%s\n' "configure session probe" "<command under test>" \
  "show session-config diffs" "abort" | docker exec -i <node> Cli -p 15
```

Rules:

- **Always include a sanity probe** with a bogus command. If that doesn't error, your
  harness is broken and every "accepted" result is meaningless.
- **A real diff = strong evidence. An empty diff = weak evidence** (a submode with
  nothing under it changes nothing). Mark weak results as weak.
- **Config acceptance ≠ forwarding.** Finish with a data-plane test: does traffic
  actually cross the thing you configured?

Record results in the capability table in `CLAUDE.md`, including the ❌ rows —
knowing what *doesn't* work is worth as much as knowing what does.

---

## Directory skeleton

```
docs/courses/<nn>-<slug>/
  index.md              overview · prerequisites · what you'll build · status
  sessions/
    01-<topic>.md       … one file per session (7-part rhythm)
  labs/
    lab-01-<topic>.md   … the guide learners read
labs/<nn>-<slug>-<lab>/ runnable only: topology.clab.yml, configs/, apply/
```

`index.md` must open with a **status banner** — `⚠️ DRAFT` or `✅ Validated` — and
state its **prerequisites** as links to the courses that come before it.

---

## Session template (the 7-part rhythm)

```markdown
# Session N — <Title>

> One-sentence promise: what the learner can do after this.

## 1. Mental model
An analogy. No config, no jargon-dumping.

## 2. Why? — the problem
What breaks without this? Show the pain before the cure.

## 3. The mechanism
What happens on the wire / in the control plane. Packet or message walk.
Mermaid diagram (spines #1565c0, leaves #2e7d32, hosts #ef6c00).

## 4. Build it
Config, explained line by line. Say WHY each line exists.

## 5. Verify
`show` commands **and how to read the output.** Paste REAL captured output.
Bold or annotate the field that proves it worked.

## 6. Break & observe
Deliberately break one thing. Show the failure signature. Then fix it.

## 7. Lessons & interview
Gotchas table, then collapsible Q&A:

??? question "Why does X need Y?"
    The answer.
```

**Length guide:** 150–300 lines per session. If it's longer, it's two sessions.

---

## Lab guide template

Every lab guide has, in order:

1. **What you'll build** — Mermaid topology + the one-line goal
2. **Prerequisites** — fabric up, health-checked, prior labs applied
3. **Command cheat-sheet** — deploy / apply / clean / verify, copy-pasteable
4. **Steps**, each gated:

```markdown
### Step 3 — Enable the overlay

**Apply** (on leaf1 and leaf2):
​```
<config>
​```

**Verify:**
​```
<show command>
​```
You should see **`Established`** in the State column.

**✅ DONE when:** both leaves show Established to both spines.
```

5. **Break & fix** — one deliberate failure
6. **Troubleshooting table** — symptom / cause / fix
7. **Teardown**

**Never** let a learner proceed past a step without a check that proves it worked.

---

## Quality gate (before you ship)

- [ ] Step 0 probe recorded in `CLAUDE.md` (including data-plane result)
- [ ] Every `show` output is **real, captured from a live run** — nothing invented
- [ ] Status banner is honest (`⚠️ DRAFT` unless actually run end-to-end)
- [ ] Every step has a **DONE gate**
- [ ] Mermaid diagrams use the standard colours; no binary images
- [ ] Interview Q&A present and collapsible
- [ ] Nav entries added in `mkdocs.yml` (real content only)
- [ ] No links from `docs/` to outside `docs/`
- [ ] `mkdocs build --strict` passes
- [ ] `CLAUDE.md` updated in the same commit if any convention changed

---

## Effort baseline

From Course 2 (VXLAN-EVPN on cEOS), measured:

| Work | Real cost |
|---|---|
| Capability probe | 0.5 day |
| Topology + validate by hand | 1–2 days |
| Session (each) | 0.5–1 day |
| Lab guide (each) | 0.5 day |
| Study primers + interview bank | 0.5 day |

A 4-session / 3-lab course ≈ **5–7 working days** *if* the platform cooperates.
Budget more for anything involving MPLS labels or a new NOS.
