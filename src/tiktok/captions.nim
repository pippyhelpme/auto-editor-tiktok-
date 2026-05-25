import std/[os, strutils]

import ../[av, ffmpeg, log]

const assHeader* = """
[Script Info]
ScriptType: v4.00+

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,28,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2,1,2,10,10,96,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

proc escapeSubtitlesPath*(path: string): string =
  result = path
  result = result.replace("\\", "/")
  result = result.replace(":", "\\:")
  result = result.replace("'", "'\\''")

proc tiktokCaptionStyle*(): string =
  "Fontsize=28,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=1,Outline=2,Shadow=1,Alignment=2,MarginV=96"

proc buildSubtitlesFilterArgs*(path: string): string =
  "'" & escapeSubtitlesPath(path) & "':force_style='" & tiktokCaptionStyle() & "'"

proc extractEmbeddedSubtitles*(inputPath, outPath: string): bool =
  var container: InputContainer
  try:
    container = av.open(inputPath)
  except IOError:
    return false
  defer: container.close()

  if container.subtitle.len == 0:
    return false

  let streamIndex = container.subtitle[0].index
  let stream = container.formatContext.streams[streamIndex]
  var codecCtx = initDecoder(stream.codecpar)
  defer:
    var p = codecCtx
    avcodec_free_context(addr p)

  var events: seq[string]
  var subtitle: AVSubtitle
  while av_read_frame(container.formatContext, container.packet) >= 0:
    defer: av_packet_unref(container.packet)
    if container.packet.stream_index != streamIndex.cint:
      continue

    var gotSubtitle: cint = 0
    let ret = avcodec_decode_subtitle2(codecCtx, addr subtitle, addr gotSubtitle,
      container.packet)
    if ret < 0 or gotSubtitle == 0:
      continue
    defer: avsubtitle_free(addr subtitle)

    for i in 0 ..< subtitle.num_rects:
      let rect = subtitle.rects[i]
      if rect.`type` == SUBTITLE_ASS and rect.ass != nil:
        let line = ($rect.ass).strip()
        if line.len > 0:
          events.add line

  if events.len == 0:
    return false

  writeFile(outPath, assHeader & events.join("\n") & "\n")
  true

proc resolveCaptionFile*(args: mainArgs, inputPath: string): string =
  if args.burnCaptionsPath != "":
    if not fileExists(args.burnCaptionsPath):
      error("Caption file not found: " & args.burnCaptionsPath)
    return absolutePath(args.burnCaptionsPath)

  let base = if tempDir != "": tempDir else: getTempDir()
  let outPath = base / "ae-burn-captions.ass"
  if extractEmbeddedSubtitles(inputPath, outPath):
    return outPath
  ""
