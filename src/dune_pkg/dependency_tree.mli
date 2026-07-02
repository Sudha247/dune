(** A node in the dependency tree of the local packages locked in a lockdir. A
    package's subtree is expanded only the first time it is encountered while
    building the tree; later encounters are leaves (empty [deps]). *)
type t =
  { package : OpamPackage.t
  ; occurrences : int (** how many times this package occurs in the fully-expanded tree *)
  ; deps : t list
  }

(** The dependency tree of the local packages of the universe, one entry per
    local package (in package-name order).

    @raise User_error
      if the dependency graph contains a cycle (only possible between local
      packages; the lockdir itself is acyclic). *)
val create : Package_universe.t -> t list

val to_dyn : t -> Dyn.t
