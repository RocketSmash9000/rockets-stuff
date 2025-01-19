#!/bin/bash

# A simple script that searches for all files with a specific name within a directory
# and renames them using a specified name and a simple counter.

# First parameter = directory to search in
# Second = Name to search for
# Third = Name to replace with
# Fourth (optional) = Search mode

tempdir=$(mktemp -d)

# If the temporary directory was successfully created, create a temporary file within it
if [ -d $tempdir ]; then
    trap "rm -rf $tempdir" EXIT # Ensure that the directory is deleted when the script ends
    temp=$(mktemp "$tempdir/tempfile.XXXXXX")
else
    echo "Unable to create a temporary directory. Aborting..."
    exit 4
fi

# If no parameters are passed
if [ $# -eq 0 ]; then
    echo "Usage: ./rrename.sh [directory] [name to search for] [name to replace with]"
    exit 0
fi

if [ $1 == "help" ]; then
    echo -e "rrename is a script that searches for files within a directory with a specific name or pattern and renames them.\n"
    echo "- First argument: directory. The script will search within the specified directory. You can use 'pwd' to indicate the directory where the script is located."
    echo "- Second argument: name to search for. The script will search for all files that start with this name if no modifier is specified."
    echo "- Third argument: name to replace with. The script will rename all found files with this argument, adding a number at the end of the name."
    echo "- Fourth argument (optional): modifier. Depending on which one is provided, it will search for files in a particular way."
    echo "      - 'ex': Searches for files with the exact name. Does not consider file extensions."
    echo "      - 'e': Searches for files that end with the specified name. Does not consider file extensions."
    echo "      - 't': Searches for files based on their extension, regardless of their name."
    exit 0
fi

# If fewer than three arguments are passed, abort.
if [ $# -lt 3 ]; then
    echo "Invalid number of arguments."
    exit 2
fi

# If 'pwd' is passed as the first parameter, directory to search = current script's directory
if [ $1 == "pwd" ]; then
    dir=$(pwd)
fi

# If the directory passed does not exist and dir is different from pwd, abort
if [ ! -d $1 ]; then
    if [  ! $dir == $(pwd) ]; then
        echo "The parent directory does not exist or is invalid."
        exit 3
    fi
else
    dir=$1
fi

# Check if the mod is one of these:
# ex = Exact name (without extension)
# e = Ends with
# t = File type
case $4 in
    "ex")
        find "$dir" -type f -name "${2}.*" > "$temp"
        if [ -s $temp ]; then
            echo "Matching files found:"
            cat $temp
        else
            echo -e "No matching file was found."
            exit 0
        fi

        counter=1
        while read -r file; do
            # Skip empty lines or non-existent files
            [[ -z $file || ! -f $file ]] && continue

            # Extract the directory, base name and extension
            directorio=$(dirname "$file")
            extension="${file##*.}"

            # Generate a unique new name
            new_name="$directorio/${3}_${counter}.${extension}"

            # Rename the file
            mv "$file" "$new_name"
            echo -e "Renamed: $file -> $new_name"

            # Increment counter
            ((counter++))
        done < "$temp"
        ;;
    "e")
        find "$dir" -type f -name "*${2}.*" > "$temp"
        if [ -s $temp ]; then
            echo "Matching files found:"
            cat $temp
        else
            echo -e "No matching file was found."
            exit 0
        fi

        counter=1
        while read -r file; do
            # Skip empty lines or non-existent files
            [[ -z $file || ! -f $file ]] && continue

            # Extract the directory, base name and extension
            directorio=$(dirname "$file")
            extension="${file##*.}"

            # Generate a unique new name
            new_name="$directorio/${3}_${counter}.${extension}"

            # Rename the file
            mv "$file" "$new_name"
            echo -e "Renamed: $file -> $new_name"

            # Increment counter
            ((counter++))
        done < "$temp"
        ;;
    "t")
        find "$dir" -type f -name "*.${2}" > "$temp"
        if [ -s $temp ]; then
            echo "Matching files found:"
            cat $temp
        else
            echo -e "No matching file was found."
            exit 0
        fi

        counter=1
        while read -r file; do
            # Skip empty lines or non-existent files
            [[ -z $file || ! -f $file ]] && continue

            # Extract the directory, base name and extension
            directorio=$(dirname "$file")
            extension="${file##*.}"

            # Generate a unique new name
            new_name="$directorio/${3}_${counter}.${extension}"

            # Rename the file
            mv "$file" "$new_name"
            echo -e "Renamed: $file -> $new_name"

            # Increment counter
            ((counter++))
        done < "$temp"
        ;;
    "")
        find "$dir" -type f -name "${2}*" > "$temp"

        if [ -s $temp ]; then
            echo "Matching files found:"
            cat $temp
        else
            echo -e "No matching file was found."
            exit 0
        fi

        counter=1
        while read -r file; do
            # Skip empty lines or non-existent files
            [[ -z $file || ! -f $file ]] && continue

            # Extract the directory, base name and extension
            directorio=$(dirname "$file")
            extension="${file##*.}"

            # Generate a unique new name
            new_name="$directorio/${3}_${counter}.${extension}"

            # Rename the file
            mv "$file" "$new_name"
            echo -e "Renamed: $file -> $new_name"

            # Increment counter
            ((counter++))
        done < "$temp"
        ;;
    *)
        echo -e "$4 is not a valid modifier. Run './rrename.sh help' for more information."
        exit 5
esac


exit 0
