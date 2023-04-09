# Package

version       = "0.1.0"
author        = "Avahe Kellenberger"
description   = "A new awesome nimble package"
license       = "GPL-2.0-only"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ufd"]


# Dependencies

requires "nim >= 1.6.12"
requires "jester >= 0.5.0"

task runr, "Runs the program":
  exec "nim r -d:release --opt:speed src/ufd.nim"

task release, "Creates a release build":
  exec "nim c -o:bin/ufd -d:release --opt:speed src/ufd.nim"

