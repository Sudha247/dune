open Import

let external_lock_dirs_basename = ".tools.lock"

let external_lock_dirs_root () =
  let external_root =
    Path.Build.root |> Path.build |> Path.to_absolute_filename |> Path.External.of_string
  in
  Path.External.relative external_root external_lock_dirs_basename
;;

let external_lock_dir name =
  Path.External.relative (external_lock_dirs_root ()) (Package_name.to_string name)
;;

let lock_dir_path_to_source_dir_opt path =
  match Path.Expert.try_localize_external (Path.external_ path) with
  | External _ | In_source_tree _ -> None
  | In_build_dir b ->
    (match Path.Build.explode b |> Filename.L.to_string with
     | prefix :: components when String.equal prefix external_lock_dirs_basename ->
       let build_as_source = Path.build_dir |> Path.to_string |> Path.Source.of_string in
       Some (Path.Source.L.relative build_as_source (prefix :: components))
     | _ -> None)
;;
