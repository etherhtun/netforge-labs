# 🧪 Lab 05 · GitHub Actions ရှိ Containerlab CI/CD Pipelines {: #lab-05-github-actions-cicd }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - GitHub Actions & CI အတွင်း Containerlab ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **ကိရိယာများ:** GitHub Actions, Containerlab, PyATS

---

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Network CI/CD Pipelines {: #technology-deep-dive-network-cicd-pipelines }

ခေတ်သစ် NetDevOps engineering တွင် network configuration အပြောင်းအလဲများကို software source code များကဲ့သို့ တိကျစွာ ကိုင်တွယ်ဆောင်ရွက်ပါသည်:
1. **Pull Request (PR)**: အင်ဂျင်နီယာတစ်ဦးသည် git branch တစ်ခု ပြုလုပ်ပြီး `data/hosts.yaml` ကို ပြင်ဆင်သည့် PR တစ်ခု တင်သွင်းသည်။
2. **Automated CI Pipeline**: GitHub Actions သည် runner တစ်ခုကို အလိုအလျောက် စတင်ပြီး အောက်ပါတို့ကို လုပ်ဆောင်စေသည်:
   - Jinja2 ဖြင့် config များကို ထုတ်လုပ်ဖန်တီးခြင်း (`generate_configs.py`)။
   - Batfish ဖြင့် pre-flight စစ်ဆေးမှု ပြုလုပ်ခြင်း (`test_batfish.py`)။
   - GitHub runner အတွင်း containerlab topology တစ်ခုကို boot တက်စေခြင်း။
   - PyATS automated verification test များကို စတင် run ခြင်း (`test_fabric.py`)။
3. **Merge Approval**: အကယ်၍ test အားလုံးသည် error 0 ခုဖြင့် အောင်မြင်ပါက production deployment အတွက် PR ကို approve ပြုလုပ်ပေးသည်။

```
+-------------------+      +-------------------+      +-------------------+
|  PULL REQUEST     |      |  GITHUB ACTIONS   |      |  CONTAINERLAB CI  |
|  Git Branch PR    | +===>|  Render & Static  | +===>|  Boot Topology &  |
|  "Add Leaf3"      |      |  Batfish Analysis |      |  Run PyATS Tests  |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 GitHub Actions Workflow သတ်မှတ်ချက် (`.github/workflows/containerlab-ci.yml`) {: #github-actions-workflow-definition }

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

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** GitHub Actions သည် pull request များတွင် containerlab deployment ကို run ပြီး PyATS test gate အားလုံးကို အောင်မြင်စွာ ကျော်ဖြတ်ရပါမည်။
