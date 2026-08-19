A tool stanza can select a subset of the binaries its package
provides via "binaries". Unselected binaries are no longer resolvable
by "dune exec".

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
  >  (binaries alpha)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

  $ dune tools add multibin
  Solution for _build/.tools.lock/multibin
  
  Dependencies common to all supported platforms:
  - multibin.1.0.0



The selected binary is runnable by name:

  $ dune exec alpha
  alpha

The unselected binary is no longer resolvable, even though the
package installs it:

  $ dune exec beta
  Error: Program 'beta' not found!
  [1]
