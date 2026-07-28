The (tool ...) stanza is only available since dune lang 3.24.

  $ cat > dune-workspace <<EOF
  > (lang dune 3.23)
  > (tool
  >  (packages ocamlformat))
  > EOF

  $ dune build
  File "dune-workspace", lines 2-3, characters 0-30:
  2 | (tool
  3 |  (packages ocamlformat))
  Error: 'tool' is only available since version 3.24 of the dune language.
  Please update your dune-project file to have (lang dune 3.24).
  [1]
