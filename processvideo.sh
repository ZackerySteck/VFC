#!/bin/bash
trap ctrl_c INT

function ctrl_c() {
	exit 1
}

# Get file name
me=`basename "$0"`
me=${me%.*}

# Not enough arguments, error out
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: ./$me.sh [filename] [dimensions] "
	echo "Examples: "
	echo "./$me.sh example.mp4 640x480"
	echo "./$me.sh all 640x480"
	exit
fi

target="$1"

# Function for processing individual video file
function processVideo {
	target=$3
	target=${target%.*}/
	if [ -d ./frames/$target ]; then
		if [ "$(ls -A ./frames/$target)" ]; then
			echo "Files found in ./frames/$target. Cleaning..."
			rm ./frames/$target*
			echo "Done!"
		fi
	else
		mkdir ./frames/$target
	fi

	echo "Outputting frames from $1 to ./frames/$target"
	fsize=$(stat -c '%s' "$3" | numfmt --to=iec-i --suffix=B)
	echo "File size: $fsize"
	ffmpeg -re -i $1 -s $2 ./frames/$target%04d.png &>> $me.out
	echo "Done!"

	echo "Generating timestamp file..."
	python create_timestamps.py -i "./frames/$target" -o "./timestamps/" &>> $me.out

	echo "Done!"
}

# Erase previous log file
if [ -f ./$me.out ]; then
	rm ./$me.out
fi
echo "Logging to $me.out"

# Make directories if they dont exist
if [ ! -d ./frames/ ]; then
	mkdir ./frames
fi
if [ ! -d ./timestamps/ ]; then
	mkdir ./timestamps
fi

# Check target
if [[ $target == [aA][lL][lL] ]]; then
	echo "Processing all video files in the current directory. This may take some time..."
	shopt -s nullglob # remove empty values from list
	
	# Target is all files in current dir; loop through and process
	for file in *.{avi,mp4,flv,wmv,h264}; do
		eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
		processVideo "$file" "$2" "$file"
	done
else
	# Target is a single file; process it
	printf '%.0s-' {1..100}; echo
	processVideo "$1" "$2" "$target"
fi

eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
echo "File processing complete!"
