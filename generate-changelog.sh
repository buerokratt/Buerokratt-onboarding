#!/bin/bash

append=${1:-false}; [ "$append" = "true" ] && append=true || append=false

env_file=$(<release.env)

REMOTE_URL=$(git config --get remote.origin.url)

if [[ $REMOTE_URL == git@* ]]; then
    REPO_NAME=$(echo "$REMOTE_URL" | sed -E 's/git@([^:]+):(.*).git/\1\/\2/')
    REPO_URL="https://$REPO_NAME"
else
    REPO_URL=${REMOTE_URL%.git}
fi

current_branch=$(git branch --show-current)
current_version=""

# Get version based on current branch
found_branch=false
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

if [ "$found_branch" == true ]; then
    current_version="$MAJOR.$MINOR.$PATCH "
fi

# Prepare the changelog content
changelog_content=$(cat <<EOF
### $current_version($(date +"%d, %b %Y"))
EOF
)

features=()
fixes=()
docs=()
styles=()
refactors=()
tests=()
chores=()
others=()

latest_merge_commit=$(git rev-list --merges --first-parent -n 1 origin/"${current_branch}")
parent1=$(git rev-parse "${latest_merge_commit}"^1) # For Current branch
parent2=$(git rev-parse "${latest_merge_commit}"^2) # For Branch that was merged
common_ancestor=$(git merge-base "${parent1}" "${parent2}")
commit_log=$(git log "${common_ancestor}".."${parent2}" --oneline --pretty=format:"%s by [<u>@%an</u>](https://www.github.com/%an) in [#%h]($REPO_URL/commit/%h)")

while read -r line; do
    pattern="^([^(:]+)\(([^)]+)\): (.*)"
    
    if [[ $line =~ $pattern ]]; then
        type="${BASH_REMATCH[1]}"
        scope="${BASH_REMATCH[2]}"
        description="${BASH_REMATCH[3]}"
        rest_of_line="**$scope**: $description"
    else
        type="others"
        rest_of_line="$line"
    fi

    author_link=$(echo "$rest_of_line" | grep -o 'https://www.github.com/[[:alnum:][:space:]]*' | tr -d '[:space:]')
    rest_of_line=$(echo "$rest_of_line" | awk -v replacement="$author_link" '{gsub(/https:\/\/www\.github\.com\/[[:alnum:][:space:]]*/, replacement); print}')

    case $type in  
        "feat") features+=("- $rest_of_line");;
        "fix")  fixes+=("- $rest_of_line");;
        "docs") docs+=("- $rest_of_line");;
        "style") styles+=("- $rest_of_line");;
        "refactor") refactors+=("- $rest_of_line");;
        "test") tests+=("- $rest_of_line");;
        "chore") chores+=("- $rest_of_line");;
        *) others+=("- $rest_of_line");;
    esac
done <<< "$commit_log"

[[ ${#features[@]} -gt 0 ]] && changelog_content+="\n## Features\n$(printf "%s\n" "${features[@]}")"
[[ ${#fixes[@]} -gt 0 ]] && changelog_content+="\n## Fixes\n$(printf "%s\n" "${fixes[@]}")"
[[ ${#docs[@]} -gt 0 ]] && changelog_content+="\n## Documentation\n$(printf "%s\n" "${docs[@]}")"
[[ ${#styles[@]} -gt 0 ]] && changelog_content+="\n## Style\n$(printf "%s\n" "${styles[@]}")"
[[ ${#refactors[@]} -gt 0 ]] && changelog_content+="\n## Refactor\n$(printf "%s\n" "${refactors[@]}")"
[[ ${#tests[@]} -gt 0 ]] && changelog_content+="\n## Tests\n$(printf "%s\n" "${tests[@]}")"
[[ ${#chores[@]} -gt 0 ]] && changelog_content+="\n## Chores\n$(printf "%s\n" "${chores[@]}")"
[[ ${#others[@]} -gt 0 ]] && changelog_content+="\n## Others\n$(printf "%s\n" "${others[@]}")"

# Append or overwrite the changelog file based on the append variable
if [ "$append" = "true" ]; then
    echo -e "$changelog_content" >> "CHANGELOG.md"
else
    echo -e "$changelog_content" > "CHANGELOG.md"
fi
