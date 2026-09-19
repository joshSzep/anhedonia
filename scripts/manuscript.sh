#!/usr/bin/env bash
# Build the manuscript from any working directory.
set -euo pipefail
export LC_ALL=C
shopt -s nullglob

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
output="$root/Anhedonia.md"
temporary=$(mktemp "$root/.Anhedonia.md.XXXXXX")
trap 'rm -f "$temporary"' EXIT

romans=(I II III IV)
movements=("$root"/manuscript/[0-9][0-9]\ -\ *)
if [[ ${#movements[@]} -ne 4 ]]; then
    printf 'Expected four manuscript movements.\n' >&2
    exit 1
fi

{
    printf '# Anhedonia\n\n*Joshua Szepietowski*\n'
    for index in "${!movements[@]}"; do
        movement=${movements[$index]}
        name=${movement##*/}
        printf '\n## %s. %s\n' "${romans[$index]}" "${name#* - }"

        chapters=("$movement"/[0-9][0-9]\ -\ *.md)
        if [[ ${#chapters[@]} -eq 0 ]]; then
            printf 'No chapters found in %s\n' "$movement" >&2
            exit 1
        fi

        for chapter in "${chapters[@]}"; do
            name=${chapter##*/}
            title=${name%.md}
            IFS= read -r heading < "$chapter"
            if [[ "$heading" != "# ${title#* - }" ]]; then
                printf 'Unexpected chapter heading in %s\n' "$chapter" >&2
                exit 1
            fi

            printf '\n### %s\n\n' "$title"
            # Replace the standalone chapter title; preserve the body verbatim.
            awk 'NR == 1 { next } NR == 2 && /^$/ { next } { print }' "$chapter"
        done
    done
} > "$temporary"

chmod 644 "$temporary"
mv -- "$temporary" "$output"
printf 'Built %s\n' "$output"
