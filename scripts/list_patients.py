#!/usr/bin/env python3

#This script will display patient lists in a variety of formats

# First grab all of the goodies that I will need
import os
import json
from datetime import datetime
import subprocess
from tabulate import tabulate
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--json", help="Outputs patient list as json", action="store_true")
parser.add_argument("--csv", help="Outputs patient list as a csv file", action="store_true")
args = parser.parse_args()


# First let's get the easy thing out of the way (constants)
PATIENT_DIR = "patients"

# Now let's build the functions

def retrieve_patient_paths():
    patient_directory_contents = os.listdir(PATIENT_DIR)
    patient_directory_paths = []
    for patient_directory in patient_directory_contents:
        full_patient_path = os.path.join(PATIENT_DIR, patient_directory)
        patient_directory_paths.append(full_patient_path)
    return patient_directory_paths

# Now using those directories, I have to look up and store their info.json files
def build_info_file_paths(patient_directory_list):
    info_file = "info.json"
    info_file_paths = []
    for directory in patient_directory_list:
        patient_info_path = os.path.join(directory, info_file)
        info_file_paths.append(patient_info_path)
    return info_file_paths

def grab_json_data(info_file_paths):
    # build full info path
    all_json_data = []
    for info_file_path in info_file_paths:
        with open(info_file_path, "r") as content:
            all_json_data.append(json.load(content))
    return all_json_data
    
def print_patient_info(all_json_data):
    headers = ["Name", "DOB", "Phone", "Date Created"]
    table = []
    for data in all_json_data:
        name = f"{data['first_name']} {data['middle_name']} {data['last_name']}"
        row = [name,
               data.get("dob", ""),
               data.get("phone", ""),
               data.get("created", "")
               ]
        table.append(row)

    print(tabulate(table, headers=headers, tablefmt="grid"))

def output_as_json(all_json_data):
    print(f"{json.dumps(all_json_data, indent=4)}")


def main():
    patient_directory_paths = retrieve_patient_paths()
    #for d in patient_directory_paths:
    #    print(d)
    info_file_paths = build_info_file_paths(patient_directory_paths)
    #for info_file_path in info_file_paths:
     #   print(info_file_path)
    all_json_data = grab_json_data(info_file_paths)
    #for json_data in all_json_data:
    #    print(json_data)
    
    if args.json:
        output_as_json(all_json_data)
    if args.csv:
        if all_json_data:
            # This is a magic line that creats a set of all possible keys (even ones that are added later as the program is developed)
            headers = sorted(set().union(*(row.keys() for row in all_json_data)))
            print(','.join(headers))
            for row in all_json_data:
                print(','.join(str(row.get(h, "")) for h in headers))
    else:
        print_patient_info(all_json_data)

if __name__ == "__main__":
    main()
