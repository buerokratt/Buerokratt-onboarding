#!/bin/bash

# This script is used to sync the version number of the current branch with the previous branch.

current_branch=$(git branch --show-current)
env_file="release.env"

lines=()
while IFS= read -r line; do
  lines+=("$line")
done < "$env_file"

previous_version=()
found_previous_branch=0

for (( i=0; i<${#lines[@]}; i++ )); do
  line="${lines[i]}"
  
  if [[ "$line" =~ ^([a-zA-Z0-9_]+)$ ]]; then
    if [ "$line" == "$current_branch" ]; then
      if [ "$found_previous_branch" -eq 1 ]; then
        break
      else
        exit 0
      fi
    fi
    
    found_previous_branch=1
    previous_version=()
  fi

  if [[ "$line" =~ ^(MAJOR=|MINOR=|PATCH=) ]]; then
    previous_version+=("$line")
  fi
done

if [ ${#previous_version[@]} -ne 0 ]; then
  for (( i=0; i<${#lines[@]}; i++ )); do
    if [[ "${lines[i]}" == "$current_branch" ]]; then
      lines[i+1]="${previous_version[0]}"
      lines[i+2]="${previous_version[1]}"
      lines[i+3]="${previous_version[2]}"
      break
    fi
  done

  printf "%s\n" "${lines[@]}" > "$env_file"
else
  exit 0
fi
