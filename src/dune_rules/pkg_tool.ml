open Import
open Memo.O
module Tool = Dune_pkg.Tool

let install_path_base_dir_name = Filename.tools_dir_basename

let private_default_dir base_dir_name =
  Path.Build.L.relative
    Private_context.t.build_dir
    [ Context_name.to_string Context_name.default; Filename.to_string base_dir_name ]
;;

let install_path_base = lazy (private_default_dir Filename.tools_dir_basename)
let lock_dir_base = lazy (private_default_dir Filename.tool_locks_dir_basename)

let universe_install_path name =
  Path.Build.relative (Lazy.force install_path_base) (Package.Name.to_string name)
;;

(* The dependencies of a tool live next to the tool universes rather
   than inside them: expanding a tool's build command requires its
   dependencies to be built, so rules for the dependencies cannot live
   below the tool's own directory. The leading dot avoids clashing with
   tool package names. *)
let deps_install_path_base name =
  Path.Build.L.relative
    (Lazy.force install_path_base)
    [ ".deps"; Package.Name.to_string name ]
;;

let exe_path name =
  Path.Build.L.relative
    (universe_install_path name)
    ("target" :: Tool.exe_path_components_within_package name)
;;

let build_lock_dir name =
  Path.Build.relative (Lazy.force lock_dir_base) (Package.Name.to_string name)
;;

let is_locked name =
  Fs_memo.dir_exists (Path.Outside_build_dir.External (Tool.external_lock_dir name))
;;

let raise_not_locked name =
  let name = Package.Name.to_string name in
  User_error.raise
    [ Pp.textf "Tool %S is not locked." name ]
    ~hints:
      [ Pp.concat
          ~sep:Pp.space
          [ Pp.text "Run"; User_message.command (sprintf "dune tools add %s" name) ]
      ]
;;

let check_locked name =
  let+ locked = is_locked name in
  if not locked then raise_not_locked name
;;

let lock_dir name =
  let* () = check_locked name in
  (* Ensure the internal lock dir is built so copy rules run *)
  let* () = Build_system.build_dir (Path.build (build_lock_dir name)) in
  Lock_dir.load_exn (Path.external_ (Tool.external_lock_dir name))
;;

let check_declared name =
  let+ workspace = Workspace.workspace () in
  let declared =
    List.exists workspace.tools ~f:(fun (tool : Workspace.Tool.t) ->
      Package.Name.equal tool.name name)
  in
  if not declared
  then (
    let name = Package.Name.to_string name in
    User_error.raise
      [ Pp.textf "Tool %S is not declared in the workspace." name ]
      ~hints:[ Pp.textf "Add (tool (name %s)) to your dune-workspace file." name ])
;;
