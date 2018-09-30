import logging
import strformat
import sequtils
import streams
from os import nil
from osproc import nil
from ospaths import nil
from system import nil
from tempfile import nil
from strutils import nil


proc main() : int


system.quit(main())


proc main() : int =
    if os.paramCount() < 1:
        echo "ERROR: nimrun requires at least one argument: the nim program to run (additional arguments to the script are optional)"
        return 1

    let nim_script = os.paramStr(1)
    let (_, basename, _) = ospaths.splitFile(nim_script)

    let tempDir = tempfile.mkdtemp()

    debug(&"Using temporary directory {tempDir}")

    try:
        let srcDir = ospaths.joinPath(tempDir, "src")
        let binDir = ospaths.joinPath(tempDir, "bin")
        os.createDir(srcDir)
        os.createDir(binDir)

        let nimbleFile = basename & ".nimble"
        let nimblePath = ospaths.joinPath(tempDir, nimbleFile)
        let srcFile = basename & ".nim"
        let tempSrc = ospaths.joinPath(srcDir, srcFile)

        var nimbleFP = open(nimblePath, mode=fmWrite)

        let nimbleDef = strutils.join(@[
                "# Package",
                "",
                "version = \"0.1.0\"",
                "author = \"(not available)\"",
                "description = \"(not available)\"",
                "license = \"(not available)\"",
                "",
                "srcDir = \"src\"",
                "binDir = \"bin\"",
                "",
                &"bin = @[\"{basename}\"]",
                "",
                "skipExt = @[\"nim\"]",
            ],
            "\n"
        )

        nimbleFP.write(nimbleDef)
        nimbleFP.close()

        debug(&"Copying {nim_script} to {tempSrc}")

        os.copyFile(nim_script, tempSrc)

        let build_proc = osproc.startProcess(
            os.findExe("nimble"), tempDir,
            ["build",], nil,
            {osproc.poUseShell, },
        )

        let build_output = osproc.outputStream(build_proc).readAll()

        let build_rc = osproc.waitForExit(build_proc)

        if build_rc != 0:
            echo &"ERROR: {nim_script} failed to compile; aborting."
            echo build_output
            return build_rc

        let executablePath = ospaths.joinPath(tempDir, "bin", basename)

        debug(&"Built {executablePath}")

        var script_params = os.commandLineParams()
        script_params.delete(0)

        let args = strutils.join(script_params, " ")

        let rc = os.execShellCmd(&"{executablePath} {args}")

        return rc

    finally:
        os.removeDir(tempDir)
