#!/usr/bin/env bash
# This script will begin a new condition by 
# creating the new directory for the condition and updating the master
# conditions list conditions.json

# First make sure that the $VISIT_PATH environmental variable is set...
if [[ -z $VISIT_PATH ]]; then
	echo "Error!  Must set \$VISIT_PATH first: source visit_setter.sh"
	exit 1
fi

PATIENTS_PATH=$(dirname $(dirname $VISIT_PATH))

echo "==== New Condition Generator ===="
read -r -p "New condition (eg. low back): " new_condition
read -r -p "Onset: " onset
read -r -p "Palliative: " palliative
read -r -p "Provacative: " provocative
read -r -p "Quality: " quality
read -r -p "Radiation: " radiation
read -r -p "Severity (1-10): " severity
read -r -p "Timing (% of the day, constant, etc): " timing

condition_slug=$(echo $new_condition | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | tr ' ' '_')
condition_uid="$condition_slug-$(date +%s)"
condition_path="$VISIT_PATH/Conditions/$condition_uid"

#create condition subfolder for this condition
mkdir -p "$condition_path"

# Save Subjective Data
cat > "$condition_path/S.json" <<EOF
{
  "onset": "$onset",
  "palliative": "$palliative",
  "provocative": "$provocative",
  "quality": "$quality",
  "radiation": "$radiation",
  "severity": "$severity",
  "timing": "$timing"
}
EOF

conditions_file="$PATIENTS_PATH/conditions.json"

# Create the file if missing
if [[ ! -f $conditions_file ]]; then
	echo '{"active": [], "resolved": []}' > "$conditions_file"
fi

# Check for duplicate UID just in case
if ! jq -e --arg uid "$condition_uid" '.active[] | select(.uid == $uid)' "$conditions_file" > /dev/null; then
    jq --arg uid "$condition_uid" \
       --arg name "$condition_slug" \
       --arg date "$(date +%F)" \
       '.active += [{"uid": $uid, "name": $name, "first_noted": $date}]' "$conditions_file" > "$conditions_file.tmp" && \
       mv "$conditions_file.tmp" "$conditions_file"
    echo "Condition '$condition_slug' added as UID '$condition_uid'"
else
    echo "Condition with UID '$condition_uid' already exists."
fi

