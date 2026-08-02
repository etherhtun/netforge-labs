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

**Curriculum = 7 phases** (IGP → BGP → Internet edge → MPLS/L3VPN → SR → EVPN →
NetDevOps → Cloud → Telemetry). See [`docs/roadmap.md`](docs/roadmap.md) for the map
and current status of each.

---

## Platforms (two NOSes, deliberately)

| | **Arista cEOS** ⭐ primary | **Juniper vJunos-switch** (legacy) |
|---|---|---|
| Used by | Course 2 onward — all new work | Course 1 only (reference) |
| Runs on | **Mac, locally** (OrbStack) | GCP VM |
| Why | container, boots in minutes, Cisco-like CLI | — |
| Status | ✅ active | ⚠️ **abandoned for hands-on** — 4 concurrent PFE boots are unstable; kept as a written reference course |

**Do not build new courses on vJunos.** New work targets cEOS unless a capability
probe proves cEOS can't do it (then consider **cRPD**, which we already have locally).

### Local dev workflow (Mac)

Lab work happens **inside the OrbStack VM** (`ssh orb` → `mylab`), *not* on the Mac.
The Mac is for **git and authoring only**. Lab files live at `~/ceos-lab/` in the VM.

---

## Repo layout

```
CLAUDE.md             ← this file (internal)
meta/                 internal authoring standards (NOT in the portal)
  course-authoring.md the per-course build checklist + skeleton
docs/                 ALL portal content (rendered by MkDocs)
  roadmap.md          the 7-phase curriculum map + status
  courses/<nn>-<slug>/  ⭐ NEW course scheme (one dir per course)
    index.md            course overview + prerequisites
    sessions/           the deep guided path (7-part rhythm)
    labs/               the lab GUIDES learners read
  sessions/ labs/ study/ ceos/ …  ← LEGACY dirs (Course 1 & 2). Leave in place.
  host-setup/ reference/ quickstart/
labs/<NN-name>/       RUNNABLE files only: topology.clab.yml, apply/*.set, configs/
                      README.md = SHORT pointer to the portal guide
scripts/              deploy · apply · switch · clean · reset · destroy · capture
common/ipplan.md      canonical addressing (mirrored to docs/reference/ipplan.md)
mkdocs.yml · requirements.txt
```

**New courses use `docs/courses/<nn>-<slug>/`.** Courses 1–2 predate this scheme and
stay where they are — migrating them is optional tech debt, not a blocker.

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

Supporting tiers: **Study** (`docs/study/`) 5-minute primers + collapsible interview
Q&A; **Labs** — complete, self-contained runnable guides.

Build order always mirrors reality: **underlay → overlay → services → scale.**
Never teach or configure a layer before the one beneath it is verified.

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

## Validated facts — Arista cEOS 4.32.0F (live, Apple Silicon / OrbStack)

**VXLAN-EVPN fabric validated end-to-end** (2 spine RR × 2 leaf VTEP + 2 hosts;
host↔host ping over VXLAN, Type-2/3 routes reflected with far-leaf next-hop).

Mandatory config that is easy to miss:

- **`ip routing`** — EOS defaults to an L2 switch. Without this, nothing routed works.
- **`service routing protocols model multi-agent`** — required for EVPN.
- OSPF via **interface-level** `ip ospf area 0.0.0.0` + `ip ospf network
  point-to-point`. The `network X/31 area …` form was flaky — don't use it.
- Single `Loopback0` = router-id + BGP update-source + `vxlan source-interface`.
- Spine RR: `neighbor <peer> route-reflector-client`; leaves peer both spines.

**Gotchas:**

- cEOS is **amd64-only** → runs under Rosetta on M-series. `docker import
  --platform linux/amd64` is mandatory (else `exec format error`).
- ⭐ **Link endpoints MUST be lowercase `ethN`** in `.clab.yml` — `["p1:eth1",
  "pe1:eth1"]`, never `Ethernet1`. cEOS's entrypoint counts `eth*` interfaces to know
  when wiring is done; a literal `Ethernet1` veth never matches, so it hangs on
  `Connected 0 interfaces out of N` forever and **EOS never boots** — which also
  makes `docker exec … Cli` fail with *"executable file not found"*. That error means
  **EOS hasn't started**, not that the image is broken. Inside EOS, `eth1` is
  `Ethernet1`.
- **Boot race:** with 4 nodes booting at once under emulation, a node can come up
  degraded — `show int Et1 status` shows type **`Unknown`**. `reload` is unsupported
  and **`docker restart` destroys the clab veths**. Fix = `containerlab destroy` +
  `deploy`, then **health-check every node** before configuring.
- ⭐ **Piping config in needs `docker exec -i`.** Without `-i` stdin is not attached,
  so a heredoc is silently discarded — the command exits 0, prints nothing, and
  **applies no configuration**. Looks identical to success. Use
  `docker exec -i <node> Cli -p 15 <<'EOF' … EOF`. (`-c "show …"` doesn't need it.)
- **LDP needs an interface-derived identity:** a bare `router-id 1.1.1.1` under
  `mpls ldp` is not enough — EOS reports *"TransportAddr interface not configured and
  router-id not derived from an interface"* and LDP stays operationally down. Use
  `router-id interface Loopback0` + `transport-address interface Loopback0`.
- Config entry: `docker exec -it clab-<fabric>-<node> Cli` → `enable` → `configure`.
  EOS applies live; `write memory` to persist.
- **Safe capability probing:** `configure session <name>` … `show session-config
  diffs` … `abort` — tests syntax without touching the running config.

### Capability probe — MPLS / SR / L3VPN (2026-08-02)

Probed via abortable config sessions on cEOS 4.32.0F. Sanity check confirmed invalid
commands *do* error, so "accepted" is meaningful.

| Feature | Verdict |
|---|---|
| `mpls ip`, `mpls ldp` | ✅ accepted (LdpAgent needs starting) |
| BGP `address-family vpn-ipv4` / `vpn-ipv6` | ✅ accepted (weak evidence — empty diff) |
| `vrf instance` + `rd` + `route-target import vpn-ipv4` | ✅ accepted — full L3VPN syntax |
| IS-IS / OSPF `segment-routing mpls` | ✅ accepted |
| `mpls rsvp` | ✅ accepted (weak evidence) |
| EVPN-VPWS `patch panel` / `connector` | ✅ accepted |
| **SRv6** | ❌ rejected — plan around its absence (cRPD is the fallback) |

⚠️ **Control plane only — the data plane is UNPROVEN.** cEOS forwards in software.
Before building Phase 3/3.5, run a real forwarding test (LDP label allocation +
labeled traceroute across 3 nodes). Do it on a **scratch topology**, not the
validated EVPN fabric.

---

## ⭐ Keep this file updated

**After ANY design change, new course/session/lab, nav change, capability finding, or
convention shift — update this file in the same commit.** It is the source of truth
for how NetForge is built.
