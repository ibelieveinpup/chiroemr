#!/usr/bin/env bash
# Load utility functions relative to scripts location
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

check_visit_path
# Visit path exists, so continue...
echo "==== H.E.L.P.S. ===="
read -r -p "Position(Standing, Seated, Prone): " position
read -r -p "H: " high_crest
read -r -p "E: " errector_spinae
read -r -p "L: " lowest
read -r -p "P: " pain
read -r -p "S: " sacro_tuberous

#make the directory 
helps_dir_path=$VISIT_PATH/helps
mkdir -p "$helps_dir_path"

filename=$(date +%Y%m%d_%H%M%S)
full_helps_path="${helps_dir_path}/$filename"
echo $full_helps_path

cat > "$full_helps_path" <<EOF
{
  "Position": "$position",
  "H": "$high_crest",
  "E": "$errector_spinae",
  "L": "$lowest",
  "P": "$pain",
  "S": "$sacro_tuberous"
}
EOF
