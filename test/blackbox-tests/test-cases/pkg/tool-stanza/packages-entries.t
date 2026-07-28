Error cases and edge cases for entries in the (packages ...) field of the
(tool ...) stanza.

The packages field is required:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (skip_compiler_match))
  > EOF

  $ dune build
  File "dune-workspace", lines 2-3, characters 0-29:
  2 | (tool
  3 |  (skip_compiler_match))
  Error: Field "packages" is missing
  [1]

The packages field cannot be empty:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 1-11:
  3 |  (packages))
       ^^^^^^^^^^
  Error: Not enough arguments for "packages"
  [1]

Package names must be well-formed:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages what?))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 11-16:
  3 |  (packages what?))
                 ^^^^^
  Error: "what?" is an invalid package dependency.
  Package names can contain letters, numbers, '-', '_' and '+', and need to
  contain at least a letter.
  Hint: what_ would be a correct package dependency
  [1]

An as-pair must bind exactly one binary name:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages (menhir as menhirLib menhirSdk)))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 32-41:
  3 |  (packages (menhir as menhirLib menhirSdk)))
                                      ^^^^^^^^^
  Error: This value is unused
  [1]

An as-list cannot be empty:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages (menhir as ())))
  > EOF

  $ dune build
  File "dune-workspace", line 3, characters 24-24:
  3 |  (packages (menhir as ())))
                              
  Error: Premature end of list
  [1]

A package literally named "as" is accepted in all entry positions:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages
  >   as
  >   ((as (= 1.0)) as as-one)
  >   (as as as-bin)))
  > EOF

  $ dune build
  File "dune-workspace", line 5, characters 2-26:
  5 |   ((as (= 1.0)) as as-one)
        ^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Tool package "as" is declared multiple times in this stanza:
  - dune-workspace:4
  - dune-workspace:5
  [1]

The same, without duplicating the package:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.24)
  > (tool
  >  (packages ((as (= 1.0)) as as-bin)))
  > EOF

  $ dune build
