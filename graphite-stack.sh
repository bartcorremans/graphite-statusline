#!/bin/bash

if [[ -e $VCS_STATUS_LOCAL_BRANCH ]]; then
    exit 0
fi

# Get the graphite stack output reversed, without branches
count=0
position=0

while IFS= read -r line || [[ -n "$line" ]]; do
    ((++count))

    # Check if this is the current branch (marked with ◉)
    [[ ${line:0:1} == "◉" ]] && position=$count
done < <((gt ls -sr 2>/dev/null) | tail -n +2)

((position > 0)) && echo " $position/$count"