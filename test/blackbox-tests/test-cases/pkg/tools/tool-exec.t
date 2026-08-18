Running a workspace tool with "dune exec". Tools resolve after the
project's own executables and dependency binaries, but before binaries
from PATH.

  $ mkpkg foo 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho tool foo\n' > %{bin}%/foo" ]
  >   [ "chmod" "+x" "%{bin}%/foo" ]
  > ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name foo)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

A program that is neither buildable nor a declared tool is not found:

  $ dune exec bar
  Error: Program 'bar' not found!
  Hint: Tool "foo" is not locked: its binaries were not searched. Run
  'dune tools add foo'
  [1]

The tool is declared but not locked yet:

  $ dune exec foo
  Error: Tool "foo" is not locked.
  Hint: Run 'dune tools add foo'
  [1]

Lock the tool. It can then be run with dune exec:

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0
  $ dune exec foo
  tool foo

A declared tool takes precedence over a binary of the same name in
PATH:

  $ mkdir path-bin
  $ cat > path-bin/foo <<EOF
  > #!/bin/sh
  > echo path foo
  > EOF
  $ chmod +x path-bin/foo
  $ PATH="$PWD/path-bin:$PATH" dune exec foo
  tool foo

An executable of the project itself takes precedence over the tool:

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > (package (name proj))
  > EOF
  $ cat > dune <<EOF
  > (executable
  >  (name foo)
  >  (public_name foo))
  > EOF
  $ cat > foo.ml <<EOF
  > let () = print_endline "project foo"
  > EOF
  $ dune exec foo
  project foo
