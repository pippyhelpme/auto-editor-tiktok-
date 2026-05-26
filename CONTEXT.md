# CONTEXT — auto-editor-tiktok

Domain language and project boundaries for agents working in this repo.

## What this project is

A **fork of [auto-editor](https://github.com/WyattBlue/auto-editor)** (Nim CLI) repositioned for **TikTok-first short-form video editing**. The upstream tool automatically cuts dead space (silence, low motion, etc.) from long footage; this fork will layer TikTok-specific defaults, export specs, and workflows on top of that core.

**Upstream:** `WyattBlue/auto-editor`  
**This fork:** `pippyhelpme/auto-editor-tiktok-`

## Current state (honest)

**v0.2.0-tiktok** ships clip ranking, batch folder export, and [creator onboarding](docs/creator-quickstart.md) on top of v0.1.

**v0.1.0-tiktok** ships a working **`--profile tiktok`** preset in source. Implemented in `src/tiktok/`:

- Vertical **1080×1920** defaults, snappier margin, H.264 encode, `{stem}_tiktok.mp4` output
- **Hook window** — first 3s kept uncut (`--set-action nil,0,3sec`)
- **Caption-safe zone** — content top-aligned in upper 75% of frame
- **Burn-in captions** — FFmpeg `subtitles` filter via libass (Linux/macOS static release builds; Windows deferred)

Release binaries are built by GitHub Actions (`release-build` workflow). Attach to [Releases](https://github.com/pippyhelpme/auto-editor-tiktok-/releases). **Linux and macOS** static builds include libass burn-in. Windows release binaries omit burn-in until a later release (deferred — see plan below).

**Creator onboarding:** [docs/creator-quickstart.md](docs/creator-quickstart.md) — install, workflows, modifiers, troubleshooting.

## Current plan (2026-05-26)

**North star (now):** **Linux-first** — you dogfood on Linux; prove `--profile tiktok` workflows before investing in cross-platform release engineering.

**Phase 1 — dogfood on Linux (now):** Use the **[Linux release binary](https://github.com/pippyhelpme/auto-editor-tiktok-/releases)** (not a local `nimble makeff` / cross-build). Run the five workflows in [creator-validation.md](docs/creator-validation.md). File issues for anything broken.

**Phase 2 — creator validation:** Triage Phase 1 issues, then recruit 2–3 creators (same doc). Feedback drives v0.4+ features.

**Deferred — Windows burn-in parity:** Bundle libass in Windows cross-builds (`gccWin` / `llvmWin`). Revisit only after Linux dogfood is green; automate via CI then, not before.

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

## Glossary — TikTok target domain (shipped + planned)

Use these terms for TikTok-facing work. Do **not** invent synonyms once defined here.

| Term | Meaning |
|------|---------|
| **Profile** | Named preset bundle applied via `--profile NAME` (e.g. `tiktok`). Modifiers use colon syntax: `tiktok:no-hook`. Implemented in `src/tiktok/preset.nim`. |
| **Short-form clip** | Vertical video intended for TikTok (and similar platforms). Default target length: under 3 minutes; sweet spot 15–60 seconds. Use `--profile tiktok`. |
| **Vertical frame** | 9:16 aspect ratio. Target resolution: **1080×1920** unless an ADR says otherwise. |
| **Platform export** | Final encode profile tuned for TikTok upload (codec, bitrate, audio loudness). Use `--profile tiktok` for the current preset. |
| **Burn-in captions** | Hard-coded captions via FFmpeg `subtitles` filter. Use `--burn-captions` / `--captions FILE`; enabled by `--profile tiktok` when a caption source exists. Soft subs are omitted (`-sn`) when burning. |
| **Hook window** | First **3 seconds** of a clip; `--profile tiktok` keeps this range uncut via `--set-action nil,0,3sec`. Disable with `--no-hook-window` or `--profile tiktok:no-hook`. |
| **Caption-safe zone** | Bottom **25%** of a vertical frame reserved for TikTok caption UI. `--profile tiktok` top-aligns content in the upper **75%**. Disable with `--no-caption-safe-zone` or `--profile tiktok:no-safe-zone`. |
| **Multi-clip export** | Split one long source into **N** ranked short clips (15–60s kept segments), each with `--profile tiktok` defaults. Use `--clips N` or `--profile tiktok:clips=N`. Outputs `{stem}_clip01_tiktok.mp4`, etc. Implemented in `src/tiktok/clips.nim`. |
| **Clip ranking** | Ranks candidate kept segments by **audio/motion peak scores** from cached analysis (written during the normal `--edit` pass). Falls back to longest-in-range when no cache is available. Implemented in `src/tiktok/clips.nim`. |
| **Batch folder export** | Process every video in a folder with the same CLI options via `--input-dir DIR`. Optional `--output-dir DIR` collects outputs in one place. Implemented in `src/tiktok/batch.nim`. |
| **Creator quickstart** | Onboarding doc for TikTok creators: first export, workflows, profile modifiers, troubleshooting. See `docs/creator-quickstart.md`. |
| **Creator validation** | Dogfood checklist + recruited-creator feedback template before v0.4 feature work. See `docs/creator-validation.md`. |
| **Dogfood method** | Validate with the **Linux release binary** from GitHub Releases — same artifact creators get; no local FFmpeg/libass build during Phase 1. |
| **Deferred platform work** | Windows libass in cross-build release binaries. Not blocking Linux dogfood. |

## Code layout

```
src/
├── main.nim, cli.nim      # Entry point and argument parsing
├── conductor.nim          # Pipeline orchestration
├── edit.nim, editlexer.nim # Edit-method parsing
├── timeline.nim           # Segment timeline
├── tiktok/                # Fork-specific TikTok preset, captions
├── analyze/               # audio, motion, subtitle analysis
├── render/                # video, audio, subtitle rendering
├── exports/               # NLE and interchange formats
├── cmds/                  # Subcommands (info, levels, cache, whisper, …)
└── ffmpeg.nim, media.nim  # FFmpeg integration
```

Fork-specific TikTok code lives in `src/tiktok/` (see ADR-0001).

## Boundaries

- **In scope:** TikTok-oriented defaults, vertical export, short-form pacing, caption/hook helpers, CLI presets for creators.
- **Out of scope (unless ADR says otherwise):** Reimplementing FFmpeg, replacing upstream analysis algorithms wholesale, or building a full GUI.
- **Upstream sync:** Bugfixes that belong upstream should eventually go to `WyattBlue/auto-editor`; fork-only features stay here.

## Agent skills config

Issue tracker, triage labels, and domain-doc rules: see `AGENTS.md` and `docs/agents/`.
