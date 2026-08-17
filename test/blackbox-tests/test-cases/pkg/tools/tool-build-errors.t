Error cases when building a locked tool. Each scenario uses its own
tool so that they do not interfere.

  $ mkpkg buildfail 1.0.0 <<EOF
  > build: [ "sh" "-c" "echo something went wrong; exit 1" ]
  > EOF
  $ mkpkg nobin 1.0.0 <<EOF
  > EOF
  $ mkpkg badbar 1.0.0 <<EOF
  > build: [ "sh" "-c" "echo dependency broke; exit 1" ]
  > EOF
  $ mkpkg depfail 1.0.0 <<EOF
  > depends: [ "badbar" ]
  > EOF

A tarball for the badcheck tool, served by the fake curl, whose opam
file declares a wrong checksum:

  $ mkdir badcheck-src
  $ printf '#!/bin/sh\necho badcheck\n' > badcheck-src/badcheck.sh
  $ tar cf badcheck.tar badcheck-src
  $ rm -rf badcheck-src
  $ echo badcheck.tar >> fake-curls
  $ PORT=1
  $ mkpkg badcheck 1.0.0 <<EOF
  > install: [ "sh" "-c" "mkdir -p %{bin}% && cp badcheck.sh %{bin}%/badcheck" ]
  > url {
  >  src: "http://0.0.0.0:$PORT"
  >  checksum: [ "md5=00000000000000000000000000000000" ]
  > }
  > EOF

  $ mkpkg tampered 1.0.0 <<EOF
  > install: [ "sh" "-c" "mkdir -p %{bin}% && touch %{bin}%/tampered" ]
  > EOF
  $ mkpkg corrupt 1.0.0 <<EOF
  > install: [ "sh" "-c" "mkdir -p %{bin}% && touch %{bin}%/corrupt" ]
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.25)
  > EOF
  $ cat > dune-workspace <<EOF
  > (lang dune 3.25)
  > (tool
  >  (name buildfail)
  >  (repositories mock))
  > (tool
  >  (name nobin)
  >  (repositories mock))
  > (tool
  >  (name depfail)
  >  (repositories mock))
  > (tool
  >  (name badcheck)
  >  (repositories mock))
  > (tool
  >  (name tampered)
  >  (repositories mock))
  > (tool
  >  (name corrupt)
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "$(default_repo_path)"))
  > EOF

The build command of the tool's package fails:

  $ dune tools add buildfail
  Solution for _build/.tools.lock/buildfail
  
  Dependencies common to all supported platforms:
  - buildfail.1.0.0
  $ dune build _build/_private/default/.tools/buildfail/target/bin/buildfail
  something went wrong
  File "_build/.tools.lock/buildfail/buildfail.1.0.0.pkg", line 4, characters 30-32:
  4 |  (all_platforms ((action (run sh -c "echo something went wrong; exit 1")))))
                                    ^^
  Error: Logs for package buildfail
  
  [1]

The tool's package builds but does not install a binary named after
the package:

  $ dune tools add nobin
  Solution for _build/.tools.lock/nobin
  
  Dependencies common to all supported platforms:
  - nobin.1.0.0
  $ dune build _build/_private/default/.tools/nobin/target/bin/nobin
  Error: This rule defines a directory target "default/.tools/nobin/target"
  that matches the requested path "default/.tools/nobin/target/bin/nobin" but
  the rule's action didn't produce it
  [1]

The build command of one of the tool's dependencies fails:

  $ dune tools add depfail
  Solution for _build/.tools.lock/depfail
  
  Dependencies common to all supported platforms:
  - badbar.1.0.0
  - depfail.1.0.0

  $ dune build _build/_private/default/.tools/depfail/target/bin/depfail
  dependency broke
  File "_build/.tools.lock/depfail/badbar.1.0.0.pkg", line 4, characters 30-32:
  4 |  (all_platforms ((action (run sh -c "echo dependency broke; exit 1")))))
                                    ^^
  Error: Logs for package badbar
  
  [1]


The fetched source of the tool does not match the checksum recorded
in the lock directory:

  $ dune tools add badcheck
  Solution for _build/.tools.lock/badcheck
  
  Dependencies common to all supported platforms:
  - badcheck.1.0.0
  $ actual=$(md5sum badcheck.tar | cut -f1 -d' ')
  $ dune build _build/_private/default/.tools/badcheck/target/bin/badcheck 2>&1 | sed "s/$actual/ACTUAL/g"
  File "_build/.tools.lock/badcheck/badcheck.1.0.0.pkg", line 10, characters 12-48:
  10 |   (checksum md5=00000000000000000000000000000000)))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Invalid checksum, got
  md5=ACTUAL
  [1]

The lockfile of the tool's package was deleted from the lock
directory:

  $ dune tools add tampered
  Solution for _build/.tools.lock/tampered
  
  Dependencies common to all supported platforms:
  - tampered.1.0.0
  $ rm _build/.tools.lock/tampered/tampered.1.0.0.pkg
  $ dune build _build/_private/default/.tools/tampered/target/bin/tampered
  Error: The lock directory of the tool "tampered" does not contain a lockfile
  for its package. It may have been modified.
  Hint: Delete
  $TESTCASE_ROOT/_build/.tools.lock/tampered
  and run 'dune tools add tampered' again.
  [1]

The lock.dune of the tool's lock directory is corrupted:

  $ dune tools add corrupt
  Solution for _build/.tools.lock/corrupt
  
  Dependencies common to all supported platforms:
  - corrupt.1.0.0
  $ echo garbage > _build/.tools.lock/corrupt/lock.dune
  $ dune build _build/_private/default/.tools/corrupt/target/bin/corrupt
  File "$TESTCASE_ROOT/_build/.tools.lock/corrupt/lock.dune", line 1, characters 0-7:
  1 | garbage
      ^^^^^^^
  Error: Invalid first line, expected: (lang <lang> <version>)
  [1]
