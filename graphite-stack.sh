#!/bin/bash

# Graphite stack position " N/M" for the current branch, e.g. " 3/3".
# `gt ls` is a Node CLI (~800ms cold start) and the statusline renders
# constantly, so cache the result per branch like pr-status / ci-status do.
# Consumed (as a subprocess) by .p10k.zsh and the Claude statusline.

branch=$(git branch --show-current 2>/dev/null)
[[ -z "$branch" ]] && exit 0

cache_dir="${HOME}/.cache/graphite-statusline"
cache_file="${cache_dir}/${branch//\//__}"
cache_ttl=120

if [[ -f "$cache_file" ]]; then
    cache_mtime=$(stat -f %m "$cache_file" 2>/dev/null)
    now=$(date +%s)
    if (( now - cache_mtime < cache_ttl )); then
        cat "$cache_file"
        exit 0
    fi
fi

# Walk the reversed stack listing (branches only, header dropped); the current
# branch is marked with ◉.
count=0
position=0
while IFS= read -r line || [[ -n "$line" ]]; do
    ((++count))
    [[ ${line:0:1} == "◉" ]] && position=$count
done < <(gt ls -sr 2>/dev/null | tail -n +2)

result=""
((position > 0)) && result=" $position/$count"

# Cache unconditionally — including an empty result — so a non-Graphite repo or
# off-stack branch doesn't re-spawn gt every render. Worst case is ≤120s of
# stale-empty after a transient gt hiccup, acceptable for a cosmetic indicator.
mkdir -p "$cache_dir"
printf '%s' "$result" > "$cache_file"
printf '%s' "$result"
