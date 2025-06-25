#!/usr/bin/env bash

# set the pipefail to warn me if something breaks
set -euo pipefail
#include the utils script
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Make sure that the $VISIT_PATH is set 
# This is from utils...
check_visit_path

choices=("Yes" "No")
result_options=("+" "-")
severity_options=("minimal" "mild" "moderate" "severe")
side_options=("L" "R" "B")

# Derive the patient's home dir
patient_dir=$(dirname $(dirname $VISIT_PATH))
#echo "patient_dir=${patient_dir}"
conditions_file_path="${patient_dir}/conditions.json"
# check if this exists
#echo $conditions_file_path
[ -f $conditions_file_path ] || cecho red "conditions.json does not exist!: use new_condition.sh"
# echo "result of cat that file:"
#cat $conditions_file_path
# make sure there are active conditions...
[ "$(jq '.active | length' "$conditions_file_path")" -gt 0 ] || { cecho red "No active Conditions found!: Use ./new_condition.sh"; exit 1; }

# feed the name of the active ones to fzf so I can pick which one to work on.
#echo "result of jq"
condition=$(jq -r '.active[] | .uid' "$conditions_file_path" | fzf --prompt "Choose condition.")
echo "==== Condition: $condition ===="
# set check the directory where the lists will be
lists_dir=lists
exam_procedure=$((echo "New"; cat $(dirname "${BASH_SOURCE[0]}")/lists/ortho.list) | fzf --prompt "Choose test to perform.")
echo "Test: $exam_procedure"
if test $exam_procedure = "New"; then
	read -r -p "What is the name of this test?: " new_test_name
	choice=$(printf "%s\n" ${choices[@]} | fzf --prompt "Would you like to save this new test?")
	[ "$choice" = "Yes" ] && { echo "${new_test_name}" >> scripts/lists/ortho.list; echo "${new_test_name} saved."; }
fi
result=$(printf "%s\n" "${result_options[@]}" | fzf --prompt "Result of ${exam_procedure}")
echo "Result: $result"
if [ "$result" = "+" ]; then
	side=$(printf "%s\n" "${side_options[@]}" | fzf --prompt "Choose side")
	echo "Side: $side"
	severity=$(printf "%s\n" "${severity_options[@]}" | fzf --prompt "Choose Severity")
	echo "Severity: $severity"
fi
save_choice=$(printf "%s\n" "${choices[@]}" | fzf --prompt "Would you like to save these results?")
echo "The choice was $save_choice"
if [ "$save_choice" = "Yes" ]; then
	o_file_path="${VISIT_PATH}/Conditions/${condition}/O.json"
	echo $o_file_path
fi
