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

# -s (non-empty), not -f: an empty cache file is treated as a miss, so a blank
# never gets served — it recomputes and self-heals on the next render.
if [[ -s "$cache_file" ]]; then
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

# U+F51E nerd-font branch/stack glyph, octal-escaped (its UTF-8 bytes ef 94 9e) so
# this file stays pure ASCII — a literal glyph here gets silently eaten on any
# Read→Write round-trip (the cause of this regression). bash 3.2 has no printf \u.
icon=$(printf '\357\224\236')
result=""
((position > 0)) && result="${icon} $position/$count"

# Cache only a real result — never an empty/failed compute. Caching empty would
# pin a blank segment for the whole TTL after a transient gt hiccup (the bug this
# fixes). Cost: off-stack branches re-spawn gt each render (same as pre-cache),
# but there's nothing to show there anyway.
if [[ -n "$result" ]]; then
    mkdir -p "$cache_dir"
    printf '%s' "$result" > "$cache_file"
fi
printf '%s' "$result"
