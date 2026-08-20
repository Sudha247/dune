Version constraints on a tool's declared name.

  $ mkpkg foo 1.0.0 <<EOF
  > EOF
  $ mkpkg foo 2.0.0 <<EOF
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

A version constraint on the singular "name" field is not supported yet:

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
  File "dune-workspace", line 3, characters 7-22:
  3 |  (name (foo (= 1.0.0)))
             ^^^^^^^^^^^^^^^
  Error: Atom or quoted string expected
  [1]

A version constraint combined with (binaries ...) inside a "names" entry
is not supported yet:

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
  File "dune-workspace", line 3, characters 29-30:
  3 |  (names (baz (binaries baz) (= 1.0.0)) bar)
                                   ^
  Error: Unknown field "="
  [1]

A filter atom is not a valid version constraint; today it also just fails
to parse rather than getting a dedicated error:

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
  File "dune-workspace", line 3, characters 7-23:
  3 |  (name (foo :with-test))
             ^^^^^^^^^^^^^^^^
  Error: Atom or quoted string expected
  [1]
