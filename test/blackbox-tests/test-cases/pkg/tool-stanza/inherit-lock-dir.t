The inherit_lock_dir field of the (tool ...) stanza must reference an existing
lock_dir stanza.

Referencing a lock_dir that is not defined:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (inherit_lock_dir other.lock)
  >  (packages ocamlformat))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 1-30:
  3 |  (inherit_lock_dir other.lock)
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: No lock_dir stanza with path "other.lock" to inherit from.
  Hint: Add a (lock_dir ...) stanza with this path, or remove this field.
  [1]

Without an argument, inherit_lock_dir refers to dune.lock, which also must be
explicitly configured by a lock_dir stanza:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (inherit_lock_dir)
  >  (packages ocamlformat))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 1-19:
  3 |  (inherit_lock_dir)
       ^^^^^^^^^^^^^^^^^^
  Error: No lock_dir stanza with path "dune.lock" to inherit from.
  Hint: Add a (lock_dir ...) stanza with this path, or remove this field.
  [1]
