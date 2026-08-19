A tool's "binaries" field can declare a binary name the package
doesn't actually provide. This can only be detected once the tool is
built (binaries are read from its install cookie), and raises a
dedicated error rather than the generic "no binary named after tool"
error.

  $ mkpkg foo 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "printf '#!/bin/sh\necho alpha\n' > %{bin}%/alpha" ]
  >   [ "chmod" "+x" "%{bin}%/alpha" ]
  > ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name foo)
  >  (binaries nope)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0



Building the tool succeeds (it's the declared selection that's wrong,
not the package itself), but resolving any of its binaries reports the
declared-but-not-provided binary:

  $ dune exec alpha
  Error: Tool "foo" does not provide a binary named "nope", declared in its
  (binaries ...) field.
  Hint: The tool provides the following binaries: alpha
  [1]
  $ dune exec foo
  Error: Tool "foo" does not provide a binary named "nope", declared in its
  (binaries ...) field.
  Hint: The tool provides the following binaries: alpha
  [1]
