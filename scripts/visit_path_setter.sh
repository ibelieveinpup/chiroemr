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
# Now a fancy if statement without an "if"
[ ! -d "$patients_path" ] && cecho red "❌ Invalid directory chosen: $patients_path" && exit 1

visits_dir="${patients_path}/visits"
if [ ! -d "$visits_dir" ] || ! has_subdirs "$visits_dir"; then
	# Visits Dir is missing or empty, so first create the dir in case it isn't there.
	mkdir -p "$visits_dir"
	cecho green "Created visits/ directory: ${visits_dir}"	
fi

visit_choice=$((echo "New"; ls "$visits_dir") | fzf)
visit_path=""
# Check if visit choice == new
if test "$visit_choice" = "New"; then
	timestamp=$(date +%Y-%m-%d_%H%M)
	new_visit_dir="$timestamp"
	visit_path="${visits_dir}/${new_visit_dir}"
	#make the new dir
	mkdir -p "$visit_path"
	#make the meta file
	metafile="meta.json"
	new_visit_metafile_path="${visit_path}/${metafile}"
	visit_number=$(ls "$visits_dir" | wc -l)
	cat > "$new_visit_metafile_path" <<EOF
{
    "timestamp": "$timestamp"
    "chiropractor": "Dr S",
    "Visit_number": $visit_number
}
EOF
else
	visit_path="${visits_dir}/${visit_choice}"
	[ ! -d "$visit_path" ] && cecho red "❌ Visit Path does not exist!: $visit_path" && exit 1 
	#echo visit_path: $visit_path
fi

export VISIT_PATH="$visit_path"
cecho green "✅ \$VISIT_PATH set to ${visit_path}"

# Extract last/first name or UID from patient folder
patient_name=$(basename "$patients_path")
visit_name=$(basename "$VISIT_PATH")
tmux rename-window "$patient_name ($visit_name)" 2> /dev/null
