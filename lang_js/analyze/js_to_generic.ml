(* Yoann Padioleau
 *
 * Copyright (C) 2019 r2c
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common

open Ast_js
module G = AST_generic

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Ast_js to AST_generic.
 *
 * See ast_generic.ml for more information.
 *)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)
let id = fun x -> x
let option = Common.map_opt
let list = List.map
let vref f x = ref (f !x)

let bool = id
let string = id

let error = AST_generic.error


(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)

let info x = x

let wrap = fun _of_a (v1, v2) ->
  let v1 = _of_a v1 and v2 = info v2 in 
  (v1, v2)

let bracket of_a (t1, x, t2) = (info t1, of_a x, info t2)

let name v = wrap id v
let ident x = name x

let filename v = wrap string v

let label v = wrap string v

(* note: we do not care anymore about the language-specific tagger.
 * we use instead the generic naming_ast.ml *)
let resolved_name _x = 
(* old:
  let _qualified_name x = [x, fake "TODO qualified name"] in
  match x with
  | Local -> Some (G.Local, G.sid_TODO)
  | Param -> Some (G.Param, G.sid_TODO)
  | Global x -> Some (G.ImportedEntity (qualified_name x), G.sid_TODO)
  | NotResolved -> None
*)
  None

type special_result = 
  | SR_Special of G.special wrap
  | SR_Other of G.other_expr_operator wrap
  | SR_Literal of G.literal
  | SR_NeedArgs of (G.expr list -> G.expr)

let special (x, tok) = 
  match x with
  | UseStrict -> SR_Other (G.OE_UseStrict, tok)
  | Null -> SR_Literal (G.Null tok) 
  | Undefined -> SR_Literal (G.Undefined tok)
  | This -> SR_Special (G.This, tok)
  | Super -> SR_Special (G.Super, tok)
  | Require -> SR_Other (G.OE_Require, tok) (* TODO: left up to include? *)
  | Exports -> SR_Other (G.OE_Exports, tok)
  | Module -> SR_Other (G.OE_Module, tok)
  | Define -> SR_Other (G.OE_Define, tok)
  | Arguments -> SR_Other (G.OE_Arguments, tok)
  | New -> SR_Special (G.New, tok)
  | NewTarget -> SR_Other (G.OE_NewTarget, tok)
  | Eval -> SR_Special (G.Eval, tok)
  | Seq -> SR_NeedArgs (fun args -> G.Seq args)
  | Typeof -> SR_Special (G.Typeof, tok)
  | Instanceof -> SR_Special (G.Instanceof, tok)
  | In -> SR_Other (G.OE_In, tok)
  | Delete -> SR_Other (G.OE_Delete, tok)
  (* a kind of cast operator: 
   * See https://stackoverflow.com/questions/7452341/what-does-void-0-mean
   *)
  | Void -> SR_NeedArgs (fun args -> 
          match args with
          | [e] -> 
              let tvoid = G.TyBuiltin ("void", tok) in
              G.Cast(tvoid, e)
          | _ -> error tok "Impossible: Too many arguments to Void"
          ) 
  | Spread -> SR_Special (G.Spread, tok)
  | Yield -> SR_NeedArgs (fun args -> 
          match args with
          | [e] -> G.Yield (tok, Some e, false)
          | _ -> error tok "Impossible: Too many arguments to Yield"
          )
  | YieldStar -> SR_Other (G.OE_YieldStar, tok)
  | Await -> SR_NeedArgs (fun args ->
          match args with
          | [e] -> G.Await (tok, e)
          | _ -> error tok "Impossible: Too many arguments to Await"
          )
  | Encaps has_tag_function -> 
      if not has_tag_function 
      then SR_NeedArgs (fun args -> 
            G.Call (G.IdSpecial (G.ConcatString G.InterpolatedConcat, tok), 
                    args |> List.map (fun e -> G.Arg e) |> G.fake_bracket))
      else SR_NeedArgs (fun args ->
         match args with
         | [] -> raise Impossible
         | tag::rest ->
            G.Call (tag, G.fake_bracket
             [G.Arg (G.Call (
                      G.IdSpecial (G.ConcatString G.InterpolatedConcat, tok), 
                        rest |> List.map (fun e -> G.Arg e) |> G.fake_bracket))]))
  | ArithOp op -> SR_Special (G.Op op, tok)
  | IncrDecr v -> SR_Special (G.IncrDecr v, tok)

(*
   This is used to expose an individual statement as a block of one statement,
   where a sequence of statements is allowed. This simplifies the task
   of the sgrep pattern matcher.
   TODO: check all the places where this wrapping is necessary.
   TODO: see if this is an issue with other languages besides javascript.
*)
let as_block stmt =
  match stmt with
  | G.Block _ as block -> block
  | other -> G.Block (G.fake_bracket [other])

let rec property_name =
  function
  | PN v1 -> let v1 = name v1 in Left v1
  | PN_Computed v1 -> let v1 = expr v1 in Right v1

and xhp =
  function
  | XmlText v1 -> let v1 = string v1 in G.XmlText v1
  | XmlExpr v1 -> let v1 = expr v1 in G.XmlExpr v1
  | XmlXml v1 -> let v1 = xml v1 in G.XmlXml v1

and xml_attribute = function
  | XmlAttr (v1, v2) -> 
      let v1 = ident v1 and v2 = xhp_attr v2 in G.XmlAttr (v1, v2)
  | XmlAttrExpr v ->
      let v = bracket expr v in
      G.XmlAttrExpr v

and xml { xml_tag = xml_tag; xml_attrs = xml_attrs; xml_body = xml_body } =
  let tag = ident xml_tag in
  let attrs =list xml_attribute xml_attrs in
  let body = list xhp xml_body in 
  { G.xml_tag = tag; xml_attrs = attrs; xml_body = body }

and xhp_attr v          = expr v

and expr (x: expr) =
  match x with
  | Bool v1 -> let v1 = wrap bool v1 in G.L (G.Bool v1)
  | Num v1 -> let v1 = wrap string v1 in G.L (G.Float v1)
  | String v1 -> let v1 = wrap string v1 in G.L (G.String v1)
  | Regexp v1 -> let v1 = wrap string v1 in G.L (G.Regexp v1)
  | Id (v1, refresolved) -> 
      let v1 = name v1 in
      let v3 = { (G.empty_id_info ()) with
                 G.id_resolved = vref resolved_name refresolved } in
      G.Id (v1, v3)

  | IdSpecial (v1) -> 
      let x = special v1 in
      (match x with
      | SR_Special v -> G.IdSpecial v
      | SR_NeedArgs _ -> 
          error (snd v1) "Impossible: should have been matched in Call first"
      | SR_Literal l -> G.L l
      | SR_Other (x, tok) -> G.OtherExpr (x, [G.Tk tok])
      )
  | Assign ((v1, tok, v2)) -> let v1 = expr v1 and v2 = expr v2 in 
      let tok = info tok in
      G.Assign (v1, tok, v2)
  | ArrAccess ((v1, v2)) -> let v1 = expr v1 and v2 = expr v2 in 
      G.ArrayAccess (v1, v2)
  | Obj v1 -> let flds = obj_ v1 in G.Record flds
  | Ellipsis v1 -> let v1 = info v1 in G.Ellipsis v1
  | DeepEllipsis v1 -> let v1 = bracket expr v1 in G.DeepEllipsis v1
  | Class (v1, _v2TODO) -> 
      let def, _more_attrsTODOEMPTY  = class_ v1 in
      G.AnonClass def
  | ObjAccess ((v1, t, v2)) ->
      let v1 = expr v1 in
      let v2 = property_name v2 in
      let t = info t in
      (match v2 with
      | Left n -> G.DotAccess (v1, t, G.FId n)
      | Right e -> G.DotAccess (v1, t, G.FDynamic e)
      )
  | Fun ((v1, _v2TODO)) -> 
      let def, _more_attrs   = fun_ v1 in
      (* todo? assert more_attrs = []? *)
      G.Lambda (def)

  | Apply ((IdSpecial v1, v2)) ->
      let x = special v1 in
      let v2 = bracket (list expr) v2 in 
      (match x with
      | SR_Special v -> 
        G.Call (G.IdSpecial (v), bracket (List.map (fun e -> G.Arg e)) v2)
      | SR_Literal _ ->
        error (snd v1) "Weird: literal in call position"
      | SR_Other (x, tok) -> (* ex: NewTarget *)
        G.Call (G.OtherExpr (x, [G.Tk tok]), 
              bracket (List.map (fun e -> G.Arg e)) v2)
      | SR_NeedArgs f ->
        f (G.unbracket v2)
      )
  | Apply ((v1, v2)) -> let v1 = expr v1 and v2 = bracket (list expr) v2 in 
      G.Call (v1, bracket (List.map (fun e -> G.Arg e)) v2)
  | Arr ((v1)) -> let v1 = bracket (list expr) v1 in G.Container (G.Array, v1)
  | Conditional ((v1, v2, v3)) ->
      let v1 = expr v1 and v2 = expr v2 and v3 = expr v3 in
      G.Conditional (v1, v2, v3)
  | Xml v1 -> let v1 = xml v1 in G.Xml v1

and stmt x =
  match x with
  | M v1 -> let v1 = module_directive v1 in G.DirectiveStmt v1
  | VarDecl v1 -> let v1 = def_of_var v1 in G.DefStmt (v1)
  | Block v1 -> let v1 = bracket (list stmt) v1 in G.Block v1
  | ExprStmt (v1, t) -> let v1 = expr v1 in G.ExprStmt (v1, t)
  | If ((t, v1, v2, v3)) ->
      let v1 = expr v1 and v2 = stmt v2 and v3 = option stmt v3 in 
      G.If (t, v1, v2, v3)
  | Do ((t, v1, v2)) -> let v1 = stmt v1 and v2 = expr v2 in 
      G.DoWhile (t, v1, v2)
  | While ((t, v1, v2)) -> let v1 = expr v1 and v2 = stmt v2 in
      G.While (t, v1, v2)
  | For ((t, v1, v2)) -> let v1 = for_header v1 and v2 = stmt v2 in
      G.For (t, v1, v2)
  | Switch ((v0, v1, v2)) -> 
      let v0 = info v0 in
      let v1 = expr v1 and v2 = list case v2 in
      G.Switch (v0, Some v1, v2)
  | Continue (t, v1) -> let v1 = option label v1 in 
     G.Continue (t, G.opt_to_label_ident v1)
  | Break (t, v1) -> let v1 = option label v1 in
     G.Break (t, G.opt_to_label_ident v1)
  | Return (t, v1) -> 
      let v1 = option expr v1 in 
      G.Return (t, v1)
  | Label ((v1, v2)) -> let v1 = label v1 and v2 = stmt v2 in
      G.Label (v1, v2)
  | Throw (t, v1) -> let v1 = expr v1 in G.Throw (t, v1)
  | Try ((t, v1, v2, v3)) ->
      let v1 = stmt v1
      and v2 = option catch_block v2
      and v3 = option tok_and_stmt v3 in
      G.Try (t, v1, Common.opt_to_list v2, v3)
  | With (_v1, v2, v3) ->
      let e = expr v2 in
      let v3 = stmt v3 in
      G.OtherStmtWithStmt (G.OSWS_With, Some e, v3)

and catch_block = function
  | BoundCatch (t, v1, v2) ->
      let v1 = G.expr_to_pattern (expr v1)
      and v2 = stmt v2
      in t, v1, v2
  | UnboundCatch (t, v1) ->
      let v1 = stmt v1
      (* bugfix: reusing 't' to avoid NoTokenLocation error when
       * a semgrep patter like catch($ERR) matches an UnboundCatch. *)
      in t, G.PatUnderscore (t), v1

and tok_and_stmt (t, v) = 
  let v = stmt v in
  (t, v)

and for_header =
  function
  | ForClassic ((v1, v2, v3)) ->
      let v2 = option expr v2 in
      let v3 = option expr v3 in
      (match v1 with
      | Left vars ->
            let vars = vars |> List.map (fun x -> 
                  let (a,b) = var_of_var x in
                  G.ForInitVar (a, b)
            )
            in
            G.ForClassic (vars, v2, v3)
      | Right e ->
         let e = expr e in
         G.ForClassic ([G.ForInitExpr e], v2, v3)
      )
      
  | ForIn ((v1, t, v2)) ->
      let v2 = expr v2 in
      let pattern = 
        match v1 with
        | Left {v_name = id; v_init = _NONE; v_resolved = _; v_kind = _ } -> 
            G.PatId (id, G.empty_id_info())
        | Right e ->
            let e = expr e in
            G.expr_to_pattern e
      in
      G.ForEach (pattern, t, v2)
  | ForOf ((v1, t, v2)) ->
      let v2 = expr v2 in
      let pattern = 
        match v1 with
        | Left {v_name = id; v_init = _NONE; v_resolved = _; v_kind = _ } -> 
            G.PatId (id, G.empty_id_info())
        | Right e ->
            let e = expr e in
            G.expr_to_pattern e
      in
      let e = G.Call (G.IdSpecial (G.ForOf, t), G.fake_bracket [G.Arg v2]) in
      G.ForEach (pattern, t, e)
  | ForEllipsis v1 ->
      G.ForEllipsis v1

and case =
  function
  | Case ((t, v1, v2)) -> let v1 = expr v1 and v2 = stmt v2 in
      [G.Case (t, G.expr_to_pattern v1)], v2
  | Default (t, v1) -> let v1 = stmt v1 in
      [G.Default t], v1

and def_of_var { v_name = x_name; v_kind = x_kind; 
                 v_init = x_init; v_resolved = x_resolved } =
  let v1 = name x_name in
  let v2 = var_kind x_kind in 
  let ent = G.basic_entity v1 [v2] in
  (match x_init with
  | Some (Fun (v3, _nTODO))   -> 
      let def, more_attrs = fun_ v3 in
      { ent with G.attrs = ent.G.attrs @ more_attrs}, G.FuncDef def
  | Some (Class (v3, _nTODO)) -> 
      let def, more_attrs = class_ v3 in
      { ent with G.attrs = ent.G.attrs @ more_attrs}, G.ClassDef def
  | _ -> 
       let v3 = option expr x_init in 
       let v4 = vref resolved_name x_resolved in
       ent.G.info.G.id_resolved := !v4;
       ent, G.VarDef { G.vinit = v3; G.vtype = None }
   )

and var_of_var { v_name = x_name; v_kind = x_kind; 
                 v_init = x_init; v_resolved = x_resolved } =
  let v1 = name x_name in
  let v2 = var_kind x_kind in 
  let ent = G.basic_entity v1 [v2] in
  let v3 = option expr x_init in 
  let v4 = vref resolved_name x_resolved in
  ent.G.info.G.id_resolved := !v4;
  ent, { G.vinit = v3; G.vtype = None }


and var_kind (x, tok) =
  match x with
  | Var -> G.attr G.Var tok
  | Let -> G.attr G.Let tok
  | Const -> G.attr G.Const tok

and fun_ { f_props = f_props; f_params = f_params; f_body = f_body } =
  let v1 = list fun_prop f_props in
  let v2 = list parameter_binding f_params in 
  let v3 = stmt f_body |> as_block in
  { G.fparams = v2; frettype = None; fbody = v3; }, v1

and parameter_binding = function
 | ParamClassic x -> G.ParamClassic (parameter x)
 | ParamPattern x -> G.ParamPattern (pattern x)
 | ParamEllipsis x -> G.ParamEllipsis x

and pattern x = 
  let x = expr x in
  G.expr_to_pattern x

and parameter x =
 match x with
 { p_name = p_name; p_default = p_default; p_dots = p_dots } ->
  let v1 = name p_name in
  let v2 = option expr p_default in 
  let v3 = bool p_dots in
   { 
    G.pname = Some v1; pdefault = v2; ptype = None;
    pattrs = (match v3 with None -> [] | Some tok -> [G.attr G.Variadic tok]);
    pinfo = G.empty_id_info ();
  }
  

and fun_prop (x, tok) =
  match x with
  | Get -> G.attr G.Getter tok
  | Set -> G.attr G.Setter tok
  | Generator -> G.attr G.Generator tok 
  | Async -> G.attr G.Async tok

and obj_ v = bracket (list property) v

and class_ { c_extends = c_extends; c_body = c_body; c_tok } =
  let v1 = option expr c_extends in
  let v2 = bracket (list property) c_body in
  (* todo: could analyze arg to look for Id *)
  let extends = 
    match v1 with
    | None -> [] 
    | Some e -> [G.OtherType (G.OT_Expr, [G.E e])]
  in
  { G.ckind = (G.Class, c_tok); cextends = extends; 
    cimplements = []; cmixins = []; cbody = v2;}, []
and property x =
   match x with
  | Field ((v1, v2, v3)) ->
      let v1 = property_name v1
      and v2 = list property_prop v2
      and v3 = option expr v3
      in 
      (match v1 with
      | Left n ->
        let ent = G.basic_entity n v2 in
       (* todo: could be a Lambda in which case we should return a FuncDef? *)
        G.FieldStmt (G.DefStmt 
                ((ent, G.FieldDef { G.vinit = v3; vtype = None })))

      | Right e -> 
        (match v3 with
         | None -> raise Impossible
         | Some x -> G.FieldDynamic (e, v2, x)
        )
      )
  | FieldSpread (t, v1) -> 
      let v1 = expr v1 in 
      G.FieldSpread (t, v1)
  | FieldEllipsis v1 -> 
      G.FieldStmt (G.exprstmt (G.Ellipsis v1))
  | FieldPatDefault (v1, _v2, v3) ->
      let v1 = pattern v1 in
      let v3 = expr v3 in
      G.FieldStmt (G.exprstmt (G.LetPattern (v1, v3)))
and property_prop (x, tok) =
  match x with
  | Static -> G.attr G.Static tok
  | Public -> G.attr G.Public tok
  | Private -> G.attr G.Private tok
  | Protected -> G.attr G.Protected tok
  

and toplevel x = stmt x

and module_directive x = 
  match x with
  | ReExportNamespace (v1, _v2, _v3, v4) ->
      let v4 = filename v4 in
      G.OtherDirective (G.OI_ReExportNamespace, [G.Tk v1; G.I v4])
  | Import ((t, v1, v2, v3)) ->
      let v1 = name v1 and v2 = option name v2 and v3 = filename v3 in 
      G.ImportFrom (t, G.FileName v3, v1, v2)
  | ModuleAlias ((t, v1, v2)) ->
      let v1 = name v1 and v2 = filename v2 in
      G.ImportAs (t, G.FileName v2, Some v1)
  | ImportCss ((_t, v1)) ->
      let v1 = name v1 in
      G.OtherDirective (G.OI_ImportCss, [G.I v1])
  (* sgrep: we used to convert this in an OI_ImportEffect, but
   * we now want import "foo" to be used to match any form of import
   *)
  | ImportEffect ((t, v1)) ->
      let v1 = name v1 in
      (* old: G.OtherDirective (G.OI_ImportEffect, [G.I v1]) *)
      G.ImportAs (t, G.FileName v1, None)
  | Export ((t, v1)) -> let v1 = name v1 in
      G.OtherDirective (G.OI_Export, [G.Tk t; G.I v1])

and program v = list toplevel v

let any =
  function
  | Expr v1 -> let v1 = expr v1 in G.E v1
  | Stmt v1 -> let v1 = stmt v1 in G.S v1
  | Item v1 -> let v1 = toplevel v1 in G.S v1
  | Items v1 -> let v1 = List.map toplevel v1 in G.Ss v1
  | Program v1 -> let v1 = program v1 in G.Pr v1
  | Pattern v1 -> let v1 = pattern v1 in G.P v1
