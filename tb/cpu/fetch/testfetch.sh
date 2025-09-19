#!/usr/bin/bash
#
# This program executes tests from ./cases and places results in ./output.
# Using --case=<NUM> or -c <NUM> one can select a single case to run.

# Parse arguments.
case=-1

# Handle "-c <NUM>"
regex="-c ([0-9]+)"
if [[ "$@" =~ $regex ]]; then
	case=$((BASH_REMATCH[1]))
fi

# Handle "--case=<NUM>"
regex="--case=([0-9]+)"
if [[ "$@" =~ $regex ]]; then
	case=$((BASH_REMATCH[1]))
fi

# Runs a single test case.
# Takes the path of the case as input (e.g., "./case/03").
function test() {
	# Prepare the relevant paths
	echo ""
	name=$1
	path=$(printf "./tb/cpu/fetch/cases/%02d" "$name")
	imem="$path/imem"
	res="$path/res"
	dump="../../output/$path/dump"
	desc=$(<$path/desc.txt)

	# Create the output file.
	outdir=$(printf "$path/../../output/%02d" "$name")
	dump="$outdir/dump"
	if [ ! -d "$outdir" ]; then
		mkdir -p "$outdir"
	fi

	# Run the test case.
	output=$(./bin/tb/cpu/fetch/Vfetchtb \
		+IMEM_FILE=$imem \
		+RES_FILE=$res \
		+DUMP_FILE=$dump | \
		tee /dev/tty)

	# Check the output.
	RED="\033[1;31m"
	GREEN="\033[1;32m"
	NC="\033[0m"
	if echo "$output" | grep -i -e "FAIL" -e "ERROR" ; then
		echo -e "[${RED}FAIL${NC}] - $desc"
	else
		echo -e "[${GREEN}PASS${NC}] - $desc"
	fi
}

# If we are only going to run a single case, then run that case and quit.
if [[ $case -ge 0 ]]; then
	test $path
	exit
fi

# Loop over all test cases in the file.
for case in ./tb/cpu/fetch/cases/*; do
	name=${case: -2}
	test $name
done
