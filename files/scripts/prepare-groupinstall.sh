#!/bin/bash

set -oex pipefail
set +u

# Find the dnf groupinstall lines and extract quoted strings
VALUE="$(grep '^dnf groupinstall' /tmp/files/scripts/groupinstall.sh | grep -o '"[^"]*"' | tr '\n' ' ')"
echo "Extracted VALUE: $VALUE"

if [ -z "$VALUE" ]; then
	echo "No groups found in build.sh"
	exit 0
fi

# Initialize an empty array
declare -a GROUP_ARRAY


# Use read with a custom delimiter to split the input string
while IFS='"' read -ra parts; do
for part in "${parts[@]}"; do
	# Trim leading and trailing spaces and check if the part is not empty
	trimmed=$(echo "$part" | xargs)
	if [[ -n "$trimmed" ]]; then
		GROUP_ARRAY+=("$trimmed")
	fi
done
done <<< "$VALUE"
echo "Raw Array without double-quotes: ${GROUP_ARRAY[*]}"

IS_DNF5=$(dnf --version | { grep -sc dnf5 || test $? = 1; })
echo "IS_DNF5: $IS_DNF5 (dnf4 = 0, else dnf5)"
for GROUP_E in "${GROUP_ARRAY[@]}"; do 
	echo "Getting pkgs for group: $GROUP_E"
	if [ "$IS_DNF5" -ne 0 ]; then
		#dnf5
		OUTPUT="$OUTPUT $(dnf group info "$GROUP_E" 2>&1 | grep -E "packages|^[[:space:]]*:" | cut -d: -f2 | tr -s ' ' | tr -d '\n' | sed 's/^ //; s/ $//')" 
	else 
		#dnf4
		OUTPUT="$OUTPUT $(dnf group info "$GROUP_E" 2>&1 | grep -v : | tr -d '\n' | tr -s '  ' | cut -c2-)"
	fi
done
          
          
sed -i "s/^dnf groupinstall.*/rpm-ostree install $OUTPUT}/" /tmp/files/scripts/groupinstall.sh
