#!/bin/bash

# This script is used to quickly set the $VISIT_PATH environment variable
# so your shell will know what folder to save the measurments that you choose 

if [ "$0" = "$BASH_SOURCE" ]; then
  echo "❌ Please run this script with: source $0"
  exit 1
fi

# First let's use fzf to pick the patient
patients_dir=$(ls patients |fzf)

# Might as well prepend the patients folder to the patients_dir
patients_path="patients/$patients_dir"
# echo $patients_path
# Now a fancy if statement withou an "if"
[ ! -d "$patients_path" ] && echo "X Invalid directory chosen: $patients_path" && exit 1

# Grab the has_subdirs() function from utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

visits_dir="$patients_path/visits"
if [ ! -d "$visits_dir" ] || ! has_subdirs "$visits_dir"; then
	echo "X Visits directory is missing or empty.  Use eval \$(./scripts/new_visit.py)"  
	exit 1
fi

visit_choice=$(ls "$visits_dir" | fzf)
visit_path="$visits_dir/$visit_choice"
[ ! -d "$visit_path" ] && echo "Visit Path does not exist!: $visit_path" && exit 1 

#echo visit_path: $visit_path
export VISIT_PATH=${visit_path}
echo "\$VISIT_PATH set to ${visit_path}"

# Extract last/first name or UID from patient folder
patient_name=$(basename "$patients_path")
visit_name=$(basename "$VISIT_PATH")
tmux rename-window "$patient_name ($visit_name)" 2> /dev/null
