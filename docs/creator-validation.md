# Creator validation — dogfood then recruit

Use this on **Linux first** (your platform). Goal: prove `--profile tiktok` workflows before any Windows release-engineering or multi-hour CI builds.

**Install:** [v0.2.0-tiktok Linux release binary](https://github.com/pippyhelpme/auto-editor-tiktok-/releases/tag/v0.2.0-tiktok) — download, `chmod +x`, run as `auto-editor`. No local build.

---

## Phase A — Dogfood (you, 1–2 sessions)

Run these five workflows on **your own footage**. Note what breaks, confuses, or produces bad TikTok output. File issues with label `needs-triage` — one issue per distinct problem.

| # | Workflow | Command | Pass criteria |
|---|----------|---------|---------------|
| 1 | Single export | `auto-editor talk.mp4 --profile tiktok` | Upload-ready vertical file; hook + caption-safe zone look right in TikTok preview |
| 2 | Multi-clip | `auto-editor talk.mp4 --profile tiktok --clips 3` | 3 clips, 15–60s each; at least one feels like a strong hook |
| 3 | Batch folder | `auto-editor --input-dir ./raw --profile tiktok --output-dir ./out` | Every file exports; names are predictable |
| 4 | Burn-in captions | `auto-editor talk.mp4 --profile tiktok --captions subs.srt` | Captions readable; not covered by TikTok UI (upper 75%) |
| 5 | Preview first | `auto-editor talk.mp4 --profile tiktok --preview` then full render | Preview matches final cut closely enough to trust |

**Capture per workflow:**

- Source file type (podcast, gaming, talking head, screen recording)
- Platform you tested upload on (TikTok app vs draft)
- What you expected vs what you got (one sentence)
- CLI output or error text if it failed

---

## Phase B — Recruit (2–3 creators, after Phase A issues are triaged)

Share:

1. [Releases](https://github.com/pippyhelpme/auto-editor-tiktok-/releases) link for their OS
2. [Creator quickstart](creator-quickstart.md)
3. The feedback template below (copy into email/DM)

Ask them to run **workflows 1 and 2 only** — enough signal without overwhelming non-CLI users.

### Feedback template (send to creators)

```
Thanks for trying auto-editor-tiktok!

1. What kind of content do you make? (podcast clip, vlog, gameplay, etc.)
2. Which OS? (Windows / macOS / Linux)
3. Did install work on first try? (yes / no — what blocked you)
4. Run: auto-editor YOURFILE.mp4 --profile tiktok
   - Would you post the output as-is? (yes / no / with edits)
   - What would you change? (pacing, framing, captions, length)
5. Optional: auto-editor YOURFILE.mp4 --profile tiktok --clips 3
   - Were the 3 picks useful? (yes / no — why)
6. Anything confusing in the docs or error messages?
```

---

## What becomes v0.4+

| Feedback theme | Likely next work |
|----------------|------------------|
| Wrong clips picked | Smarter ranking (transcript hooks, not just audio peaks) |
| Install friction | Homebrew/winget/package manager (ADR if chosen) |
| Captions ugly or wrong | Caption styling presets for TikTok |
| Too slow | Cache/analysis tuning, not new features |
| Docs gap | Quickstart patch only — no new code |

Do **not** expand scope during validation. Triage into issues; ship doc fixes immediately; batch feature work for v0.4 planning.
