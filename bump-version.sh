#!/bin/bash

# This script is used to bump the version number based on the bump type provided to the current branch.

# Check if the bump type is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {major|minor|patch}"
    exit 1
fi

# Get the current branch name
current_branch=$(git branch --show-current)

# Initialize variables
found_branch=false
bump_type=$1

# Read the environment content from the file
env_file=$(<release.env)

# Get the version based on the current branch
while IFS= read -r line; do
    if [ "$line" == "$current_branch" ]; then
        found_branch=true
    elif [ "$found_branch" == true ]; then
        if [[ "$line" == MAJOR=* || "$line" == MINOR=* || "$line" == PATCH=* ]]; then
            var_name="${line%%=*}"
            var_value="${line#*=}"

            if [[ "$var_name" == "MAJOR" || "$var_name" == "MINOR" || "$var_name" == "PATCH" ]]; then
                declare -i "$var_name=$var_value"
            fi
        else
            break
        fi
    fi
done <<< "$env_file"

# Increment the version number based on the bump type
if [ "$found_branch" == true ]; then
    case "$bump_type" in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            echo "Invalid bump type: $bump_type"
            exit 1
            ;;
    esac

    updated_content=$(awk -v branch="$current_branch" -v major="$MAJOR" -v minor="$MINOR" -v patch="$PATCH" '
       BEGIN { found = 0 }
       $0 == branch { 
          print $0; 
          found=1; 
          next 
        } 

        # If the branch was found, replace MAJOR, MINOR, and PATCH values
        found && $0 ~ /^MAJOR=/ {
        print "MAJOR=" major
        next
        }

        found && $0 ~ /^MINOR=/ {
        print "MINOR=" minor
        next
        }

        found && $0 ~ /^PATCH=/ {
        print "PATCH=" patch
        next
        }

       # Check for the start of a new branch. If a new branch is found, stop processing the values of the previous branch.
        /^[a-zA-Z]+$/ { 
        if (found) {
            found = 0  # Reset found when a new branch is encountered
        }
        }

        # If we have not found the branch yet, just print the line
        { print $0 } 
    ' release.env)

    echo -e "$updated_content" > "release.env"
fi
