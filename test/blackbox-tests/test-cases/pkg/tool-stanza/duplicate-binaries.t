Binary names exposed by (tool ...) stanzas must be unique.

Within a single stanza:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages
  >   (merlin as (ocamlmerlin foo))
  >   (odoc as foo)))
  > EOF

  $ dune build
  File "dune-workspace", line 5, characters 11-14:
  5 |   (odoc as foo)))
                 ^^^
  Error: Tool binary "foo" is defined multiple times:
  - dune-workspace:4
  - dune-workspace:5
  [1]

A bare entry exposes a binary named after the package, so it can collide with
an explicit binding:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages
  >   ocamlformat
  >   (menhir as ocamlformat)))
  > EOF

  $ dune build
  File "dune-workspace", line 5, characters 13-24:
  5 |   (menhir as ocamlformat)))
                   ^^^^^^^^^^^
  Error: Tool binary "ocamlformat" is defined multiple times:
  - dune-workspace:4
  - dune-workspace:5
  [1]

Across stanzas:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages ocamlformat))
  > (tool
  >  (packages (menhir as ocamlformat)))
  > EOF

  $ dune build
  File "dune-workspace", line 5, characters 22-33:
  5 |  (packages (menhir as ocamlformat)))
                            ^^^^^^^^^^^
  Error: Tool binary "ocamlformat" is defined multiple times:
  - dune-workspace:3
  - dune-workspace:5
  [1]

The same package may however appear in two stanzas under different binary
names:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages menhir))
  > (tool
  >  (packages (menhir as menhirSdk)))
  > EOF

  $ dune build

Duplicate packages within one stanza are rejected:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages
  >   (ocamlformat (= 0.26.2))
  >   (ocamlformat as fmt)))
  > EOF

  $ dune build
  File "dune-workspace", line 5, characters 2-22:
  5 |   (ocamlformat as fmt)))
        ^^^^^^^^^^^^^^^^^^^^
  Error: Tool package "ocamlformat" is declared multiple times in this stanza:
  - dune-workspace:4
  - dune-workspace:5
  [1]
