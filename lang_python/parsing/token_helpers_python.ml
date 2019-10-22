(* Yoann Padioleau
 *
 * Copyright (C) 2010 Facebook
 * Copyright (C) 2019 Yoann Padioleau
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

open Parser_python

(*****************************************************************************)
(* Token Helpers *)
(*****************************************************************************)
let is_eof = function
  | EOF _ -> true
  | _ -> false

let is_comment = function
  | TComment _ | TCommentSpace _ -> true
  | _ -> false 

let is_special = function
  | INDENT | DEDENT -> true
  | _ -> false

(*****************************************************************************)
(* Visitors *)
(*****************************************************************************)

let visitor_info_of_tok f = function

  | TUnknown (ii) -> TUnknown (f ii)
  | EOF (ii) -> EOF (f ii)
  | TCommentSpace (ii) -> TCommentSpace (f ii)
  | TComment (ii) -> TComment (f ii)

  | NAME (x, ii) -> NAME (x, f ii)
  | INT (x, ii) -> INT (x, f ii)
  | LONGINT (x, ii) -> LONGINT (x, f ii)
  | FLOAT (x, ii) -> FLOAT (x, f ii)
  | IMAG (x, ii) -> IMAG (x, f ii)
  | STR (x, ii) -> STR (x, f ii)

  | AND (ii) -> AND (f ii)
  | AS (ii) -> AS (f ii)
  | ASSERT (ii) -> ASSERT (f ii)
  | BREAK (ii) -> BREAK (f ii)
  | CLASS (ii) -> CLASS (f ii)
  | CONTINUE (ii) -> CONTINUE (f ii)
  | DEF (ii) -> DEF (f ii)
  | DEL (ii) -> DEL (f ii)
  | ELIF (ii) -> ELIF (f ii)
  | ELSE (ii) -> ELSE (f ii)
  | EXCEPT (ii) -> EXCEPT (f ii)
  | FINALLY (ii) -> FINALLY (f ii)
  | FOR (ii) -> FOR (f ii)
  | FROM (ii) -> FROM (f ii)
  | GLOBAL (ii) -> GLOBAL (f ii)
  | IF (ii) -> IF (f ii)
  | IMPORT (ii) -> IMPORT (f ii)
  | IN (ii) -> IN (f ii)
  | IS (ii) -> IS (f ii)
  | LAMBDA (ii) -> LAMBDA (f ii)
  | NOT (ii) -> NOT (f ii)
  | OR (ii) -> OR (f ii)
  | PASS (ii) -> PASS (f ii)
  | RAISE (ii) -> RAISE (f ii)
  | RETURN (ii) -> RETURN (f ii)
  | TRY (ii) -> TRY (f ii)
  | WHILE (ii) -> WHILE (f ii)
  | WITH (ii) -> WITH (f ii)
  | YIELD (ii) -> YIELD (f ii)

  | LPAREN (ii) -> LPAREN (f ii)
  | RPAREN (ii) -> RPAREN (f ii)
  | LBRACK (ii) -> LBRACK (f ii)
  | RBRACK (ii) -> RBRACK (f ii)
  | LBRACE (ii) -> LBRACE (f ii)
  | RBRACE (ii) -> RBRACE (f ii)
  | COLON (ii) -> COLON (f ii)
  | SEMICOL (ii) -> SEMICOL (f ii)
  | DOT (ii) -> DOT (f ii)
  | COMMA (ii) -> COMMA (f ii)
  | BACKQUOTE (ii) -> BACKQUOTE (f ii)
  | AT (ii) -> AT (f ii)
  | ADD (ii) -> ADD (f ii)
  | SUB (ii) -> SUB (f ii)
  | MULT (ii) -> MULT (f ii)
  | DIV (ii) -> DIV (f ii)
  | MOD (ii) -> MOD (f ii)
  | POW (ii) -> POW (f ii)
  | FDIV (ii) -> FDIV (f ii)
  | BITOR (ii) -> BITOR (f ii)
  | BITAND (ii) -> BITAND (f ii)
  | BITXOR (ii) -> BITXOR (f ii)
  | BITNOT (ii) -> BITNOT (f ii)
  | LSHIFT (ii) -> LSHIFT (f ii)
  | RSHIFT (ii) -> RSHIFT (f ii)
  | EQ (ii) -> EQ (f ii)
  | ADDEQ (ii) -> ADDEQ (f ii)
  | SUBEQ (ii) -> SUBEQ (f ii)
  | MULTEQ (ii) -> MULTEQ (f ii)
  | DIVEQ (ii) -> DIVEQ (f ii)
  | MODEQ (ii) -> MODEQ (f ii)
  | POWEQ (ii) -> POWEQ (f ii)
  | FDIVEQ (ii) -> FDIVEQ (f ii)
  | ANDEQ (ii) -> ANDEQ (f ii)
  | OREQ (ii) -> OREQ (f ii)
  | XOREQ (ii) -> XOREQ (f ii)
  | LSHEQ (ii) -> LSHEQ (f ii)
  | RSHEQ (ii) -> RSHEQ (f ii)
  | EQUAL (ii) -> EQUAL (f ii)
  | NOTEQ (ii) -> NOTEQ (f ii)
  | LT (ii) -> LT (f ii)
  | GT (ii) -> GT (f ii)
  | LEQ (ii) -> LEQ (f ii)
  | GEQ (ii) -> GEQ (f ii)

  | INDENT -> INDENT
  | DEDENT -> DEDENT
  | NEWLINE (ii) -> NEWLINE (f ii)

let info_of_tok tok = 
  let res = ref None in
  visitor_info_of_tok (fun ii -> res := Some ii; ii) tok +> ignore;
  match !res with
  | Some x -> x
  | None -> Parse_info.fake_info "NOTOK"
