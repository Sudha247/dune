Pins referenced by a (tool ...) stanza must be defined by a (pin ...) stanza
in the same dune-workspace file.

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (pins my-ocamllsp)
  >  (packages (ocaml-lsp-server as ocamllsp)))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 7-18:
  3 |  (pins my-ocamllsp)
             ^^^^^^^^^^^
  Error: Unknown pin "my-ocamllsp".
  Hint: Pins must be defined with a (pin ...) stanza in this file.
  [1]

With the pin defined:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (pin
  >  (name my-ocamllsp)
  >  (url "file://$PWD/vendor/lsp")
  >  (package (name ocaml-lsp-server)))
  > (tool
  >  (pins my-ocamllsp)
  >  (packages (ocaml-lsp-server as ocamllsp)))
  > EOF

  $ dune build
