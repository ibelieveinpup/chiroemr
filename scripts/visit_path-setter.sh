#!/bin/bash

# This script is used to quickly set the $VISIT_PATH environment variable
# so your shell will know what folder to save the measurments that you choose 

# First let's use fzf to pick the patient
patients_dir=$(ls patients |fzf)

# Might as well prepend the patients folder to the patients_dir
patients_path="patients/$patients_dir"
# echo $patients_path
# Now a fancy if statement withou an "if"
[ ! -d "$patients_path" ] && echo "X Invalid directory chosen: $patients_path" && exit 1

visits_dir="$patients_path/visits"
if [ ! -d "$visits_dir" ] || [ -z "$(ls -A "visits_dir")" ]; then
	echo "X Visits directory is missing or empty.  Use eval \$(./scripts/new_visit.py)"  
	return 1
fi

visit_choice=$(ls "$visits_dir" | fzf)
visit_path="$visits_dir/$visit_choice"
[ ! -d "$visit_path" ] && echo "Visit Path does not exist!: $visit_path" && exit 1 

# echo visit_path: $visit_path
export VISIT_PATH=${visit_path}
echo "\$VISIT_PATH set to ${visit_path}"
