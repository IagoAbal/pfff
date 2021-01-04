(* Iago Abal
 *
 * Copyright (C) 2020 r2c
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
open IL

module G = AST_generic
module F = IL
module D = Dataflow
module VarMap = Dataflow.VarMap

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(* map for each node/var whether a variable is constant *)
type mapping = G.constness Dataflow.mapping

module DataflowX = Dataflow.Make (struct
    type node = F.node
    type edge = F.edge
    type flow = (node, edge) Ograph_extended.ograph_mutable
    let short_string_of_node n =
      Display_IL.short_string_of_node_kind n.F.n
  end)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

let string_of_ctype = function
  | G.Cbool -> "bool"
  | G.Cint  -> "int"
  | G.Cstr  -> "str"
  | G.Cany  -> "???"

let string_of_constness = function
  | G.NotCst -> "dyn"
  | G.Cst t  -> Printf.sprintf "cst(%s)" (string_of_ctype t)
  | G.Lit l  ->
      match l with
      | G.Bool (b, _)   -> Printf.sprintf "lit(%b)" b
      | G.Int (s, _)    -> Printf.sprintf "lit(%s)" s
      | G.String (s, _) -> Printf.sprintf "lit(\"%s\")" s
      | ___else___      -> "lit(???)"

let str_of_name ((s, _tok), sid) =
  spf "%s:%d" s sid

(*****************************************************************************)
(* Constness *)
(*****************************************************************************)

(* TODO: Use Lib_AST.abstract_position_info_any (G.E (G.Literal l1)) and =*=. *)
let eq_literal l1 l2 =
  match l1, l2 with
  | G.Bool  (b1, _),  G.Bool  (b2, _)  -> b1 =:= b2
  | G.Int   (s1, _),  G.Int   (s2, _)
  | G.Float (s1, _),  G.Float (s2, _)
  | G.Char  (s1, _),  G.Char   (s2, _)
  | G.String (s1, _), G.String (s2, _) -> s1 =$= s2
  (* add more cases if needed *)
  | ___else___ -> false

let eq_ctype t1 t2 = t1 = t2

let ctype_of_literal = function
  | G.Bool _   -> G.Cbool
  | G.Int _    -> G.Cint
  | G.String _ -> G.Cstr
  | ___else___ -> G.Cany

let eq c1 c2 =
  match c1, c2 with
  | G.Lit l1, G.Lit l2 -> eq_literal l1 l2
  | G.Cst t1, G.Cst t2 -> eq_ctype t1 t2
  | G.NotCst, G.NotCst -> true
  | ___else___         -> false

let union_ctype t1 t2 = if eq_ctype t1 t2 then t1 else G.Cany

let union c1 c2 =
  match c1, c2 with
  | _ when eq c1 c2     -> c1
  | _any,     G.NotCst
  | G.NotCst,    _any   -> G.NotCst
  | G.Lit l1, G.Lit l2  ->
      let t1 = ctype_of_literal l1
      and t2 = ctype_of_literal l2 in
      G.Cst (union_ctype t1 t2)
  | G.Lit l1, G.Cst t2
  | G.Cst t2, G.Lit l1 ->
      let t1 = ctype_of_literal l1 in
      G.Cst (union_ctype t1 t2)
  | G.Cst t1, G.Cst t2 ->
      G.Cst (union_ctype t1 t2)

(* THINK: This assumes that analyses are sound... but they are not
   (e.g. due to aliasing). *)
let refine c1 c2 =
  match c1, c2 with
  | _ when eq c1 c2    -> c1
  | c,        G.NotCst
  | G.NotCst, c        -> c
  | G.Lit _,  _
  | G.Cst _,  G.Cst _  -> c1
  | G.Cst _,  G.Lit _  -> c2

let refine_constness_ref c_ref c' =
  match !c_ref with
  | None   -> c_ref := Some c'
  | Some c -> c_ref := Some (refine c c')

(*****************************************************************************)
(* Constness evaluation *)
(*****************************************************************************)

let literal_of_bool b =
  let b_str = string_of_bool b in
  (* TODO: use proper token when possible? *)
  let tok   = Parse_info.fake_info b_str in
  G.Bool(b, tok)

let literal_of_int i =
  let i_str = string_of_int i in
  (* TODO: use proper token when possible? *)
  let tok   = Parse_info.fake_info i_str in
  G.Int(i_str, tok)

let int_of_literal = function
  | G.Int (str, _) -> int_of_string_opt str
  | ___else___     -> None

let literal_of_string s =
  (* TODO: use proper token when possible? *)
  let tok = Parse_info.fake_info s in
  G.String(s, tok)

let eval_unop_bool op b =
  match op with
  | G.Not -> G.Lit (literal_of_bool (not b))
  | _else -> G.Cst G.Cbool

let eval_binop_bool op b1 b2 =
  match op with
  | G.Or  -> G.Lit (literal_of_bool (b1 || b2))
  | G.And -> G.Lit (literal_of_bool (b1 && b2))
  | _else -> G.Cst G.Cbool

let eval_unop_int op opt_i =
  match op, opt_i with
  | G.Plus,  Some i -> G.Lit (literal_of_int i)
  | G.Minus, Some i -> G.Lit (literal_of_int (-i))
  | ___else____     -> G.Cst G.Cint

let eval_binop_int op opt_i1 opt_i2 =
  match op, opt_i1, opt_i2 with
  (* TODO: Handle overflows and division by zero. *)
  | G.Plus,  Some i1, Some i2 -> G.Lit (literal_of_int (i1 + i2))
  | G.Minus, Some i1, Some i2 -> G.Lit (literal_of_int (i1 - i2))
  | G.Mult,  Some i1, Some i2 -> G.Lit (literal_of_int (i1 * i2))
  | G.Div,   Some i1, Some i2 -> G.Lit (literal_of_int (i1 / i2))
  | ___else____     -> G.Cst G.Cint

let eval_binop_string op s1 s2 =
  match op with
  | G.Plus
  | G.Concat -> G.Lit (literal_of_string (s1 ^ s2))
  | __else__ -> G.Cst G.Cstr

let rec eval (env :G.constness D.env) exp : G.constness =
  match exp.e with
  | Lvalue lval -> eval_lval env lval
  | Literal li -> G.Lit li
  | Operator (op, args) -> eval_op env op args
  | Composite _
  | Record _
  | Cast _
  | FixmeExp _
    -> G.NotCst

and eval_lval env lval =
  match lval with
  | { base=Var x; offset=NoOffset; constness; } ->
      let opt_c = D.VarMap.find_opt (str_of_name x) env in
      (match !constness, opt_c with
       | None, None       -> G.NotCst
       | Some c, None
       | None, Some c     -> c
       | Some c1, Some c2 -> refine c1 c2
      )
  | ___else___ ->
      G.NotCst

and eval_op env op args =
  let cs = List.map (eval env) args in
  match fst op, cs with
  | G.Plus, [c1]             -> c1
  | op,     [G.Lit (G.Bool (b, _))] -> eval_unop_bool op b
  | op,     [G.Lit (G.Int _ as li)] -> eval_unop_int op (int_of_literal li)
  | op,     [G.Lit (G.Bool (b1, _)); G.Lit (G.Bool (b2, _))] ->
      eval_binop_bool op b1 b2
  | op,     [G.Lit (G.Int _ as li1); G.Lit (G.Int _ as li2)] ->
      eval_binop_int op (int_of_literal li1) (int_of_literal li2)
  | op,     [G.Lit (G.String (s1, _)); G.Lit (G.String (s2, _))] ->
      eval_binop_string op s1 s2
  | _op,    [G.Cst _ as c1]    -> c1
  | _op,    [G.Cst t1; G.Cst t2] -> G.Cst (union_ctype t1 t2)
  | _op,    [G.Lit l1; G.Cst t2]
  | _op,    [G.Cst t2; G.Lit l1] ->
      let t1 = ctype_of_literal l1 in
      G.Cst (union_ctype t1 t2)
  | ___else___ -> G.NotCst

(*****************************************************************************)
(* Transfer *)
(*****************************************************************************)

let union_env =
  Dataflow.varmap_union union

let (transfer: flow:F.cfg -> G.constness Dataflow.transfn) =
  fun ~flow ->
  (* the transfer function to update the mapping at node index ni *)
  fun mapping ni ->

  let inp' = (* input mapping *)
    (flow#predecessors ni)#fold (fun acc (ni_pred, _) ->
      union_env acc mapping.(ni_pred).D.out_env
    ) VarMap.empty
  in

  let out' =
    let node = flow#nodes#assoc ni in
    match node.F.n with
    | Enter | Exit | TrueNode | FalseNode | Join
    | NCond _ | NGoto _ | NReturn _ | NThrow _ | NOther _
    | NTodo _
      -> inp'
    | NInstr instr ->
        match instr.i with
        (* TODO: Handle base=Mem _ and base=VarSpecial _ cases. *)
        | Assign ({base=Var var; offset=NoOffset; constness=_;}, exp) ->
            let cexp = eval inp' exp in
            D.VarMap.add (str_of_name var) cexp inp'
        | ___else___ -> (* assume non-constant *)
            let lvar_opt = IL.lvar_of_instr_opt instr in
            match lvar_opt with
            | None      -> inp'
            | Some lvar -> D.VarMap.add (str_of_name lvar) G.NotCst inp'
  in

  {D. in_env = inp'; out_env = out'}

(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)

let (fixpoint: F.cfg -> mapping) = fun flow ->
  DataflowX.fixpoint
    ~eq
    ~init:(DataflowX.new_node_array flow (Dataflow.empty_inout ()))
    ~trans:(transfer ~flow)
    (* constness is a forward analysis! *)
    ~forward:true
    ~flow

let update_constness (flow :F.cfg) mapping =

  flow#nodes#keys
  |> List.iter (fun ni ->

    let ni_info = mapping.(ni) in

    let node = flow#nodes#assoc ni in

    (* Update RHS constness according to the input env. *)
    rlvals_of_node node.n
    |> List.iter (function
      | {base = Var var; constness; _} ->
          (match D.VarMap.find_opt (str_of_name var) ni_info.D.in_env with
           | None   -> ()
           | Some c -> refine_constness_ref constness c
          )
      | ___else___ -> ()
    );

    (* Update LHS constness according to the output env. *)
    match lval_of_node_opt node.n with
    | None -> ()
    | Some {base=Var var; offset=NoOffset; constness;} ->
        (match D.VarMap.find_opt (str_of_name var) ni_info.D.out_env with
         | None   -> ()
         | Some c -> refine_constness_ref constness c)
    | Some _ -> () (* TODO: Handle base=Mem _ and base=VarSpecial _ cases. *)
  )
