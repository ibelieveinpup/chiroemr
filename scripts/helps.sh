#!/usr/bin/env bash
# Load utility functions relative to scripts location
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Make sure the $VISIT_PATH is set
check_visit_path

#Great! now build the directory and filename where the data will go.
helps_dir_path=$VISIT_PATH/general_findings/helps
mkdir -p "$helps_dir_path"
timestamp=$(date +%Y-%m-%dT%H:%M:%S)
filename=$(sed 's/:/-/g' <<< "${timestamp}")
full_helps_path="${helps_dir_path}/$filename"

# create the arrays to use
timing_options=("Pre" "During"  "Post")
position_options=("Standing" "Seated" "Prone")
side_options=("L" "R" "Undetermined")
side_options_extra=("L" "R" "B" "Undetermined")
lumbar_level_options=("L5" "L4" "L3" "L2" "L1" "L6" "Undetermined")

# Visit path exists, so continue...
echo "==== H.E.L.P.S. ===="
timing=$(printf "%s\n" "${timing_options[@]}" | fzf --prompt "Select Timing")
position=$(printf "%s\n" "${position_options[@]}" | fzf --prompt "Select Position For H.E.L.P.S. Measurements")
#echo "Position: ${position}"
high_crest=$(printf "%s\n" "${side_options[@]}" | fzf --prompt "Select Side Of High Iliac Crest.")
errector_spinae=$(printf "%s\n" "${side_options_extra[@]}" | fzf --prompt "Select Side Errector Spinae Tension.")
read -r -p "Notes for Errector Spinae Tension where findings were $errector_spinae:  " e_notes
lumbar_level=$(printf "%s\n" "${lumbar_level_options[@]}" | fzf --prompt "Select Level of Lowest Freely Movable Vertebrae.")
lowest=$(printf "%s\n" "${side_options[@]}" | fzf --prompt "Select Body Rotation of $lumbar_level.")
pain=$(printf "%s\n" "${side_options_extra[@]}" | fzf --prompt "Select Side of S-I Joint Pain.")
read -r -p "Notes for S-I Joint Pain Findings:  " p_notes
sacro_tuberous=$(printf "%s\n" "${side_options[@]}" | fzf --prompt "Select Side of Tighter Sacrotuberous Ligament.")
read -r -p "Notes for $sacro_tuberous sacro tuberous findings: " s_notes

#read -r -p "H: " high_crest
#read -r -p "E: " errector_spinae
#read -r -p "L: " lowest
#read -r -p "P: " pain
#read -r -p "S: " sacro_tuberous

echo "Does the following look correct?"
echo "This is a $timing measurement in the $position position."
echo "H: $high_crest"
echo "E: $errector_spinae Notes: $e_notes"
echo "L: $lumbar_level on $lowest"
echo "P: $pain Notes: $p_notes"
echo "S: $sacro_tuberous Notes: $s_notes"
read -r -p "Would you like to save this reading (y,n)?  " input
if  test "$input" = y ; then
	echo "it was y!"
else 
	echo "it wasn't y!"
fi


# TODO SWAP OUT THE FOLLOWING LINE TO ACTUALLY SAVE
#cat > "$full_helps_path" <<EOF
cat<<EOF
{
  "timestamp": "$timestamp",
  "timing": "$timing",
  "position": "$position",
  "findings": [
	{
	  "name":"High Iliac Crest",
	  "symbol": "H",
	  "side": "$high_crest"
	},
        {
 	  "name": "Errector Spinae Tension",
	  "symbol": "E",
	  "side": "$errector_spinae",
	  "notes: "$e_notes"
        },
     	{
	  "name": "Rotation of LFMV",
	  "symbol": "L",
	  "level": "$lumbar_level",
	  "side": "$lowest"
        },
        {
	  "name": "Side of Pain",
      	  "symbol": "P",
	  "side": "$pain"
	  "notes": "$p_notes",
	},
	{
	  "name": "Sacrotuberous Tension",
	  "symbol": "S",
	  "side": "$sacro_tuberous",
	  "notes": "$s_notes"
	}
  ]
}
EOF
# TODO  REMOVE THE FOLLOWING LINE FOR PRODUCTION
exit 1
# Check if the file was created successfully
if [ $? -eq 0 ]; then
  echo "Success: File saved to $full_helps_path"
else
  echo "Error: Failed to save the file."
fi
