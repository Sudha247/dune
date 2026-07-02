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

Two local packages that are both roots, where "proj_a" depends on "proj_b". The
subtree of "proj_b" is expanded under "proj_a"; its second, top-level occurrence
is collapsed to a leaf. This confirms top-level roots are collapsed like any
other repeated package.

  $ solve_project <<EOF
  > (lang dune 3.11)
  > (package (name proj_a) (depends proj_b))
  > (package (name proj_b) (depends c))
  > EOF
  Solution for dune.lock:
  - c.0.0.1
  $ dune describe pkg tree
  Dependency tree of local packages locked in dune.lock
  - proj_a.dev
    - proj_b.dev (*2)
      - c.0.0.1 (*2)
  - proj_b.dev (*2)

A local package ("alpha") depending on a locked package ("beta") that in turn
depends back on a local package ("gamma") is not a supported workspace: dune
rejects a package outside the workspace depending on one inside it, so this
topology never reaches the dependency tree.

  $ mkpkg beta <<EOF
  > depends: [ "gamma" ]
  > EOF
  $ solve_project <<EOF
  > (lang dune 3.11)
  > (package (name alpha) (depends beta))
  > (package (name gamma))
  > EOF
  Error: Dune does not support packages outside the workspace depending on
  packages in the workspace. The package "beta" is not in the workspace but it
  depends on the package "gamma" which is in the workspace.
  [1]

A dependency cycle between two local packages. Cycles are not supported, so the
command reports a controlled error rather than looping.

  $ solve_project <<EOF
  > (lang dune 3.11)
  > (package (name left) (depends right))
  > (package (name right) (depends left))
  > EOF
  Solution for dune.lock:
  (no dependencies to lock)
  $ dune describe pkg tree
  Error: Dependency cycle detected involving package "left"
  [1]
