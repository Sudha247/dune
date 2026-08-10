open Import

(* The solver satisfies dependencies for local packages, but tools are
   not local packages. As a workaround, create an empty local package
   which depends on the tool package. *)
let make_local_package_wrapping_tool name : Dune_pkg.Local_package.t =
  let dependency = { Dune_lang.Package_dependency.name; constraint_ = None } in
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

let check_tool_is_declared name =
  let open Memo.O in
  let+ workspace = Workspace.workspace () in
  let declared =
    List.exists workspace.tools ~f:(fun (tool : Workspace.Tool.t) ->
      Package_name.equal tool.name name)
  in
  if not declared
  then
    User_error.raise
      [ Pp.textf "Tool %S is not declared in the workspace." (Package_name.to_string name)
      ]
      ~hints:
        [ Pp.textf
            "Add (tool (name %s)) to your dune-workspace file."
            (Package_name.to_string name)
        ]
;;

let solve name =
  let open Memo.O in
  let* solver_env_from_current_system =
    Pkg.Pkg_common.poll_solver_env_from_current_system ()
    |> Memo.of_reproducible_fiber
    >>| Option.some
  and* workspace = Workspace.workspace () in
  let lock_dir = Dune_pkg.Tool.external_lock_dir name |> Path.external_ in
  let local_pkg = make_local_package_wrapping_tool name in
  let local_packages = Package_name.Map.singleton local_pkg.name local_pkg in
  Memo.of_reproducible_fiber
  @@ Pkg.Lock.solve
       workspace
       ~local_packages
       ~project_pins:Dune_pkg.Pin.DB.empty
       ~solver_env_from_current_system
       ~version_preference:None
       ~lock_dirs:[ lock_dir ]
       ~print_perf_stats:false
       ~portable_lock_dir:false
;;

let lock_tool name =
  let open Memo.O in
  let* () = check_tool_is_declared name in
  let lock_dir = Dune_pkg.Tool.external_lock_dir name in
  Dune_engine.Fs_memo.dir_exists (Path.Outside_build_dir.External lock_dir)
  >>= function
  | true ->
    Console.print [ Pp.textf "Tool %S is already locked." (Package_name.to_string name) ];
    Memo.return ()
  | false -> solve name
;;
