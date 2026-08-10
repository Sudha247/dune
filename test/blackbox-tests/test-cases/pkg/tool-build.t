Building a tool declared with the (tool ...) stanza from an existing lock
directory. "dune tools add" will eventually create tool lock directories;
here one is constructed by hand at the expected location.

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool (name foo))
  > EOF

The tool's package source: a shell script to be installed as the "foo"
executable.

  $ mkdir foo-source
  $ cat > foo-source/foo.sh <<EOF
  > #!/bin/sh
  > echo "hello from foo"
  > EOF
  $ chmod a+x foo-source/foo.sh

A hand-constructed lock directory for the tool containing a single
dependency-free package:

  $ tool_lock_dir="_build/.tools.lock/foo"
  $ mkdir -p "$tool_lock_dir"
  $ cat > "$tool_lock_dir/lock.dune" <<EOF
  > (lang package 0.1)
  > (repositories (complete true))
  > EOF
  $ cat > "$tool_lock_dir/foo.pkg" <<EOF
  > (version 1.0.0)
  > (source (copy $PWD/foo-source))
  > (build
  >  (progn
  >   (run mkdir -p %{prefix}/bin)
  >   (run cp foo.sh %{prefix}/bin/foo)))
  > EOF

Build the tool's executable and run it:

  $ dune build _build/_private/default/.tools/foo/target/bin/foo
  $ ./_build/_private/default/.tools/foo/target/bin/foo
  hello from foo

A tool that is not declared in dune-workspace cannot be built:

  $ dune build _build/_private/default/.tools/bar/target/bin/bar
  Error: Tool "bar" is not declared in the workspace.
  Hint: Add (tool (name bar)) to your dune-workspace file.
  [1]
