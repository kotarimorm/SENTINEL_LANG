# Sentinel Lang Full Specification

**Version:** `v0.6-alpha`  
**Status:** Experimental alpha  
**Milestone:** Core Language Completion  
**Specification snapshot:** `2026-09-01`  
**Main target:** `x64`  
**Secondary target:** `x16` boot sectors  
**Primary backend:** NASM assembly / flat binary  
**Compiler backend:** Private experimental compiler  
**Current focus:** function-local temporary values, explicit step data flow, semantic hardening, and stable x64 code generation

---

# 1. What Sentinel Is

Sentinel Lang is an experimental low-level systems programming language designed primarily for OS development.

It is intended for:

- OSDev experiments
- bootloader prototypes
- kernel prototypes
- direct hardware access
- readable low-level programs
- explicit control over program stages
- inspectable NASM output
- flat binary generation

Sentinel currently compiles through the following pipeline:

```text
.sl source
    |
    v
Lexer
    |
    v
Parser
    |
    v
AST
    |
    v
Semantic Analyzer
    |
    v
NASM Codegen
    |
    v
Optimizer
    |
    v
.asm
    |
    v
NASM
    |
    v
.bin
```

Short form:

```text
.sl -> Sentinel -> NASM -> flat binary
```

Sentinel does not attempt to hide the machine.

It provides structured syntax over low-level operations while keeping generated assembly readable and inspectable.

---

# 2. What Sentinel Is Not

Sentinel is currently not:

| Not A | Reason |
| :--- | :--- |
| Production-ready language | The language is still alpha |
| Complete C/C++ replacement | ABI, ecosystem, optimizer, and target support remain incomplete |
| Rust replacement | Full memory safety and ownership analysis are not implemented |
| Complete operating system framework | Drivers, filesystems, networking, and graphics libraries are not finished |
| Desktop application framework | Desktop development is not the current target |
| High-level scripting language | Sentinel intentionally stays close to hardware |
| Stable ABI language | The current ABI remains experimental |
| Self-hosted compiler | The compiler is currently implemented outside Sentinel |
| Complete x86 toolchain | x32 remains incomplete |
| Automatic boot-image builder | Binary composition is currently left to external tools |

Current honest description:

```text
Sentinel is a real experimental low-level language
for OSDev-oriented programs and flat binary generation.
```

---

# 3. Design Philosophy

Sentinel follows four primary rules:

```text
Be readable.
Stay close to the machine.
Reject dangerous ambiguity early.
Keep data flow explicit.
```

The language should make low-level development easier without pretending that hardware does not exist.

Sentinel programs should be:

- easier to read than raw assembly
- explicit about persistent and temporary storage
- predictable in execution order
- inspectable after code generation
- rejected before NASM when the compiler already understands the error

The goal is not:

```text
Turn OS development into ordinary application development.
```

The goal is:

```text
Make low-level experiments faster, clearer, and harder to misuse.
```

---

# 4. Version Meaning

Current version:

```text
v0.6-alpha
```

| Part | Meaning |
| :--- | :--- |
| `v0` | The language is not stable |
| `6` | Sixth alpha milestone |
| `alpha` | Breaking changes remain possible |

`v0.6-alpha` is the **Core Language Completion** milestone.

Its main additions are:

- function-local temporary values through `stand`
- explicit step transfer through `give to (N)`
- x64 stack-frame allocation for stand values
- stricter numbered-step ordering
- explicit `result expression` semantics
- improved `get` expression support
- protection against direct calls to stand-dependent steps
- strict rejection of unknown lexer tokens
- per-command x16 `lib(std)` validation
- safer function parameter mapping restoration
- removal of unsafe stand-dependent step wrappers

---

# 5. Build Pipeline

The compiler pipeline is:

```text
Source
  |
  v
Lexer
  |
  v
Parser
  |
  v
AST
  |
  v
Semantic Analyzer
  |
  v
Code Generator
  |
  v
Optimizer
  |
  v
NASM
  |
  v
Flat Binary
```

Semantic analysis occurs before code generation.

Core rule:

```text
Broken Sentinel should fail as Sentinel.
```

The compiler should not knowingly pass invalid state into NASM.

Examples of errors rejected before NASM include:

- unknown symbols
- duplicate storage
- duplicate functions
- missing steps
- calls before declaration
- invalid stand transfers
- unavailable stand values
- unsupported x16 std commands
- unknown source characters

---

# 6. Transparent Output Model

Generated assembly is intentionally readable.

Users may:

- inspect generated `.asm`
- compare Sentinel source with NASM output
- assemble the output manually
- debug the resulting binary
- inspect stack allocation
- verify register usage
- verify emitted runtime helpers

Trust boundary:

```text
Sentinel generates NASM assembly.
NASM generates machine code.
```

Sentinel currently emits flat binaries rather than ELF, PE, or another executable container.

---

# 7. Target Status

| Target | Status |
| :--- | :--- |
| `x64` | Main compiler path |
| `x16` | Working experimental boot-sector path |
| `x32` | Incomplete and deferred |

The strongest current language path is:

```sl
lib(std)
x64
type(console)
```

The confirmed x16 boot path is:

```sl
custing(silk)
lib(std)
x16
type(console)
```

---

# 8. Important Boot Limitation

Sentinel can generate:

- a working x16 BIOS boot sector
- a separate x64 flat kernel binary

However, `v0.6-alpha` does not yet provide a complete long-mode boot chain.

The current x16 bootloader does not automatically:

- load an x64 kernel from disk
- build a GDT
- build page tables
- enable protected mode
- enable long mode
- jump to the x64 kernel entry point

Therefore:

```text
Generating kernel.bin does not automatically make it bootable.
```

A future boot chain must load the x64 binary into memory and transfer control to it.

This limitation is separate from x64 language code generation.

---

# 9. Output Type

The main tested output declaration is:

```sl
type(console)
```

This selects the current console-oriented output path.

Experimental output concepts may later include:

- `type(kernel)`
- `type(raw)`
- `type(not_out)`
- framebuffer-oriented output types

These are not stable `v0.6-alpha` features.

---

# 10. Core Language Concepts

| Keyword or Concept | Meaning |
| :--- | :--- |
| `local` | Declares persistent flat storage |
| `stand` | Declares a temporary value inside one function invocation |
| `give` | Transfers a stand value to a later function step |
| `redo` | Mutates existing persistent storage or an active stand |
| `create` | Declares a function |
| `start` | Executes a function or allowed independent step |
| `get` | Executes a function and obtains its result |
| `result` | Produces the final function value |
| `lib(std)` | Enables built-in OSDev commands |
| `type(console)` | Selects console output |
| `x16`, `x32`, `x64` | Select compilation target |

---

# 11. Storage Model

Sentinel `v0.6-alpha` has two primary storage categories:

| Storage | Lifetime | Location |
| :--- | :--- | :--- |
| `local` | Entire program | Flat static storage |
| `stand` | One function invocation | x64 function stack |

This distinction is fundamental.

```text
local = persistent program state
stand = temporary function state
```

---

# 12. Persistent Storage With local

`local` declares persistent flat storage.

Example:

```sl
local counter = 0
local status = 1
```

A top-level `local` may appear before or after function declarations.

```sl
x64

local first = 10

create show()
    (1) print("show")

local second = 20

start show()
```

Both `first` and `second` belong to the same flat source-file storage model.

They are not block-scoped.

They are not automatically destroyed.

They may be accessed by functions declared in the same program.

---

# 13. Function-Local local Is Forbidden

`local` cannot be declared inside a function.

Invalid:

```sl
x64

create calculate()
    (1) local temporary = 10
```

Expected diagnostic:

```text
[SEMANTIC S011]
```

Reason:

```text
local declares persistent flat storage.
It does not declare temporary function memory.
```

Use `stand` instead:

```sl
x64

create calculate()
    (1) stand: temporary = 10
```

Use top-level `local` only when the value must persist beyond one function call.

---

# 14. Temporary Storage With stand

`stand` declares a temporary value inside a function invocation.

Syntax:

```sl
stand: name = expression
```

Example:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b
```

A stand value:

- exists only during the current function invocation
- is stored in the x64 function stack frame
- does not become global storage
- does not survive a later independent function call
- does not conflict with another invocation of the same function
- may be transferred to a later step through `give`

Current implementation:

```text
One stand value uses one 8-byte stack slot.
The complete stand frame is aligned to 16 bytes.
```

Example generated direction:

```asm
push rbp
mov  rbp, rsp
sub  rsp, 16

mov  [rbp-8], rax
```

---

# 15. stand Is Currently x64-Only

The first stand implementation uses the x64 function stack.

Valid:

```sl
x64

create test()
    (1) stand: temporary = 10
```

Invalid:

```sl
x16

create test()
    (1) stand: temporary = 10
```

Expected diagnostic:

```text
[SEMANTIC S037]
```

Current target support:

| Target | `stand` |
| :--- | :--- |
| x64 | Supported |
| x16 | Rejected |
| x32 | Rejected / deferred |

---

# 16. Explicit Transfer With give

A stand value does not silently become available everywhere.

To transfer it to a later numbered step:

```sl
stand: name = expression give to (step)
```

Example:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

Execution model:

```text
Step 1 creates temporary.
Step 1 explicitly gives temporary to step 2.
Step 2 may read temporary.
```

Without the transfer, a later step must not assume the stand exists.

---

# 17. give Rules

`give to (N)` follows these rules:

1. The target must be a numbered step in the same function.
2. The target step must exist.
3. The target must come after the source step.
4. Backward stand transfers are forbidden.
5. One give expression currently has one target.
6. The transferred stand keeps the same name.
7. Transfer does not create persistent storage.
8. Transfer applies only to the current function invocation.

Valid:

```sl
create pipeline()
    (1) stand: value = 10 give to (2)
    (2) result value
```

Invalid missing target:

```sl
create pipeline()
    (1) stand: value = 10 give to (9)
    (2) result value
```

Expected diagnostic:

```text
[SEMANTIC S034]
```

---

# 18. Multiple stand Values

A function may declare multiple stand values.

Example:

```sl
create process(a, b, c)
    (1) stand: base = a + b give to (2)
    (2) stand: doubled = base * 2 give to (3)
    (3) stand: mixed = doubled + c give to (4)
    (4) result mixed * 3
```

Each stand receives its own stack slot.

Possible generated frame:

```text
base    -> [rbp-8]
doubled -> [rbp-16]
mixed   -> [rbp-24]
```

The complete frame may be aligned to:

```text
32 bytes
```

---

# 19. stand Name Rules

Within one function:

- stand names must be unique
- stand names must not conflict with parameters
- stand names must not conflict with forbidden reserved names
- unavailable stand names cannot be used in unrelated steps

Duplicate example:

```sl
create broken()
    (1) stand: value = 10 give to (2)
    (2) stand: value = 20
```

Expected diagnostic:

```text
[SEMANTIC S033]
```

Name conflict diagnostics may use:

```text
[SEMANTIC S035]
```

---

# 20. stand Lifetime

A stand value exists for exactly one complete function invocation.

Example:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

This is valid:

```sl
local answer = get calculate(left, right)
```

This does not mean that `temporary` becomes global.

After `calculate` returns:

```text
temporary no longer exists.
```

A later call receives a new stack frame and a new temporary value.

---

# 21. Independent Step Calls and stand

A direct step call starts an independent function invocation.

Example shape:

```sl
start pipeline(2)
```

If step `(2)` requires a stand value from step `(1)`, the call is rejected.

Invalid:

```sl
x64

create pipeline()
    (1) stand: temporary = 30 give to (2)
    (2) result temporary * 2

start pipeline(2)
```

Expected diagnostic:

```text
[SEMANTIC S036]
```

Reason:

```text
The direct call starts at step 2.
Step 1 did not execute.
temporary was never created.
```

Possible fix:

```sl
start pipeline()
```

---

# 22. Step Wrapper Generation

The x64 backend may generate labels for independently callable steps.

Example:

```asm
sl_func_example_L1:
```

However, a wrapper is not emitted when a step requires incoming stand values.

Example generated message:

```asm
; step wrapper sl_func_calculate_L2 skipped:
; requires incoming stand values
```

This prevents assembly output from exposing an unsafe entry point that would read an uninitialized stack slot.

---

# 23. Numbered Function Steps

Functions use numbered steps.

```sl
create boot()
    (1) print("begin")
    (2) print("ready")
```

Step numbers must be declared in ascending order.

Valid:

```sl
create test()
    (1) print("one")
    (3) print("three")
    (8) print("eight")
```

Gaps are allowed.

Invalid:

```sl
create test()
    (2) print("two")
    (1) print("one")
```

Expected diagnostic:

```text
[SEMANTIC S031]
```

Duplicate step numbers remain invalid:

```text
[SEMANTIC S018]
```

---

# 24. Full Function Calls

A full function call executes the function from its first declared step through its final step.

```sl
start boot()
```

For a stand pipeline:

```sl
start calculate(left, right)
```

A full call:

- prepares function arguments
- creates the stack frame
- executes stand declarations
- performs step transfers
- executes the final step
- destroys the stand frame
- returns to the caller

If the function produces a result, `start` ignores the returned value.

---

# 25. Function Parameters

Function parameters are temporary input names.

Example:

```sl
create add(left, right)
    (1) result left + right
```

Current experimental x64 mapping:

| Argument | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

Parameters:

- are not persistent storage
- are not declared with `local`
- cannot be mutated directly using `redo`
- may be used to initialize stand values
- are restored as compiler symbol mappings after function generation

Invalid:

```sl
create test(value)
    (1) redo: value to value + 1
```

Expected diagnostic:

```text
[SEMANTIC S007]
```

Recommended direction:

```sl
create test(value)
    (1) stand: changed = value + 1
```

---

# 26. Parameterized Step Calls

Direct step calls on parameterized functions are blocked.

Example:

```sl
create add(a, b)
    (1) result a + b

start add(1)
```

The numeric value is interpreted as a step selector, not argument data.

Expected diagnostic:

```text
[SEMANTIC S020]
```

Reason:

```text
A direct step label does not prepare the complete function argument state.
```

To pass numeric data, use named storage:

```sl
local first = 1
local second = 2

local answer = get add(first, second)
```

---

# 27. Function Declaration Order

Functions must be declared before use.

Valid:

```sl
create boot()
    (1) print("boot")

start boot()
```

Invalid:

```sl
start boot()

create boot()
    (1) print("boot")
```

Expected diagnostic:

```text
[SEMANTIC S027]
```

This rule applies to:

- `start`
- `get`
- function calls inside other functions

Sentinel does not currently perform hidden forward function resolution.

---

# 28. result

`result` produces the final value of a function.

Syntax:

```sl
result expression
```

Example:

```sl
create add(a, b)
    (1) result a + b
```

The result is generated into:

```asm
rax
```

Current rules:

1. `result` may only appear inside a function.
2. `result` must be in the final function step.
3. `result` must be the final statement of that step.
4. Code after `result` is forbidden.
5. A function used with `get` must contain a result.

Top-level result is invalid:

```sl
result 10
```

Expected diagnostic:

```text
[SEMANTIC S029]
```

Incorrect result position produces:

```text
[SEMANTIC S030]
```

---

# 29. get

`get` executes a function and obtains its returned value.

Canonical syntax:

```sl
get function(arguments)
```

Example:

```sl
create calculate(a, b)
    (1) result (a + b) * 2

local left = 10
local right = 20
local answer = get calculate(left, right)
```

Generated direction:

```asm
call sl_func_calculate
mov  [sl_var_answer], rax
```

Calling `get` on a function without `result` is invalid.

Expected diagnostic:

```text
[SEMANTIC S028]
```

`get` also follows:

- declaration-order checks
- argument-count checks
- parameter register rules
- stand frame lifetime rules

---

# 30. start Versus get

| Operation | Purpose |
| :--- | :--- |
| `start function()` | Execute function for side effects |
| `get function()` | Execute function and keep returned value |

Example side-effect function:

```sl
create show()
    (1) vga_print("online")

start show()
```

Example value function:

```sl
create calculate(a, b)
    (1) result a + b

local answer = get calculate(left, right)
```

Using `start` on a value function is allowed, but its result is ignored.

Using `get` on a function without `result` is rejected.

---

# 31. Mutation With redo

`redo` mutates existing storage.

Persistent storage:

```sl
local counter = 0

redo: counter to counter + 1
```

Active stand storage may also be mutated when the stand is available in the current step.

General form:

```sl
redo: name to expression
```

Arithmetic examples:

```sl
redo: value to value + 1
redo: value to value - 1
redo: value to value * 2
redo: value to value / 2
```

Bitwise examples:

```sl
redo: flags bit_and 1
redo: flags bit_or 2
redo: flags bit_xor 4
```

Shift examples:

```sl
redo: mask shift_left 3
redo: mask shift_right 1
```

Unknown mutation targets produce:

```text
[SEMANTIC S008]
```

---

# 32. Shift Code Generation

x86/x64 shift counts may use:

- an immediate value
- the `cl` register

Valid:

```asm
shl rbx, 3
```

```asm
shl rbx, cl
```

Invalid:

```asm
shl rbx, rax
```

Sentinel converts dynamic shift values through `rcx/cl`.

This behavior was hardened during the Kernel Beast validation path.

---

# 33. Conditions

Basic conditional:

```sl
if condition then
    statement
end
```

Conditional with fallback:

```sl
if condition then
    statement
else
    statement
end
```

Example:

```sl
if answer == 195 then
    vga_print("PASSED")
else
    vga_print("FAILED")
end
```

Nested conditions are supported on the tested x64 path.

---

# 34. Loops

Current loop forms include:

```sl
while condition
    statement
end
```

and:

```sl
repeat(4)
    statement
end
```

Example:

```sl
local counter = 0

while counter < 4
    redo: counter to counter + 1
end
```

Current loop control keywords include:

```sl
break
skip
```

Complex nested loop label behavior remains experimental.

---

# 35. Arrays

Basic arrays and indexing are supported.

```sl
local index = 0
local values = [10, 20, 30]
local selected = 0

redo: selected to values[index]
```

Current limitations:

- no bounds checking
- no complete dynamic allocation model
- elements currently follow backend-sized storage assumptions
- advanced array typing is not stable

---

# 36. lib(std)

`lib(std)` enables built-in OSDev commands.

Example:

```sl
lib(std)
x64
type(console)
```

`std` now has different support levels by target.

| Target | Status |
| :--- | :--- |
| x64 | Main implementation |
| x16 | Minimal bootloader subset |
| x32 | Rejected |

Unknown libraries produce:

```text
[SEMANTIC S021]
```

Using std commands without `lib(std)` produces:

```text
[SEMANTIC S022]
```

---

# 37. x64 std Commands

Current x64 commands:

| Command | Kind | Purpose |
| :--- | :--- | :--- |
| `vga_print(value)` | Statement | Print through VGA text output |
| `vga_clear()` | Statement | Clear VGA text output |
| `halt()` | Statement | Emit a safe halt loop |
| `nop()` | Statement | Emit `nop` |
| `panic(value)` | Statement | Print panic information and halt |
| `io_wait()` | Statement | Perform a short I/O delay |
| `read_port(port)` | Expression | Read one byte from an I/O port |
| `write_port(port, value)` | Statement | Write one byte to an I/O port |
| `pic_eoi()` | Statement | Send PIC end-of-interrupt |
| `irq_disable()` | Statement | Emit `cli` |
| `irq_enable()` | Statement | Emit `sti` |

Wrong argument counts produce:

```text
[SEMANTIC S024]
```

---

# 38. x16 std Subset

The x16 backend supports a deliberately small std subset:

```text
halt
nop
vga_clear
vga_print
```

Example:

```sl
custing(silk)
lib(std)
x16
type(console)

create boot()
    (1) vga_clear()
    (2) vga_print("Sentinel online")

start boot()
halt()
```

This path has produced a 512-byte boot sector and displayed Sentinel output in QEMU.

Unsupported x16 command:

```sl
custing(silk)
lib(std)
x16

write_port(0x20, 0x20)
```

Expected diagnostic:

```text
[SEMANTIC S026]
```

The compiler rejects the operation before x64 registers can accidentally appear in `BITS 16` assembly.

---

# 39. VGA Text Helpers

Current helpers:

```sl
vga_clear()
vga_print(value)
```

x16 behavior:

- `vga_clear()` uses BIOS video services
- `vga_print()` uses BIOS teletype output

x64 behavior:

- `vga_clear()` writes to VGA text memory
- `vga_print()` writes characters and attributes to `0xB8000`

The x64 printer tracks:

```text
sl_vga_row
sl_vga_col
```

Current output is text mode, not a complete pixel framebuffer API.

Commands such as the following do not yet exist:

```text
vga_pixel
vga_line
framebuffer_blit
double_buffer_swap
```

---

# 40. Port I/O

`read_port(port)` is an expression.

```sl
lib(std)
x64

local keyboard_port = 0x60
local key = 0

redo: key to read_port(keyboard_port)
```

`write_port(port, value)` is a statement.

```sl
lib(std)
x64

write_port(0x20, 0x20)
```

Current x64 preservation behavior includes protection for registers used internally by port helpers.

Port I/O is unavailable through the x16 std subset in `v0.6-alpha`.

Programmers requiring unsupported x16 instructions may use `low-code`, but must understand the generated machine behavior.

---

# 41. IRQ Helpers

Current IRQ-related commands:

```sl
irq_disable()
irq_enable()
pic_eoi()
```

Expected instruction direction:

```asm
cli
sti
out dx, al
```

These helpers do not create a complete interrupt subsystem.

Sentinel does not yet automatically provide:

- IDT generation
- ISR wrappers
- IRQ routing
- interrupt stack management
- APIC support
- exception decoding

---

# 42. x16 Bootloader Path

A boot-sector program starts with:

```sl
custing(silk)
lib(std)
x16
type(console)
```

The generated assembly uses:

```asm
BITS 16
ORG 0x7C00
```

A bootloader build includes:

```asm
times 510-($-$$) db 0
dw 0xAA55
```

Confirmed behavior:

```text
Generated binary size: 512 bytes
QEMU BIOS execution: working
VGA/BIOS text output: working
```

`custing(silk)` currently marks the source as bootloader-oriented output.

The exact future meaning of `custing` may change.

---

# 43. No receive/give File Protocol

The old experimental inter-file protocol using concepts such as:

```sl
give("kernel.sl")
receive("bootloader.sl")
x16 goto x32
```

is not part of `v0.6-alpha`.

It was removed.

The `give` keyword now belongs exclusively to stand transfer:

```sl
stand: value = expression give to (2)
```

A future real boot chain should operate through:

- disk reads
- memory placement
- processor mode transitions
- page tables
- an explicit jump to the kernel entry point

The kernel should not need to declare the source filename from which control arrived.

---

# 44. low-code

`low-code` is the current escape path for operations not represented by high-level Sentinel syntax.

Example:

```sl
create boot()
    (1) low-code:
            cli
            halt
```

Current status:

```text
Experimental and intentionally unsafe.
```

The programmer is responsible for:

- correct instruction encoding
- correct target mode
- correct register behavior
- stack preservation
- control-flow safety

Semantic guarantees cannot fully protect arbitrary low-code blocks.

---

# 45. Unknown Tokens

Unknown characters are rejected by the parser.

Invalid:

```sl
x64

local value = 10 @ 20
```

Expected behavior:

```text
[PARSE ERROR] Unknown character `@`
```

Earlier compiler paths could silently skip unknown tokens.

`v0.6-alpha` treats silent token loss as unsafe and rejects it.

---

# 46. Semantic Diagnostics

Current diagnostics include:

| Code | Meaning |
| :--- | :--- |
| `S001` | Reserved keyword used as a name |
| `S002` | Duplicate function |
| `S003` | Duplicate persistent storage |
| `S004` | Duplicate parameter |
| `S005` | Parameter conflicts with storage |
| `S006` | Reserved legacy diagnostic slot |
| `S007` | Parameter mutated directly |
| `S008` | Unknown mutation target |
| `S009` | Unknown function |
| `S010` | Recursive call unsupported |
| `S011` | Function-local `local` blocked |
| `S012` | Missing function step |
| `S013` | Invalid redo target |
| `S014` | Storage conflicts with function |
| `S015` | Unknown storage symbol |
| `S016` | Arguments mixed with step selectors |
| `S017` | Wrong function argument count |
| `S018` | Duplicate numbered step |
| `S019` | FREERAM target does not exist |
| `S020` | Unsafe parameterized step call |
| `S021` | Unknown library |
| `S022` | std used without `lib(std)` |
| `S023` | Unknown std command |
| `S024` | Wrong std argument count |
| `S025` | Reserved legacy port diagnostic slot |
| `S026` | std operation unsupported by target |
| `S027` | Function called before declaration |
| `S028` | `get` used on function without result |
| `S029` | `result` used outside a function |
| `S030` | `result` is not the final statement |
| `S031` | Function steps are not ascending |
| `S032` | Invalid stand declaration position |
| `S033` | Duplicate stand name |
| `S034` | Missing or invalid stand target step |
| `S035` | Stand name conflict |
| `S036` | Stand unavailable or required by direct step |
| `S037` | stand used outside x64 |

Exact wording may evolve during alpha development.

Diagnostic meaning should remain stable within the `v0.6-alpha` release line.

---

# 47. Stand Beast Test

The Stand Beast Test is the primary `v0.6-alpha` language validation program.

```sl
lib(std)
x64
type(console)

create stand_beast(a, b, c)
    (1) stand: base = a + b give to (2)
    (2) stand: doubled = base * 2 give to (3)
    (3) stand: mixed = doubled + c give to (4)
    (4) result mixed * 3

local first = 10
local second = 20
local third = 5

local answer = get stand_beast(first, second, third)

if answer == 195 then
    vga_print("STAND BEAST PASSED")
else
    vga_print("STAND BEAST FAILED")
end

halt()
```

Expected calculation:

```text
base = 10 + 20
base = 30

doubled = 30 * 2
doubled = 60

mixed = 60 + 5
mixed = 65

result = 65 * 3
result = 195
```

Confirmed compiler behavior:

- source tokenization succeeds
- parsing succeeds
- semantic analysis succeeds
- three stand slots are allocated
- frame size is aligned to 32 bytes
- result is returned through `rax`
- result is stored in persistent `answer`
- stand-dependent wrappers are omitted
- NASM assembly succeeds
- flat x64 binary generation succeeds

Running the x64 result directly in QEMU still requires a real long-mode boot chain.

---

# 48. Kernel Beast Test

The Kernel Beast Test remains the primary large `v0.5-alpha` regression test.

It covers:

- x64 code generation
- `lib(std)`
- VGA output
- IRQ helpers
- PIC helpers
- port I/O
- arrays
- indexing
- loops
- nested conditions
- function calls
- six-argument register pressure
- bitwise operations
- shift operations
- kernel-style sequencing

Result:

```text
Passed
```

Its purpose in `v0.6-alpha` is regression protection.

The Stand Beast extends coverage to the new temporary function storage model.

---

# 49. Current Safety Model

Sentinel currently provides compile-time protection against several classes of mistakes:

- unknown storage
- duplicate storage
- unknown functions
- calls before declarations
- duplicate function steps
- missing step selectors
- unsupported direct step calls
- invalid stand transfers
- unavailable stand values
- unsupported target-specific std commands
- unknown lexer characters

Sentinel does not yet provide complete protection against:

- memory corruption
- invalid pointers
- array out-of-bounds access
- incorrect hardware addresses
- race conditions
- interrupt reentrancy
- stack overflow
- invalid low-code
- incorrect device programming
- ABI mismatches with external binaries

Current safety principle:

```text
Reject what the compiler can prove is structurally unsafe.
Do not pretend unimplemented safety already exists.
```

---

# 50. Current Limitations

| Area | Limitation |
| :--- | :--- |
| x64 boot | No complete long-mode boot chain |
| x32 | Backend incomplete |
| x16 | Small std subset only |
| `stand` | x64-only |
| Stand types | Automatic scalar-sized storage only |
| Type system | Incomplete |
| Memory safety | Incomplete |
| Recursion | Unsupported |
| Function-local `local` | Forbidden; use `stand` |
| Function arguments | First six x64 register arguments only |
| Strings | No complete string runtime |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | Experimental |
| Optimizer | Basic |
| ABI | Experimental |
| Graphics | VGA text helpers only |
| Filesystems | Not implemented |
| Networking | Not implemented |
| Drivers | No complete driver framework |
| Libraries | Only built-in `std` is currently available |
| Self-hosting | Not implemented |

---

# 51. Migration From v0.5-alpha

Important changes:

## Temporary function values

Old situation:

```sl
create calculate()
    (1) local temporary = 10
```

This remains invalid.

New solution:

```sl
create calculate()
    (1) stand: temporary = 10
```

## Step transfer

New explicit form:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

## Function results

Preferred `v0.6-alpha` form:

```sl
create calculate(a, b)
    (1) result a + b

local answer = get calculate(left, right)
```

## x16 std

The old statement:

```text
lib(std) is x64-only
```

is no longer correct.

The correct rule is:

```text
x64 has the main std implementation.
x16 has a minimal command subset.
x32 remains unsupported.
```

## Removed file protocol

Remove obsolete code such as:

```sl
receive("bootloader.sl")
```

No replacement declaration is required.

---

# 52. Roadmap

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 compiler core |
| `v0.3-alpha` | Completed | Semantic diagnostics and core hardening |
| `v0.4-alpha-stable` | Completed | First built-in OSDev std commands |
| `v0.5-alpha` | Completed | Kernel Toolkit Preview and Kernel Beast |
| `v0.6-alpha` | Current | Core Language Completion and stand/give |
| `v0.6.1-alpha` | Planned | Library ecosystem foundation and v0.6 fixes |
| `v0.7-alpha` | Planned | x32 backend work and optimizer foundation |
| `v0.7.1-alpha` | Planned | Advanced Targeted Output Pruning |
| `v0.8-alpha` | Planned | Tooling, playground, and developer experience |
| `v0.9-beta` | Planned | Stability, tests, ABI, and documentation hardening |
| `v1.0-beta` | Future | Stable experimental OSDev-first platform |

The roadmap may change when compiler architecture reveals a more important dependency.

---

# 53. v0.6.1-alpha Direction

Possible `v0.6.1-alpha` work:

- fixes discovered after stand/give release
- Library Authoring Specification
- `sentinel-lib.json`
- one library per repository
- library version compatibility metadata
- unsafe capability declarations
- static Library Hub prototype
- Official / Approved / Community statuses
- one large library integration example

Potential future library families include:

```text
graphics
files
BTK
syler
```

These libraries are architectural directions, not current built-in features.

---

# 54. v0.7-alpha Direction

`v0.7-alpha` is expected to focus on:

- x32 backend repair
- target-specific register correctness
- target-specific expression codegen
- smaller generated assembly
- basic helper pruning
- string deduplication
- stack-operation cleanup
- unused wrapper removal
- stronger optimizer structure

`v0.7.1-alpha` may introduce:

```text
TOP = Targeted Output Pruning
```

Potential TOP responsibilities:

- remove unused runtime helpers
- remove unreachable function-step wrappers
- merge duplicate string constants
- remove unnecessary labels
- eliminate redundant stack operations
- simplify generated control flow

---

# 55. Requirements for Real Graphics

A real pseudo-3D Sentinel demonstration requires more than VGA text printing.

Minimum future graphics layer:

```text
pixel(x, y, color)
line(x1, y1, x2, y2, color)
clear(color)
present()
```

Minimum 3D pipeline:

```text
3D vertices
    |
    v
Fixed-point rotation
    |
    v
Perspective projection
    |
    v
Screen clipping
    |
    v
Line rasterization
    |
    v
Framebuffer
```

Additional requirements:

- graphics mode established before x64 execution
- framebuffer address
- width, height, and pitch information
- keyboard input
- frame timing
- optional double buffering
- fixed-point or floating-point math support

A rotating cube would demonstrate serious compiler capability, but would not alone prove production maturity.

---

# 56. Final Position

Sentinel remains experimental alpha software.

It is not yet:

- production-ready
- a complete OS framework
- a mature C/C++ replacement
- a complete boot environment
- a complete graphics platform

However, Sentinel now has:

- a real lexer, parser, and AST
- semantic diagnostics before NASM
- working x64 flat binary generation
- working x16 BIOS boot-sector generation
- a minimal x16 std subset
- a larger x64 std implementation
- persistent flat storage through `local`
- temporary function storage through `stand`
- explicit step data flow through `give`
- explicit function values through `result`
- function result retrieval through `get`
- stack-frame allocation and cleanup
- strict function declaration ordering
- target-specific command validation
- passed Kernel Beast regression testing
- passed Stand Beast compilation testing

Current honest description:

```text
Sentinel is no longer only a syntax experiment.

It is an experimental OSDev-first compiler with a working
x64 language core, a working x16 boot-sector path, explicit
temporary function storage, semantic diagnostics, readable
NASM output, and a clear route toward complete kernel execution.
```
