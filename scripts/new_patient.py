#!/usr/bin/env python3

import os
import json
import hashlib
from datetime import datetime

def slugify(first, middle, last):
    return f"{first.strip().lower()}_{middle.strip().lower()}_{last.strip().lower()}"

def generate_uid(slug, dob, now=None):
    now = now or datetime.now().isoformat()
    base = f"{slug}_{dob}_{now}"
    return hashlib.sha1(base.encode()).hexdigest()[:6]

def patient_exists(patients_path, slug):
    matches = [f for f in os.listdir(patients_path) if f.startswith(slug)]
    return matches

def load_info_json(folder_path):
    info_file = os.path.join(folder_path, "info.json")
    if os.path.exists(info_file):
        with open(info_file, "r") as f:
            return json.load(f)
    return None

def main():
    patients_path = "patients"
    os.makedirs(patients_path, exist_ok=True)

    print("== New Patient Registration ==")
    first_name = input("First Name: ")
    middle_name = input("Middle Name: ")
    last_name = input("Last Name: ")
    dob = input("Date of Birth (YYYY-MM-DD): ")
    phone = input("Phone Number: ")

    slug = slugify(first_name, middle_name, last_name)
    timestamp = datetime.now().isoformat()
    uid = generate_uid(slug, dob, timestamp)

    folder_name = f"{slug}_{uid}"
    folder_path = os.path.join(patients_path, folder_name)

    # Check for potential duplicates
    matches = patient_exists(patients_path, slug)
    possible_duplicates = []

    for match in matches:
        info = load_info_json(os.path.join(patients_path, match))
        if info and info.get("dob") == dob:
            possible_duplicates.append((match, info))

    if possible_duplicates:
        print("\n⚠️ Warning: A patient with the same name and DOB already exists:")
        for match, info in possible_duplicates:
            print(f"  - {match} (Phone: {info.get('phone')}, Created: {info.get('created')})")
        confirm = input("Do you want to create another patient with the same info? [y/N]: ").strip().lower()
        if confirm != 'y':
            print("❌ Aborted. No patient created.")
            return

    os.makedirs(folder_path, exist_ok=True)

    info = {
        "uid": uid,
        "first_name": first_name,
        "middle_name": middle_name,
        "last_name": last_name,
        "dob": dob,
        "phone": phone,
        "created": timestamp
    }

    with open(os.path.join(folder_path, "info.json"), "w") as f:
        json.dump(info, f, indent=4)

    print(f"\n✅ Patient '{first_name} {middle_name} {last_name}' created in: {folder_path}")

if __name__ == "__main__":
    main()

