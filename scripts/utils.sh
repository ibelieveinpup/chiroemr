# This nice function cat be resued by invoking
# source utils.sh
# returns 0 if a directory contains at least one subfolder (not dot files)

has_subdirs() {
	local dir=$1
	find "$dir" -mindepth 1 -maxdepth 1 -type d | grep -q .
}
