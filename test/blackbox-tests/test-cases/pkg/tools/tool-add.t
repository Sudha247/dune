Locking a tool declared with the (tool ...) stanza using "dune tools add".

A mock repository with the tool's package:

  $ mkpkg foo 1.0.0 <<EOF
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo))
  > (lock_dir
  >  (path _build/.tools.lock/foo)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "file://$(pwd)/mock-opam-repository"))
  > EOF

Lock the tool:

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0


The lock directory is created at the tool lock dir location:

  $ ls _build/.tools.lock/foo
  foo.1.0.0.pkg
  lock.dune

Adding a tool that is already locked does not re-lock it:

  $ dune tools add foo
  Tool "foo" is already locked.

A tool that is not declared in dune-workspace cannot be added:

  $ dune tools add bar
  Error: Tool "bar" is not declared in the workspace.
  Hint: Add (tool (name bar)) to your dune-workspace file.
  [1]
