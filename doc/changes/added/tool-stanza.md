- Add a `(tool ...)` stanza to `dune-workspace` files for declaring dev tools
  and the settings used to solve their dependencies: tool packages with
  optional version constraints and binary name bindings, solver settings
  matching the `lock_dir` fields, inheritance of a `lock_dir` stanza's solve
  environment via `inherit_lock_dir`, per-stanza `constraints` and `pins`, and
  `skip_compiler_match`. The stanza is parsed and validated; it is not yet
  consumed when solving dev tools. (@sudha247)
