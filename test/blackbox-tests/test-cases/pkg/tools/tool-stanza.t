Tests for the (tool ...) stanza in dune-workspace.

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

A tool stanza declaring a single tool by name:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name ocamlfind))
  > EOF
  $ dune build

The stanza is versioned and unavailable in older versions of the dune
language:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 0-23:
  2 | (tool (name ocamlfind))
      ^^^^^^^^^^^^^^^^^^^^^^^
  Error: 'tool' is only available since version 3.25 of the dune language.
  Please update your dune-project file to have (lang dune 3.25).
  [1]

Declaring the same tool twice is an error:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name ocamlfind))
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 3, characters 0-23:
  3 | (tool (name ocamlfind))
      ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Tool "ocamlfind" is defined multiple times:
  - dune-workspace:2
  - dune-workspace:3
  [1]

A tool stanza declaring several tools that share the same
repositories:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (names ocamlfind ocp-indent))
  > EOF
  $ dune build

The same duplicate-name check applies across a "names" list too, and
across a "names" list and a separate "name" stanza:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (names ocamlfind ocp-indent ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 34-43:
  2 | (tool (names ocamlfind ocp-indent ocamlfind))
                                        ^^^^^^^^^
  Error: Tool "ocamlfind" is defined multiple times:
  - dune-workspace:2
  - dune-workspace:2
  [1]

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (names ocamlfind ocp-indent))
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 3, characters 0-23:
  3 | (tool (name ocamlfind))
      ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Tool "ocamlfind" is defined multiple times:
  - dune-workspace:2
  - dune-workspace:3
  [1]
