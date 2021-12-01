(**************************************************************************)
(*                                                                        *)
(*    Copyright 2021 Tweag                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamParserTypes
open Cmdliner
open Yojson

let fatal_exn = function
  | Sys.Break as e -> raise e
  | _ -> ()

let arg_files =
  let doc =
    "File to process. If unspecified, stdin is used. Can be repeated."
  in
  Arg.(value & pos_all file [] & info ~docv:"FILE" ~doc [])

let string_of_channel ic =
  let b = Buffer.create 4096 in
  try while true do Buffer.add_channel b ic 4096 done; assert false
  with End_of_file -> Buffer.contents b

let render_relop = function
  | `Eq -> "eq"
  | `Neq -> "neq"
  | `Geq -> "geq"
  | `Gt -> "gt"
  | `Leq -> "leq"
  | `Lt -> "lt"

let render_logop = function
  | `And -> "and"
  | `Or -> "or"

let render_pfxop = function
  | `Not -> "not"
  | `Defined -> "defined"

let render_env_update_op = function
  | Eq -> "set"
  | PlusEq -> "prepend"
  | EqPlus -> "append"
  | ColonEq -> "prepend_trailing"
  | EqColon -> "append_trailing"
  | EqPlusEq -> "prepend_or_replace"

let rec opam_value_to_json : (OpamParserTypes.value -> Yojson.Basic.t) = function
  | Bool (_, b) -> `Bool b
  | Int (_, i) -> `Int i
  | String (_, s) -> `String s
  | Relop (_ , op, v1, v2) -> `Assoc [("op", `String (render_relop op)); ("val", list_to_json [v1; v2])]
  | Prefix_relop (_, op, v) -> `Assoc [("op", `String (render_relop op)); ("val", list_to_json [v])]
  | Logop (_, op, v1, v2) -> `Assoc [("op", `String (render_logop op)); ("val", list_to_json [v1; v2])]
  | Pfxop (_, op, v) -> `Assoc [("op", `String (render_pfxop op)); ("val", list_to_json [v])]
  | Ident (_, i) -> `Assoc [("id", `String i)]
  | List (_, l) -> list_to_json l
  | Group (_, g) -> list_to_json g
  | Option (_, v, l) -> `Assoc [("val", opam_value_to_json v); ("options", list_to_json l)]
  | Env_binding (_, v1, op, v2) -> `Assoc [("op", `String (render_env_update_op op)); ("val", list_to_json [v1; v2])]
and list_to_json l = `List (List.map opam_value_to_json l)

let rec section_to_json = function
  | { section_kind; section_name; section_items } ->
     (section_kind, `Assoc (List.map file_item_to_json_tuple section_items))
and file_item_to_json_tuple : (OpamParserTypes.opamfile_item -> string * Yojson.Basic.t) = function
  | Section (_, s) -> section_to_json s
  | Variable (_, name, v) -> (name, opam_value_to_json v)

let file_to_json = function
  | { file_contents; file_name } -> `Assoc (List.map file_item_to_json_tuple file_contents)

let print_file f = print_string (Yojson.Basic.pretty_to_string (file_to_json f))

let run files =
  if files = [] then
    try
      let txt = try string_of_channel stdin with Sys_error _ -> "" in
      let orig = OpamParser.string txt "/dev/stdin" in
      print_file orig
    with e ->
      fatal_exn e;
      Printf.eprintf "Error on input from stdin: %s\n"
        (Printexc.to_string e);
      exit 10
  else
  let ok =
    List.fold_left (fun ok file ->
        try
          let ic = open_in file in
          let txt = try string_of_channel ic with Sys_error _ -> "" in
          print_file (OpamParser.string txt file);
          ok
        with e ->
          fatal_exn e;
          Printf.eprintf "Error on file %s: %s\n" file (Printexc.to_string e);
          false
      ) true files
  in
  if not ok then exit 10

let cmd =
  Term.(pure run $ arg_files)

let man = []

let main_cmd_info =
  Term.info "opam2json" ~version:"0.1"
    ~doc:"A command-line utility to turn opam file format to json"
    ~man

let () =
  let r = Term.eval (cmd, main_cmd_info) in
  Term.exit r
