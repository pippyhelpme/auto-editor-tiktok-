import std/[options, os]

import ../action
import ../log
import ../util/[color, fun]

type ProfileField* = enum
  pfMargin, pfResolution, pfBackground, pfVideoCodec, pfEncoderPreset, pfCrf,
  pfVprofile, pfOutput

type ProfileOverrides* = set[ProfileField]

type ProfileSpec* = object
  name*: string
  hookWindow*: bool

const tiktokResolution* = (int32(1080), int32(1920))
const hookWindowEnd* = "3sec"

proc parseProfileSpec*(raw: string): ProfileSpec =
  result = ProfileSpec(name: raw, hookWindow: true)
  let colon = raw.find(':')
  if colon == -1:
    return
  result.name = raw[0 ..< colon]
  case raw[colon + 1 .. ^1]
  of "no-hook":
    result.hookWindow = false
  else:
    error("Unknown profile modifier: " & raw[colon + 1 .. ^1])

proc applyHookWindow*(args: var mainArgs) =
  args.setAction.insert(0, (aNil, parseTime("0"), parseTime(hookWindowEnd)))

proc applyTiktokPreset*(args: var mainArgs, overrides: ProfileOverrides,
    hookWindow = true) =
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
  if hookWindow:
    applyHookWindow(args)

proc applyProfile*(args: var mainArgs, overrides: ProfileOverrides) =
  let spec = parseProfileSpec(args.profile)
  case spec.name
  of "tiktok":
    let hook = spec.hookWindow and not args.noHookWindow
    applyTiktokPreset(args, overrides, hook)
  of "":
    discard
  else:
    error("Unknown profile: " & spec.name & "\nAvailable profiles: tiktok")
