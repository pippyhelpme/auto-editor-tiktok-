# CONTEXT — auto-editor-tiktok

Domain language and project boundaries for agents working in this repo.

## What this project is

A **fork of [auto-editor](https://github.com/WyattBlue/auto-editor)** (Nim CLI) repositioned for **TikTok-first short-form video editing**. The upstream tool automatically cuts dead space (silence, low motion, etc.) from long footage; this fork will layer TikTok-specific defaults, export specs, and workflows on top of that core.

**Upstream:** `WyattBlue/auto-editor`  
**This fork:** `pippyhelpme/auto-editor-tiktok-`

## Current state (honest)

The codebase is still **upstream-equivalent**. TikTok-specific behavior is **not implemented yet** — only repo branding and agent tooling differ. When adding features, prefer extending existing auto-editor modules rather than duplicating upstream logic.

## Glossary — inherited from auto-editor

Use these terms as upstream defines them unless this file explicitly overrides them.

| Term | Meaning |
|------|---------|
| **First pass** | Initial automated cut that removes dead space (typically silence) before any manual edit. |
| **Dead space** | Segments with no meaningful audio/motion — the primary removal target. |
| **`--edit`** | Method selector for automated cuts (`audio`, `motion`, combined expressions). |
| **`--margin`** | Padding added before/after kept segments so cuts feel natural. |
| **`--when-normal` / `--when-silent`** | What to do with normal vs silent sections (`cut`, `nil`, etc.). |
| **Timeline** | Internal representation of kept/cut segments (`src/timeline.nim`). |
| **Conductor** | Orchestrates analysis → timeline → render pipeline (`src/conductor.nim`). |
| **Action** | Post-cut transform (speed, scale, flip, etc.) applied to a section (`src/action.nim`). |
| **Export** | Output to a target format or NLE (`src/exports/` — FCP7, OTIO, JSON, etc.). |

## Glossary — TikTok target domain (planned)

Use these terms for TikTok-facing work. Do **not** invent synonyms once defined here.

| Term | Meaning |
|------|---------|
| **Short-form clip** | Vertical video intended for TikTok (and similar platforms). Default target length: under 3 minutes; sweet spot 15–60 seconds. Use `--profile tiktok`. |
| **Vertical frame** | 9:16 aspect ratio. Target resolution: **1080×1920** unless an ADR says otherwise. |
| **Platform export** | Final encode profile tuned for TikTok upload (codec, bitrate, audio loudness). Use `--profile tiktok` for the current preset. |
| **Hook window** | First **3 seconds** of a clip; `--profile tiktok` keeps this range uncut via `--set-action nil,0,3sec`. Disable with `--no-hook-window` or `--profile tiktok:no-hook`. |
| **Caption-safe zone** | Bottom **25%** of a vertical frame reserved for TikTok caption UI. `--profile tiktok` top-aligns content in the upper **75%**. Disable with `--no-caption-safe-zone` or `--profile tiktok:no-safe-zone`. |

## Code layout

```
src/
├── main.nim, cli.nim      # Entry point and argument parsing
├── conductor.nim          # Pipeline orchestration
├── edit.nim, editlexer.nim # Edit-method parsing
├── timeline.nim           # Segment timeline
├── analyze/               # audio, motion, subtitle analysis
├── render/                # video, audio, subtitle rendering
├── exports/               # NLE and interchange formats
├── cmds/                  # Subcommands (info, levels, cache, whisper, …)
└── ffmpeg.nim, media.nim  # FFmpeg integration
```

Fork-specific TikTok code should live in clearly named modules (e.g. `src/tiktok/` or `src/exports/tiktok.nim`) once work begins — record the choice in `docs/adr/`.

## Boundaries

- **In scope:** TikTok-oriented defaults, vertical export, short-form pacing, caption/hook helpers, CLI presets for creators.
- **Out of scope (unless ADR says otherwise):** Reimplementing FFmpeg, replacing upstream analysis algorithms wholesale, or building a full GUI.
- **Upstream sync:** Bugfixes that belong upstream should eventually go to `WyattBlue/auto-editor`; fork-only features stay here.

## Agent skills config

Issue tracker, triage labels, and domain-doc rules: see `AGENTS.md` and `docs/agents/`.
