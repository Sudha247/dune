open Import

(** In-build locations and lock dir loading for tools declared with the
    [tool] stanza in dune-workspace. The corresponding external
    (solver-written) lock dir locations live in [Dune_pkg.Tool]. *)

val install_path_base_dir_name : Filename.t

(** The path to the package universe inside the _build directory for
    the given tool *)
val universe_install_path : Package.Name.t -> Path.Build.t

(** The directory containing the builds of tools' dependencies, keyed by
    package digest. Shared across all tools: a dependency with a given
    digest is the same build regardless of which tool depends on it. *)
val deps_install_path_base : unit -> Path.Build.t

(** The lock dir location where the build system can create the lock
    directory for the given tool. It is populated by copy rules from
    the external lock dir. *)
val build_lock_dir : Package.Name.t -> Path.Build.t

(** Whether the given tool's external lock dir exists *)
val is_locked : Package.Name.t -> bool Memo.t

(** Raises a user error explaining that the given tool is not locked,
    with a hint to run [dune tools add] *)
val raise_not_locked : Package.Name.t -> 'a

(** Loads the lock dir of the given tool, making sure the copy rules
    populating it have run. Raises the same error as [raise_not_locked]
    if the tool is not locked. *)
val lock_dir : Package.Name.t -> Dune_pkg.Lock_dir.t Memo.t

(** Raises a user error if the given tool is not declared with a [tool]
    stanza in the workspace *)
val check_declared : Package.Name.t -> unit Memo.t
