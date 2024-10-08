import os, strutils, tables

proc countFileTypes(dir: string): Table[string, int] =
  var typeCounts = initTable[string, int]()
  for kind in { pcFile, pcDir, pcLink, pcSocket, pcNamedPipe, pcBlockDev, pcCharDev }:
    typeCounts[kind.repr] = 0


  for entry in walkDirRec(dir):
    inc typeCounts[entry.kind.repr]

  return typeCounts

when isMainModule:
  if paramCount() == 1:
    let dir = paramStr(1)
    let counts = countFileTypes(dir)
    for kind, count in counts:
      echo kind, ": ", count
  else:
    echo "Usage: ", getAppFilename(), " <directory>"
