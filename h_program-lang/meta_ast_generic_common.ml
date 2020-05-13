(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_vof.cmo  pr_o.cmo /tmp/xxx.ml  *)

open Ast_generic


let vof_arithmetic_operator =
  function
  | Concat -> Ocaml.VSum (("Concat", []))
  | Plus -> Ocaml.VSum (("Plus", []))
  | Minus -> Ocaml.VSum (("Minus", []))
  | Mult -> Ocaml.VSum (("Mult", []))
  | Div -> Ocaml.VSum (("Div", []))
  | Mod -> Ocaml.VSum (("Mod", []))
  | Pow -> Ocaml.VSum (("Pow", []))
  | FloorDiv -> Ocaml.VSum (("FloorDiv", []))
  | MatMult -> Ocaml.VSum (("MatMult", []))
  | LSL -> Ocaml.VSum (("LSL", []))
  | LSR -> Ocaml.VSum (("LSR", []))
  | ASR -> Ocaml.VSum (("ASR", []))
  | BitOr -> Ocaml.VSum (("BitOr", []))
  | BitXor -> Ocaml.VSum (("BitXor", []))
  | BitAnd -> Ocaml.VSum (("BitAnd", []))
  | BitNot -> Ocaml.VSum (("BitNot", []))
  | BitClear -> Ocaml.VSum (("BitClear", []))
  | And -> Ocaml.VSum (("And", []))
  | Or -> Ocaml.VSum (("Or", []))
  | Xor -> Ocaml.VSum (("Xor", []))
  | Not -> Ocaml.VSum (("Not", []))
  | Eq -> Ocaml.VSum (("Eq", []))
  | NotEq -> Ocaml.VSum (("NotEq", []))
  | PhysEq -> Ocaml.VSum (("PhysEq", []))
  | NotPhysEq -> Ocaml.VSum (("NotPhysEq", []))
  | Lt -> Ocaml.VSum (("Lt", []))
  | LtE -> Ocaml.VSum (("LtE", []))
  | Gt -> Ocaml.VSum (("Gt", []))
  | GtE -> Ocaml.VSum (("GtE", []))
  | Cmp -> Ocaml.VSum (("Cmp", []))

let vof_incr_decr =
  function
  | Incr -> Ocaml.VSum (("Incr", []))
  | Decr -> Ocaml.VSum (("Decr", []))

let vof_prepost =
  function
  | Prefix -> Ocaml.VSum (("Prefix", []))
  | Postfix -> Ocaml.VSum (("Postfix", []))

let vof_inc_dec (v1, v2) =
      let v1 = vof_incr_decr v1
      and v2 = vof_prepost v2
      in Ocaml.VTuple [ v1; v2 ]

