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

def select_patient_folder():
    if not os.path.exists(PATIENTS_DIR):
        print("Patients dir not found.")
        return None
    
    folders = sorted(os.listdir(PATIENTS_DIR))
    return use_fzf(folders) or fallback_select(folders, "Select a patient:")

def select_visit_folder(visits_folder_path):
    visits_folders = sorted(os.listdir(visits_folder_path), reverse=True)
    return use_fzf(visits_folders) or fallback_select(visits_folders, "Select a visit:")

# A generic data_load function
def data_load(file_path):
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
    
def print_basic_visit_info(patient_info, visit_info):
    print(f"\n{patient_info.get('first_name')} {patient_info.get('last_name')}")
    print(f"{patient_info.get('phone', 'None')}")
    print(f"Email: {patient_info.get('email', 'None on file!')}")
    print(f"Visit Date: {visit_info.get('timestamp', ' ')}")
    print(f"Chiropractor: {visit_info.get('chiropractor', ' ')}")


def print_weiibal_info(weiibal_dir):
    for measurement in weiibal_dir:
        print("Coming soon!")

def main():
    patient_folder = select_patient_folder()
    if not patient_folder:
        print("❌ No patient selected.")
        return
    patient_folder_path = os.path.join(PATIENTS_DIR, patient_folder)
    visits_folder_path = os.path.join(patient_folder_path, "visits")

    if not os.path.exists(visits_folder_path):
        print("⚠️ No visits found for this patient.")
        return
    selected_visit_folder = select_visit_folder(visits_folder_path)
    if not selected_visit_folder:
        print("❌ No visit selected.")
        return
    
    # Now it is a visit_folder instead of an visit_file
    selected_visit_folder_path = os.path.join(visits_folder_path, selected_visit_folder)
    # test it
    if not os.path.exists(selected_visit_folder_path):
        print(" Selected visit folder path does not exist!")
        return

    # Now that we have the visit_folder, let's build the visit.
    # Let's start with the clients name 
    patient_info_path = os.path.join(patient_folder_path, "info.json")
    if not os.path.exists(patient_info_path):
        print(" No info data found for this patient!")
        return

    visit_info_path = os.path.join(selected_visit_folder_path, "meta.json")
    # print (visit_info_path)
    if not os.path.exists(visit_info_path):
        print(" No meta.json found for the selected visit")
        return

    patient_info = data_load(patient_info_path)
    visit_info = data_load(visit_info_path)
    print_basic_visit_info(patient_info, visit_info)


if __name__ == "__main__":
    main()
