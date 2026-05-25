import std/[algorithm, os]

import ../action
import ../timeline
import ../util/fun
import ../util/rational

const defaultMinClipSec* = 15.0
const defaultMaxClipSec* = 60.0

proc clipDurationSec*(clip: Clip2, tb: AVRational): float64 =
  (clip.`end` - clip.start).float64 / tb.float64

proc selectClips*(tl: v3, count: int, minSec = defaultMinClipSec,
    maxSec = defaultMaxClipSec): seq[Clip2] =
  if count < 1:
    return @[]

  var ranked: seq[(Clip2, float64)] = @[]
  for clip in tl.clips2:
    if tl.effects[clip.effect].isCut:
      continue
    let dur = clipDurationSec(clip, tl.tb)
    if dur >= minSec and dur <= maxSec:
      ranked.add (clip, dur)

  ranked.sort(proc(a, b: (Clip2, float64)): int = cmp(b[1], a[1]))

  for i in 0 ..< min(count, ranked.len):
    result.add ranked[i][0]

proc clipIndexLabel*(index, total: int): string =
  let width = if total >= 100: 3 elif total >= 10: 2 else: 2
  let num = index + 1
  if width == 2:
    if num < 10:
      return "0" & $num
    return $num
  if num < 10:
    return "00" & $num
  if num < 100:
    return "0" & $num
  return $num

proc clipOutputPath*(inputPath, userOutput: string, index, total: int): string =
  let (dir, name, _) =
    if userOutput != "":
      agSplitFile(userOutput)
    else:
      agSplitFile(inputPath)
  let label = clipIndexLabel(index, total)
  joinPath(dir, name & "_clip" & label & "_tiktok.mp4")
