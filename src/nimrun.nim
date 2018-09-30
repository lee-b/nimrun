import logging
import os
import osproc
import ospaths
import posix
import sequtils
import streams
import strformat
import system
import strutils

from tempfile import nil


when isMainModule:
    proc main() : int
    system.quit(main())


proc run(executablePath: string, args: seq[string]) : int =
    # We just need to ignore these signals (rather than pass them
    # to the child), as the child process will receive them
    # separately from the terminal due to being in the same
    # progress group.
    signal(SIGINT, SIG_IGN)
    signal(SIGQUIT, SIG_IGN)

    let process = startProcess(
        executablePath,
        "",
        options = {
            poStdErrToStdout,
            poParentStreams,
        }
    )

    return process.waitForExit()

proc runSuppressed(working_dir: string, cmd: string, args: seq[string]) : int =
    # Runs the process with all output (both stdout and stderr
    # suppressed, unless an error occurs, in which case the output
    # is dumped to stderr

    let build_proc = osproc.startProcess(
        os.findExe("nimble"), working_dir,
        ["build"], nil,
        {osproc.poStdErrToStdOut},
    )

    let build_output = osproc.outputStream(build_proc).readAll()

    let build_rc = osproc.waitForExit(build_proc)

    build_proc.close()

    if build_rc != 0:
        stderr.writeLine("ERROR: {nim_script} failed to compile; aborting.")
        stderr.write(build_output)

    return build_rc


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

        let basename_fixed =
            basename.replace(" ", "_")
            .replace("-", "_")

        let nimbleFile = basename_fixed & ".nimble"
        let nimblePath = ospaths.joinPath(tempDir, nimbleFile)
        let srcFile = basename_fixed & ".nim"
        let tempSrc = ospaths.joinPath(srcDir, srcFile)

        var nimbleFP = open(nimblePath, mode=fmWrite)

        let nimbleDef = @[
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
            &"bin = @[\"{basename_fixed}\"]",
            "",
            "skipExt = @[\"nim\"]",
        ].join("\n")

        nimbleFP.write(nimbleDef)
        nimbleFP.close()

        debug(&"Copying {nim_script} to {tempSrc}")

        os.copyFile(nim_script, tempSrc)

        let build_rc = runSuppressed(
            tempDir,
            os.findExe("nimble"),
            @["build"]
        )

        if build_rc != 0:
            return build_rc

        let executablePath = ospaths.joinPath(tempDir, "bin", basename_fixed)

        debug(&"Built {executablePath}")

        var script_params = os.commandLineParams()
        script_params.delete(0)

        let rc = run(executablePath, script_params);

        return rc

    finally:
        os.removeDir(tempDir)
