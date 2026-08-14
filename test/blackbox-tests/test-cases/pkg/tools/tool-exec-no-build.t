Running a locked but not yet built tool with "dune exec --no-build".

  $ mkpkg foo 1.0.0 <<EOF
  > install: [ "sh" "-c" "mkdir -p %{bin}% && touch %{bin}%/foo && chmod +x %{bin}%/foo" ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
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

The tool is locked but has never been built, so --no-build refuses to
run it:

  $ dune exec --no-build foo
  Error: Program 'foo' isn't built yet. You need to build it first or remove
  the '--no-build' option.
  [1]
