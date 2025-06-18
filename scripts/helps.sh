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
position_options=("Standing" "Seated" "Prone")
side_options=("L" "R" "B")

# Visit path exists, so continue...
echo "==== H.E.L.P.S. ===="
position=$(printf "%s\n" "${position_options[@]}" | fzf --prompt "Select Position For H.E.L.P.S. Measurements")
echo "Position: ${position}"
high_crest=$(printf "%s\n" "${side_options[@]}" | fzf --prompt "Select Side Of High Iliac Crest.")
#read -r -p "H: " high_crest
read -r -p "E: " errector_spinae
read -r -p "L: " lowest
read -r -p "P: " pain
read -r -p "S: " sacro_tuberous

cat > "$full_helps_path" <<EOF
{
  "timestamp": "$timestamp",
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
	  "side": "$errector_spinae"
        },
     	{
	  "name": "Rotation of LFMV",
	  "symbol": "L",
	  "side": "$lowest"
        },
        {
	  "name": "Side of Pain",
      	  "symbol": "P",
	  "side": "$pain"
	},
	{
	  "name": "Sacrotuberous Tension",
	  "symbol": "S",
	  "side": "$sacro_tuberous"
	}
  ]
}
EOF

# Check if the file was created successfully
if [ $? -eq 0 ]; then
  echo "Success: File saved to $full_helps_path"
else
  echo "Error: Failed to save the file."
fi
