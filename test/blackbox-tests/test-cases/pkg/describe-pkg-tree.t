Test that "dune describe pkg tree" recursively displays the dependency tree of
each local package.

  $ mkrepo

  $ mkpkg a 0.0.1 <<EOF
  > EOF
  $ mkpkg b <<EOF
  > EOF
  $ mkpkg c <<EOF
  > EOF
  $ mkpkg bar <<EOF
  > depends: [ "b" "c"]
  > EOF
  $ mkpkg baz <<EOF
  > depends: [ "bar" ]
  > EOF
  $ mkpkg qux <<EOF
  > depends: [ "a" "b" "c" ]
  > EOF
  $ solve_project <<EOF
  > (lang dune 3.11)
  > (package
  >  (name local_1)
  >  (depends
  >   local_2))
  > (package
  >  (name local_2)
  >  (depends
  >   baz
  >   (qux :with-test)))
  > EOF
  Solution for dune.lock:
  - a.0.0.1
  - b.0.0.1
  - bar.0.0.1
  - baz.0.0.1
  - c.0.0.1
  - qux.0.0.1

The tree is printed recursively. Each package's subtree is expanded only the
first time it is encountered; later occurrences print just the package, and the
number of times a package occurs in the full tree is shown as "(*N)". For
example "b" and "c" occur 4 times each, and "local_2" is both a local package
and a dependency of "local_1" so it occurs twice.

  $ dune describe pkg tree
  Dependency tree of local packages locked in dune.lock
  - local_1.dev
    - local_2.dev (*2)
      - baz.0.0.1 (*2)
        - bar.0.0.1 (*2)
          - b.0.0.1 (*4)
          - c.0.0.1 (*4)
      - qux.0.0.1 (*2)
        - a.0.0.1 (*2)
        - b.0.0.1 (*4)
        - c.0.0.1 (*4)
  - local_2.dev (*2)
