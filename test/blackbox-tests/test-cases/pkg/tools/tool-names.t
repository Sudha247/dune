A "(tool (names ...))" stanza declares several tools sharing the same
repositories, but each name is still solved, locked, and built fully
independently: there is no shared lock dir or build universe.

  $ mkpkg foo 1.0.0 <<EOF
  > EOF
  $ mkpkg bar 1.0.0 <<EOF
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (names foo bar)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

Locking one of the two names does not lock the other:

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0


  $ ls _build/.tools.lock/foo
  foo.1.0.0.pkg
  lock.dune

  $ ls _build/.tools.lock
  foo

Locking the second name is a fully separate operation, with its own
independent solution:

  $ dune tools add bar
  Solution for _build/.tools.lock/bar
  
  Dependencies common to all supported platforms:
  - bar.1.0.0


  $ ls _build/.tools.lock
  bar
  foo

Both are runnable independently:

  $ dune exec foo
  Error: Tool "foo" does not provide a binary named "foo".
  Hint: The tool installs no binaries.
  [1]
  $ dune exec bar
  Error: Tool "bar" does not provide a binary named "bar".
  Hint: The tool installs no binaries.
  [1]
