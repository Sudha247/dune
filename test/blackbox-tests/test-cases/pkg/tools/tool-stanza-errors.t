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
  Error: fields name, names are all missing (exactly one is needed)
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

The name must be a valid opam package name:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo/bar))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 12-19:
  2 | (tool (name foo/bar))
                  ^^^^^^^
  Error: "foo/bar" is an invalid opam package name.
  Package names can contain letters, numbers, '-', '_' and '+', and need to
  contain at least a letter.
  Hint: foo_bar would be a correct opam package name
  [1]

"name" and "names" are mutually exclusive:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo) (names bar))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 0-29:
  2 | (tool (name foo) (names bar))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: fields "name" and "names" are mutually exclusive.
  [1]

"names" must declare at least one tool name:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (names))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 13-13:
  2 | (tool (names))
                   
  Error: "names" must declare at least one tool name.
  [1]

"binaries" cannot be used alongside "names" at the stanza level; it
must nest inside each entry of "names" instead:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (names foo) (binaries a))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 0-31:
  2 | (tool (names foo) (binaries a))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: "binaries" cannot be used together with "names"; put a per-name
  (binaries ...) inside each entry of "names" instead.
  [1]

"binaries" must select at least one binary:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo) (binaries))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 27-27:
  2 | (tool (name foo) (binaries))
                                 
  Error: "binaries" must select at least one binary.
  [1]
