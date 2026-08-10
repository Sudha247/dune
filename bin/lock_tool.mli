open Import

(** [lock_tool name] generates the lock directory for the tool [name]
    declared in the workspace, unless one already exists. Raises a user
    error if [name] is not declared with a [tool] stanza. *)
val lock_tool : Package_name.t -> unit Memo.t
