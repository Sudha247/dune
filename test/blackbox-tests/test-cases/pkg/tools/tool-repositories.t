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
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0

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
  File "dune-workspace", line 4, characters 15-21:
  4 |  (repositories nosuch))
                     ^^^^^^
  Error: Repository 'nosuch' is not a known repository
  [1]
