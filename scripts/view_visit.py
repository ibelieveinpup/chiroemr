#!/usr/bin/env python3

import os
import json
from datetime import datetime
import subprocess

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

def fallback_select(options, label="Choose one:"):
    print(f"\n{label}")
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
    return use_fzf(folders) or fallback_select(visits, "Select a visit:")

def select_visit(visits_path):
    visits = sorted(os.listdir(visits_path), reverse=True)
    return use_fzf(visits) or fallback_select(visits, "Select a visit:")

def load_visit(file_path):
    with open(file_path, "r") as f:
        return json.load(f)

def print_visit(visit_data):
    print("\n=== Visit Details ===")
    print(f"Timestamp: {visit_data.get('timestamp', 'N/A')}")
    print(f"Notes: {visit_data.get('notes', '')}")
    print(f"Adjustments: {visit_data.get('adjustments', '')}")

    weiibal = visit_data.get("weiibal", {})
    print("\n-- Weiibal --")
    print(f"Pre: {weiibal.get('pre', 'None')}")
    print(f"Post: {weiibal.get('post', 'None')}")
    
def main():
    selected_patient = select_patient()
    if not selected_patient:
        print("❌ No patient selected.")
        return
    patient_path = os.path.join(PATIENTS_DIR, selected_patient)
    visits_path = os.path.join(patient_path, "visits")

    if not os.path.exists(visits_path):
        print("⚠️ No visits found for this patient.")
        return
    selected_visit = select_visit(visits_path)
    if not selected_visit:
        print("❌ No visit selected.")
        return
    
    visit_file = os.path.join(visits_path, selected_visit)
    visit_data = load_visit(visit_file)
    print_visit(visit_data)

if __name__ == "__main__":
    main()
