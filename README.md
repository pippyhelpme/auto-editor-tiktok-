<p align="center"><img src="https://auto-editor.com/img/auto-editor-banner.webp" title="Auto-Editor" width="700"></p>

**Auto-Editor** is a command line application for automatically **editing video and audio** by analyzing a variety of methods, most notably audio loudness.

---

[![Actions Status](https://img.shields.io/github/actions/workflow/status/wyattblue/auto-editor/build.yml?style=flat)](https://github.com/wyattblue/auto-editor/actions)
[![Nim](https://img.shields.io/badge/nim-%23FFE953.svg?style=flat&logo=nim&logoColor=black)](https://nim-lang.org)

Before doing the real editing, you first cut out the "dead space" which is typically silence. This is known as a "first pass". Cutting these is a boring task, especially if the video is very long.

```
auto-editor path/to/your/video.mp4
```

<h2 align="center">TikTok preset</h2>

This fork adds a platform preset for short-form vertical video:

```
auto-editor example.mp4 --profile tiktok
```

`--profile tiktok` applies TikTok-oriented defaults:

- **1080×1920** vertical frame (letterboxed/pillarboxed with black bars)
- **0.15s** margin for snappier pacing
- **H.264** encode with CRF 23, `medium` encoder preset, `high` profile
- Output named `{stem}_tiktok.mp4` when `--output` is not set

Explicit flags override preset values, e.g. `--profile tiktok --margin 0.5sec`.

The preset keeps the first **3 seconds** (the hook window) uncut by default. Disable with `--no-hook-window` or `--profile tiktok:no-hook`.

Video is reframed to the **upper 75%** of the vertical frame so TikTok's caption UI does not cover important content. Disable with `--no-caption-safe-zone` or `--profile tiktok:no-safe-zone`.

Embedded or file-based captions can be **burned in** with `--burn-captions` (or `--captions FILE`). The TikTok profile enables burn-in when captions are available. Disable with `--no-burn-captions` or `--profile tiktok:no-burn-captions`.

Export multiple short clips from one long video:

```
auto-editor long.mp4 --profile tiktok --clips 5
```

Process every video in a folder (same options for each file):

```
auto-editor --input-dir ./raw-footage --profile tiktok --clips 3
auto-editor --input-dir ./raw-footage --profile tiktok --output-dir ./exports
```

Ranks **15–60 second** kept segments by audio/motion peaks and writes `{stem}_clip01_tiktok.mp4`, `{stem}_clip02_tiktok.mp4`, etc. Same as `--profile tiktok:clips=5`.

**New to TikTok exports?** See [Creator quickstart](docs/creator-quickstart.md) for install, common workflows, and troubleshooting.

<h2 align="center">Installing (this fork)</h2>

### Pre-built binaries (recommended)

Download a static binary for your platform from the [Releases page](https://github.com/pippyhelpme/auto-editor-tiktok-/releases):

| Platform | Asset |
|----------|-------|
| Linux x86_64 | `auto-editor-tiktok-linux-x86_64` |
| Linux ARM64 | `auto-editor-tiktok-linux-aarch64` |
| Linux ARMv7 | `auto-editor-tiktok-linux-armv7` |
| macOS Intel | `auto-editor-tiktok-macos-x86_64` |
| macOS Apple Silicon | `auto-editor-tiktok-macos-arm64` |
| Windows x86_64 | `auto-editor-tiktok-windows-x86_64.exe` |
| Windows ARM64 | `auto-editor-tiktok-windows-aarch64.exe` |

```bash
chmod +x auto-editor-tiktok-linux-x86_64
./auto-editor-tiktok-linux-x86_64 example.mp4 --profile tiktok
```

Burn-in captions (`--burn-captions`) require the Linux/macOS static builds (libass bundled). Windows pre-built binaries do not include burn-in yet.

### Build from source

If no binary matches your platform, build locally:

- **Nim** 2.2.2+ and **nimble**
- A C compiler (gcc or clang)
- **FFmpeg development libraries** — `libavcodec`, `libavformat`, `libavutil`, `libavfilter`, `libswscale`, `libswresample`
- **libass** — required for `--burn-captions` / TikTok burn-in

**Fedora / RHEL:**
```bash
sudo dnf install nim gcc nimble ffmpeg-free-devel libass-devel
```

**Debian / Ubuntu:**
```bash
sudo apt install nim nimble gcc libavcodec-dev libavformat-dev libavutil-dev \
  libavfilter-dev libswscale-dev libswresample-dev libass-dev
```

**Install Nim** (if needed): https://nim-lang.org/install.html

```bash
git clone https://github.com/pippyhelpme/auto-editor-tiktok-.git
cd auto-editor-tiktok-
nimble brewmake
```

This produces `./auto-editor` in the repo root (dynamically linked to system FFmpeg).

For a fully static binary (longer build, bundles FFmpeg + libass):

```bash
nimble makeff   # download & compile FFmpeg (~30+ min)
nimble make
```

### Verify

```bash
./auto-editor --version
./auto-editor example.mp4 --profile tiktok --preview
```

### Tests

```bash
nimble test                              # Nim unit tests
python tests/test.py -n test_profile_tiktok test_burn_captions_movtext
```

Upstream install methods (without TikTok features): [auto-editor.com/installing](https://auto-editor.com/installing)

<h2 align="center">Cutting</h2>

Change the **pace** of the edited video by using `--margin`.

`--margin` adds in some "silent" sections to make the editing feel nicer.

```
# Add 0.2 seconds of padding before and after to make the edit nicer.
# `0.2s` is the default value for `--margin`
auto-editor example.mp4 --margin 0.2sec

# Add 0.3 seconds of padding before, 1.5 seconds after
auto-editor example.mp4 --margin 0.3s,1.5sec
```

### Methods for Making Automatic Cuts
The `--edit` option is how auto-editor makes automated cuts.

For example, edit out motionlessness in a video by setting `--edit motion`.

```
# cut out sections where the total motion is less than 2%.
auto-editor example.mp4 --edit motion:threshold=0.02

# `--edit audio:threshold=0.04,stream=all` is used by defaut.
auto-editor example.mp4

# Different tracks can be set with different attribute.
auto-editor multi-track.mov --edit "(or audio:stream=0 audio:threshold=10%,stream=1)"
```

Different editing methods can be used together.
```
# 'threshold' is always the first argument for edit-method objects
auto-editor example.mp4 --edit "(or audio:0.03 motion:0.06)"
```

You can also use `dB` unit, a volume unit familiar to video-editors (case sensitive):
```
auto-editor example.mp4 --edit audio:-19dB
auto-editor example.mp4 --edit audio:-7dB
auto-editor example.mp4 --edit motion:-19dB
```

### See What Auto-Editor Cuts Out
To export what auto-editor normally cuts out. Set `--when-normal` to `cut` and `--when-silent` to `nil` (leave as is). This is the reverse of the usual default values.

```
auto-editor example.mp4 --when-normal cut --when-silent nil
```

<h2 align="center">Exporting to Editors</h2>

Create an XML file that can be imported to Adobe Premiere Pro using this command:

```
auto-editor example.mp4 --export premiere
```

Auto-Editor can also export to:
- DaVinci Resolve with `--export resolve`
- Final Cut Pro with `--export final-cut-pro`
- ShotCut with `--export shotcut`
- Kdenlive with `--export kdenlive`
- Individual media clips with `--export clip-sequence`

### Naming Timelines
Some editors support naming timelines. By default, auto-editor will use the name "Auto-Editor Media Group". For `premiere` `resolve` and `final-cut-pro` export options, you can change the name with the following syntax.

```
# for POSIX shells
auto-editor example.mp4 --export 'premiere:name="Your name here"'

# for Powershell
auto-editor example.mp4 --export 'premiere:name=""Your name here""'
```

### Split by Clip

If you want to split the clips, but don't want auto-editor to do any more editing. There's a simple command.
```
auto-editor example.mp4 --when-silent nil --when-normal nil --export premiere
```

<h2 align="center">Importing timeline files</h2>
Auto-Editor can read fcp7 xml files and render them as media files:

```
auto-editor myFcp7File.xml -o render.mp4
```

Available Importers:
 - Auto-Editor timeline files (`.v1`, `.v2`, `.v3`)
 - FCP7 XML (experimental)

PRs implementing more importers are encouraged.

<h2 align="center">Manual Editing</h2>

Use the `--cut-out` option to always remove a section.

```
# Cut out the first 30 seconds.
auto-editor example.mp4 --cut-out 0,30sec

# Cut out the first 30 frames.
auto-editor example.mp4 --cut-out 0,30

# Always leave in the first 30 seconds.
auto-editor example.mp4 --add-in 0,30sec

# Cut out the last 10 seconds.
auto-editor example.mp4 --cut-out -10sec,end

# You can do multiple at once.
auto-editor example.mp4 --cut-out 0,10 15sec,20sec
auto-editor example.mp4 --add-in 30sec,40sec 120,150sec
```

And of course, you can use any `--edit` configuration.

If you don't want **any automatic cuts**, you can use `--edit none` or `--edit all`

```
# Cut out the first 5 seconds, leave the rest untouched.
auto-editor example.mp4 --edit none --cut-out 0,5sec

# Leave in the first 5 seconds, cut everything else out.
auto-editor example.mp4 --edit all --add-in 0,5sec
```

<h2 align="center">More Options</h2>

List all available options:

```
auto-editor --help
```

## Articles
 - [Creator quickstart (TikTok fork)](docs/creator-quickstart.md)
 - [How to Install Auto-Editor](https://auto-editor.com/installing)
 - [All the Options (And What They Do)](https://auto-editor.com/ref/options)
 - [Docs](https://auto-editor.com/docs)
 - [Blog](https://basswood-io.com/blog/)

## GUI Application
There is a graphical application [available](https://app.auto-editor.com) under a propriety license. No GUI code, or proprietary code/assets, are included in this repository.

## Copyright
Everything in this repository is under the [Public Domain](https://github.com/WyattBlue/auto-editor/blob/master/LICENSE). Binary artifacts in the "Releases" section may be under various open source licenses.
