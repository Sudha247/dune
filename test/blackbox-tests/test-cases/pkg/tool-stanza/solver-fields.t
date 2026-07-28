The solve environment fields of the (tool ...) stanza share the validation of
the corresponding lock_dir fields.

A variable cannot appear in both solver_env and unset_solver_vars:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (solver_env (os linux))
  >  (unset_solver_vars os)
  >  (packages ocamlformat))
  > EOF

  $ dune build
  File "dune-workspace", line 4, characters 20-22:
  4 |  (unset_solver_vars os)
                          ^^
  Error: Variable "os" appears in both 'solver_env' and 'unset_solver_vars'
  which is not allowed.
  [1]

solve_for_platforms cannot be empty:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (solve_for_platforms)
  >  (packages ocamlformat))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 1-22:
  3 |  (solve_for_platforms)
       ^^^^^^^^^^^^^^^^^^^^^
  Error: No platforms were specified for solving dependencies.
  Hint: Specify at least one platform here, or remove this field to solve for
  the default platforms.
  [1]
