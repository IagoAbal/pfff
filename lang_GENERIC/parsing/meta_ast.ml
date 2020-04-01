
(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_vof.cmo  pr_o.cmo /tmp/xxx.ml  *)

open Ast_generic

let vof_tok v = Meta_parse_info.vof_info_adjustable_precision v
  
let vof_wrap _of_a (v1, v2) =
  let v1 = _of_a v1 and v2 = vof_tok v2 in Ocaml.VTuple [ v1; v2 ]

let vof_bracket of_a (_t1, x, _t2) =
  of_a x
  
let vof_ident v = vof_wrap Ocaml.vof_string v
  
let vof_dotted_name v = Ocaml.vof_list vof_ident v
  
let vof_qualifier = vof_dotted_name
  
let vof_module_name =
  function
  | FileName v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1
      in Ocaml.VSum (("FileName", [ v1 ]))
  | DottedName v1 ->
      let v1 = vof_dotted_name v1 in Ocaml.VSum (("DottedName", [ v1 ]))

let vof_dotted_ident = vof_dotted_name

let rec vof_resolved_name (v1, v2) =
  let v1 = vof_resolved_name_kind v1 in
  let v2 = Ocaml.vof_int v2 in
  Ocaml.VTuple [ v1; v2 ]
and vof_resolved_name_kind = 
  function
  | Local  ->  Ocaml.VSum (("Local", [ ]))
  | Param  -> Ocaml.VSum (("Param", [ ]))
  | EnclosedVar -> Ocaml.VSum (("EnclosedVar", [ ]))
  | Global -> Ocaml.VSum (("Global", [ ]))
  | ImportedEntity v1 ->
      let v1 = vof_dotted_ident v1 in Ocaml.VSum (("ImportedEntity", [ v1 ]))
  | ImportedModule v1 ->
      let v1 = vof_module_name v1 in Ocaml.VSum (("ImportedModule", [ v1 ]))
  | Macro -> Ocaml.VSum (("Macro", []))
  | EnumConstant -> Ocaml.VSum (("EnumConstant", []))
  | TypeName -> Ocaml.VSum (("TypeName", []))


let rec vof_name (v1, v2) =
  let v1 = vof_ident v1 and v2 = vof_name_info v2 in Ocaml.VTuple [ v1; v2 ]

and
  vof_name_info {
                  name_qualifier = v_name_qualifier;
                  name_typeargs = v_name_typeargs
                } =
  let bnds = [] in
  let arg = Ocaml.vof_option vof_type_arguments v_name_typeargs in
  let bnd = ("name_typeargs", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_qualifier v_name_qualifier in
  let bnd = ("name_qualifier", arg) in
  let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_id_info { id_resolved = v_id_resolved; id_type = v_id_type; 
    id_const_literal = v3;
  } =
  let bnds = [] in
  let arg = Ocaml.vof_ref (Ocaml.vof_option vof_literal) v3 in
  let bnd = ("id_const_literal", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_ref (Ocaml.vof_option vof_type_) v_id_type in
  let bnd = ("id_type", arg) in
  let bnds = bnd :: bnds in
  let arg =
    Ocaml.vof_ref (Ocaml.vof_option vof_resolved_name) v_id_resolved in
  let bnd = ("id_resolved", arg) in
  let bnds = bnd :: bnds in 
  Ocaml.VDict bnds



and
  vof_xml {
            xml_tag = v_xml_tag;
            xml_attrs = v_xml_attrs;
            xml_body = v_xml_body
          } =
  let bnds = [] in
  let arg = Ocaml.vof_list vof_xml_body v_xml_body in
  let bnd = ("xml_body", arg) in
  let bnds = bnd :: bnds in
  let arg =
    Ocaml.vof_list
      (fun (v1, v2) ->
         let v1 = vof_ident v1
         and v2 = vof_xml_attr v2
         in Ocaml.VTuple [ v1; v2 ])
      v_xml_attrs in
  let bnd = ("xml_attrs", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_ident v_xml_tag in
  let bnd = ("xml_tag", arg) in let bnds = bnd :: bnds in 
  Ocaml.VDict bnds

and vof_xml_attr v = vof_expr v

and vof_xml_body =
  function
  | XmlText v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1
      in Ocaml.VSum (("XmlText", [ v1 ]))
  | XmlExpr v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("XmlExpr", [ v1 ]))
  | XmlXml v1 -> let v1 = vof_xml v1 in Ocaml.VSum (("XmlXml", [ v1 ]))


and vof_expr =
  function
  | DisjExpr (v1, v2) -> let v1 = vof_expr v1 in let v2 = vof_expr v2 in
      Ocaml.VSum (("DisjExpr", [v1; v2]))
  | Xml v1 -> let v1 = vof_xml v1 in Ocaml.VSum (("Xml", [ v1 ]))
  | L v1 -> let v1 = vof_literal v1 in Ocaml.VSum (("L", [ v1 ]))
  | Container ((v1, v2)) ->
      let v1 = vof_container_operator v1
      and v2 = vof_bracket (Ocaml.vof_list vof_expr) v2
      in Ocaml.VSum (("Container", [ v1; v2 ]))
  | Tuple v1 ->
      let v1 = Ocaml.vof_list vof_expr v1 in Ocaml.VSum (("Tuple", [ v1 ]))
  | Record v1 ->
      let v1 = vof_bracket (Ocaml.vof_list vof_field) v1 in 
      Ocaml.VSum (("Record", [ v1 ]))
  | Constructor ((v1, v2)) ->
      let v1 = vof_name v1
      and v2 = Ocaml.vof_list vof_expr v2
      in Ocaml.VSum (("Constructor", [ v1; v2 ]))
  | Lambda v1 ->
      let v1 = vof_function_definition v1
      in Ocaml.VSum (("Lambda", [ v1 ]))
  | AnonClass v1 ->
      let v1 = vof_class_definition v1
      in Ocaml.VSum (("AnonClass", [ v1 ]))
  | Id ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = vof_id_info v2
      in Ocaml.VSum (("Id", [ v1; v2 ]))
  | IdQualified ((v1, v2)) ->
      let v1 = vof_name v1
      and v2 = vof_id_info v2
      in Ocaml.VSum (("IdQualified", [ v1; v2 ]))
  | IdSpecial v1 ->
      let v1 = vof_wrap vof_special v1 in Ocaml.VSum (("IdSpecial", [ v1 ]))
  | Call ((v1, v2)) ->
      let v1 = vof_expr v1
      and v2 = vof_arguments v2
      in Ocaml.VSum (("Call", [ v1; v2 ]))
  | Assign ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_tok v2
      and v3 = vof_expr v3
      in Ocaml.VSum (("Assign", [ v1; v2; v3 ]))
  | AssignOp ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_wrap vof_arithmetic_operator v2
      and v3 = vof_expr v3
      in Ocaml.VSum (("AssignOp", [ v1; v2; v3 ]))
  | LetPattern ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("LetPattern", [ v1; v2 ]))
  | DotAccess ((v1, t, v2)) ->
      let v1 = vof_expr v1
      and t = vof_tok t
      and v2 = vof_field_ident v2
      in Ocaml.VSum (("DotAccess", [ v1; t; v2 ]))
  | ArrayAccess ((v1, v2)) ->
      let v1 = vof_expr v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("ArrayAccess", [ v1; v2 ]))
  | SliceAccess ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_option vof_expr v2
      and v3 = Ocaml.vof_option vof_expr v3
      and v4 = Ocaml.vof_option vof_expr v4
      in Ocaml.VSum (("SliceAccess", [ v1; v2; v3; v4 ]))
  | Conditional ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_expr v2
      and v3 = vof_expr v3
      in Ocaml.VSum (("Conditional", [ v1; v2; v3 ]))
  | MatchPattern ((v1, v2)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_action v2
      in Ocaml.VSum (("MatchPattern", [ v1; v2 ]))
  | Yield ((t, v1, v2)) -> 
      let t = vof_tok t in
      let v1 = Ocaml.vof_option vof_expr v1 and v2 = Ocaml.vof_bool v2 in 
      Ocaml.VSum (("Yield", [ t; v1; v2 ]))
  | Await (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_expr v1 in Ocaml.VSum (("Await", [ t; v1 ]))
  | Cast ((v1, v2)) ->
      let v1 = vof_type_ v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("Cast", [ v1; v2 ]))
  | Seq v1 ->
      let v1 = Ocaml.vof_list vof_expr v1 in Ocaml.VSum (("Seq", [ v1 ]))
  | Ref (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_expr v1 in Ocaml.VSum (("Ref", [ t; v1 ]))
  | DeRef (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_expr v1 in Ocaml.VSum (("DeRef", [ t; v1 ]))
  | Ellipsis v1 -> 
      let v1 = vof_tok v1 in Ocaml.VSum (("Ellipsis", [ v1 ]))
  | TypedMetavar ((v1, v2, v3)) ->
      let v1 = vof_ident v1
      and v2 = vof_tok v2
      and v3 = vof_type_ v3
      in Ocaml.VSum (("TypedMetavar", [ v1; v2; v3 ]))
  | OtherExpr ((v1, v2)) ->
      let v1 = vof_other_expr_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherExpr", [ v1; v2 ]))

and vof_field_ident = function
 | FId (v1) -> let v1 = vof_ident v1 in Ocaml.VSum (("FId", [v1]))
 | FName (v1) -> let v1 = vof_name v1 in Ocaml.VSum (("FName", [v1]))
 | FDynamic (v1) -> let v1 = vof_expr v1 in Ocaml.VSum (("FDynamic", [v1]))

and vof_literal =
  function
  | Unit v1 -> let v1 = vof_tok v1 in Ocaml.VSum (("Unit", [ v1 ]))
  | Bool v1 ->
      let v1 = vof_wrap Ocaml.vof_bool v1 in Ocaml.VSum (("Bool", [ v1 ]))
  | Int v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1 in Ocaml.VSum (("Int", [ v1 ]))
  | Float v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1 in Ocaml.VSum (("Float", [ v1 ]))
  | Imag v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1 in Ocaml.VSum (("Imag", [ v1 ]))
  | Char v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1 in Ocaml.VSum (("Char", [ v1 ]))
  | String v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1
      in Ocaml.VSum (("String", [ v1 ]))
  | Regexp v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1
      in Ocaml.VSum (("Regexp", [ v1 ]))
  | Null v1 -> let v1 = vof_tok v1 in Ocaml.VSum (("Null", [ v1 ]))
  | Undefined v1 -> let v1 = vof_tok v1 in Ocaml.VSum (("Undefined", [ v1 ]))
and vof_container_operator =
  function
  | Array -> Ocaml.VSum (("Array", []))
  | List -> Ocaml.VSum (("List", []))
  | Set -> Ocaml.VSum (("Set", []))
  | Dict -> Ocaml.VSum (("Dict", []))
and vof_special =
  function
  | This -> Ocaml.VSum (("This", []))
  | Super -> Ocaml.VSum (("Super", []))
  | Self -> Ocaml.VSum (("Self", []))
  | Parent -> Ocaml.VSum (("Parent", []))
  | Eval -> Ocaml.VSum (("Eval", []))
  | Typeof -> Ocaml.VSum (("Typeof", []))
  | Instanceof -> Ocaml.VSum (("Instanceof", []))
  | Sizeof -> Ocaml.VSum (("Sizeof", []))
  | New -> Ocaml.VSum (("New", []))
  | Concat -> Ocaml.VSum (("Concat", []))
  | Spread -> Ocaml.VSum (("Spread", []))
  | EncodedString v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1 in
      Ocaml.VSum (("EncodedString", [v1]))
  | ArithOp v1 ->
      let v1 = vof_arithmetic_operator v1 in Ocaml.VSum (("ArithOp", [ v1 ]))
  | IncrDecr (v) ->
      let v = vof_inc_dec v in
      Ocaml.VSum (("IncrDecr", [ v]))

and vof_inc_dec (v1, v2) =
      let v1 = vof_incr_decr v1
      and v2 = vof_prepost v2
      in Ocaml.VTuple [ v1; v2 ]

and vof_incr_decr =
  function
  | Incr -> Ocaml.VSum (("Incr", []))
  | Decr -> Ocaml.VSum (("Decr", []))

and vof_prepost =
  function
  | Prefix -> Ocaml.VSum (("Prefix", []))
  | Postfix -> Ocaml.VSum (("Postfix", []))

and vof_arithmetic_operator =
  function
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
  | Not -> Ocaml.VSum (("Not", []))
  | Xor -> Ocaml.VSum (("Xor", []))
  | Eq -> Ocaml.VSum (("Eq", []))
  | NotEq -> Ocaml.VSum (("NotEq", []))
  | PhysEq -> Ocaml.VSum (("PhysEq", []))
  | NotPhysEq -> Ocaml.VSum (("NotPhysEq", []))
  | Lt -> Ocaml.VSum (("Lt", []))
  | LtE -> Ocaml.VSum (("LtE", []))
  | Gt -> Ocaml.VSum (("Gt", []))
  | GtE -> Ocaml.VSum (("GtE", []))
  | Cmp -> Ocaml.VSum (("Cmp", []))

and vof_arguments v = Ocaml.vof_list vof_argument v
and vof_argument =
  function
  | Arg v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("Arg", [ v1 ]))
  | ArgKwd ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("ArgKwd", [ v1; v2 ]))
  | ArgType v1 -> let v1 = vof_type_ v1 in Ocaml.VSum (("ArgType", [ v1 ]))
  | ArgOther ((v1, v2)) ->
      let v1 = vof_other_argument_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("ArgOther", [ v1; v2 ]))
and vof_other_argument_operator =
  function
  | OA_ArgPow -> Ocaml.VSum (("OA_ArgPow", []))
  | OA_ArgComp -> Ocaml.VSum (("OA_ArgComp", []))
  | OA_ArgQuestion -> Ocaml.VSum (("OA_ArgQuestion", []))
and vof_action (v1, v2) =
  let v1 = vof_pattern v1 and v2 = vof_expr v2 in Ocaml.VTuple [ v1; v2 ]
and vof_other_expr_operator =
  function
  | OE_Send -> Ocaml.VSum (("OE_Send", []))
  | OE_Recv -> Ocaml.VSum (("OE_Recv", []))
  | OE_StmtExpr -> Ocaml.VSum (("OE_StmtExpr", []))
  | OE_Exports -> Ocaml.VSum (("OE_Exports", []))
  | OE_Module -> Ocaml.VSum (("OE_Module", []))
  | OE_Define -> Ocaml.VSum (("OE_Define", []))
  | OE_Arguments -> Ocaml.VSum (("OE_Arguments", []))
  | OE_NewTarget -> Ocaml.VSum (("OE_NewTarget", []))
  | OE_Delete -> Ocaml.VSum (("OE_Delete", []))
  | OE_YieldStar -> Ocaml.VSum (("OE_YieldStar", []))
  | OE_EncapsName -> Ocaml.VSum (("OE_EncapsName", []))
  | OE_Require -> Ocaml.VSum (("OE_Require", []))
  | OE_UseStrict -> Ocaml.VSum (("OE_UseStrict", []))
  | OE_In -> Ocaml.VSum (("OE_In", []))
  | OE_NotIn -> Ocaml.VSum (("OE_NotIn", []))
  | OE_Invert -> Ocaml.VSum (("OE_Invert", []))
  | OE_Slices -> Ocaml.VSum (("OE_Slices", []))
  | OE_CompForIf -> Ocaml.VSum (("OE_CompForIf", []))
  | OE_CompFor -> Ocaml.VSum (("OE_CompFor", []))
  | OE_CompIf -> Ocaml.VSum (("OE_CompIf", []))
  | OE_CmpOps -> Ocaml.VSum (("OE_CmpOps", []))
  | OE_Repr -> Ocaml.VSum (("OE_Repr", []))
  | OE_NameOrClassType -> Ocaml.VSum (("OE_NameOrClassType", []))
  | OE_ClassLiteral -> Ocaml.VSum (("OE_ClassLiteral", []))
  | OE_NewQualifiedClass -> Ocaml.VSum (("OE_NewQualifiedClass", []))
  | OE_GetRefLabel -> Ocaml.VSum (("OE_GetRefLabel", []))
  | OE_ArrayInitDesignator -> Ocaml.VSum (("OE_ArrayInitDesignator", []))
  | OE_Unpack -> Ocaml.VSum (("OE_Unpack", []))
  | OE_RecordFieldName -> Ocaml.VSum (("OE_RecordFieldName", []))
  | OE_RecordWith -> Ocaml.VSum (("OE_RecordWith", []))
  
and vof_type_ =
  function
  | TyAnd v1 ->
      let v1 =
        vof_bracket
          (Ocaml.vof_list
             (fun (v1, v2) ->
                let v1 = vof_ident v1
                and v2 = vof_type_ v2
                in Ocaml.VTuple [ v1; v2 ]))
          v1
      in Ocaml.VSum (("TyAnd", [ v1 ]))
  | TyOr v1 ->
      let v1 = Ocaml.vof_list vof_type_ v1 in Ocaml.VSum (("TyOr", [ v1 ]))
  | TyBuiltin v1 ->
      let v1 = vof_wrap Ocaml.vof_string v1
      in Ocaml.VSum (("TyBuiltin", [ v1 ]))
  | TyFun ((v1, v2)) ->
      let v1 = Ocaml.vof_list vof_parameter_classic v1
      and v2 = vof_type_ v2
      in Ocaml.VSum (("TyFun", [ v1; v2 ]))
  | TyNameApply ((v1, v2)) ->
      let v1 = vof_name v1
      and v2 = vof_type_arguments v2
      in Ocaml.VSum (("TyNameApply", [ v1; v2 ]))
  | TyName ((v1)) ->
      let v1 = vof_name v1
      in Ocaml.VSum (("TyName", [ v1 ]))
  | TyVar v1 -> let v1 = vof_ident v1 in Ocaml.VSum (("TyVar", [ v1 ]))
  | TyArray ((v1, v2)) ->
      let v1 = Ocaml.vof_option vof_expr v1
      and v2 = vof_type_ v2
      in Ocaml.VSum (("TyArray", [ v1; v2 ]))
  | TyPointer (t, v1) ->
      let t = vof_tok t in
      let v1 = vof_type_ v1 in Ocaml.VSum (("TyPointer", [ t; v1 ]))
  | TyTuple v1 ->
      let v1 = vof_bracket (Ocaml.vof_list vof_type_) v1
      in Ocaml.VSum (("TyTuple", [ v1 ]))
  | TyQuestion (v1, t) ->
      let t = vof_tok t in
      let v1 = vof_type_ v1 in Ocaml.VSum (("TyQuestion", [ t; v1 ]))
  | OtherType ((v1, v2)) ->
      let v1 = vof_other_type_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherType", [ v1; v2 ]))
and vof_type_arguments v = Ocaml.vof_list vof_type_argument v
and vof_type_argument =
  function
  | TypeArg v1 -> let v1 = vof_type_ v1 in Ocaml.VSum (("TypeArg", [ v1 ]))
  | OtherTypeArg ((v1, v2)) ->
      let v1 = vof_other_type_argument_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherTypeArg", [ v1; v2 ]))
and vof_other_type_argument_operator =
  function | OTA_Question -> Ocaml.VSum (("OTA_Question", []))
and vof_other_type_operator =
  function
  | OT_Expr -> Ocaml.VSum (("OT_Expr", []))
  | OT_Arg -> Ocaml.VSum (("OT_Arg", []))
  | OT_StructName -> Ocaml.VSum (("OT_StructName", []))
  | OT_UnionName -> Ocaml.VSum (("OT_UnionName", []))
  | OT_EnumName -> Ocaml.VSum (("OT_EnumName", []))
  | OT_ShapeComplex -> Ocaml.VSum (("OT_ShapeComplex", []))
  | OT_Variadic -> Ocaml.VSum (("OT_Variadic", []))
and vof_keyword_attribute =
  function
  | Static -> Ocaml.VSum (("Static", []))
  | Volatile -> Ocaml.VSum (("Volatile", []))
  | Extern -> Ocaml.VSum (("Extern", []))
  | Public -> Ocaml.VSum (("Public", []))
  | Private -> Ocaml.VSum (("Private", []))
  | Protected -> Ocaml.VSum (("Protected", []))
  | Abstract -> Ocaml.VSum (("Abstract", []))
  | Final -> Ocaml.VSum (("Final", []))
  | Var -> Ocaml.VSum (("Var", []))
  | Let -> Ocaml.VSum (("Let", []))
  | Const -> Ocaml.VSum (("Const", []))
  | Mutable -> Ocaml.VSum (("Mutable", []))
  | Generator -> Ocaml.VSum (("Generator", []))
  | Async -> Ocaml.VSum (("Async", []))
  | Recursive -> Ocaml.VSum (("Recursive", []))
  | MutuallyRecursive -> Ocaml.VSum (("MutuallyRecursive", []))
  | Ctor -> Ocaml.VSum (("Ctor", []))
  | Dtor -> Ocaml.VSum (("Dtor", []))
  | Getter -> Ocaml.VSum (("Getter", []))
  | Setter -> Ocaml.VSum (("Setter", []))
  | Variadic -> Ocaml.VSum (("Variadic", []))

and vof_attribute = function
  | KeywordAttr x -> let v1 = vof_wrap vof_keyword_attribute x in
    Ocaml.VSum (("KeywordAttr", [v1]))
  | NamedAttr ((v1, v2, v3)) ->
      let v1 = vof_ident v1
      and v2 = vof_id_info v2
      and v3 = Ocaml.vof_list vof_argument v3
      in Ocaml.VSum (("NamedAttr", [ v1; v2; v3 ]))
  | OtherAttribute ((v1, v2)) ->
      let v1 = vof_other_attribute_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherAttribute", [ v1; v2 ]))
and vof_other_attribute_operator =
  function
  | OA_StrictFP -> Ocaml.VSum (("OA_StrictFP", []))
  | OA_Transient -> Ocaml.VSum (("OA_Transient", []))
  | OA_Synchronized -> Ocaml.VSum (("OA_Synchronized", []))
  | OA_Native -> Ocaml.VSum (("OA_Native", []))
  | OA_AnnotJavaOther -> Ocaml.VSum (("OA_AnnotJavaOther", [ ]))
  | OA_AnnotThrow -> Ocaml.VSum (("OA_AnnotThrow", []))
  | OA_Expr -> Ocaml.VSum (("OA_Expr", []))
and vof_stmt =
  function
  | DisjStmt (v1, v2) -> let v1 = vof_stmt v1 in let v2 = vof_stmt v2 in
      Ocaml.VSum (("DisjStmt", [v1; v2]))
  | ExprStmt v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("ExprStmt", [ v1 ]))
  | DefStmt v1 ->
      let v1 = vof_definition v1 in Ocaml.VSum (("DefStmt", [ v1 ]))
  | DirectiveStmt v1 ->
      let v1 = vof_directive v1 in Ocaml.VSum (("DirectiveStmt", [ v1 ]))
  | Block v1 ->
      let v1 = Ocaml.vof_list vof_stmt v1 in Ocaml.VSum (("Block", [ v1 ]))
  | If ((t, v1, v2, v3)) ->
      let t = vof_tok t in
      let v1 = vof_expr v1
      and v2 = vof_stmt v2
      and v3 = vof_stmt v3
      in Ocaml.VSum (("If", [ t; v1; v2; v3 ]))
  | While ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_expr v1
      and v2 = vof_stmt v2
      in Ocaml.VSum (("While", [ t; v1; v2 ]))
  | DoWhile ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_stmt v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("DoWhile", [ t; v1; v2 ]))
  | For ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_for_header v1
      and v2 = vof_stmt v2
      in Ocaml.VSum (("For", [ t; v1; v2 ]))
  | Switch ((v0, v1, v2)) ->
      let v0 = vof_tok v0 in
      let v1 = Ocaml.vof_option vof_expr v1
      and v2 = Ocaml.vof_list vof_case_and_body v2
      in Ocaml.VSum (("Switch", [ v0; v1; v2 ]))
  | Return (t, v1) -> 
      let t = vof_tok t in
      let v1 = Ocaml.vof_option vof_expr v1 in 
      Ocaml.VSum (("Return", [ t; v1 ]))
  | Continue (t, v1) ->
      let t = vof_tok t in
      let v1 = vof_label_ident v1
      in Ocaml.VSum (("Continue", [ t; v1 ]))
  | Break (t, v1) ->
      let t = vof_tok t in
      let v1 = vof_label_ident v1 in
      Ocaml.VSum (("Break", [ t; v1 ]))
  | Label ((v1, v2)) ->
      let v1 = vof_label v1
      and v2 = vof_stmt v2
      in Ocaml.VSum (("Label", [ v1; v2 ]))
  | Goto (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_label v1 in Ocaml.VSum (("Goto", [ t; v1 ]))
  | Throw (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_expr v1 in Ocaml.VSum (("Throw", [ t; v1 ]))
  | Try ((t, v1, v2, v3)) ->
      let t = vof_tok t in
      let v1 = vof_stmt v1
      and v2 = Ocaml.vof_list vof_catch v2
      and v3 = Ocaml.vof_option vof_finally v3
      in Ocaml.VSum (("Try", [ t; v1; v2; v3 ]))
  | Assert ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_option vof_expr v2
      in Ocaml.VSum (("Assert", [ t; v1; v2 ]))
  | OtherStmtWithStmt ((v1, v2, v3)) ->
      let v1 = vof_other_stmt_with_stmt_operator v1
      and v2 = vof_expr v2
      and v3 = vof_stmt v3
      in Ocaml.VSum (("OtherStmtWithStmt", [ v1; v2; v3 ]))
  | OtherStmt ((v1, v2)) ->
      let v1 = vof_other_stmt_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherStmt", [ v1; v2 ]))
and vof_other_stmt_with_stmt_operator = function
  | OSWS_With -> Ocaml.VSum (("OSWS_With", []))

and vof_label_ident =
  function
  | LNone -> Ocaml.VSum (("LNone", []))
  | LId v1 -> let v1 = vof_label v1 in Ocaml.VSum (("LId", [ v1 ]))
  | LInt v1 -> let v1 = vof_wrap Ocaml.vof_int v1 in Ocaml.VSum (("LInt", [ v1 ]))
  | LDynamic v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("LDynamic", [ v1 ]))

and vof_case_and_body (v1, v2) =
  let v1 = Ocaml.vof_list vof_case v1
  and v2 = vof_stmt v2
  in Ocaml.VTuple [ v1; v2 ]
and vof_case =
  function
  | Case (t, v1) -> 
      let t = vof_tok t in
      let v1 = vof_pattern v1 in 
      Ocaml.VSum (("Case", [ t; v1 ]))
  | CaseEqualExpr (v1, v2) -> 
      let v1 = vof_tok v1 in
      let v2 = vof_expr v2 in 
      Ocaml.VSum (("CaseEqualExpr", [ v1; v2 ]))
  | Default t -> 
      let t = vof_tok t in
      Ocaml.VSum (("Default", [t]))
and vof_catch (t, v1, v2) =
  let t = vof_tok t in 
  let v1 = vof_pattern v1 and v2 = vof_stmt v2 in Ocaml.VTuple [ t; v1; v2 ]
and vof_finally v = vof_tok_and_stmt v
and vof_tok_and_stmt (t, v) = 
  let t = vof_tok t in
  let v = vof_stmt v in
  Ocaml.VTuple [t; v]

and vof_label v = vof_ident v
and vof_for_header =
  function
  | ForClassic ((v1, v2, v3)) ->
      let v1 = Ocaml.vof_list vof_for_var_or_expr v1
      and v2 = Ocaml.vof_option vof_expr v2
      and v3 = Ocaml.vof_option vof_expr v3
      in Ocaml.VSum (("ForClassic", [ v1; v2; v3 ]))
  | ForEach ((v1, t, v2)) ->
      let t = vof_tok t in
      let v1 = vof_pattern v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("ForEach", [ v1; t; v2 ]))
and vof_for_var_or_expr =
  function
  | ForInitVar ((v1, v2)) ->
      let v1 = vof_entity v1
      and v2 = vof_variable_definition v2
      in Ocaml.VSum (("ForInitVar", [ v1; v2 ]))
  | ForInitExpr v1 ->
      let v1 = vof_expr v1 in Ocaml.VSum (("ForInitExpr", [ v1 ]))
and vof_other_stmt_operator =
  function
  | OS_Delete -> Ocaml.VSum (("OS_Delete", []))
  | OS_Async -> Ocaml.VSum (("OS_Async", []))
  | OS_ForOrElse -> Ocaml.VSum (("OS_ForOrElse", []))
  | OS_WhileOrElse -> Ocaml.VSum (("OS_WhileOrElse", []))
  | OS_TryOrElse -> Ocaml.VSum (("OS_TryOrElse", []))
  | OS_ThrowFrom -> Ocaml.VSum (("OS_ThrowFrom", []))
  | OS_ThrowNothing -> Ocaml.VSum (("OS_ThrowNothing", []))
  | OS_GlobalComplex -> Ocaml.VSum (("OS_GlobalComplex", []))
  | OS_Pass -> Ocaml.VSum (("OS_Pass", []))
  | OS_Sync -> Ocaml.VSum (("OS_Sync", []))
  | OS_Asm -> Ocaml.VSum (("OS_Asm", []))
  | OS_Go -> Ocaml.VSum (("OS_Go", []))
  | OS_Defer -> Ocaml.VSum (("OS_Defer", []))
  | OS_Fallthrough -> Ocaml.VSum (("OS_Fallthrough", []))
and vof_pattern =
  function
  | PatId ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = vof_id_info v2
      in Ocaml.VSum (("PatVar", [ v1; v2 ]))

  | PatVar ((v1, v2)) ->
      let v1 = vof_type_ v1
      and v2 =
        Ocaml.vof_option
          (fun (v1, v2) ->
             let v1 = vof_ident v1
             and v2 = vof_id_info v2
             in Ocaml.VTuple [ v1; v2 ])
          v2
      in Ocaml.VSum (("PatVar", [ v1; v2 ]))

  | PatLiteral v1 ->
      let v1 = vof_literal v1 in Ocaml.VSum (("PatLiteral", [ v1 ]))
  | PatType v1 ->
      let v1 = vof_type_ v1 in Ocaml.VSum (("PatType", [ v1 ]))
  | PatRecord v1 ->
      let v1 =
        vof_bracket (Ocaml.vof_list
          (fun (v1, v2) ->
             let v1 = vof_name v1
             and v2 = vof_pattern v2
             in Ocaml.VTuple [ v1; v2 ]))
          v1
      in Ocaml.VSum (("PatRecord", [ v1 ]))
  | PatConstructor ((v1, v2)) ->
      let v1 = vof_name v1
      and v2 = Ocaml.vof_list vof_pattern v2
      in Ocaml.VSum (("PatConstructor", [ v1; v2 ]))
  | PatWhen ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 = vof_expr v2
      in Ocaml.VSum (("PatWhen", [ v1; v2 ]))
  | PatAs ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 =
        (match v2 with
         | (v1, v2) ->
             let v1 = vof_ident v1
             and v2 = vof_id_info v2
             in Ocaml.VTuple [ v1; v2 ])
      in Ocaml.VSum (("PatAs", [ v1; v2 ]))
  | PatTuple v1 ->
      let v1 = Ocaml.vof_list vof_pattern v1
      in Ocaml.VSum (("PatTuple", [ v1 ]))
  | PatList v1 ->
      let v1 = vof_bracket (Ocaml.vof_list vof_pattern) v1
      in Ocaml.VSum (("PatList", [ v1 ]))
  | PatKeyVal ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 = vof_pattern v2
      in Ocaml.VSum (("PatKeyVal", [ v1; v2 ]))
  | PatUnderscore v1 ->
      let v1 = vof_tok v1 in Ocaml.VSum (("PatUnderscore", [ v1 ]))
  | PatDisj ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 = vof_pattern v2
      in Ocaml.VSum (("PatDisj", [ v1; v2 ]))
  | PatTyped ((v1, v2)) ->
      let v1 = vof_pattern v1
      and v2 = vof_type_ v2
      in Ocaml.VSum (("PatTyped", [ v1; v2 ]))
  | OtherPat ((v1, v2)) ->
      let v1 = vof_other_pattern_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherPat", [ v1; v2 ]))
and vof_other_pattern_operator =
  function
  | OP_Expr -> Ocaml.VSum (("OP_Expr", []))
and vof_definition (v1, v2) =
  let v1 = vof_entity v1
  and v2 = vof_definition_kind v2
  in Ocaml.VTuple [ v1; v2 ]

and
  vof_entity {
               name = v_name;
               attrs = v_attrs;
               tparams = v_tparams;
               info = v_info
             } =
  let bnds = [] in
  let arg = vof_id_info v_info in
  let bnd = ("info", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_type_parameter v_tparams in
  let bnd = ("tparams", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_attribute v_attrs in
  let bnd = ("attrs", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_ident v_name in
  let bnd = ("name", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds

and vof_definition_kind =
  function
  | FuncDef v1 ->
      let v1 = vof_function_definition v1 in Ocaml.VSum (("FuncDef", [ v1 ]))
  | VarDef v1 ->
      let v1 = vof_variable_definition v1 in Ocaml.VSum (("VarDef", [ v1 ]))
  | ClassDef v1 ->
      let v1 = vof_class_definition v1 in Ocaml.VSum (("ClassDef", [ v1 ]))
  | TypeDef v1 ->
      let v1 = vof_type_definition v1 in Ocaml.VSum (("TypeDef", [ v1 ]))
  | ModuleDef v1 ->
      let v1 = vof_module_definition v1 in Ocaml.VSum (("ModuleDef", [ v1 ]))
  | MacroDef v1 ->
      let v1 = vof_macro_definition v1 in Ocaml.VSum (("MacroDef", [ v1 ]))
  | Signature v1 ->
      let v1 = vof_type_ v1 in Ocaml.VSum (("Signature", [ v1 ]))
  | UseOuterDecl v1 ->
      let v1 = vof_tok v1 in Ocaml.VSum (("UseOuterDecl", [ v1 ]))

and vof_module_definition { mbody = v_mbody } =
  let bnds = [] in
  let arg = vof_module_definition_kind v_mbody in
  let bnd = ("mbody", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_module_definition_kind =
  function
  | ModuleAlias v1 ->
      let v1 = vof_name v1 in Ocaml.VSum (("ModuleAlias", [ v1 ]))
  | ModuleStruct ((v1, v2)) ->
      let v1 = Ocaml.vof_option vof_dotted_name v1
      and v2 = Ocaml.vof_list vof_item v2
      in Ocaml.VSum (("ModuleStruct", [ v1; v2 ]))
  | OtherModule ((v1, v2)) ->
      let v1 = vof_other_module_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherModule", [ v1; v2 ]))
and vof_other_module_operator =
  function | OMO_Functor -> Ocaml.VSum (("OMO_Functor", []))
and
  vof_macro_definition { macroparams = v_macroparams; macrobody = v_macrobody
                       } =
  let bnds = [] in
  let arg = Ocaml.vof_list vof_any v_macrobody in
  let bnd = ("macrobody", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_ident v_macroparams in
  let bnd = ("macroparams", arg) in
  let bnds = bnd :: bnds in Ocaml.VDict bnds

and vof_type_parameter (v1, v2) =
  let v1 = vof_ident v1
  and v2 = vof_type_parameter_constraints v2
  in Ocaml.VTuple [ v1; v2 ]
and vof_type_parameter_constraints v =
  Ocaml.vof_list vof_type_parameter_constraint v
and vof_type_parameter_constraint =
  function
  | Extends v1 -> let v1 = vof_type_ v1 in Ocaml.VSum (("Extends", [ v1 ]))
and
  vof_function_definition {
                            fparams = v_fparams;
                            frettype = v_frettype;
                            fbody = v_fbody
                          } =
  let bnds = [] in
  let arg = vof_stmt v_fbody in
  let bnd = ("fbody", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_type_ v_frettype in
  let bnd = ("frettype", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_parameters v_fparams in
  let bnd = ("fparams", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_parameters v = Ocaml.vof_list vof_parameter v
and vof_parameter =
  function
  | ParamClassic v1 ->
      let v1 = vof_parameter_classic v1
      in Ocaml.VSum (("ParamClassic", [ v1 ]))
  | ParamPattern v1 ->
      let v1 = vof_pattern v1 in Ocaml.VSum (("ParamPattern", [ v1 ]))
  | ParamEllipsis v1 ->
      let v1 = vof_tok v1 in Ocaml.VSum (("ParamEllipsis", [ v1 ]))
  | OtherParam ((v1, v2)) ->
      let v1 = vof_other_parameter_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherParam", [ v1; v2 ]))

and
  vof_parameter_classic {
                          pname = v_pname;
                          pdefault = v_pdefault;
                          ptype = v_ptype;
                          pattrs = v_pattrs;
                          pinfo = v_pinfo
                        } =
  let bnds = [] in
  let arg = vof_id_info v_pinfo in
  let bnd = ("pinfo", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_attribute v_pattrs in
  let bnd = ("pattrs", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_type_ v_ptype in
  let bnd = ("ptype", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_expr v_pdefault in
  let bnd = ("pdefault", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_ident v_pname in
  let bnd = ("pname", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds

and vof_other_parameter_operator =
  function
  | OPO_KwdParam -> Ocaml.VSum (("OPO_KwdParam", []))
  | OPO_Ref -> Ocaml.VSum (("OPO_Ref", []))
  | OPO_Receiver -> Ocaml.VSum (("OPO_Receiver", []))
  | OPO_SingleStarParam -> Ocaml.VSum ("OPO_SingleStarParam", [])
and vof_variable_definition { vinit = v_vinit; vtype = v_vtype } =
  let bnds = [] in
  let arg = Ocaml.vof_option vof_type_ v_vtype in
  let bnd = ("vtype", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_option vof_expr v_vinit in
  let bnd = ("vinit", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_field =
  function
  | FieldDynamic ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = Ocaml.vof_list vof_attribute v2
      and v3 = vof_expr v3
      in Ocaml.VSum (("FieldDynamic", [ v1; v2; v3 ]))
  | FieldSpread (t, v1) ->
      let t = vof_tok t in
      let v1 = vof_expr v1 in Ocaml.VSum (("FieldSpread", [ t; v1 ]))
  | FieldStmt v1 ->
      let v1 = vof_stmt v1 in Ocaml.VSum (("FieldStmt", [ v1 ]))
and vof_type_definition { tbody = v_tbody } =
  let bnds = [] in
  let arg = vof_type_definition_kind v_tbody in
  let bnd = ("tbody", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_type_definition_kind =
  function
  | OrType v1 ->
      let v1 = Ocaml.vof_list vof_or_type_element v1
      in Ocaml.VSum (("OrType", [ v1 ]))
  | AndType v1 ->
      let v1 = vof_bracket (Ocaml.vof_list vof_field) v1
      in Ocaml.VSum (("AndType", [ v1 ]))
  | AliasType v1 ->
      let v1 = vof_type_ v1 in Ocaml.VSum (("AliasType", [ v1 ]))
  | NewType v1 ->
      let v1 = vof_type_ v1 in Ocaml.VSum (("NewType", [ v1 ]))
  | Exception ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = Ocaml.vof_list vof_type_ v2
      in Ocaml.VSum (("Exception", [ v1; v2 ]))
  | OtherTypeKind ((v1, v2)) ->
      let v1 = vof_other_type_kind_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherTypeKind", [ v1; v2 ]))
and vof_other_type_kind_operator =
  function 
    | OTKO_AbstractType -> Ocaml.VSum (("OTKO_AbstractType", []))
and vof_or_type_element =
  function
  | OrConstructor ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = Ocaml.vof_list vof_type_ v2
      in Ocaml.VSum (("OrConstructor", [ v1; v2 ]))
  | OrEnum ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = Ocaml.vof_option vof_expr v2
      in Ocaml.VSum (("OrEnum", [ v1; v2 ]))
  | OrUnion ((v1, v2)) ->
      let v1 = vof_ident v1
      and v2 = vof_type_ v2
      in Ocaml.VSum (("OrUnion", [ v1; v2 ]))
  | OtherOr ((v1, v2)) ->
      let v1 = vof_other_or_type_element_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherOr", [ v1; v2 ]))
and vof_other_or_type_element_operator =
  function
  | OOTEO_EnumWithMethods -> Ocaml.VSum (("OOTEO_EnumWithMethods", []))
  | OOTEO_EnumWithArguments -> Ocaml.VSum (("OOTEO_EnumWithArguments", []))
and
  vof_class_definition {
                         ckind = v_ckind;
                         cextends = v_cextends;
                         cimplements = v_cimplements;
                         cbody = v_cbody;
                         cmixins = v_cmixins;
                       } =
  let bnds = [] in
  let arg = vof_bracket (Ocaml.vof_list vof_field) v_cbody in
  let bnd = ("cbody", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_type_ v_cmixins in
  let bnd = ("cmixins", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_type_ v_cimplements in
  let bnd = ("cimplements", arg) in
  let bnds = bnd :: bnds in
  let arg = Ocaml.vof_list vof_type_ v_cextends in
  let bnd = ("cextends", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_class_kind v_ckind in
  let bnd = ("ckind", arg) in let bnds = bnd :: bnds in Ocaml.VDict bnds
and vof_class_kind =
  function
  | Class -> Ocaml.VSum (("Class", []))
  | Interface -> Ocaml.VSum (("Interface", []))
  | Trait -> Ocaml.VSum (("Trait", []))
and vof_directive =
  function
  | ImportFrom ((t, v1, v2, v3)) ->
      let t = vof_tok t in
      let v1 = vof_module_name v1
      and v2, v3 = vof_alias (v2, v3)
      in Ocaml.VSum (("ImportFrom", [ t; v1; v2; v3 ]))
  | ImportAs ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_module_name v1
      and v2 = Ocaml.vof_option vof_ident v2
      in Ocaml.VSum (("ImportAs", [ t; v1; v2 ]))
  | ImportAll ((t, v1, v2)) ->
      let t = vof_tok t in
      let v1 = vof_module_name v1
      and v2 = vof_tok v2
      in Ocaml.VSum (("ImportAll", [ t; v1; v2 ]))
  | Package ((t, v1)) ->
      let t = vof_tok t in
      let v1 = vof_dotted_ident v1
      in Ocaml.VSum (("Package", [ t; v1 ]))
  | PackageEnd (t) ->
      let t = vof_tok t in
      Ocaml.VSum (("PackageEnd", [ t ]))
  | OtherDirective ((v1, v2)) ->
      let v1 = vof_other_directive_operator v1
      and v2 = Ocaml.vof_list vof_any v2
      in Ocaml.VSum (("OtherDirective", [ v1; v2 ]))
and vof_alias (v1, v2) =
  let v1 = vof_ident v1
  and v2 = Ocaml.vof_option vof_ident v2
  in v1, v2
and vof_other_directive_operator =
  function
  | OI_Export -> Ocaml.VSum (("OI_Export", []))
  | OI_ImportCss -> Ocaml.VSum (("OI_ImportCss", []))
  | OI_ImportEffect -> Ocaml.VSum (("OI_ImportEffect", []))
and vof_item x = vof_stmt x
and vof_program v = Ocaml.vof_list vof_item v
and vof_any =
  function
  | Tk v1 -> let v1 = vof_tok v1 in Ocaml.VSum (("Tk", [ v1 ]))
  | N v1 -> let v1 = vof_name v1 in Ocaml.VSum (("N", [ v1 ]))
  | En v1 -> let v1 = vof_entity v1 in Ocaml.VSum (("En", [ v1 ]))
  | E v1 -> let v1 = vof_expr v1 in Ocaml.VSum (("E", [ v1 ]))
  | S v1 -> let v1 = vof_stmt v1 in Ocaml.VSum (("S", [ v1 ]))
  | Ss v1 -> let v1 = Ocaml.vof_list vof_stmt v1 in Ocaml.VSum (("Ss", [ v1 ]))
  | T v1 -> let v1 = vof_type_ v1 in Ocaml.VSum (("T", [ v1 ]))
  | P v1 -> let v1 = vof_pattern v1 in Ocaml.VSum (("P", [ v1 ]))
  | Def v1 -> let v1 = vof_definition v1 in Ocaml.VSum (("D", [ v1 ]))
  | Dir v1 -> let v1 = vof_directive v1 in Ocaml.VSum (("Di", [ v1 ]))
  | Fld v1 -> let v1 = vof_field v1 in Ocaml.VSum (("Fld", [ v1 ]))
  | Di v1 -> let v1 = vof_dotted_name v1 in Ocaml.VSum (("Dn", [ v1 ]))
  | I v1 -> let v1 = vof_ident v1 in Ocaml.VSum (("I", [ v1 ]))
  | Pa v1 -> let v1 = vof_parameter v1 in Ocaml.VSum (("Pa", [ v1 ]))
  | Ar v1 -> let v1 = vof_argument v1 in Ocaml.VSum (("Ar", [ v1 ]))
  | At v1 -> let v1 = vof_attribute v1 in Ocaml.VSum (("At", [ v1 ]))
  | Dk v1 -> let v1 = vof_definition_kind v1 in Ocaml.VSum (("Dk", [ v1 ]))
  | Pr v1 -> let v1 = vof_program v1 in Ocaml.VSum (("Pr", [ v1 ]))
  
