A tool package that provides several binaries, none of which is named
after the package. All binaries of the package are installed, but only
a binary named after the package can currently be run.

  $ mkpkg multibin 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho alpha\n' > %{bin}%/alpha" ]
  >   [ "chmod" "+x" "%{bin}%/alpha" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho beta\n' > %{bin}%/beta" ]
  >   [ "chmod" "+x" "%{bin}%/beta" ]
  > ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name multibin)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

  $ dune tools add multibin
  Solution for _build/.tools.lock/multibin
  
  Dependencies common to all supported platforms:
  - multibin.1.0.0


The binaries the locked tool provides cannot be run by name:

  $ dune exec alpha
  Error: Program 'alpha' not found!
  [1]

Running the tool by its package name fails, because the package
installs no binary named after itself:

  $ dune exec multibin
  Error: This rule defines a directory target "default/.tools/multibin/target"
  that matches the requested path "default/.tools/multibin/target/bin/multibin"
  but the rule's action didn't produce it
  [1]

The binaries are nevertheless installed; building one directly works:

  $ dune build _build/_private/default/.tools/multibin/target/bin/alpha
  $ _build/_private/default/.tools/multibin/target/bin/alpha
  alpha
