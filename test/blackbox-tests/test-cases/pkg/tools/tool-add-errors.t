Error cases when locking a tool with "dune tools add".

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF

Broken repositories (nonexistent path, not an opam repository, ...)
are covered by pkg/invalid-opam-repo-errors.t; the errors are the same
when locking a tool.

The tool's package does not exist in the repository:

  $ mkpkg unrelated 0.0.1 <<EOF
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
  Error:
  Unable to solve dependencies while generating lock directory:
  $TESTCASE_ROOT/_build/.tools.lock/foo
  
  The dependency solver failed to find a solution for the following platforms:
  - arch = x86_64; os = linux
  - arch = arm64; os = linux
  - arch = x86_64; os = macos
  - arch = arm64; os = macos
  ...with this error:
  Couldn't solve the package dependency formula.
  The following packages couldn't be found: foo
  [1]

The tool's dependencies cannot be solved: foo requires a version of
bar that the repository does not have.

  $ mkpkg bar 1.0.0 <<EOF
  > EOF
  $ mkpkg foo 1.0.0 <<EOF
  > depends: [ "bar" {>= "2.0"} ]
  > EOF
  $ dune tools add foo
  Error:
  Unable to solve dependencies while generating lock directory:
  $TESTCASE_ROOT/_build/.tools.lock/foo
  
  The dependency solver failed to find a solution for the following platforms:
  - arch = x86_64; os = linux
  - arch = arm64; os = linux
  - arch = x86_64; os = macos
  - arch = arm64; os = macos
  ...with this error:
  Couldn't solve the package dependency formula.
  Selected candidates: foo.1.0.0 foo_tool_wrapper.dev
  - bar -> (problem)
      foo 1.0.0 requires >= 2.0
      Rejected candidates:
        bar.1.0.0: Incompatible with restriction: >= 2.0
  [1]
