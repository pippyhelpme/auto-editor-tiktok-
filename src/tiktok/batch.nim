import std/[algorithm, os, strformat, strutils]

import ../conductor
import ../log
import ../util/fun
import ./preset

const mediaExtensions* = [".mp4", ".mkv", ".mov", ".avi", ".webm", ".m4v",
  ".flv", ".wmv", ".mpg", ".mpeg", ".3gp"]

proc isMediaFile*(path: string): bool =
  mediaExtensions.contains(agSplitFile(path).ext.toLowerAscii())

proc collectMediaFiles*(dir: string): seq[string] =
  if not dirExists(dir):
    error("Input directory does not exist: " & dir)
  for kind, path in walkDir(dir):
    if kind == pcFile and isMediaFile(path):
      result.add path
  result.sort()

proc perFileOutput*(baseArgs: mainArgs, inputPath: string): string =
  let (srcDir, name, _) = agSplitFile(inputPath)
  let outDir =
    if baseArgs.outputDir != "":
      baseArgs.outputDir
    else:
      srcDir
  let spec = parseProfileSpec(baseArgs.profile)
  if spec.name == "tiktok" or baseArgs.clipCount > 0:
    if baseArgs.clipCount > 0:
      return joinPath(outDir, name & ".mp4")
    return joinPath(outDir, name & "_tiktok.mp4")
  if baseArgs.output != "":
    return baseArgs.output
  if baseArgs.outputDir != "":
    return joinPath(outDir, name & "_ALTERED.mp4")
  return ""

proc runBatch*(baseArgs: mainArgs) =
  let files = collectMediaFiles(baseArgs.inputDir)
  if files.len == 0:
    error("No media files found in " & baseArgs.inputDir)

  echo fmt"Batch: processing {files.len} file(s) from {baseArgs.inputDir}"

  for i, path in files.pairs:
    echo fmt"\n[{i + 1}/{files.len}] {path}"
    var fileArgs = baseArgs
    fileArgs.inputs = @[path]
    fileArgs.inputDir = ""
    fileArgs.outputDir = ""
    fileArgs.output = perFileOutput(baseArgs, path)
    editMedia(fileArgs)
