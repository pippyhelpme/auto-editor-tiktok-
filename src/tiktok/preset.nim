import std/[options, os]

import ../log
import ../util/[color, fun]

type ProfileField* = enum
  pfMargin, pfResolution, pfBackground, pfVideoCodec, pfEncoderPreset, pfCrf,
  pfVprofile, pfOutput

type ProfileOverrides* = set[ProfileField]

const tiktokResolution* = (int32(1080), int32(1920))

proc applyTiktokPreset*(args: var mainArgs, overrides: ProfileOverrides) =
  if pfMargin notin overrides:
    args.margin = (pack(true, 150), pack(true, 150)) # 0.15s
  if pfResolution notin overrides:
    args.resolution = tiktokResolution
  if pfBackground notin overrides:
    args.background = some(RGBColor(red: 0, green: 0, blue: 0))
  if pfVideoCodec notin overrides:
    args.videoCodec = "libx264"
  if pfEncoderPreset notin overrides:
    args.preset = "medium"
  if pfCrf notin overrides:
    args.crf = 23
  if pfVprofile notin overrides:
    args.vprofile = "high"
  if pfOutput notin overrides and args.inputs.len > 0:
    let (dir, name, _) = agSplitFile(args.inputs[0])
    args.output = joinPath(dir, name & "_tiktok.mp4")

proc applyProfile*(args: var mainArgs, overrides: ProfileOverrides) =
  case args.profile
  of "tiktok":
    applyTiktokPreset(args, overrides)
  of "":
    discard
  else:
    error("Unknown profile: " & args.profile & "\nAvailable profiles: tiktok")
