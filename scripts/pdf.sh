#!/usr/bin/env bash
# Build a 6 x 9 inch book from the existing Anhedonia.md and cover.png.
# Requires Pandoc and a TeX installation with pdflatex.
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
for command in pandoc pdflatex; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$command" >&2
        exit 1
    fi
done
for input in Anhedonia.md cover.png; do
    if [[ ! -f "$root/$input" ]]; then
        printf 'Missing input: %s\n' "$root/$input" >&2
        exit 1
    fi
done

build=$(mktemp -d "${TMPDIR:-/tmp}/anhedonia-pdf.XXXXXX")
trap 'rm -rf "$build"' EXIT
cp "$root/cover.png" "$build/cover.png"

# Preserve Markdown inline formatting while mapping movements and chapters to
# unnumbered LaTeX parts and chapters. Their source titles already have numbers.
cat > "$build/book.lua" <<'LUA'
local function latex_inline(content)
  return pandoc.write(pandoc.Pandoc({pandoc.Plain(content)}), 'latex')
    :gsub('%s+$', '')
end

function Pandoc(doc)
  local title, author = doc.blocks[1], doc.blocks[2]
  assert(title and title.t == 'Header' and title.level == 1
    and pandoc.utils.stringify(title.content) == 'Anhedonia',
    'Expected # Anhedonia as the manuscript title')
  assert(author and author.t == 'Para'
    and pandoc.utils.stringify(author.content) == 'Joshua Szepietowski',
    'Expected Joshua Szepietowski below the manuscript title')
  doc.blocks:remove(1)
  doc.blocks:remove(1)
  return doc:walk({Header = function(header)
    local kind = ({[2] = 'part', [3] = 'chapter'})[header.level]
    assert(kind, 'Expected movement (H2) or chapter (H3) headings')
    local text = latex_inline(header.content)
    local entry = '\\addcontentsline{toc}{' .. kind .. '}{' .. text .. '}'
    if kind == 'part' then
      -- A book part ends its page internally; write the entry on that page.
      return pandoc.RawBlock('latex', '\\part*{' .. text .. entry .. '}')
    end
    return pandoc.RawBlock('latex', '\\chapter*{' .. text .. '}\n' .. entry)
  end, HorizontalRule = function()
    return pandoc.RawBlock('latex', '\\begin{center}*\\quad *\\quad *\\end{center}')
  end})
end
LUA

cat > "$build/book.tex.template" <<'TEX'
\documentclass[11pt,oneside,openany]{book}
\usepackage[paperwidth=6in,paperheight=9in,top=0.8in,bottom=0.8in,left=0.8in,right=0.75in]{geometry}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{mathpazo}
\usepackage{microtype}
\usepackage{graphicx}
\usepackage{eso-pic}
\usepackage{titlesec}
\usepackage[hidelinks,unicode,pdfpagelabels]{hyperref}
\hypersetup{pdftitle={Anhedonia},pdfauthor={Joshua Szepietowski}}
\titleformat{\chapter}[display]{\normalfont\Large}{}{0pt}{\raggedright}
\titlespacing*{\chapter}{0pt}{28pt}{24pt}
\setlength{\parindent}{1.2em}
\setlength{\parskip}{0pt}
\linespread{1.08}
\setlength{\emergencystretch}{2em}
\widowpenalty=10000
\clubpenalty=10000
\raggedbottom
\providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\begin{document}
\hypersetup{pageanchor=false}
\pagestyle{empty}
\AddToShipoutPictureBG*{\AtPageLowerLeft{\includegraphics[width=\paperwidth,height=\paperheight]{cover.png}}}
\null\clearpage
\begin{titlepage}
\centering
\vspace*{1.5in}
{\Huge Anhedonia\par}
\vspace{0.5in}
{\large Joshua Szepietowski\par}
\end{titlepage}
\frontmatter
\hypersetup{pageanchor=true}
\pagestyle{plain}
\tableofcontents
\mainmatter
$body$
\end{document}
TEX

pandoc "$root/Anhedonia.md" \
    --from=markdown --to=latex --standalone \
    --lua-filter="$build/book.lua" \
    --template="$build/book.tex.template" \
    --output="$build/Anhedonia.tex"

# Three passes stabilize the contents and page references after pagination.
for pass in 1 2 3; do
    if ! (cd "$build" && pdflatex -interaction=nonstopmode -halt-on-error \
        -file-line-error -no-shell-escape Anhedonia.tex > compile.log 2>&1); then
        tail -n 70 "$build/compile.log" >&2
        exit 1
    fi
done

if grep -E 'Overfull \\[hv]box|Missing character:' "$build/Anhedonia.log"; then
    printf 'Warning: review the typesetting warnings above.\n' >&2
fi
cp "$build/Anhedonia.pdf" "$root/Anhedonia.pdf"
printf 'Built %s\n' "$root/Anhedonia.pdf"
