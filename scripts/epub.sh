#!/usr/bin/env bash
# Build Anhedonia.epub from the existing manuscript and cover, from any directory.
# Requires Pandoc.
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if ! command -v pandoc >/dev/null 2>&1; then
    printf 'Required command not found: pandoc\n' >&2
    exit 1
fi
for input in Anhedonia.md cover.png; do
    if [[ ! -f "$root/$input" ]]; then
        printf 'Missing input: %s\n' "$root/$input" >&2
        exit 1
    fi
done

build=$(mktemp -d "${TMPDIR:-/tmp}/anhedonia-epub.XXXXXX")
trap 'rm -rf "$build"' EXIT

cat > "$build/book.lua" <<'LUA'
function Pandoc(doc)
  local title, author = doc.blocks[1], doc.blocks[2]
  assert(title and title.t == 'Header' and title.level == 1
    and pandoc.utils.stringify(title.content) == 'Anhedonia',
    'Expected # Anhedonia as the manuscript title')
  assert(author and author.t == 'Para'
    and pandoc.utils.stringify(author.content) == 'Joshua Szepietowski',
    'Expected Joshua Szepietowski below the manuscript title')
  -- Pandoc creates the title page from metadata, so omit the duplicate here.
  doc.blocks:remove(1)
  doc.blocks:remove(1)
  return doc:walk({Header = function(header)
    assert(header.level == 2 or header.level == 3,
      'Expected movement (H2) or chapter (H3) headings')
    header.level = header.level - 1
    return header
  end, HorizontalRule = function()
    return pandoc.Div({pandoc.Para({pandoc.Str('* * *')})},
      pandoc.Attr('', {'scene-break'}, {role = 'separator'}))
  end})
end
LUA

cat > "$build/book.css" <<'CSS'
body { font-family: serif; line-height: 1.4; margin: 5%; }
p { margin: 0; text-indent: 1.2em; orphans: 2; widows: 2; }
h1, h2 { text-align: left; line-height: 1.2; break-after: avoid; }
h1 { font-size: 1.7em; margin: 2em 0; }
h2 { font-size: 1.35em; margin: 2em 0 1.5em; }
h1 + p, h2 + p, .scene-break + p { text-indent: 0; }
.scene-break { margin: 1.5em 0; break-inside: avoid; }
.scene-break p { text-align: center; text-indent: 0; letter-spacing: 0.3em; }
.titlepage { text-align: center; margin-top: 20%; }
.titlepage h1, .titlepage p { text-align: center; text-indent: 0; }
nav ol { list-style-type: none; padding-left: 1em; }
nav li { margin: 0.6em 0; }
img { max-width: 100%; height: auto; }
CSS

pandoc "$root/Anhedonia.md" \
    --from=markdown --to=epub3 --standalone \
    --metadata=title:Anhedonia \
    --metadata=author:'Joshua Szepietowski' \
    --metadata=lang:en-US \
    --metadata=toc-title:Contents \
    --lua-filter="$build/book.lua" \
    --css="$build/book.css" \
    --epub-cover-image="$root/cover.png" \
    --epub-title-page=true \
    --toc --toc-depth=2 --split-level=2 \
    --resource-path="$root" \
    --output="$build/Anhedonia.epub"

cp "$build/Anhedonia.epub" "$root/Anhedonia.epub"
printf 'Built %s\n' "$root/Anhedonia.epub"
