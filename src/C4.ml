(* Interpreter for C4: a small language based on a 4-counter machine *)
(* author: Yu-Yang Lin *)
(* 11/03/2019 *)

(* Abstract Syntax *)
type nat = Nil | Suc of nat
let inc n = Suc n
let dec = function Nil -> Nil | Suc n -> n
let rec int_of_nat n acc = if acc > 127 then 127 else (match n with Nil -> acc | Suc n -> int_of_nat n (acc+1))
let char_of_nat n = Char.chr (int_of_nat n 0)
let rec nat_of_int n = if n<=0 then Nil else Suc(nat_of_int (n-1))

type register = nat (* counters *)
type command = I    (* increments current register *)
             | D    (* decrements current register up to Nil *)
             | N    (* select next register, wrapping around *)
             | T    (* target for jump *)
             | J    (* rewind program until matching target is found, or program start is reached *)
             | Out  (* print character at current register. Must be between 0-255 *)
             | In   (* waits and stores user input at current register *)
type program = command list
type counter_machine = (register   (* register 1 *)
                        * register (* register 2 *)
                        * register (* register 3 *)
                        * register (* register 4 *)
                        * program  (* new commands, default = whole program *)
                        * program) (* old commands, default = empty program *)

(* Operational Semantics *)
let transition ((r1,r2,r3,r4,new_prog,old_prog):counter_machine) :(counter_machine) =
  match new_prog with
  | [] -> (r1,r2,r3,r4,new_prog,old_prog)
  | I::new_prog' -> (inc r1,r2,r3,r4,new_prog',I::old_prog)
  | D::new_prog' -> (dec r1,r2,r3,r4,new_prog',D::old_prog)
  | N::new_prog' -> (r2,r3,r4,r1,new_prog',N::old_prog)
  | T::new_prog' -> (r1,r2,r3,r4,new_prog',T::old_prog)
  | J::new_prog' ->
     if r1 = Nil then (r1,r2,r3,r4,new_prog',J::old_prog) else
     let rec scan_open ((r1,r2,r3,r4,new_prog,old_prog):counter_machine) to_skip :(counter_machine) =
       (match old_prog with
        | [] -> (r1,r2,r3,r4,new_prog,old_prog)
        | T::old_prog' -> if to_skip=0 then (r1,r2,r3,r4,new_prog,old_prog)
                          else scan_open (r1,r2,r3,r4,T::new_prog,old_prog') (to_skip-1)
        | J::old_prog' -> scan_open (r1,r2,r3,r4,J::new_prog,old_prog') (to_skip+1)
        | x::old_prog' -> scan_open (r1,r2,r3,r4,x::new_prog,old_prog') to_skip)
     in scan_open (r1,r2,r3,r4,new_prog,old_prog) 0
  | Out::new_prog' -> print_char (char_of_nat r1);(r1,r2,r3,r4,new_prog',Out::old_prog)
  | In::new_prog' -> let input = nat_of_int(int_of_string(read_line())) in
                      (input,r2,r3,r4,new_prog',In::old_prog)

(* Toplevel *)
let rec run config =
  match config with
  | (_,_,_,_,[],_) -> config
  | _ -> run (transition config)

let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []
                  
let lexer s =
  let ls = explode s in
  let rec parse_helper = function
    | [] -> []
    | '+'::xs -> I::(parse_helper xs)
    | '-'::xs -> D::(parse_helper xs)
    | '>'::xs -> N::(parse_helper xs)
    | '['::xs -> T::(parse_helper xs)
    | ']'::xs -> J::(parse_helper xs)
    | '.'::xs -> Out::(parse_helper xs)
    | ','::xs -> In::(parse_helper xs)
    | _::xs -> parse_helper xs
  in parse_helper ls

let new_config prog = (Nil,Nil,Nil,Nil,prog,[])
let run_prog prog = run (new_config prog)
let run s = run_prog (lexer s)
let run_cmd s = let _ = run_prog (lexer s) in ()

let read_file filename = 
  let lines = ref "" in
  let chan = open_in filename in
  try
    while true; do
      lines := !lines ^ input_line chan
    done; !lines
  with End_of_file ->
    close_in chan;
    !lines ;;
                
let _ =
  let file = Sys.argv.(1) in
  let program = read_file file in
  let _ =
      try
        run program
      with e -> exit 1
  in exit 0
