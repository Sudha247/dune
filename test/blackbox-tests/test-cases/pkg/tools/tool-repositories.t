The repositories used to lock a tool are declared in the tool stanza
itself.

  $ mkpkg foo 1.0.0 <<EOF
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

Lock a tool against the repositories named in its stanza. No lock_dir
stanza is involved:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name foo)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "$(default_repo_path)"))
  > EOF
  $ dune tools add foo
  File "dune-workspace", line 4, characters 2-14:
  4 |  (repositories mock))
        ^^^^^^^^^^^^
  Error: Unknown field "repositories"
  [1]

Naming a repository that is not declared in the workspace is an
error:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name foo)
  >  (repositories nosuch))
  > EOF
  $ rm -rf _build/.tools.lock
  $ dune tools add foo
  File "dune-workspace", line 4, characters 2-14:
  4 |  (repositories nosuch))
        ^^^^^^^^^^^^
  Error: Unknown field "repositories"
  [1]
