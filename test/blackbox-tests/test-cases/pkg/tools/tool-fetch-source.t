Building a tool whose package fetches its source archive over http.
The checksum of a fetched source is looked up in the known lock
directories when the fetch rule runs.

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
  > (tool (name foo))
  > (lock_dir
  >  (path _build/.tools.lock/foo)
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

Build and run the tool. The checksum lookup does not include tool lock
directories, so the fetch rule cannot find the source URL:

  $ dune build _build/_private/default/.tools/foo/target/bin/foo 2>&1 | sed "s/$checksum/CHECKSUM/g"
  Error: unknown checksum md5=CHECKSUM
  -> required by _build/_private/default/.tools/foo/source
  -> required by _build/_private/default/.tools/foo/target/bin/foo
  [1]
  $ ./_build/_private/default/.tools/foo/target/bin/foo
  ./_build/_private/default/.tools/foo/target/bin/foo: No such file or directory
  [127]
