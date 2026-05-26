# Creator quickstart — auto-editor-tiktok

Turn long footage into vertical TikTok-ready clips from the command line. No timeline editor required.

**Install:** see [README — Installing (this fork)](../README.md#installing-this-fork). Pre-built binaries are on the [Releases](https://github.com/pippyhelpme/auto-editor-tiktok-/releases) page.

---

## Your first export (60 seconds)

1. Put a video file in your working directory (e.g. `podcast.mp4`).
2. Run:

```bash
auto-editor podcast.mp4 --profile tiktok
```

3. Upload `podcast_tiktok.mp4` to TikTok.

That one command:

- Cuts dead space (silence by default)
- Exports **1080×1920** vertical H.264
- Keeps the first **3 seconds** uncut (hook window)
- Frames faces/content in the **upper 75%** (caption-safe zone)
- Burns in captions when the file has embedded subs or you pass `--captions FILE` (Linux/macOS static release builds)

Preview cuts without rendering:

```bash
auto-editor podcast.mp4 --profile tiktok --preview
```

---

## Workflows that match how creators actually work

### One long video → several TikTok clips

Best for podcasts, streams, or vlogs. Picks up to **N** kept segments between **15–60 seconds**, ranked by **loudest/most active** moments (not just the longest chunks).

```bash
auto-editor podcast.mp4 --profile tiktok --clips 5
```

Outputs:

```
podcast_clip01_tiktok.mp4
podcast_clip02_tiktok.mp4
…
```

Same thing via profile modifier:

```bash
auto-editor podcast.mp4 --profile tiktok:clips=5
```

### Batch a folder of raw recordings

Process every video in a directory with the same settings:

```bash
auto-editor --input-dir ./raw-footage --profile tiktok --clips 3
```

Collect everything into one export folder:

```bash
auto-editor --input-dir ./raw-footage --profile tiktok --clips 3 --output-dir ./ready-to-post
```

Supported formats in the folder: `.mp4`, `.mkv`, `.mov`, `.avi`, `.webm`, `.m4v`, and common variants (see `src/tiktok/batch.nim`).

### Talking head with your own captions

```bash
auto-editor interview.mp4 --profile tiktok --captions interview.srt
```

Use `--burn-captions` explicitly if you are not using the TikTok profile. Burn-in requires a **Linux or macOS** static release build (libass bundled).

### Snappier or slower pacing

Default TikTok margin is **0.15s** (tighter than stock auto-editor). Loosen it:

```bash
auto-editor talk.mp4 --profile tiktok --margin 0.4sec
```

### Cut on motion instead of silence

Good for B-roll–heavy or music content:

```bash
auto-editor broll.mp4 --profile tiktok --edit motion:threshold=0.02
```

Combine audio and motion:

```bash
auto-editor mix.mp4 --profile tiktok --edit "(or audio:0.04 motion:0.03)"
```

---

## Profile modifiers cheat sheet

| Goal | Command |
|------|---------|
| Standard TikTok export | `--profile tiktok` |
| Five ranked clips | `--profile tiktok:clips=5` |
| Disable hook (first 3s can be cut) | `--profile tiktok:no-hook` or `--no-hook-window` |
| Full-frame (no caption-safe crop) | `--profile tiktok:no-safe-zone` or `--no-caption-safe-zone` |
| No burned captions | `--profile tiktok:no-burn-captions` or `--no-burn-captions` |
| Stack modifiers | `--profile tiktok:clips=3,no-hook` |

Explicit flags always win over profile defaults.

---

## Output naming

| Command | Output |
|---------|--------|
| `--profile tiktok` | `{stem}_tiktok.mp4` |
| `--profile tiktok --clips 5` | `{stem}_clip01_tiktok.mp4` … `{stem}_clip05_tiktok.mp4` |
| `--input-dir` + `--output-dir ./out` | Files land under `./out/` with the same naming |

---

## Troubleshooting

### `No clips matched duration limits (15–60s)`

The first pass did not leave any **kept** segments in the 15–60 second range. Try:

- Looser silence detection: `--edit audio:0.02` (lower threshold = more kept)
- Wider margins: `--profile tiktok --margin 0.3sec`
- Fewer clips: `--clips 2`
- Check what was cut: `--profile tiktok --preview`

### Output looks too zoomed / subject cropped oddly

Caption-safe mode top-aligns content. Disable for full-frame:

```bash
auto-editor clip.mp4 --profile tiktok --no-caption-safe-zone
```

### Captions did not burn in

- Confirm subs exist: `auto-editor info yourfile.mp4`
- On Linux/macOS, use a static release binary with libass. Windows pre-built binaries do not include burn-in yet.
- Force a caption file: `--captions subs.srt`

### Hook feels too long or too short

Disable the protected hook window:

```bash
auto-editor clip.mp4 --profile tiktok --no-hook-window
```

Or manually protect a different range with `--add-in` / `--set-action` (see upstream [manual editing](https://auto-editor.com/docs)).

---

## What to upload to TikTok

This fork exports **9:16 at 1080×1920**, H.264 — compatible with TikTok upload. Clips under **3 minutes** fit platform limits; **15–60 seconds** is the sweet spot for discovery (what `--clips` targets).

Add captions, hashtags, and sound in TikTok after upload unless you burned them in here.

---

## Next steps

- **Validate before v0.4:** [Creator validation checklist](creator-validation.md) — dogfood five workflows, then recruit 2–3 creators
- Full CLI reference: `auto-editor --help`
- Upstream options and edit syntax: [auto-editor.com/docs](https://auto-editor.com/docs)
- Fork domain terms: [CONTEXT.md](../CONTEXT.md)
