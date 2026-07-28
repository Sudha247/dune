tool
====

.. warning::

   :doc:`Dune Package Management </explanation/package-management>` is not
   final yet and the configuration options are subject to change.

This stanza declares development tools (such as ``ocamlformat`` or
``ocaml-lsp-server``) for the workspace, along with the settings used to
solve their dependencies. Each tool is solved and built independently of the
project's own dependencies.

.. describe:: (tool ...)

   .. versionadded:: 3.24

   Declares a set of tool packages sharing the same solve settings. The
   stanza can appear multiple times, e.g., to give different groups of tools
   different settings.

   .. describe:: (packages <entry> ...)

      Required and non-empty: the tool packages this stanza covers. Each
      entry is one of:

      - ``<package>``: a package providing a single binary named after the
        package itself, e.g., ``ocamlformat``.
      - ``(<package> <constraint>)``: the same, with a version constraint
        using the same syntax as ``(depends ...)``, e.g.,
        ``(ocamlformat (= 0.27.0))``.
      - ``(<package> as <binary>)``: a package exposing a single binary
        under a different name, e.g., ``(ocaml-lsp-server as ocamllsp)``.
      - ``(<package> as (<binary> ...))``: a package exposing several
        binaries, e.g., ``(merlin as (ocamlmerlin ocamlmerlin-server))``.
      - ``((<package> <constraint>) as <binary>)``: both a version
        constraint and a binary binding.

      The binary names exposed by all ``tool`` stanzas of a workspace must
      be distinct.

   .. describe:: (inherit_lock_dir [<path>])

      Inherit the solve environment fields (``repositories``,
      ``solver_env``, ``unset_solver_vars``, ``version_preference`` and
      ``solve_for_platforms``) from the :doc:`lock_dir` stanza with the
      given path. Without an argument, it inherits from the ``lock_dir``
      stanza configuring ``dune.lock``. The referenced ``lock_dir`` stanza
      must exist.

      The dependency payload fields of the ``lock_dir`` stanza
      (``constraints``, ``depopts``, ``pins`` and ``path``) are never
      inherited.

      For every solve setting, the most specific value wins: fields written
      in the ``tool`` stanza override inherited fields, which override the
      built-in defaults.

   .. describe:: (repositories <name list>)

      Same syntax and semantics as the corresponding :doc:`lock_dir` field,
      applied to the solve of each package of the stanza. In this
      :doc:`ordered set </reference/ordered-set-language>`, ``:standard``
      refers to the inherited repositories when ``inherit_lock_dir`` is
      used, and to the default repositories otherwise.

   .. describe:: (solver_env ...)

      Same syntax and semantics as the corresponding :doc:`lock_dir` field.

   .. describe:: (unset_solver_vars <name list>)

      Same syntax and semantics as the corresponding :doc:`lock_dir` field.

   .. describe:: (version_preference <string>)

      Same syntax and semantics as the corresponding :doc:`lock_dir` field.

   .. describe:: (solve_for_platforms <env> ...)

      Same syntax and semantics as the corresponding :doc:`lock_dir` field.

   .. describe:: (constraints <dep> ...)

      Additional constraints applied to the solve of each package of the
      stanza, e.g., ``(ocaml (>= 5.1.0))``. This is distinct from the
      version constraint of a ``packages`` entry, which constrains the tool
      package itself.

   .. describe:: (pins <name list>)

      Pins available to the solve of each package of the stanza, referencing
      :doc:`pin` stanzas of this ``dune-workspace`` file by name.

   .. describe:: (skip_compiler_match)

      Disable compiler matching for the packages of this stanza. By default,
      tools are built with a compiler matching the project's: the compiler is
      taken from the project's lock directory if available, otherwise from
      the system OCaml, otherwise any compatible compiler is used.

Examples
--------

A typical project configuration:

.. code:: dune

   (tool
    (packages
     (ocamlformat (= 0.27.0)) ; pinned: must agree with .ocamlformat
     odoc
     (ocaml-lsp-server as ocamllsp)))

Splitting compiler-coupled and compiler-independent tools:

.. code:: dune

   (tool
    (constraints (ocaml (>= 5.2.0)))
    (packages
     (ocaml-lsp-server as ocamllsp)
     (merlin as (ocamlmerlin ocamlmerlin-server))))

   (tool
    (skip_compiler_match)
    (packages
     (ocamlformat (= 0.27.0))
     odoc))

A tool pinned to a fork:

.. code:: dune

   (pin
    (name my-ocamllsp)
    (url "git+https://github.com/me/ocaml-lsp.git#my-branch")
    (package (name ocaml-lsp-server)))

   (tool
    (pins my-ocamllsp)
    (packages (ocaml-lsp-server as ocamllsp)))
