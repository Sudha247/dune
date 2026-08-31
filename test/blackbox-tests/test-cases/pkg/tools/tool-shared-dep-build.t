Two tools that depend on the exact same package (same name, version, and
dependency closure, hence the same package digest) should build that shared
dependency once and reuse it, rather than building it separately for each
tool.

  $ counter="$PWD/counter.txt"
  $ touch "$counter"

A dependency shared by both tools. Its build command logs to a counter file
so this test can tell how many times it actually ran.

  $ mkpkg common 0.0.1 << EOF
  > build: [ [ "sh" "-c" "echo build >> $counter" ] ]
  > EOF

  $ mkpkg toolA 1.0.0 << EOF
  > depends: [ "common" ]
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho hello from toolA\n' > %{bin}%/toolA" ]
  >   [ "chmod" "+x" "%{bin}%/toolA" ]
  > ]
  > EOF

  $ mkpkg toolB 1.0.0 << EOF
  > depends: [ "common" ]
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho hello from toolB\n' > %{bin}%/toolB" ]
  >   [ "chmod" "+x" "%{bin}%/toolB" ]
  > ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name toolA)
  >  (repositories mock))
  > (tool
  >  (name toolB)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

  $ dune tools add toolA
  Solution for _build/.tools.lock/toolA
  
  Dependencies common to all supported platforms:
  - common.0.0.1
  - toolA.1.0.0


  $ dune tools add toolB
  Solution for _build/.tools.lock/toolB
  
  Dependencies common to all supported platforms:
  - common.0.0.1
  - toolB.1.0.0


Building toolA's dependency runs the shared package's build command once:

  $ dune build _build/_private/default/.tools/toolA/target/bin/toolA
  $ cat "$counter"
  build

Building toolB, which depends on the identical "common" package, should
reuse that build rather than running it again:

  $ dune build _build/_private/default/.tools/toolB/target/bin/toolB
  $ cat "$counter"
  build
