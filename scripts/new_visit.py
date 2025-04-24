#!/usr/bin/env python3

import os
import json
from datetime import datetime
import subprocess
import sys

PATIENTS_DIR = "patients"

def use_fzf(options):
    try:
        fzf = subprocess.Popen(
            ['fzf'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True
        )
        stdout, _ = fzf.communicate("\n".join(options))
        return stdout.strip() if fzf.returncode == 0 else None
    except FileNotFoundError:
        return None


def fallback_select(options):
    print("\nSelect a patient:")
    for i, option in enumerate(options):
        print(f"{i+1}. {option}")
    choice = input("Enter number: ").strip()
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(options):
            return options[idx]
    return None

def select_patient():
    if not os.path.exists(PATIENTS_DIR):
        print("No patients found.")
        return None

    folders = sorted(os.listdir(PATIENTS_DIR))
    if not folders:
        print("No patient folders found.")
        return None

    selected = use_fzf(folders) or fallback_select(folders)
    return os.path.join(PATIENTS_DIR, selected) if selected else None

def prompt_visit_data():
    print("\n== New Visit Entry ==")
    notes = input("Notes: ")
    adjustments = input("Adjustments (contacts taken): ")

    # Let user enter raw JSON strings or just leave blank
    pre_weiibal = input("Pre-weiibal data (JSON-style string or leave blank): ")
    post_weiibal = input("Post-weiibal data (JSON-style string or leave blank): ")

    visit = {
        "timestamp": datetime.now().isoformat(),
        "notes": notes,
        "adjustments": adjustments,
        "weiibal": {
            "pre": pre_weiibal or None,
            "post": post_weiibal or None
        }
    }

    return visit

def main():
    patient_path = select_patient()
    if not patient_path:
        print("[X] No patient selected.")
        return

    visits_dir = os.path.join(patient_path, "visits")
    os.makedirs(visits_dir, exist_ok=True)
    
    #visit = prompt_visit_data()
    ts = datetime.now().strftime("%Y-%m-%d_%H%M")
    new_visit_dir = os.path.join(visits_dir, ts)
    os.makedirs(new_visit_dir, exist_ok=True)
    new_visit_meta_file = os.path.join(new_visit_dir, "meta.json")
    visit_number = sum(
                    1 for name in os.listdir(visits_dir)
                    if os.path.isdir(os.path.join(visits_dir, name))
                    )
    # visit_file = os.path.join(visits_dir, f"{ts}.json")
    meta = {
        "timestamp": ts,
        "chiropractor": "Dr S",
        "Visit_number": visit_number
    }
    with open(new_visit_meta_file, "w") as f:
        json.dump(meta, f, indent=4)

    # print(f"\n[✓] Visit saved to {visit_file}")
    # print(f"\n New Visit Ready to go: \n")
    # print(f"{new_visit_dir}")
    print(f"export VISIT_PATH={new_visit_dir}")
    print(f"# You can now run: ./record_notes.py $VISIT_PATH", file=sys.stderr)
if __name__ == "__main__":
    main()

