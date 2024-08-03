import os, strutils, tables

# Count files with different extensions
proc countFileExtensions(dir: string): Table[string, int] =
  var extensionCount = initTable[string, int]()

  for entry in walkDir(dir):
    if entry.kind == pcFile:
      let ext = entry.path.splitFile.ext
      if ext.len > 0:
        extensionCount[ext] = extensionCount.getOrDefault(ext, 0) + 1

  return extensionCount

when isMainModule:
  if paramCount() == 1:
    let directory = paramStr(1)
    let extensionCount = countFileExtensions(directory)
    for ext, count in extensionCount:
      echo "Extension: ", ext, " Count: ", count
  else:
    echo "Usage: ", getAppFilename(), " <directory>"
