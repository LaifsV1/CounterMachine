# C4: A 4-Counter Machine Language
Here is an interpreter (or emulator) for a 4-counter machine language I
call `C4`. It's based on [BF](https://en.wikipedia.org/wiki/Brainfuck) syntax. The interpreter is written in OCaml.

Given two counters can emulate a stack of 1s and 0s, four counters are
capable of emulating a Turing Machine with alphabet `{0,1}`. Two counters 
are actually enough to be Turing Complete, done by simulating four
counters using two, but that would make programming very hard.

## Compiling the C4 interpreter

    ocamlc C4.ml -o c4

## Usage
The following executes a given file:

    ./c4 <file_name>

Programs are text files written in `C4`. Characters that are not
commands will be ignored. Only `>`,`+`,`-`,`[`,`]`,`.` and `,` are
recognised as commands. Sample programs are provided in `/programs`.

## C4 Syntax
The following commands are available:
- `>` next register (starting at `r1`, it loops from `r4` to `r1`)
- `+` increment current register indefinitely
- `-` decrement current register up to 0
- `[` jump target
- `]` jumps to matching `[` if current register is not zero
- `.` prints ASCII value of current register up to 127 (>127 = 127)
- `,` waits for user to input an integer into current register (>=0)

Internally, the interpreter implements an abstract machine for the
4-counter machine. The abstract machine has configurations 
`(r1,r2,r3,r4,s1,s2)` which contain four counters and 2 program
stacks that contain the commands to run. Counters hold a natural number
of arbitrary size. Transitions implement the semantics described above.

I do no error handling, so expect the interpreter to crash on I/O.

### Sample Program: HELLO WORLD!

    ++++++++>+++++++++[->>>[->>+>+>]>>>[->+>>>]
	>>]>.---.+++++++..+++.+[-->+>>>]>--------.[-
	>++>>>]>+++++++++++++++.--------.+++.------.
	--------.[-->+>>>]>-.
