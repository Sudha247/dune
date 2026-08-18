Two tool packages each install a binary with the same name. Requesting
that name must inform the user of the conflict rather than silently
picking one of the tools.

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


Both tools are locked and both provide a binary named "clash".
Requesting that name reports the conflict instead of picking a tool:

  $ dune exec clash
  Error: Binary "clash" is provided by several tools: toola, toolb.
  [1]
