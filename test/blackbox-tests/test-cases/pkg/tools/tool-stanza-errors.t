Error cases in the (tool ...) stanza itself.

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

The name field is required:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool)
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 0-6:
  2 | (tool)
      ^^^^^^
  Error: Field "name" is missing
  [1]

Unknown fields are rejected. In particular the version of a tool
cannot be specified yet:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo) (version 1.2.3))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 18-25:
  2 | (tool (name foo) (version 1.2.3))
                        ^^^^^^^
  Error: Unknown field "version"
  [1]

An invalid package name is currently accepted silently. This is a
known gap: "foo/bar" can never name an opam package and would produce
nested tool lock dir paths.

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo/bar))
  > EOF
  $ dune build
