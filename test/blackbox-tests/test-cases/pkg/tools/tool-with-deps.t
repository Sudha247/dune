Building a tool whose package has dependencies. Tools are solved
independently of the project's dependencies, and their dependencies are
built in a pool shared across tools (keyed by package digest) rather than
in the project's own package pool. In particular the project here does
not use package management at all.

  $ mkpkg bar 0.0.1 <<EOF
  > EOF
  $ mkpkg foo 1.0.0 <<EOF
  > depends: [ "bar" ]
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho hello from foo\n' > %{bin}%/foo" ]
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

Lock the tool. The solution contains the tool and its dependency:

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - bar.0.0.1
  - foo.1.0.0


Build and run the tool:

  $ dune build _build/_private/default/.tools/foo/target/bin/foo
  $ ./_build/_private/default/.tools/foo/target/bin/foo
  hello from foo

The tool's dependency was built in the tools' shared dependency pool
rather than the project's own package pool:

  $ ls _build/_private/default/.tools/.deps | sed 's/\..*//'
  bar
  $ ls _build/_private/default/.pkg
  ls: cannot access '_build/_private/default/.pkg': No such file or directory
  [2]
