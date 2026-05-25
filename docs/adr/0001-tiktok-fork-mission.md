# ADR-0001: TikTok-first fork mission

**Status:** Accepted  
**Date:** 2026-05-25

## Context

This repo is a fork of WyattBlue/auto-editor — a Nim CLI that automatically removes dead space from video/audio. The fork owner wants effort-free editing optimized for TikTok creators rather than general-purpose long-form editing.

## Decision

1. Keep the upstream auto-editor pipeline (analyze → timeline → render) as the core engine.
2. Add TikTok-specific behavior as **fork extensions** — presets, vertical export profiles, pacing defaults — not by forking the analysis algorithms unnecessarily.
3. Target **9:16 / 1080×1920** as the default vertical frame unless a later ADR overrides it.
4. Brand and document the project as TikTok-first; upstream terminology (`--edit`, first pass, dead space) remains valid in code and docs.

## Consequences

- Early work can ship as CLI flags or a `tiktok` preset before deeper integration.
- Upstream merges stay feasible if fork-specific code stays in dedicated modules.
- `CONTEXT.md` glossary will grow as TikTok features land; update it when terms become real in code.
