# Package

version = "0.1.0"
author = "Lee Braiden <leebraid@gmail.com>"
description = "Runs nim code as scripts, regardless of file extension"
license = "MIT"

srcDir = "src"
binDir = "bin"

bin = @["nimrun"]

skipExt = @["nim"]

requires "tempfile"