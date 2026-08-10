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
  Usage: dune tools [--help] COMMAND …
  dune: unknown command 'add'. Must be one of 'env', 'exec', 'install' or
        'which'
  [1]

The lock directory is created at the tool lock dir location:

  $ ls _build/.tools.lock/foo
  ls: cannot access '_build/.tools.lock/foo': No such file or directory
  [2]

Adding a tool that is already locked does not re-lock it:

  $ dune tools add foo
  Usage: dune tools [--help] COMMAND …
  dune: unknown command 'add'. Must be one of 'env', 'exec', 'install' or
        'which'
  [1]

A tool that is not declared in dune-workspace cannot be added:

  $ dune tools add bar
  Usage: dune tools [--help] COMMAND …
  dune: unknown command 'add'. Must be one of 'env', 'exec', 'install' or
        'which'
  [1]
