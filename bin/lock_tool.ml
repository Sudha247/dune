open Import

(* The solver satisfies dependencies for local packages, but tools are
   not local packages. As a workaround, create an empty local package
   which depends on the tool package. *)
let make_local_package_wrapping_tool ~constraint_ name : Dune_pkg.Local_package.t =
  let dependency = { Dune_lang.Package_dependency.name; constraint_ } in
  let local_package_name =
    Package_name.of_string (Package_name.to_string name ^ "_tool_wrapper")
  in
  { Dune_pkg.Local_package.name = local_package_name
  ; version = Dune_pkg.Lock_dir.Pkg_info.default_version
  ; dependencies = Dune_pkg.Dependency_formula.of_dependencies [ dependency ]
  ; conflicts = []
  ; depopts = []
  ; pins = Package_name.Map.empty
  ; conflict_class = []
  ; loc = Loc.none
  ; command_source = Opam_file { build = []; install = [] }
  }
;;

let solve name =
  let open Memo.O in
  let* solver_env_from_current_system =
    Pkg.Pkg_common.poll_solver_env_from_current_system ()
    |> Memo.of_reproducible_fiber
    >>| Option.some
  and* workspace = Workspace.workspace () in
  let constraint_ =
    match
      List.find workspace.tools ~f:(fun (tool : Workspace.Tool.t) ->
        Package.Name.equal tool.name name)
    with
    | Some tool -> tool.constraint_
    | None ->
      Code_error.raise
        "Lock_tool.solve: tool not declared"
        [ "name", Package.Name.to_dyn name ]
  in
  let lock_dir = Dune_pkg.Tool.external_lock_dir name |> Path.external_ in
  let local_pkg = make_local_package_wrapping_tool ~constraint_ name in
  let local_packages = Package_name.Map.singleton local_pkg.name local_pkg in
  let portable_lock_dir =
    match Config.get Dune_rules.Compile_time.portable_lock_dir with
    | `Enabled -> true
    | `Disabled -> false
  in
  Memo.of_reproducible_fiber
  @@ Pkg.Lock.solve
       workspace
       ~local_packages
       ~project_pins:Dune_pkg.Pin.DB.empty
       ~solver_env_from_current_system
       ~version_preference:None
       ~lock_dirs:[ lock_dir ]
       ~print_perf_stats:false
       ~portable_lock_dir
;;

let lock_tool name =
  let open Memo.O in
  let* () = Dune_rules.Pkg_tool.check_declared name in
  let lock_dir = Dune_pkg.Tool.external_lock_dir name in
  Dune_engine.Fs_memo.dir_exists (Path.Outside_build_dir.External lock_dir)
  >>= function
  | true ->
    Console.print [ Pp.textf "Tool %S is already locked." (Package_name.to_string name) ];
    Memo.return ()
  | false -> solve name
;;
