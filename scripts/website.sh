#!/usr/bin/env bash
# Build the static launch page. Requires Pandoc; CSS and JavaScript are inline.
# Refresh the root PDF/EPUB with their build scripts before packaging new editions.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
chapter="$root/manuscript/01 - The Life That Should Be Enough/01 - Saturday.md"
if ! command -v pandoc >/dev/null 2>&1; then
    printf 'Required command not found: pandoc\n' >&2
    exit 1
fi
for input in "$root/cover.png" "$root/Anhedonia.pdf" "$root/Anhedonia.epub" "$chapter"; do
    if [[ ! -f "$input" ]]; then
        printf 'Missing input: %s\n' "$input" >&2
        exit 1
    fi
done
build=$(mktemp -d "${TMPDIR:-/tmp}/anhedonia-website.XXXXXX")
trap 'rm -rf "$build"' EXIT
cat > "$build/chapter.lua" <<'LUA'
function Pandoc(doc)
  assert(doc.blocks[1].t == 'Header'
    and pandoc.utils.stringify(doc.blocks[1].content) == 'Saturday',
    'Expected the first chapter to be titled Saturday')
  doc.blocks:remove(1)
  return doc:walk({HorizontalRule = function()
    return pandoc.RawBlock('html', '<div class="scene-break" role="separator" aria-label="Scene break"><span></span><b aria-hidden="true">✦</b><span></span></div>')
  end})
end
LUA
pandoc "$chapter" --from=markdown --to=html5 --wrap=none \
    --lua-filter="$build/chapter.lua" --output="$build/chapter.html"

cat > "$build/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#eee8db">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='12' fill='%2319272c'/%3E%3Cg fill='none' stroke='%23be9852' stroke-width='2'%3E%3Ccircle cx='32' cy='32' r='22'/%3E%3Ccircle cx='32' cy='32' r='14'/%3E%3C/g%3E%3Ccircle cx='32' cy='32' r='5' fill='%23be9852'/%3E%3C/svg%3E">
<meta name="description" content="Anhedonia, a novel by Joshua Szepietowski. A treatment makes ordinary life worth staying for. What happens to the reasons to leave? Read chapter one and download the complete book free.">
<meta property="og:title" content="Anhedonia — Joshua Szepietowski">
<meta property="og:description" content="The treatment works. That is where the trouble begins. Read the first chapter. Download the complete novel free.">
<meta property="og:type" content="book">
<title>Anhedonia — A novel by Joshua Szepietowski</title>
<style>
:root{--paper:#eee8db;--paper-light:#f7f3e9;--ink:#19272c;--muted:#58615e;--gold:#a77d35;--line:#19272c30;--serif:Georgia,'Times New Roman',serif;--sans:Arial,Helvetica,sans-serif;--read-size:20px;scroll-behavior:smooth;scroll-padding-top:90px}
*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font-family:var(--sans)}body:before{content:'';position:fixed;inset:0;pointer-events:none;z-index:15;opacity:.055;background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 180 180' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.87' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Cpath fill='%23000' filter='url(%23n)' opacity='.6' d='M0 0h180v180H0z'/%3E%3C/svg%3E")}
::selection{background:#b28a45;color:#fff}a{color:inherit}button,a{-webkit-tap-highlight-color:transparent}button{font:inherit}button,a:focus-visible{outline-offset:6px}a:focus-visible,button:focus-visible{outline:2px solid var(--gold)}button{cursor:pointer}button:disabled{cursor:default;opacity:.4}.skip{position:fixed;top:-80px;left:20px;padding:15px;background:var(--ink);color:var(--paper);z-index:100}.skip:focus{top:12px}.wrap{width:min(1320px,calc(100% - 112px));margin:auto}.micro{font:11px/1.5 var(--sans);letter-spacing:.18em;text-transform:uppercase}.gold{color:var(--gold)}.nav{height:76px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--line);gap:24px}.brand{text-decoration:none;letter-spacing:.22em;font-size:12px;font-weight:bold;display:flex;align-items:center;gap:13px}.sigil{width:22px;height:22px;border:1px solid var(--gold);border-radius:50%;position:relative}.sigil:after{content:'';position:absolute;inset:5px;border:1px solid var(--gold);border-radius:50%}.nav-links{display:flex;gap:30px;align-items:center;font-size:11px;letter-spacing:.12em;text-transform:uppercase}.nav-links a{text-decoration:none}.nav-links a:hover{color:var(--gold)}.nav-download{border-bottom:1px solid var(--gold);padding-bottom:4px}.hero{position:relative;overflow:hidden;padding-bottom:86px}.hero-top{display:flex;justify-content:space-between;align-items:center;padding:34px 0 12px;gap:20px}.availability{display:flex;align-items:center;gap:9px}.availability:before{content:'';width:6px;height:6px;background:var(--gold);border-radius:50%;box-shadow:0 0 0 4px #a77d3515}.hero h1{font:normal clamp(72px,13.6vw,192px)/.94 var(--serif);letter-spacing:-.055em;margin:15px 0 35px;text-transform:uppercase;position:relative;z-index:2}.hero-body{display:grid;grid-template-columns:1fr 1fr;gap:70px;align-items:center}.hero-copy{padding:20px 0 35px;max-width:500px}.hero-copy h2{font:normal clamp(34px,3.3vw,49px)/1.12 var(--serif);letter-spacing:-.03em;margin:22px 0}.hero-copy h2 em{color:var(--gold);font-weight:normal}.lede{font:16px/1.75 var(--sans);max-width:410px;color:var(--muted)}.actions{display:flex;flex-wrap:wrap;align-items:center;gap:24px;margin:32px 0}.button{display:inline-flex;align-items:center;justify-content:space-between;gap:35px;background:var(--ink);color:var(--paper-light);padding:19px 24px;font-size:12px;text-decoration:none;border:1px solid var(--ink);transition:background .2s,transform .2s}.button:hover{background:#314349;transform:translateY(-2px)}.button .arrow{font-size:21px;line-height:12px}.text-link{font-size:12px;text-decoration:none;border-bottom:1px solid var(--gold);padding:6px 0}.text-link:hover{color:var(--gold)}.book-stage{position:relative;display:grid;place-items:center;min-height:475px;perspective:1100px}.orbit{position:absolute;width:450px;max-width:110%;aspect-ratio:1;border:1px solid #a77d3540;border-radius:50%;animation:orbit 55s linear infinite}.orbit:before,.orbit:after{content:'';position:absolute;border:1px solid #a77d352e;border-radius:50%;inset:25px}.orbit:after{inset:-26px;border-style:dashed;opacity:.5}.orbit i{width:9px;height:9px;border-radius:50%;background:var(--gold);position:absolute;top:48%;left:-5px;box-shadow:0 0 0 6px #a77d3512}.book{width:min(310px,68%);position:relative;transform:rotate(-6deg);transition:transform .35s ease;z-index:2;box-shadow:8px 10px 0 #c8bfad,10px 12px 0 #a89d87,25px 30px 50px #18262d35}.book:after{content:'';position:absolute;inset:0;background:linear-gradient(90deg,#0003,transparent 4%,#fff2 6%,transparent 9%);pointer-events:none}.book img{width:100%;height:auto;display:block}.stage-note{position:absolute;right:0;bottom:5px;writing-mode:vertical-rl;color:var(--muted);font-size:10px;letter-spacing:.2em;text-transform:uppercase}.hero-bottom{margin-top:50px;padding-top:22px;border-top:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;gap:20px}.scroll-cue{text-decoration:none;display:flex;gap:15px;align-items:center}.scroll-cue span{font-size:20px;animation:nudge 2s ease-in-out infinite}.ticker{overflow:hidden;background:var(--ink);color:var(--paper);border-top:1px solid var(--ink);padding:22px 0}.ticker-track{display:flex;gap:55px;width:max-content;animation:marquee 45s linear infinite;font:italic 25px var(--serif)}.ticker-track span{white-space:nowrap}.ticker-track b{font:normal 18px var(--serif);color:#bf9954}.premise{background:var(--ink);color:var(--paper);padding:100px 0 112px;position:relative;overflow:hidden}.premise-grid{display:grid;grid-template-columns:1fr 1.45fr;gap:80px}.section-label{display:flex;gap:20px;align-items:center}.section-label:before{content:'';display:block;width:38px;height:1px;background:var(--gold)}.premise h2{font:normal clamp(38px,4.5vw,66px)/1.06 var(--serif);letter-spacing:-.04em;margin:30px 0}.premise h2 em{color:#bf9954}.premise-intro{color:#c7c9c1;font-size:15px;line-height:1.85;max-width:430px}.path-panel{position:relative;padding-top:12px}.story-tabs{display:flex;border-bottom:1px solid #eee8db35;gap:0;margin-bottom:35px}.story-tab{background:none;color:#bbc0b8;border:0;padding:20px 0;flex:1;text-align:left;border-bottom:2px solid transparent;font-size:12px;letter-spacing:.09em}.story-tab[aria-selected=true]{color:#e1bc76;border-color:#b89350}.story-tab span{font-size:10px;opacity:.6;margin-right:10px}.story-panel{min-height:275px;padding-right:20px}.story-panel h3{font:normal 35px/1.2 var(--serif);margin:0 0 22px}.story-panel p{color:#c7c9c1;line-height:1.9;font-size:16px;max-width:470px}.story-panel[hidden]{display:none}.panel-enter{animation:fade-in .5s ease}.diagram{position:relative;height:70px;display:flex;align-items:center;justify-content:space-between;margin-top:20px;max-width:430px}.diagram:before{content:'';height:1px;background:linear-gradient(90deg,#a77d35,#b8935050);position:absolute;left:0;right:0;top:50%}.node{background:var(--ink);width:15px;height:15px;border:1px solid #b89350;border-radius:50%;position:relative}.node.active{background:#b89350;box-shadow:0 0 0 7px #b8935015,0 0 0 16px #b893500a}.node-center{width:42px;height:42px;border:1px solid #b89350;display:grid;place-items:center;border-radius:50%;background:var(--ink);z-index:1}.node-center:after{content:'';width:14px;height:14px;border-radius:50%;background:#b89350}.downloads{padding:95px 0 105px;position:relative}.download-heading{display:flex;align-items:end;justify-content:space-between;gap:40px;margin:25px 0 40px}.downloads h2{font:normal clamp(42px,5vw,68px)/1.05 var(--serif);letter-spacing:-.04em;margin:0}.download-heading p{font-size:14px;line-height:1.8;max-width:295px;color:var(--muted)}.download-grid{display:grid;grid-template-columns:1fr 1fr;border-top:1px solid var(--ink);border-bottom:1px solid var(--ink)}.download-card{display:grid;grid-template-columns:auto 1fr auto;gap:25px;align-items:center;text-decoration:none;padding:34px 28px;transition:background .2s}.download-card:first-child{border-right:1px solid var(--line)}.download-card:hover{background:#dcd3c1}.format-icon{width:45px;height:58px;border:1px solid var(--gold);position:relative;display:flex;align-items:end;padding:7px;font-size:9px;color:var(--gold);letter-spacing:.08em}.format-icon:before{content:'';position:absolute;top:8px;left:7px;width:20px;height:1px;background:var(--gold);box-shadow:0 5px var(--gold),0 10px var(--gold)}.download-card h3{font:normal 28px var(--serif);margin:0 0 7px}.download-card p{font-size:12px;color:var(--muted);margin:0;line-height:1.5}.download-arrow{font:28px var(--serif);transition:transform .2s}.download-card:hover .download-arrow{transform:translateY(4px)}.download-note{margin-top:20px;display:flex;justify-content:space-between;gap:20px}.reader{--reader-bg:#f7f3e9;--reader-ink:#243237;--reader-muted:#626a67;background:var(--reader-bg);color:var(--reader-ink);border-top:1px solid var(--line);transition:background .3s,color .3s}.reader.ink{--reader-bg:#19272c;--reader-ink:#e7e1d4;--reader-muted:#bbc2b9}.reader-head{padding:76px 0 42px;display:flex;align-items:end;justify-content:space-between;gap:30px}.reader-title h2{font:normal clamp(54px,7vw,94px)/1 var(--serif);letter-spacing:-.045em;margin:20px 0 0}.reader-title h2 span{color:var(--gold);font-size:.45em;vertical-align:top;margin-right:20px;letter-spacing:-.04em}.reader-head p{color:var(--reader-muted);font-size:12px;max-width:220px;line-height:1.8}.reader-tools{position:sticky;top:0;background:var(--reader-bg);color:var(--reader-ink);z-index:20;border-block:1px solid #8d8a793d}.tool-row{display:flex;align-items:center;justify-content:space-between;gap:15px;height:62px}.tool-label{font-size:10px;text-transform:uppercase;letter-spacing:.15em}.tool-buttons{display:flex;align-items:center;gap:10px}.tool-buttons button{border:1px solid #8d8a7960;background:none;color:inherit;border-radius:0;min-width:36px;height:34px;padding:0 10px;font-size:12px}.tool-buttons button:hover{border-color:var(--gold);color:var(--gold)}.reader-progress{position:absolute;bottom:-1px;left:0;height:2px;width:0;background:var(--gold)}.reading-progress-label{font-size:10px;min-width:42px;text-align:right;color:var(--reader-muted)}.chapter{font:var(--read-size)/1.8 var(--serif);max-width:680px;padding:65px 0 50px;margin:auto;overflow-wrap:break-word}.chapter p{margin:0 0 1.1em}.chapter>p:first-child:first-letter{font-size:4.4em;float:left;line-height:.8;padding:10px 11px 0 0;color:var(--gold)}.scene-break{display:flex;align-items:center;justify-content:center;gap:24px;margin:65px auto;color:var(--gold);max-width:220px}.scene-break span{height:1px;width:65px;background:#a77d3550}.scene-break b{font-size:18px;font-weight:normal}.chapter-end{max-width:680px;margin:auto;padding:0 0 85px;text-align:center}.end-ornament{font:34px var(--serif);color:var(--gold);margin-bottom:26px}.chapter-end h3{font:normal 32px var(--serif);margin:20px 0}.chapter-end p{font-size:14px;line-height:1.8;color:var(--reader-muted)}.chapter-end .actions{justify-content:center}.finale{background:var(--ink);color:var(--paper);padding:95px 0 65px;overflow:hidden}.finale .wrap{position:relative}.finale h2{font:normal clamp(43px,7.4vw,105px)/1.06 var(--serif);letter-spacing:-.04em;margin:28px 0 44px;max-width:1000px}.finale h2 em{color:#be9852}.finale .button{background:var(--paper);color:var(--ink);border-color:var(--paper)}.footer{display:flex;justify-content:space-between;gap:30px;border-top:1px solid #eee8db30;margin-top:75px;padding-top:26px;color:#b9beb7;font-size:11px;line-height:1.8}.footer a{text-decoration:none}.footer a:hover{color:#e1bc76}.reveal{transition:opacity .75s,transform .75s}.reveal.pending{opacity:0;transform:translateY(25px)}.focus-mode .nav,.focus-mode .hero,.focus-mode .ticker,.focus-mode .premise,.focus-mode .downloads,.focus-mode .finale{display:none}.focus-mode .reader{border-top:0}.focus-mode .reader-head{padding-top:45px}.js-only{display:none}.js .js-only{display:initial}.js .tool-buttons{display:flex}noscript p{font-size:12px;line-height:1.6}.status{min-height:18px;font-size:11px;color:var(--muted);margin-top:15px}
.js .story-tabs{display:flex}
@keyframes orbit{to{transform:rotate(360deg)}}@keyframes nudge{50%{transform:translateY(5px)}}@keyframes marquee{to{transform:translateX(-50%)}}@keyframes fade-in{from{opacity:.2;transform:translateY(10px)}to{opacity:1;transform:none}}
@media(min-width:1500px){.hero h1{font-size:190px}}@media(max-width:1000px){.wrap{width:calc(100% - 64px)}.hero-body{gap:30px}.book-stage{min-height:400px}.orbit{width:330px}.hero-copy h2{font-size:38px}.premise-grid{gap:45px}.download-card{padding:28px 18px;gap:18px}.download-heading p{max-width:260px}.chapter,.chapter-end{max-width:640px;width:calc(100% - 64px)}}
@media(max-width:700px){.wrap{width:calc(100% - 40px)}.nav{height:65px;gap:12px}.brand{font-size:10px;gap:8px}.sigil{width:18px;height:18px}.nav-links{gap:18px;font-size:9px}.nav-about{display:none}.hero-top{padding-top:25px;font-size:9px;letter-spacing:.11em}.hero h1{font-size:clamp(44px,13.35vw,93px);margin:17px 0 35px}.hero-body{grid-template-columns:1fr;gap:25px}.book-stage{grid-row:1;min-height:360px}.book{width:215px;max-width:62%}.orbit{width:300px;max-width:85%}.stage-note{right:8px;bottom:25px;font-size:8px}.hero-copy{max-width:none;padding-bottom:0}.hero-copy h2{font-size:39px;max-width:400px}.hero-copy .micro{font-size:10px}.lede{font-size:15px}.actions{gap:22px;margin:27px 0}.hero-bottom{margin-top:28px;align-items:start}.hero-bottom .micro{font-size:9px}.hero-bottom>span{max-width:140px;text-align:right}.hero{padding-bottom:38px}.ticker{padding:18px 0}.ticker-track{font-size:22px;gap:35px}.premise{padding:60px 0}.premise-grid{grid-template-columns:1fr;gap:32px}.premise h2{font-size:46px;max-width:450px}.story-panel{min-height:230px;padding:0}.story-panel h3{font-size:30px}.story-panel p{font-size:15px}.diagram{margin-top:0}.downloads{padding:65px 0}.download-heading{display:block;margin-top:25px}.downloads h2{font-size:49px}.download-heading p{max-width:330px;margin-top:25px}.download-grid{grid-template-columns:1fr}.download-card{padding:25px 10px}.download-card:first-child{border-right:0;border-bottom:1px solid var(--line)}.download-note{font-size:9px;letter-spacing:.09em}.reader-head{display:block;padding:55px 0 30px}.reader-title h2{font-size:66px}.reader-head p{margin-top:25px;max-width:none}.tool-row{height:59px;gap:8px}.tool-label{font-size:9px;letter-spacing:.08em}.tool-buttons{gap:5px}.tool-buttons button{height:32px;min-width:31px;padding:0 7px;font-size:11px}.reading-progress-label{display:none}.chapter{--read-size:19px;width:calc(100% - 42px);padding-top:40px;line-height:1.75}.chapter-end{width:calc(100% - 42px);padding-bottom:65px}.scene-break{margin:45px auto}.finale{padding:65px 0 35px}.finale h2{font-size:48px}.footer{margin-top:55px;flex-direction:column;gap:14px}.footer a{align-self:start}.focus-mode .reader-head{padding-top:30px}}
@media(prefers-reduced-motion:reduce){:root{scroll-behavior:auto}*,*:before,*:after{animation:none!important;transition:none!important}.reveal.pending{opacity:1;transform:none}.book{transform:rotate(-4deg)!important}}
</style>
</head>
<body id="top">
<a class="skip" href="#chapter-one">Skip to chapter one</a>
<header class="nav wrap">
  <a class="brand" href="#top" aria-label="Anhedonia home"><span class="sigil" aria-hidden="true"></span>ANHEDONIA</a>
  <nav class="nav-links" aria-label="Main navigation"><a class="nav-about" href="#story">The story</a><a href="#chapter-one">Read chapter 01</a><a class="nav-download" href="#download">Get the book ↗</a></nav>
</header>
<main>
<section class="hero" aria-labelledby="book-title">
  <div class="wrap">
    <div class="hero-top micro"><span>A novel by Joshua Szepietowski</span><span class="availability">Read it free</span></div>
    <h1 id="book-title">Anhedonia</h1>
    <div class="hero-body">
      <div class="hero-copy">
        <div class="section-label micro gold">Literary science fiction</div>
        <h2>The treatment works.<br><em>That is where the<br>trouble begins.</em></h2>
        <p class="lede">A man who cannot bear an ordinary evening is offered a way to stay inside his own life. But being able to stay is not the same as knowing when to leave.</p>
        <div class="actions"><a class="button" href="#download">Download the novel <span class="arrow" aria-hidden="true">↓</span></a><a class="text-link" href="#chapter-one">Begin with chapter 01 ↗</a></div>
        <p class="micro" style="color:var(--muted);font-size:9px">20 chapters &nbsp; / &nbsp; 4 movements &nbsp; / &nbsp; One ordinary life</p>
      </div>
      <div class="book-stage" id="book-stage">
        <div class="orbit" aria-hidden="true"><i></i></div>
        <div class="book" id="book-object"><img src="cover.png" alt="Anhedonia cover: an ink-black maze shaped like a brain, a golden center, and the Los Angeles skyline on textured cream paper." width="1024" height="1536" fetchpriority="high"></div>
        <span class="stage-note" aria-hidden="true">Los Angeles · The near future</span>
      </div>
    </div>
    <div class="hero-bottom"><a class="scroll-cue micro" href="#story"><span aria-hidden="true">↓</span> A reason to remain</a><span class="micro">Recovery. Desire. The terms of a life.</span></div>
  </div>
</section>
<div class="ticker" aria-hidden="true"><div class="ticker-track"><span>An ordinary evening</span><b>✦</b><span>A reason to remain</span><b>✦</b><span>A life worth choosing</span><b>✦</b><span>An ordinary evening</span><b>✦</b><span>A reason to remain</span><b>✦</b><span>A life worth choosing</span><b>✦</b></div></div>
<section class="premise" id="story" aria-labelledby="story-title">
  <div class="wrap premise-grid">
    <div class="reveal"><div class="section-label micro gold">Inside the novel</div><h2>What if enough<br>was <em>not enough?</em></h2><p class="premise-intro">Daniel has a marriage, meaningful work, and months of sobriety. He also has hours he does not know how to inhabit.</p><p class="premise-intro">A neural implant changes that. Anhedonia follows what comes after the relief: the quieter, harder work of deciding what to do with it.</p></div>
    <div class="path-panel reveal">
      <div class="story-tabs js-only" role="tablist" aria-label="Explore the novel's themes">
        <button class="story-tab" id="tab-relief" role="tab" aria-selected="true" aria-controls="panel-relief"><span>01</span>Relief</button>
        <button class="story-tab" id="tab-desire" role="tab" aria-selected="false" aria-controls="panel-desire" tabindex="-1"><span>02</span>Desire</button>
        <button class="story-tab" id="tab-choice" role="tab" aria-selected="false" aria-controls="panel-choice" tabindex="-1"><span>03</span>Choice</button>
      </div>
      <div class="story-panel" id="panel-relief" role="tabpanel" aria-labelledby="tab-relief" tabindex="0"><h3>A quiet evening.<br>Nothing more. Everything more.</h3><p>The implant does not manufacture ecstasy. A meal holds his attention. A conversation becomes worth finishing. For the first time in a long time, the hours do not need to disappear.</p></div>
      <div class="story-panel" id="panel-desire" role="tabpanel" aria-labelledby="tab-desire" tabindex="0"><h3>A life can feel better.<br>It can still need to change.</h3><p>Mara has ambitions that predate Daniel’s treatment. As ordinary life becomes easier for him, they discover that they have been imagining very different futures.</p></div>
      <div class="story-panel" id="panel-choice" role="tabpanel" aria-labelledby="tab-choice" tabindex="0"><h3>Relief is real.<br>The choices are still his.</h3><p>In a city built around imperfect measures, Daniel knows how a system can succeed and still leave something out. His own recovery asks him to look again.</p></div>
      <div class="diagram" aria-hidden="true"><span class="node active"></span><span class="node"></span><span class="node-center"></span><span class="node"></span><span class="node"></span></div>
    </div>
  </div>
</section>
<section class="downloads" id="download" aria-labelledby="download-title">
  <div class="wrap reveal"><div class="section-label micro gold">The complete novel</div><div class="download-heading"><h2>Yours to read.<br>Free to download.</h2><p>Choose a format. Settle in.<br>No account, no email, no checkout.<br>Just the book.</p></div>
  <div class="download-grid">
    <a class="download-card" href="Anhedonia.epub" download data-download="EPUB"><span class="format-icon" aria-hidden="true">EPUB</span><div><h3>For your e-reader</h3><p>Reflowable text. Read your way.<br>Download EPUB</p></div><span class="download-arrow" aria-hidden="true">↓</span></a>
    <a class="download-card" href="Anhedonia.pdf" download data-download="PDF"><span class="format-icon" aria-hidden="true">PDF</span><div><h3>For the printed page</h3><p>A typeset 6 × 9-inch edition.<br>Download PDF</p></div><span class="download-arrow" aria-hidden="true">↓</span></a>
  </div><div class="download-note micro"><span>Joshua Szepietowski</span><span>Full text · Both formats · Always yours to read</span></div><div class="status" id="download-status" role="status" aria-live="polite"></div></div>
</section>
<section class="reader" id="chapter-one" aria-labelledby="chapter-title">
  <div class="reader-head wrap"><div class="reader-title"><div class="section-label micro gold">I. The Life That Should Be Enough</div><h2 id="chapter-title"><span>01</span>Saturday</h2></div><p>The complete first chapter.<br><span id="reading-time">An invitation to spend a little time.</span></p></div>
  <div class="reader-tools"><div class="wrap tool-row"><span class="tool-label">Chapter 01 / Saturday</span><div class="tool-buttons js-only"><button id="smaller" aria-label="Decrease text size">A−</button><button id="larger" aria-label="Increase text size">A+</button><button id="reader-theme" aria-pressed="false">Ink mode</button><button id="focus-reader" aria-pressed="false">Focus</button><span class="reading-progress-label" id="progress-label" aria-label="Chapter reading progress">0%</span></div></div><div class="reader-progress" id="reader-progress" aria-hidden="true"></div></div>
  <article class="chapter" id="chapter-text" aria-label="Chapter one full text">
HTML
cat "$build/chapter.html" >> "$build/index.html"
cat >> "$build/index.html" <<'HTML'
  </article>
  <div class="chapter-end"><div class="end-ornament" aria-hidden="true">✦</div><span class="micro gold">End of chapter 01</span><h3>The evening is only the beginning.</h3><p>Continue with <em>Again</em>, chapter two of Anhedonia.<br>The complete novel is free to download.</p><div class="actions"><a class="button" href="Anhedonia.epub" download data-download="EPUB">Get the EPUB <span class="arrow" aria-hidden="true">↓</span></a><a class="text-link" href="Anhedonia.pdf" download data-download="PDF">Download PDF ↓</a></div></div>
</section>
<section class="finale" aria-labelledby="final-title"><div class="wrap"><div class="section-label micro gold">Anhedonia · Joshua Szepietowski</div><h2>What will you do<br>with a life you can<br><em>finally inhabit?</em></h2><a class="button" href="Anhedonia.epub" download data-download="EPUB">Take the book with you <span class="arrow" aria-hidden="true">↓</span></a><footer class="footer"><span>Anhedonia<br>A novel by Joshua Szepietowski</span><span>Literary science fiction.<br>Set in near-future Los Angeles.</span><a href="#top">Back to the beginning ↑</a></footer></div></section>
</main>
<script>
(() => {
  'use strict';
  document.documentElement.classList.add('js');
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  const stage = document.getElementById('book-stage');
  const book = document.getElementById('book-object');
  let tiltFrame;
  stage.addEventListener('pointermove', event => {
    if (reduced.matches || event.pointerType !== 'mouse') return;
    cancelAnimationFrame(tiltFrame);
    tiltFrame = requestAnimationFrame(() => {
      const rect = stage.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - .5;
      const y = (event.clientY - rect.top) / rect.height - .5;
      book.style.transform = `rotate(-4deg) rotateY(${x * 15}deg) rotateX(${-y * 10}deg)`;
    });
  });
  stage.addEventListener('pointerleave', () => { cancelAnimationFrame(tiltFrame); book.style.transform = ''; });
  if ('IntersectionObserver' in window && !reduced.matches) {
    const observer = new IntersectionObserver(entries => entries.forEach(entry => {
      if (entry.isIntersecting) { entry.target.classList.remove('pending'); observer.unobserve(entry.target); }
    }), {threshold: .1});
    document.querySelectorAll('.reveal').forEach(element => { element.classList.add('pending'); observer.observe(element); });
  }
  const tabs = [...document.querySelectorAll('.story-tab')];
  const panels = [...document.querySelectorAll('.story-panel')];
  function activate(index, focus = false) {
    tabs.forEach((tab, i) => { tab.setAttribute('aria-selected', String(i === index)); tab.tabIndex = i === index ? 0 : -1; });
    panels.forEach((panel, i) => { panel.hidden = i !== index; panel.classList.toggle('panel-enter', i === index); });
    if (focus) tabs[index].focus();
  }
  tabs.forEach((tab, index) => {
    tab.addEventListener('click', () => activate(index));
    tab.addEventListener('keydown', event => {
      let next;
      if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
      if (event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length;
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = tabs.length - 1;
      if (next !== undefined) { event.preventDefault(); activate(next, true); }
    });
  });
  activate(0);
  const reader = document.getElementById('chapter-one');
  const text = document.getElementById('chapter-text');
  const words = text.textContent.trim().split(/\s+/).length;
  document.getElementById('reading-time').textContent = `About ${Math.ceil(words / 220)} minutes of reading.`;
  let size = window.innerWidth <= 700 ? 19 : 20;
  const smaller = document.getElementById('smaller');
  const larger = document.getElementById('larger');
  const theme = document.getElementById('reader-theme');
  const focus = document.getElementById('focus-reader');
  const bar = document.getElementById('reader-progress');
  const label = document.getElementById('progress-label');
  function progress() {
    const rect = text.getBoundingClientRect();
    const total = Math.max(1, rect.height - window.innerHeight + 63);
    const fraction = Math.min(1, Math.max(0, (63 - rect.top) / total));
    bar.style.width = `${fraction * 100}%`;
    label.textContent = `${Math.round(fraction * 100)}%`;
  }
  function resizeText(delta) {
    const rect = text.getBoundingClientRect();
    const fraction = Math.min(1, Math.max(0, (63 - rect.top) / rect.height));
    const anchored = rect.top < 63;
    size = Math.max(16, Math.min(28, size + delta));
    text.style.setProperty('--read-size', `${size}px`);
    smaller.disabled = size <= 16; larger.disabled = size >= 28;
    if (anchored) { const updated = text.getBoundingClientRect(); window.scrollTo({top: window.scrollY + updated.top + fraction * updated.height - 63, behavior: 'instant'}); }
    progress();
  }
  smaller.addEventListener('click', () => resizeText(-1));
  larger.addEventListener('click', () => resizeText(1));
  theme.addEventListener('click', () => { const ink = reader.classList.toggle('ink'); theme.setAttribute('aria-pressed', String(ink)); theme.textContent = ink ? 'Paper mode' : 'Ink mode'; });
  focus.addEventListener('click', () => {
    const offset = reader.getBoundingClientRect().top;
    const enabled = document.body.classList.toggle('focus-mode');
    focus.setAttribute('aria-pressed', String(enabled)); focus.textContent = enabled ? 'Exit focus' : 'Focus';
    window.scrollBy({top: reader.getBoundingClientRect().top - offset, behavior: 'instant'});
    progress();
  });
  let queued = false;
  window.addEventListener('scroll', () => { if (!queued) { queued = true; requestAnimationFrame(() => { progress(); queued = false; }); } }, {passive:true});
  window.addEventListener('resize', progress);
  document.querySelectorAll('[data-download]').forEach(link => link.addEventListener('click', () => {
    document.getElementById('download-status').textContent = `${link.dataset.download} download requested. Thank you for reading.`;
  }));
  progress();
})();
</script>
</body>
</html>
HTML

mkdir -p "$root/website"
cp "$root/cover.png" "$root/Anhedonia.pdf" "$root/Anhedonia.epub" "$root/website/"
cp "$build/index.html" "$root/website/index.html"
printf 'Built %s/website/\n' "$root"
