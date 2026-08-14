Building a tool whose package fetches its source archive over http,
verifying it against the checksum recorded in the tool's lock
directory.

A tarball containing the tool's source, served by the fake curl:

  $ mkdir foo
  $ printf '#!/bin/sh\necho tool foo\n' > foo/foo.sh
  $ tar cf foo.tar foo
  $ rm -rf foo
  $ checksum=$(md5sum foo.tar | cut -f1 -d' ')
  $ echo foo.tar >> fake-curls
  $ PORT=1

  $ mkpkg foo 1.0.0 <<EOF
  > install: [
  >   [ "mkdir" "-p" "%{bin}%" ]
  >   [ "sh" "-c" "cp foo.sh %{bin}%/foo" ]
  >   [ "chmod" "+x" "%{bin}%/foo" ]
  > ]
  > url {
  >  src: "http://0.0.0.0:$PORT"
  >  checksum: [ "md5=$checksum" ]
  > }
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

Lock the tool:

  $ dune tools add foo
  Solution for _build/.tools.lock/foo
  
  Dependencies common to all supported platforms:
  - foo.1.0.0

Build and run the tool:

  $ dune build _build/_private/default/.tools/foo/target/bin/foo 2>&1 | sed "s/$checksum/CHECKSUM/g"
  $ ./_build/_private/default/.tools/foo/target/bin/foo
  tool foo
