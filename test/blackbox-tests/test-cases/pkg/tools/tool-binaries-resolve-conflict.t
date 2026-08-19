Two tool packages both install a binary named "clash" (see also
tool-binary-conflict.t, which shows the resulting conflict error).
Restricting one tool's "binaries" to exclude "clash" resolves the
conflict: the remaining tool's "clash" is unambiguous.

  $ mkpkg toola 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho clash from toola\n' > %{bin}%/clash" ]
  >   [ "chmod" "+x" "%{bin}%/clash" ]
  > ]
  > EOF
  $ mkpkg toolb 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho clash from toolb\n' > %{bin}%/clash" ]
  >   [ "chmod" "+x" "%{bin}%/clash" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho other from toolb\n' > %{bin}%/other" ]
  >   [ "chmod" "+x" "%{bin}%/other" ]
  > ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name toola)
  >  (repositories mock))
  > (tool
  >  (name toolb)
  >  (binaries other)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

  $ dune tools add toola
  Solution for _build/.tools.lock/toola
  
  Dependencies common to all supported platforms:
  - toola.1.0.0


  $ dune tools add toolb
  Solution for _build/.tools.lock/toolb
  
  Dependencies common to all supported platforms:
  - toolb.1.0.0



"clash" now unambiguously resolves to toola, since toolb's "clash" is
excluded by its "binaries" selection:

  $ dune exec clash
  clash from toola

toolb's selected binary is still reachable by name:

  $ dune exec other
  other from toolb
