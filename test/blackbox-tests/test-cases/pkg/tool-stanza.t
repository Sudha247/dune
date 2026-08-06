Tests for the (tool ...) stanza in dune-workspace.

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

A tool stanza declaring a single tool by name. This is currently rejected;
once the stanza is implemented this should build silently.

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 1-5:
  2 | (tool (name ocamlfind))
       ^^^^
  Error: Unknown field "tool"
  [1]

The stanza is versioned and unavailable in older versions of the dune
language:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 2, characters 1-5:
  2 | (tool (name ocamlfind))
       ^^^^
  Error: Unknown field "tool"
  [1]

Declaring the same tool twice is an error:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name ocamlfind))
  > (tool (name ocamlfind))
  > EOF
  $ dune build
  File "dune-workspace", line 3, characters 1-5:
  3 | (tool (name ocamlfind))
       ^^^^
  Error: Unknown field "tool"
  [1]
