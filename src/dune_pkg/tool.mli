open Import

(** Tools declared in the workspace via the [tool] stanza, identified
    by the name of the package that provides them. Unlike dev tools
    ([Dev_tool.t]) there is no fixed set of tools. Only a single
    version of a tool can be installed at a time. *)

(** The location under the build directory where the lock directory of
    the given tool is expected. Lock directories are created there
    outside the build system. *)
val external_lock_dir : Package_name.t -> Path.External.t

(** Maps a tool lock dir path back to its representation as a source
    path under the build directory. Returns [None] if the path does not
    point inside the tool lock dirs location. *)
val lock_dir_path_to_source_dir_opt : Path.External.t -> Path.Source.t option
