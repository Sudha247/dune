open Import

(** In-build locations and lock dir loading for tools declared with the
    [tool] stanza in dune-workspace. The corresponding external
    (solver-written) lock dir locations live in [Dune_pkg.Tool]. *)

val install_path_base_dir_name : Filename.t

(** The path to the package universe inside the _build directory for
    the given tool *)
val universe_install_path : Package.Name.t -> Path.Build.t

(** The path to the executable for running the given tool *)
val exe_path : Package.Name.t -> Path.Build.t

(** The lock dir location where the build system can create the lock
    directory for the given tool. It is populated by copy rules from
    the external lock dir. *)
val build_lock_dir : Package.Name.t -> Path.Build.t

(** Loads the lock dir of the given tool, making sure the copy rules
    populating it have run *)
val lock_dir : Package.Name.t -> Dune_pkg.Lock_dir.t Memo.t
