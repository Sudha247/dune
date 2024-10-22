A package depending on a package that doesn't exist.
The solver should give a more sane error message.

A few packages here so the errors get large.
  $ . ./helpers.sh
  $ mkrepo
  $ add_mock_repo_if_needed
  $ mkpkg a 0.0.1
  $ mkpkg a 0.0.2
  $ mkpkg a 0.1.0
  $ mkpkg b 0.0.1
  $ mkpkg c 0.0.1 << EOF
  > depends: [ "b" "a" {< "0.1.0"}]
  > EOF
  $ mkpkg d 0.0.1 << EOF
  > depends: [ "a" {>= "0.0.1"} "b"]
  > EOF
  $ mkpkg e 0.0.1
  $ mkpkg e 0.1.0
  $ mkpkg e 0.1.1

  $ cat > dune-project << EOF
  > (lang dune 3.15)
  > (name abc)
  > (package
  >  (name abc)
  >  (depends
  >    a
  >    b
  >    c
  >    d
  >    (e (= 0.1.0))
  >    foobar))
  > EOF

  $ dune pkg lock
  Error: Unable to solve dependencies for the following lock directories:
  Lock directory dune.lock:
  Can't find all required versions.
  Selected: a.0.1.0 abc.dev b.0.0.1 d.0.0.1
  - c -> (problem)
      Rejected candidates:
        c.0.0.1: Requires a < 0.1.0
  - e -> e.0.1.0
      abc dev requires = 0.1.0
  - foobar -> (problem)
      No known implementations at all
  [1]
The problem with foobar seems important enough to not show the wall of text above...
