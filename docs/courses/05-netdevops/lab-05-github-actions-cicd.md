# 🧪 Lab 05 · Containerlab CI/CD Pipelines in GitHub Actions

> ✅ **Validated** on GitHub Actions & Containerlab in CI.

**Time:** ~50 minutes · **Tools:** GitHub Actions, Containerlab, PyATS

---

## 🧠 Technology Deep Dive: Network CI/CD Pipelines

In modern NetDevOps engineering, network configuration changes are treated exactly like software source code:
1. **Pull Request (PR)**: An engineer creates a git branch and submits a PR modifying `data/hosts.yaml`.
2. **Automated CI Pipeline**: GitHub Actions automatically triggers a runner that:
   - Renders configs via Jinja2 (`generate_configs.py`).
   - Runs Batfish pre-flight analysis (`test_batfish.py`).
   - Boots a containerlab topology inside the GitHub runner.
   - Executes PyATS automated verification tests (`test_fabric.py`).
3. **Merge Approval**: If all tests pass with 0 errors, the PR is approved for production deployment.

```
+-------------------+      +-------------------+      +-------------------+
|  PULL REQUEST     |      |  GITHUB ACTIONS   |      |  CONTAINERLAB CI  |
|  Git Branch PR    | +===>|  Render & Static  | +===>|  Boot Topology &  |
|  "Add Leaf3"      |      |  Batfish Analysis |      |  Run PyATS Tests  |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 GitHub Actions Workflow Definition (`.github/workflows/containerlab-ci.yml`)

```yaml
name: Network Fabric CI Pipeline

on:
  pull_request:
    branches:
      - main

jobs:
  validate-fabric:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Dependencies
        run: |
          pip install pyyaml jinja2 pyats pybatfish

      - name: Render Configurations
        run: |
          python3 labs/netdevops-lab/scripts/generate_configs.py

      - name: Run Batfish Static Analysis
        run: |
          python3 labs/netdevops-lab/scripts/test_batfish.py

      - name: Install Containerlab
        run: |
          bash -c "$(curl -sL https://get.containerlab.dev)"

      - name: Deploy Fabric Topology
        run: |
          sudo containerlab deploy -t labs/netdevops-lab/topology.clab.yml

      - name: Execute PyATS Integration Tests
        run: |
          python3 labs/netdevops-lab/scripts/test_fabric.py
```

✅ **DONE when** GitHub Actions executes containerlab deployment and passes all PyATS test gates on pull requests.
