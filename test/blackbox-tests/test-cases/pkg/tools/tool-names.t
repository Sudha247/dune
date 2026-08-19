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
  File "dune-workspace", lines 2-4, characters 0-44:
  2 | (tool
  3 |  (names foo bar)
  4 |  (repositories mock))
  Error: Field "name" is missing
  [1]


  $ ls _build/.tools.lock/foo
  ls: cannot access '_build/.tools.lock/foo': No such file or directory
  [2]

  $ ls _build/.tools.lock
  ls: cannot access '_build/.tools.lock': No such file or directory
  [2]

Locking the second name is a fully separate operation, with its own
independent solution:

  $ dune tools add bar
  File "dune-workspace", lines 2-4, characters 0-44:
  2 | (tool
  3 |  (names foo bar)
  4 |  (repositories mock))
  Error: Field "name" is missing
  [1]


  $ ls _build/.tools.lock
  ls: cannot access '_build/.tools.lock': No such file or directory
  [2]

Both are runnable independently:

  $ dune exec foo
  File "dune-workspace", lines 2-4, characters 0-44:
  2 | (tool
  3 |  (names foo bar)
  4 |  (repositories mock))
  Error: Field "name" is missing
  [1]
  $ dune exec bar
  File "dune-workspace", lines 2-4, characters 0-44:
  2 | (tool
  3 |  (names foo bar)
  4 |  (repositories mock))
  Error: Field "name" is missing
  [1]
