Version constraints on a tool's declared name.

  $ mkpkg foo 1.0.0 <<EOF
  > EOF
  $ mkpkg foo 2.0.0 <<EOF
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

A version constraint on the singular "name" field pins the tool to that
version, even though a newer one is available:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name (foo (= 1.0.0)))
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF
  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0

A version constraint and (binaries ...) can be combined on one "names"
entry, in either order; the version constraint applies only to that
entry's own name:

  $ mkpkg baz 1.0.0 <<EOF
  > EOF
  $ mkpkg baz 2.0.0 <<EOF
  > EOF
  $ mkpkg bar 1.0.0 <<EOF
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (names (baz (binaries baz) (= 1.0.0)) bar)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF
  $ dune tools add baz
  Solution for _build/.tools.lock/baz
  
  Dependencies common to all supported platforms:
  - baz.1.0.0

The same, with the constraint written before (binaries ...):

  $ mkpkg qux 1.0.0 <<EOF
  > EOF
  $ mkpkg qux 2.0.0 <<EOF
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (names (qux (= 1.0.0) (binaries qux)) bar)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF
  $ dune tools add qux
  Solution for _build/.tools.lock/qux
  
  Dependencies common to all supported platforms:
  - qux.1.0.0

A version constraint cannot be specified twice on the same entry:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (names (baz (= 1.0.0) (= 2.0.0)) bar)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF
  $ dune tools add baz
  File "dune-workspace", line 3, characters 23-32:
  3 |  (names (baz (= 1.0.0) (= 2.0.0)) bar)
                             ^^^^^^^^^
  Error: A version constraint cannot be specified twice; combine multiple
  constraints with (and ...).
  [1]

A filter atom is not a valid version constraint, since a tool's own name
is unconditionally solved:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name (foo :with-test))
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF
  $ dune tools add foo
  File "dune-workspace", line 3, characters 12-22:
  3 |  (name (foo :with-test))
                  ^^^^^^^^^^
  Error: Filters such as ":with-test" are not allowed in a tool's version
  constraint. Only version-relational operators (=, <, >, <>, >=, <=), combined
  with and/or/not, are allowed.
  [1]
