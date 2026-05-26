import std/[algorithm, options, os]

import ../action
import ../cache
import ../timeline
import ../util/fun
import ../util/rational

const defaultMinClipSec* = 15.0
const defaultMaxClipSec* = 60.0

type ClipSignals* = object
  audio*: seq[float32]
  motion*: seq[float32]

proc loadClipSignals*(path: string, tb: AVRational): ClipSignals =
  if path == "":
    return
  result.audio = readCache(path, tb, "audio", "0").get(@[])
  result.motion = readCache(path, tb, "motion", "0,400,9").get(@[])

proc clipDurationSec*(clip: Clip2, tb: AVRational): float64 =
  (clip.`end` - clip.start).float64 / tb.float64

proc signalPeakMean(values: seq[float32], start, stop: int64): (float64, float64) =
  if values.len == 0:
    return (0.0, 0.0)
  let s = max(0, start.int)
  let e = min(values.len, stop.int)
  if e <= s:
    return (0.0, 0.0)
  var peak = 0.0
  var sum = 0.0
  for i in s ..< e:
    let v = values[i].float64
    if v > peak:
      peak = v
    sum += v
  (peak, sum / float64(e - s))

proc rankScore*(clip: Clip2, tb: AVRational, signals: ClipSignals): float64 =
  let (aPeak, aMean) = signalPeakMean(signals.audio, clip.start, clip.end)
  let (mPeak, mMean) = signalPeakMean(signals.motion, clip.start, clip.end)
  let hasAudio = signals.audio.len > 0
  let hasMotion = signals.motion.len > 0
  if hasAudio and hasMotion:
    0.55 * aPeak + 0.15 * aMean + 0.25 * mPeak + 0.05 * mMean
  elif hasAudio:
    0.75 * aPeak + 0.25 * aMean
  elif hasMotion:
    0.75 * mPeak + 0.25 * mMean
  else:
    clipDurationSec(clip, tb)

proc selectClips*(tl: v3, count: int, minSec = defaultMinClipSec,
    maxSec = defaultMaxClipSec, signals: ClipSignals = ClipSignals()): seq[Clip2] =
  if count < 1:
    return @[]

  let useSignals = signals.audio.len > 0 or signals.motion.len > 0
  var ranked: seq[(Clip2, float64, float64)] = @[]
  for clip in tl.clips2:
    if tl.effects[clip.effect].isCut:
      continue
    let dur = clipDurationSec(clip, tl.tb)
    if dur >= minSec and dur <= maxSec:
      let score =
        if useSignals: rankScore(clip, tl.tb, signals)
        else: dur
      ranked.add (clip, score, dur)

  ranked.sort(proc(a, b: (Clip2, float64, float64)): int =
    let byScore = cmp(b[1], a[1])
    if byScore != 0:
      byScore
    else:
      cmp(b[2], a[2]))

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
  let (_, inName, _) = agSplitFile(inputPath)
  let outDir =
    if userOutput != "":
      agSplitFile(userOutput)[0]
    else:
      agSplitFile(inputPath)[0]
  let dir = if outDir.len > 0: outDir else: "."
  let label = clipIndexLabel(index, total)
  joinPath(dir, inName & "_clip" & label & "_tiktok.mp4")
