#!/usr/bin/env python3
import os
import yaml
from jinja2 import Environment, FileSystemLoader

LAB_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_FILE = os.path.join(LAB_DIR, "data", "hosts.yaml")
TEMPLATE_DIR = os.path.join(LAB_DIR, "templates")
OUTPUT_DIR = os.path.join(LAB_DIR, "rendered")

os.makedirs(OUTPUT_DIR, exist_ok=True)

with open(DATA_FILE, "r") as f:
    data = yaml.safe_load(f)

env = Environment(loader=FileSystemLoader(TEMPLATE_DIR), trim_blocks=True, lstrip_blocks=True)

spine_template = env.get_template("spine.j2")
for spine in data.get("spines", []):
    rendered = spine_template.render(node=spine, fabric=data["fabric"])
    out_path = os.path.join(OUTPUT_DIR, f"{spine['name']}.cfg")
    with open(out_path, "w") as f:
        f.write(rendered)
    print(f"Rendered: {out_path}")

leaf_template = env.get_template("leaf.j2")
for leaf in data.get("leafs", []):
    rendered = leaf_template.render(node=leaf, fabric=data["fabric"])
    out_path = os.path.join(OUTPUT_DIR, f"{leaf['name']}.cfg")
    with open(out_path, "w") as f:
        f.write(rendered)
    print(f"Rendered: {out_path}")

print("✅ Configuration rendering complete!")
