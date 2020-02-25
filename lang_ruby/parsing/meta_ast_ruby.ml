(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_vof.cmo  pr_o.cmo /tmp/xxx.ml  *)

open Ast_ruby

let vof_tok v = Ocaml.VUnit
  (* Lexing.vof_position v *)

let vof_annotation _v =  Ocaml.VUnit
let vof_big_int _v = Ocaml.VUnit

let rec vof_expr =
  function
  | Literal ((v1, v2)) ->
      let v1 = vof_lit_kind v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Literal", [ v1; v2 ]))
  | Identifier ((v1, v2, v3)) ->
      let v1 = vof_id_kind v1
      and v2 = Ocaml.vof_string v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("Identifier", [ v1; v2; v3 ]))
  | Operator ((v1, v2)) ->
      let v1 = vof_binary_op v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Operator", [ v1; v2 ]))
  | UOperator ((v1, v2)) ->
      let v1 = vof_unary_op v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("UOperator", [ v1; v2 ]))
  | Hash ((v1, v2, v3)) ->
      let v1 = Ocaml.vof_bool v1
      and v2 = Ocaml.vof_list vof_expr v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("Hash", [ v1; v2; v3 ]))
  | Array ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Array", [ v1; v2 ]))
  | Tuple ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Tuple", [ v1; v2 ]))
  | Unary ((v1, v2, v3)) ->
      let v1 = vof_unary_op v1
      and v2 = vof_expr v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("Unary", [ v1; v2; v3 ]))
  | Binop ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = vof_binary_op v2
      and v3 = vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("Binop", [ v1; v2; v3; v4 ]))
  | Ternary ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = vof_expr v2
      and v3 = vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("Ternary", [ v1; v2; v3; v4 ]))
  | MethodCall ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_expr v2
      and v3 = Ocaml.vof_option vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("MethodCall", [ v1; v2; v3; v4 ]))
  | CodeBlock ((v1, v2, v3, v4)) ->
      let v1 = Ocaml.vof_bool v1
      and v2 = Ocaml.vof_option (Ocaml.vof_list vof_formal_param) v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("CodeBlock", [ v1; v2; v3; v4 ]))
  | Empty -> Ocaml.VSum (("Empty", []))
  | Block ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Block", [ v1; v2 ]))
  | If ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_expr v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("If", [ v1; v2; v3; v4 ]))
  | While ((v1, v2, v3, v4)) ->
      let v1 = Ocaml.vof_bool v1
      and v2 = vof_expr v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("While", [ v1; v2; v3; v4 ]))
  | Until ((v1, v2, v3, v4)) ->
      let v1 = Ocaml.vof_bool v1
      and v2 = vof_expr v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("Until", [ v1; v2; v3; v4 ]))
  | Unless ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_expr v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("Unless", [ v1; v2; v3; v4 ]))
  | For ((v1, v2, v3, v4)) ->
      let v1 = Ocaml.vof_list vof_formal_param v1
      and v2 = vof_expr v2
      and v3 = Ocaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("For", [ v1; v2; v3; v4 ]))
  | Return ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Return", [ v1; v2 ]))
  | Yield ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Yield", [ v1; v2 ]))
  | Case ((v1, v2)) ->
      let v1 = vof_case_block v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Case", [ v1; v2 ]))
  | ExnBlock ((v1, v2)) ->
      let v1 = vof_body_exn v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("ExnBlock", [ v1; v2 ]))
  | ClassDef ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_option vof_inheritance_kind v2
      and v3 = vof_body_exn v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("ClassDef", [ v1; v2; v3; v4 ]))
  | MethodDef ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_formal_param v2
      and v3 = vof_body_exn v3
      and v4 = vof_tok v4
      in Ocaml.VSum (("MethodDef", [ v1; v2; v3; v4 ]))
  | ModuleDef ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_body_exn v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("ModuleDef", [ v1; v2; v3 ]))
  | BeginBlock ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("BeginBlock", [ v1; v2 ]))
  | EndBlock ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("EndBlock", [ v1; v2 ]))
  | Alias ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_expr v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("Alias", [ v1; v2; v3 ]))
  | Undef ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("Undef", [ v1; v2 ]))
  | Annotate ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_annotation v2
      and v3 = vof_tok v3
      in Ocaml.VSum (("Annotate", [ v1; v2; v3 ]))
and vof_lit_kind =
  function
  | FixNum v1 ->
      let v1 = Ocaml.vof_int v1 in Ocaml.VSum (("FixNum", [ v1 ]))
  | BigNum v1 ->
      let v1 = vof_big_int v1 in Ocaml.VSum (("BigNum", [ v1 ]))
  | Float ((v1, v2)) ->
      let v1 = Ocaml.vof_string v1
      and v2 = Ocaml.vof_float v2
      in Ocaml.VSum (("Float", [ v1; v2 ]))
  | String v1 ->
      let v1 = vof_string_kind v1 in Ocaml.VSum (("String", [ v1 ]))
  | Atom v1 ->
      let v1 = vof_interp_string v1 in Ocaml.VSum (("Atom", [ v1 ]))
  | Regexp ((v1, v2)) ->
      let v1 = vof_interp_string v1
      and v2 = Ocaml.vof_string v2
      in Ocaml.VSum (("Regexp", [ v1; v2 ]))
  | Nil -> Ocaml.VSum (("Nil", []))
  | Self -> Ocaml.VSum (("Self", []))
  | True -> Ocaml.VSum (("True", []))
  | False -> Ocaml.VSum (("False", []))
and vof_string_kind =
  function
  | Single v1 ->
      let v1 = Ocaml.vof_string v1 in Ocaml.VSum (("Single", [ v1 ]))
  | Double v1 ->
      let v1 = vof_interp_string v1 in Ocaml.VSum (("Double", [ v1 ]))
  | Tick v1 ->
      let v1 = vof_interp_string v1 in Ocaml.VSum (("Tick", [ v1 ]))
and vof_interp_string v = Ocaml.vof_list vof_string_contents v
and vof_string_contents =
  function
  | StrChars v1 ->
      let v1 = Ocaml.vof_string v1 in Ocaml.VSum (("StrChars", [ v1 ]))
  | StrExpr v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("StrExpr", [ v1 ]))
and vof_id_kind =
  function
  | ID_Lowercase -> Ocaml.VSum (("ID_Lowercase", []))
  | ID_Instance -> Ocaml.VSum (("ID_Instance", []))
  | ID_Class -> Ocaml.VSum (("ID_Class", []))
  | ID_Global -> Ocaml.VSum (("ID_Global", []))
  | ID_Uppercase -> Ocaml.VSum (("ID_Uppercase", []))
  | ID_Builtin -> Ocaml.VSum (("ID_Builtin", []))
  | ID_Assign v1 ->
      let v1 = vof_id_kind v1 in Ocaml.VSum (("ID_Assign", [ v1 ]))
and vof_unary_op =
  function
  | Op_UMinus -> Ocaml.VSum (("Op_UMinus", []))
  | Op_UPlus -> Ocaml.VSum (("Op_UPlus", []))
  | Op_UBang -> Ocaml.VSum (("Op_UBang", []))
  | Op_UTilde -> Ocaml.VSum (("Op_UTilde", []))
  | Op_UNot -> Ocaml.VSum (("Op_UNot", []))
  | Op_UAmper -> Ocaml.VSum (("Op_UAmper", []))
  | Op_UStar -> Ocaml.VSum (("Op_UStar", []))
  | Op_UScope -> Ocaml.VSum (("Op_UScope", []))
and vof_binary_op =
  function
  | Op_ASSIGN -> Ocaml.VSum (("Op_ASSIGN", []))
  | Op_PLUS -> Ocaml.VSum (("Op_PLUS", []))
  | Op_MINUS -> Ocaml.VSum (("Op_MINUS", []))
  | Op_TIMES -> Ocaml.VSum (("Op_TIMES", []))
  | Op_REM -> Ocaml.VSum (("Op_REM", []))
  | Op_DIV -> Ocaml.VSum (("Op_DIV", []))
  | Op_CMP -> Ocaml.VSum (("Op_CMP", []))
  | Op_EQ -> Ocaml.VSum (("Op_EQ", []))
  | Op_EQQ -> Ocaml.VSum (("Op_EQQ", []))
  | Op_NEQ -> Ocaml.VSum (("Op_NEQ", []))
  | Op_GEQ -> Ocaml.VSum (("Op_GEQ", []))
  | Op_LEQ -> Ocaml.VSum (("Op_LEQ", []))
  | Op_LT -> Ocaml.VSum (("Op_LT", []))
  | Op_GT -> Ocaml.VSum (("Op_GT", []))
  | Op_AND -> Ocaml.VSum (("Op_AND", []))
  | Op_OR -> Ocaml.VSum (("Op_OR", []))
  | Op_BAND -> Ocaml.VSum (("Op_BAND", []))
  | Op_BOR -> Ocaml.VSum (("Op_BOR", []))
  | Op_MATCH -> Ocaml.VSum (("Op_MATCH", []))
  | Op_NMATCH -> Ocaml.VSum (("Op_NMATCH", []))
  | Op_XOR -> Ocaml.VSum (("Op_XOR", []))
  | Op_POW -> Ocaml.VSum (("Op_POW", []))
  | Op_kAND -> Ocaml.VSum (("Op_kAND", []))
  | Op_kOR -> Ocaml.VSum (("Op_kOR", []))
  | Op_ASSOC -> Ocaml.VSum (("Op_ASSOC", []))
  | Op_DOT -> Ocaml.VSum (("Op_DOT", []))
  | Op_SCOPE -> Ocaml.VSum (("Op_SCOPE", []))
  | Op_AREF -> Ocaml.VSum (("Op_AREF", []))
  | Op_ASET -> Ocaml.VSum (("Op_ASET", []))
  | Op_LSHIFT -> Ocaml.VSum (("Op_LSHIFT", []))
  | Op_RSHIFT -> Ocaml.VSum (("Op_RSHIFT", []))
  | Op_OP_ASGN v1 ->
      let v1 = vof_binary_op v1 in Ocaml.VSum (("Op_OP_ASGN", [ v1 ]))
  | Op_DOT2 -> Ocaml.VSum (("Op_DOT2", []))
  | Op_DOT3 -> Ocaml.VSum (("Op_DOT3", []))
and vof_formal_param =
  function
  | Formal_id v1 ->
      let v1 = vof_expr v1 in Ocaml.VSum (("Formal_id", [ v1 ]))
  | Formal_amp v1 ->
      let v1 = Ocaml.vof_string v1 in Ocaml.VSum (("Formal_amp", [ v1 ]))
  | Formal_star v1 ->
      let v1 = Ocaml.vof_string v1 in Ocaml.VSum (("Formal_star", [ v1 ]))
  | Formal_rest -> Ocaml.VSum (("Formal_rest", []))
  | Formal_tuple v1 ->
      let v1 = Ocaml.vof_list vof_formal_param v1
      in Ocaml.VSum (("Formal_tuple", [ v1 ]))
  | Formal_default ((v1, v2)) ->
      let v1 = Ocaml.vof_string v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("Formal_default", [ v1; v2 ]))
and vof_inheritance_kind =
  function
  | Class_Inherit v1 ->
      let v1 = vof_expr v1 in Ocaml.VSum (("Class_Inherit", [ v1 ]))
  | Inst_Inherit v1 ->
      let v1 = vof_expr v1 in Ocaml.VSum (("Inst_Inherit", [ v1 ]))
and
  vof_body_exn {
                 body_exprs = v_body_exprs;
                 rescue_exprs = v_rescue_exprs;
                 ensure_expr = v_ensure_expr;
                 else_expr = v_else_expr
               } =
  let bnds = [] in
  let arg = Ocaml.vof_list vof_expr v_else_expr in
  let bnd = ("else_expr", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_expr v_ensure_expr in
  let bnd = ("ensure_expr", arg) in
  let bnds = bnd :: bnds in
  let arg =
    Ocaml.vof_list
      (fun (v1, v2) ->
         let v1 = vof_expr v1 and v2 = vof_expr v2 in Ocaml.VTuple [ v1; v2 ])
      v_rescue_exprs in
  let bnd = ("rescue_exprs", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_expr v_body_exprs in
  let bnd = ("body_exprs", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and
  vof_case_block {
                   case_guard = v_case_guard;
                   case_whens = v_case_whens;
                   case_else = v_case_else
                 } =
  let bnds = [] in
  let arg = Ocaml.vof_list vof_expr v_case_else in
  let bnd = ("case_else", arg) in
  let bnds = bnd :: bnds in
  let arg =
    Ocaml.vof_list
      (fun (v1, v2) ->
         let v1 = Ocaml.vof_list vof_expr v1
         and v2 = Ocaml.vof_list vof_expr v2
         in Ocaml.VTuple [ v1; v2 ])
      v_case_whens in
  let bnd = ("case_whens", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_expr v_case_guard in
  let bnd = ("case_guard", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
  
let vof_ast v = Ocaml.vof_list vof_expr v
  
let vof_pos v = vof_tok v
  

