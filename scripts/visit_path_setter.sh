#!/usr/bin/env bash
# Load utility functions relative to script location
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# This script is used to quickly set the $VISIT_PATH environment variable
# so your shell will know what folder to save the measurments that you choose 

if [ "$0" = "$BASH_SOURCE" ]; then
  cecho red "❌ Please run this script with: source $0"
  exit 1
fi

# First let's use fzf to pick the patient
chosen_patient=$(ls patients |fzf)

# Might as well prepend the patients folder to the chosen_patient
patients_path="patients/$chosen_patient"
# echo $patients_path
# Now a fancy if statement withou an "if"
[ ! -d "$patients_path" ] && cecho red "❌ Invalid directory chosen: $patients_path" && exit 1

visits_dir="$patients_path/visits"
if [ ! -d "$visits_dir" ] || ! has_subdirs "$visits_dir"; then
	cecho red "❌ Visits directory is missing or empty.  Use eval \$(./scripts/new_visit.py)"  
	exit 1
fi

visit_choice=$(ls "$visits_dir" | fzf)
visit_path="$visits_dir/$visit_choice"
[ ! -d "$visit_path" ] && cecho red "❌ Visit Path does not exist!: $visit_path" && exit 1 

#echo visit_path: $visit_path
export VISIT_PATH=${visit_path}
cecho green "✅ \$VISIT_PATH set to ${visit_path}"

# Extract last/first name or UID from patient folder
patient_name=$(basename "$patients_path")
visit_name=$(basename "$VISIT_PATH")
tmux rename-window "$patient_name ($visit_name)" 2> /dev/null
