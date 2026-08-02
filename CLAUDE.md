# NetForge Labs — Project Guide

Guidance for anyone (human or Claude) working in this repo. **If you change how the
platform is built, update this file in the same change** (see [Keep this file
updated](#-keep-this-file-updated)).

---

## What this is

**NetForge Labs** — a hands-on network *learning platform*. Learners study the theory,
build real fabrics in **containerlab**, verify them, and break them on purpose.

The **MkDocs portal is the product**; the git repo is just the delivery mechanism.
**Learners learn entirely from the portal — git is hidden from them.**

- Portal (canonical): <https://netforge-labs.pages.dev> (Cloudflare Pages)
- Portal (backup): <https://etherhtun.github.io/netforge-labs/> (GitHub Pages)

**Curriculum = 9 phases** (IGP → BGP → Internet edge → MPLS/L3VPN → SR → EVPN →
NetDevOps → Cloud → Telemetry). See [`docs/roadmap.md`](docs/roadmap.md) for the map
and current status of each.

---

## Platforms (two NOSes, deliberately)

| | **Arista cEOS** ⭐ primary | **Juniper vJunos-switch** (legacy) |
|---|---|---|
| Used by | every phase — all new work | archive track only (reading) |
| Runs on | **Mac, locally** (OrbStack) | GCP VM |
| Why | container, boots in minutes, Cisco-like CLI | — |
| Status | ✅ active | ⚠️ **abandoned for hands-on** — 4 concurrent PFE boots are unstable; kept as a written reference course |

📌 **Platform facts, gotchas and the capability matrix live in
[`meta/ceos-platform-notes.md`](meta/ceos-platform-notes.md)** — read it before
writing any cEOS config.

**Do not build new courses on vJunos.** New work targets cEOS unless a capability
probe proves cEOS can't do it (then consider **cRPD**, which we already have locally).

### Local dev workflow (Mac)

Lab work happens **inside the OrbStack VM** (`ssh orb` → `mylab`), *not* on the Mac.
The Mac is for **git and authoring only**. Lab files live at `~/ceos-lab/` in the VM.

---

## Repo layout

```
CLAUDE.md               ← this file: conventions (internal)
meta/                   internal only, NOT in the portal
  course-authoring.md   per-course build checklist + templates
  ceos-platform-notes.md  cEOS validated facts, gotchas, capability matrix
docs/                   ALL portal content (rendered by MkDocs)
  index.md  roadmap.md
  getting-started/      lab-setup-macos · containerlab · cloud-vm · team-quickstart
  courses/<nn>-<slug>/  ⭐ ONE scheme for every phase
    index.md            phase overview + prerequisites + status
    NN-*.md             sessions / lab guides
    concepts/           optional primers (e.g. 04-evpn/concepts/)
  archive/              retired tracks, kept as reading
    juniper-vxlan-evpn/ 10 sessions + labs/
  reference/            ipplan · verify-cheatsheet · validation-runbook
  stylesheets/extra.css the design system
labs/<name>/            RUNNABLE files only: topology.clab.yml, apply/*.set, configs/
scripts/                deploy · apply · switch · clean · reset · destroy · capture
common/ipplan.md        canonical addressing (mirrored to docs/reference/ipplan.md)
mkdocs.yml · requirements.txt · .vscode/
```

⭐ **There is exactly ONE content scheme: `docs/courses/<nn>-<slug>/`.** Everything
was consolidated into it — there are no legacy directories left, and adding a new
one is how the mess started last time. If content doesn't fit the scheme, change
the scheme deliberately and migrate everything, rather than adding a parallel path.

**Runnable files never duplicate a published guide.** `labs/` holds topologies and
config snippets only. A shell script that re-implements a guide's steps *will* drift
from it and become a trap — one did, and it silently reproduced five fixed bugs.

---

## The teaching model (the "NetForge method")

**Every session follows this exact 7-part rhythm:**

1. **Mental model** — an analogy to anchor the idea
2. **Why before how** — the problem, before any config
3. **The mechanism** — what actually happens on the wire / in the control plane
4. **Build it** — hands-on, config explained line by line
5. **Verify** — the `show` commands **and how to read the output**
6. **Break & observe** — deliberately break it to see the failure mode
7. **Lessons & interview** — gotchas + interview questions

Supporting tiers: **concepts** (`docs/courses/<phase>/concepts/`) 5-minute primers +
collapsible interview Q&A; **lab guides** — complete and self-contained.

Build order always mirrors reality: **underlay → overlay → services → scale.**
Never teach or configure a layer before the one beneath it is verified.

---

## Two kinds of phase: lab track vs reading track

Not every phase earns a lab.

- **Lab track** (Phases 3, 4, …) — runnable fabric, per-step Apply → Verify → DONE
  gates, real captured output. The default.
- **Reading track** (Phase 0 · IGP) — theory only, no lab. Used where the topic is
  heavily covered elsewhere and a lab would add little: another "configure OSPF on
  three routers" walkthrough teaches nothing our readers can't get free elsewhere.
  Its value is the *mental model* every later phase depends on.

A reading track still carries the 7-part spirit (mental model → why → mechanism →
failure modes → interview Q&A) minus build/verify. Mark it clearly at the top —
`📖 Reading track — no lab` — so nobody goes hunting for a topology.

**The honesty rule still binds a reading track.** If you show command output, it
must be **really captured**. Phase 0's OSPF page uses live output from the cEOS
fabric; the IS-IS page states plainly that nothing has been run and shows syntax
only. **Never invent output to make a page look complete.**

---

## ⭐ The honesty rule (most important convention)

A lab is **⚠️ DRAFT** until its config has actually been **run on a live fabric**.
Only mark it **✅ validated** after a real run.

- **Never claim a config works, or call it validated, without a live run.**
- Flag unverified syntax explicitly and list likely fix-spots in the guide.
- **Config acceptance ≠ working data plane.** A CLI that accepts `mpls ip` does not
  prove labels forward. Prove forwarding before teaching it.
- When a probe contradicts an earlier claim in this repo, **fix the claim** — don't
  leave both versions standing.

---

## Content conventions

- **Each lab is self-contained** and reads top-to-bottom in the portal.
- **Fabric naming:** labs that share identical cabling share ONE topology `name:`
  (e.g. Juniper labs 01–04 = `evpn-lab`) so you boot once and switch designs with
  `clean.sh` + `apply.sh`. Labs with different cabling get their own name. Scripts
  derive the container prefix from the topology `name:` — never hard-code it.
  `FABRIC=<prefix>` overrides it.
- **Only one fabric at a time** on a given host (RAM).
- **Per-step Apply → Verify → DONE gates** in every lab guide.
- **Diagrams: Mermaid only** (renders in the portal *and* on GitHub — never commit
  binary SVGs). Colours: **spines blue** `#1565c0`, **leaves green** `#2e7d32`,
  **hosts orange** `#ef6c00`. Reuse everywhere.
- Config format: cEOS = EOS CLI blocks; Juniper = `set`-format.

---

## Web design / portal standards

- **MkDocs Material**, **theme-aware** (light + dark are configured — never hard-code
  colours that break one mode).
- **Portal-first / hide git:** no `repo_url`, `repo_name`, or `edit_uri` in
  `mkdocs.yml`. No GitHub chrome, no links to GitHub in learner content.
- **Scannable:** tables, admonitions (`!!! tip`, `!!! warning`), short paragraphs,
  **bold key terms**, one idea per section.
- Interview Q&A as **collapsible** `??? question "…"` blocks so learners self-test
  before revealing.
- **Add every new session and lab as a nav entry** in `mkdocs.yml`. Don't nav a page
  that has no real content yet — status lives in `docs/roadmap.md` instead.
- ⭐ **Nav is named by ROADMAP PHASE, never "Course N".** Sections read
  `Phase 3 · MPLS & L3VPN`, `Phase 4 · EVPN Services` — matching `docs/roadmap.md`
  exactly. The old Course 1/2/3 labels were historical accretion (Course 1 and 2
  were *both* VXLAN-EVPN, on different platforms) and contradicted the roadmap's
  numbering. If the menu and the roadmap ever disagree again, the roadmap wins.
- ⭐ **The top bar is FIXED at six tabs and must never grow:**
  `Home · Roadmap · Get Started · Courses · Archive · Reference`.
  **Never add a phase as a top-level nav item.** Phases live in the sidebar under
  `Courses`, so the bar stays the same width whether there are three phases or
  twenty. An earlier version put each phase in the bar; at seven tabs they already
  overflowed and faded out, and nine phases would have made it unusable.
- **Section landing pages are required.** Every top-level section starts with its
  own `index.md` as the first nav entry (`navigation.indexes` is enabled), so
  `/courses/`, `/getting-started/`, `/archive/` and `/reference/` all resolve
  instead of 404ing.
- **`docs/courses/index.md` is the catalogue** — a card per phase with a status
  badge. Adding a phase means adding a card there and a sidebar block, nothing
  else.
- The **Juniper vJunos course is archived reading**, under `docs/archive/` — kept because the theory is platform-agnostic, but
  it is not the hands-on path.
- **Landing page** (`docs/index.md`) uses Material **grid cards**
  (`<div class="grid cards" markdown>`), which need the `attr_list` and
  `md_in_html` extensions — both enabled. Keep it to *what's available now* plus a
  pointer to the roadmap; don't list unbuilt phases there.

---

## Local authoring setup

MkDocs runs from a **local venv** (`.venv/`, gitignored). On a fresh clone:

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
```

- **Preview:** `.venv/bin/mkdocs serve` → <http://127.0.0.1:8000>, live-reloads on save.
- **In VS Code / Cursor:** `.vscode/` is committed — `Cmd+Shift+B` runs the preview
  task, and the test task runs the strict build. Recommended extensions are listed
  in `.vscode/extensions.json`.
- ⚠️ **VS Code's built-in markdown preview does NOT render Material syntax** —
  admonitions, `??? question` collapsibles and mermaid all show as raw text. Judge
  pages in `mkdocs serve`, never in the built-in preview.

---

## Workflow rules (do these every time)

1. **ALWAYS run `mkdocs build --strict` before pushing.** It catches broken links and
   nav errors. ("no git logs" warnings are benign for *uncommitted* files.)
2. **Never link from `docs/` to files outside `docs/`** (`labs/`, `scripts/`,
   `meta/`) — `--strict` fails. Mirror what you need into `docs/`.
3. **Commit messages end with** the `Co-Authored-By: Claude …` line.
4. **Push = deploy.** GitHub Actions → GH Pages; Cloudflare Pages auto-builds
   (`pip install -r requirements.txt && mkdocs build`, output `site`,
   `PYTHON_VERSION=3.11`). CF takes **1–2 min** — a 404 right after push is usually
   just the build, not a bug. Hard-refresh before debugging.
5. **Never commit** NOS images (`*.qcow2`, `*.tar.xz`), credentials, or licence keys.
6. **Don't copy third-party content.** Other people's courses are reference for
   *structure and topic order* only — write original prose. No license = all rights
   reserved.

---

## ⭐ Keep this file updated

**After ANY design change, new course/session/lab, nav change, capability finding, or
convention shift — update this file in the same commit.** It is the source of truth
for how NetForge is built.
