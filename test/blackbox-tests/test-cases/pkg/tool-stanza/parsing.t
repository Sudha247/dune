Successful parses of the (tool ...) stanza.

All forms of package entries: bare, constrained, as-pair, as-list, and
constrained + as:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages
  >   ocamlformat
  >   (odoc (= 2.4.0))
  >   (ocaml-lsp-server as ocamllsp)
  >   (merlin as (ocamlmerlin ocamlmerlin-server))
  >   ((menhir (>= 20220210)) as menhirSdk)))
  > EOF

  $ dune build

Multiple tool stanzas, and all optional fields:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (pin
  >  (name my-ocamllsp)
  >  (url "file://$PWD/vendor/lsp")
  >  (package (name ocaml-lsp-server)))
  > (tool
  >  (constraints (ocaml (>= 5.2.0)))
  >  (pins my-ocamllsp)
  >  (packages (ocaml-lsp-server as ocamllsp)))
  > (tool
  >  (skip_compiler_match)
  >  (repositories overlay upstream)
  >  (solver_env (os linux))
  >  (unset_solver_vars arch)
  >  (version_preference oldest)
  >  (solve_for_platforms ((arch x86_64) (os linux)))
  >  (packages (ocamlformat (= 0.27.0)) odoc))
  > EOF

  $ dune build

Inheriting the solve environment from a lock_dir stanza, both from the default
dune.lock and from an explicitly named lock dir:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (lock_dir
  >  (solver_env (os linux)))
  > (lock_dir
  >  (path other.lock)
  >  (version_preference oldest))
  > (tool
  >  (inherit_lock_dir)
  >  (packages ocamlformat))
  > (tool
  >  (inherit_lock_dir other.lock)
  >  (packages odoc))
  > EOF

  $ dune build
