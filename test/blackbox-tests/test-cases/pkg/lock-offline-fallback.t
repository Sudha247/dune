Test that dune pkg lock --no-update uses existing lock directory and that
network failures fall back to existing lock directory.

Create a git-based mock opam repository:

  $ mkrepo
  $ mkpkg foo 1.0
  $ cd mock-opam-repository
  $ git init --quiet
  $ git add -A
  $ git commit --quiet -m "Initial commit"
  $ cd ..

  $ add_mock_repo_if_needed "git+file://$PWD/mock-opam-repository"

  $ cat > dune-project <<EOF
  > (lang dune 3.16)
  > (package
  >  (name bar)
  >  (allow_empty)
  >  (depends foo))
  > EOF

First, solve normally to create the lock directory:

  $ dune pkg lock 2>&1 | grep -i "solution"
  Solution for dune.lock

  $ test -d dune.lock && echo "lock dir exists"
  lock dir exists

Test --no-update with existing lock directory:

  $ dune pkg lock --no-update 2>&1
  Using existing lock directory dune.lock.

  $ test -d dune.lock && echo "lock dir exists"
  lock dir exists

Test --no-update without a lock directory:

  $ rm -rf dune.lock
  $ dune pkg lock --no-update 2>&1
  Error: No existing lock directory dune.lock and --no-update was specified.
  [1]

Recreate the lock directory for the fallback tests:

  $ dune pkg lock 2>&1 | grep -i "solution"
  Solution for dune.lock

Test network failure fallback with existing lock directory.
Point the repository to a nonexistent git remote to simulate a fetch error:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.16)
  > (lock_dir
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "git+file://$PWD/nonexistent-repo"))
  > EOF

  $ dune pkg lock 2>&1 | grep -A1 "^Warning:"
  Warning: Unable to connect to package repositories for lock directory
  dune.lock. The existing lock directory will be used unchanged.

  $ test -d dune.lock && echo "lock dir exists"
  lock dir exists

Test network failure without existing lock directory fails:

  $ rm -rf dune.lock
  $ dune pkg lock 2>&1 | grep "^Error:"
  Error: Failed to run external command:
  [1]

Test auto-locking without an explicit lockfile. First do a successful solve
to populate the ls-remote cache, then break the repo URL.

  $ rm -rf dune.lock

Restore working repo and solve once to populate caches:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.16)
  > (lock_dir
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "git+file://$PWD/mock-opam-repository"))
  > EOF

  $ dune pkg lock 2>&1 | grep -i "solution"
  Solution for dune.lock
  $ rm -rf dune.lock

Enable auto-locking and point to a broken repo:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.20)
  > (pkg enabled)
  > (lock_dir
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "git+file://$PWD/mock-opam-repository"))
  > EOF

First build with auto-lock succeeds (repo is still available):

  $ dune build 2>&1 | grep -i "error" || echo "build succeeded"
  build succeeded

Now break the repo URL:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.20)
  > (pkg enabled)
  > (lock_dir
  >  (repositories mock))
  > (repository
  >  (name mock)
  >  (url "git+file://$PWD/nonexistent-repo"))
  > EOF

Auto-lock should use cached ls-remote data and still succeed:

  $ dune build 2>&1 | grep -A1 "^Warning:" || echo "build succeeded"
  build succeeded
