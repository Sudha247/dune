Test installation of multiple dev tools

  $ . ./helpers.sh


Setup fake ocamlformat, ocamllsp

  $ dev_tool_lock_dir="_build/.dev-tools.locks/ocaml-lsp-server"


# Create a fake ocaml-lsp-server package containing an executable that
# just prints a message.

  $ mkpkg ocaml-lsp-server <<EOF
  > install: [
  >  [ "sh" "-c" "echo '#!/bin/sh' > %{bin}%/ocamllsp" ]
  >  [ "sh" "-c" "echo 'echo hello from fake ocamllsp' >> %{bin}%/ocamllsp" ]
  >  [ "sh" "-c" "chmod a+x %{bin}%/ocamllsp" ]
  >  ]
  > EOF

  $ mkpkg ocamlformat <<EOF
  > install: [
  >  [ "sh" "-c" "echo '#!/bin/sh' > %{bin}%/ocamlformat" ]
  >  [ "sh" "-c" "echo 'echo hello from fake ocamlformat' >> %{bin}%/ocamlformat" ]
  >  [ "sh" "-c" "chmod a+x %{bin}%/ocamlformat" ]
  >  ]
  > EOF

# Create a dune-workspace file with mock repos set up for the main
# project and the ocamllsp lockdir.
  $ mkrepo
  $ mkpkg ocaml 5.2.0

  $ cat > dune-project <<EOF
  > (lang dune 3.21)
  > 
  > (package
  >  (name foo)
  >  (depends ocaml)
  >  (allow_empty))
  > EOF

  $ cat > dune-workspace <<EOF
  > (lang dune 3.21)
  > (lock_dir
  >   (path "_build/.dev-tools.locks/ocaml-lsp-server")
  >   (repositories mock))
  > (lock_dir
  >   (path "_build/.dev-tools.locks/ocamlformat")
  >   (repositories mock))
  > (lock_dir
  >   (repositories mock))
  > (repository
  >   (name mock)
  >   (url "file://$(pwd)/mock-opam-repository"))
  > (pkg enabled)
  > EOF

  $ dune pkg lock

Install the dev tools

$ dune tools install ocamllsp ocamlformat
  $ dune tools install ocamlformat ocamllsp
