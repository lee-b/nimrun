# nimrun

This is a shebang compatibility wrapper for the nim language.  It is licensed
under the same license as nim itself, in the hopes that it will one day (with
improvements) be shipped along with nim, so that users can rely on nim scripts
working so long as nim is installed.


## Features

* This does NOT need a .nim extension on your script file, so that your nim
  script can be used just like any other executable, regardless of what language
  it was written in. What's the point of naming the interpreter on the shebang
  line, if you're going to use an extension? File extensions are a DOS
  thing anyway.

* Does not pollute your working directory or the script directory with binaries or
  cache files. Builds everything in a temporary directory, and executes it from
  there, whilst maintaining the current working directory as the relative location
  in which data files are found, etc.
  
* This also preserves your filenames and workflows, even if you decide to use a
  full nim project (or some other language) later (or earlier).


## How it works

* Takes a single argument, the nim script.

* Builds a nimrod project for it in a temporary directory

* Compiles the project, saving all compiler output. Only if the compile fails is
  the compiler output shown.

* Runs the executable with any remaining arguments

* Removes the temporary directory


## Contributing

Pull requests welcome!  Especially for anything in the **To Do** section.


## To do

* Caching. Nim (and nimble) compile quickly, but it's a bit wasteful without
  caching, regardless.

* Show the nimble build output only when something goes wrong.

* Ensure signals like Ctrl-C are sent to the child process.

* In future, I might add support for parsing the imports and includes, and
  including them in the build, giving access to all of the nimble packages
  from scripts.


## Authors

* Lee Braiden <leebraid@gmail.com>
