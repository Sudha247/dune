open Import

type t =
  { package : OpamPackage.t
  ; occurrences : int
  ; deps : t list
  }

let repr =
  Repr.fix (fun repr ->
    Repr.record
      "dependency-tree"
      [ Repr.field "package" (Repr.abstract Opam_dyn.package) ~get:(fun t -> t.package)
      ; Repr.field "occurrences" Repr.int ~get:(fun t -> t.occurrences)
      ; Repr.field "deps" (Repr.list repr) ~get:(fun t -> t.deps)
      ])
;;

let to_dyn = Repr.to_dyn repr

(* Immediate dependencies of [package_name] on [platform]. Local packages aren't
   present in the lockdir, so their dependencies are resolved through the package
   universe; the dependencies of all other (locked) packages are read directly
   from the lockdir's dependency graph. A locked package's dependency is kept if
   it resolves to another package in the lockdir or to a local package (the
   latter is not producible today, as the solver rejects out-of-workspace
   packages depending on workspace packages). *)
let immediate_dependencies
      package_universe
      ~local_packages
      ~platform_pkgs
      ~platform
      package_name
  =
  let deps =
    if Package_name.Map.mem local_packages package_name
    then
      Package_universe.opam_package_dependencies_of_package
        package_universe
        package_name
        ~which:`All
        ~traverse:`Immediate
      |> List.map ~f:(fun opam_package ->
        Package_name.of_opam_package_name (OpamPackage.name opam_package))
    else (
      match Package_name.Map.find platform_pkgs package_name with
      | None -> []
      | Some (pkg : Lock_dir.Pkg.t) ->
        Lock_dir.Conditional_choice.choose_for_platform pkg.depends ~platform
        |> Option.value ~default:[]
        |> List.filter_map ~f:(fun (dep : Lock_dir.Dependency.t) ->
          Option.some_if
            (Package_name.Map.mem platform_pkgs dep.name
             || Package_name.Map.mem local_packages dep.name)
            dep.name))
  in
  List.sort deps ~compare:Package_name.compare
;;

let create package_universe =
  let local_packages = Package_universe.local_packages package_universe in
  let platform = Package_universe.platform package_universe in
  let lock_dir = Package_universe.lock_dir package_universe in
  let platform_pkgs =
    Lock_dir.Packages.pkgs_on_platform_by_name lock_dir.packages ~platform
  in
  let roots = Package_name.Map.keys local_packages in
  (* Memoized so that the parents-graph and tree-building traversals don't each
     re-resolve a package's dependencies (formula resolution for local packages
     is not free). *)
  let immediate_dependencies =
    let immediate_deps = ref Package_name.Map.empty in
    fun package_name ->
      match Package_name.Map.find !immediate_deps package_name with
      | Some deps -> deps
      | None ->
        let deps =
          immediate_dependencies
            package_universe
            ~local_packages
            ~platform_pkgs
            ~platform
            package_name
        in
        immediate_deps := Package_name.Map.set !immediate_deps package_name deps;
        deps
  in
  (* Reverse dependency graph: the parents of each reachable package. Each
     package's dependencies are expanded only once, so every edge is recorded
     exactly once. *)
  let parents =
    let rec collect (parents, seen) package_name =
      if Package_name.Set.mem seen package_name
      then parents, seen
      else (
        let seen = Package_name.Set.add seen package_name in
        List.fold_left
          (immediate_dependencies package_name)
          ~init:(parents, seen)
          ~f:(fun (parents, seen) dependency ->
            let parents = Package_name.Map.add_multi parents dependency package_name in
            collect (parents, seen) dependency))
    in
    List.fold_left roots ~init:(Package_name.Map.empty, Package_name.Set.empty) ~f:collect
    |> fst
  in
  (* The number of times a package occurs in the fully-expanded tree: once for
     each local package that is a root, plus, for each package that depends on
     it, that package's own number of occurrences. *)
  let occurrences =
    let cache = ref Package_name.Map.empty in
    (* [visiting] is the set of packages whose count is currently being computed.
       Re-entering one means the dependency graph has a cycle (only possible
       between local packages; the lockdir is acyclic), which we don't support. *)
    let rec occurrences ~visiting package_name =
      match Package_name.Map.find !cache package_name with
      | Some n -> n
      | None ->
        if Package_name.Set.mem visiting package_name
        then
          User_error.raise
            [ Pp.textf
                "Dependency cycle detected involving package %S"
                (Package_name.to_string package_name)
            ];
        let visiting = Package_name.Set.add visiting package_name in
        let from_roots =
          if Package_name.Map.mem local_packages package_name then 1 else 0
        in
        let n =
          Package_name.Map.find parents package_name
          |> Option.value ~default:[]
          |> List.fold_left ~init:from_roots ~f:(fun acc parent ->
            acc + occurrences ~visiting parent)
        in
        cache := Package_name.Map.set !cache package_name n;
        n
    in
    occurrences ~visiting:Package_name.Set.empty
  in
  (* A package's subtree is expanded the first time it is encountered; later
     encounters become leaves. [visited] is threaded through the traversal in
     depth-first order rather than kept in a mutable cell. *)
  let rec node visited package_name =
    let make deps =
      { package = Package_universe.opam_package_of_package package_universe package_name
      ; occurrences = occurrences package_name
      ; deps
      }
    in
    if Package_name.Set.mem visited package_name
    then visited, make []
    else (
      let visited = Package_name.Set.add visited package_name in
      let visited, deps =
        List.fold_map (immediate_dependencies package_name) ~init:visited ~f:node
      in
      visited, make deps)
  in
  List.fold_map roots ~init:Package_name.Set.empty ~f:node |> snd
;;
