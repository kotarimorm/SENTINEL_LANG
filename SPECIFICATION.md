
# Sentinel Lang Specification

**Version:** `v0.4-alpha-stable`
**Status:** Experimental alpha  
**Main target:** OSDev / kernels / bootloaders / low-level systems code  
**Primary backend:** NASM assembly / flat binary  
**Compiler status:** Private experimental compiler  
**Current focus:** First `lib(std)` OSDev command pack

---

# 1. What Sentinel Is

Sentinel Lang is an experimental low-level systems programming language.

It is designed for:

- bootloader experiments
- kernel prototypes
- OSDev learning
- direct hardware-oriented code generation
- readable low-level programs
- explicit NASM-style output

Sentinel is not trying to hide the machine.

It provides a cleaner syntax over low-level ideas while still keeping the generated code understandable.

```text
Sentinel source
      │
      ▼
Lexer / Parser / AST
      │
      ▼
Semantic Analyzer
      │
      ▼
NASM Codegen
      │
      ▼
Flat binary
```

Short version:

```text
.sl -> Sentinel compiler -> NASM -> .bin
```

---

# 2. What Sentinel Is Not

Sentinel `v0.3-alpha` is currently not:

| Not A | Reason |
| :--- | :--- |
| Production language | Still alpha |
| C/C++ replacement | Core semantics are still evolving |
| Rust replacement | Full memory safety is not implemented |
| Full OS framework | OSDev libraries are planned later |
| Desktop app framework | Desktop libraries are future work |
| Full inline ASM system | `low-code` is limited |
| Garbage-collected language | No GC model |
| High-level scripting language | The design stays close to hardware |
| Stable ABI language | ABI is experimental |
| Full standard library ecosystem | `lib(std)` is planned for v0.4-alpha |

Sentinel is currently best understood as:

```text
Readable low-level language for OSDev experiments.
```

---

# 3. Design Philosophy

Sentinel follows a simple rule:

> Be readable, but stay close to the machine.

The language should make low-level programming easier to write, but not hide what the generated code does.

Sentinel code should feel more structured than raw assembly, but still obvious enough that the programmer can understand the generated NASM.

The goal is not to turn OSDev into web development.

The goal is to make OSDev faster, cleaner, and less painful.

---

# 4. Version Meaning

Current version:

```text
v0.4-alpha-stable
```

Meaning:

| Part | Meaning |
| :--- | :--- |
| `v0` | Language is not stable yet |
| `4` | Fourth alpha milestone |
| `alpha-stable` | Stable alpha milestone after passed tests |

`v0.4-alpha-stable` iis focused on the first built-in OSDev helper library:

It does not introduce large libraries yet.

---

# 5. v0.4-alpha-stable Main Goal

The main goal of `v0.4-alpha-stable` is:

```text
Add the first clean OSDev helper layer.
Keep std small and explicit.
Keep invalid std usage rejected before NASM.
```

This version builds on `v0.3-alpha`.

`v0.3-alpha` focused on core hardening and semantic diagnostics.

`v0.4-alpha-stable` adds the first working library command pack:

```sl
lib(std)
```

This release focuses on:

- library declaration parsing
- std command parsing
- std semantic validation
- x64-only std protection
- VGA helpers
- port I/O helpers
- IRQ helpers
- read/write port support
- std stress testing

---

# 6. File Extension

Sentinel source files use:

```text
.sl
```

Example:

```text
bootloader.sl
kernel.sl
main.sl
```

---

# 7. Compilation Pipeline

The compiler pipeline is:

```text
Source text
    │
    ▼
Lexer
    │
    ▼
Tokens
    │
    ▼
Parser
    │
    ▼
AST
    │
    ▼
Semantic Analyzer
    │
    ▼
Code Generator
    │
    ▼
NASM assembly
    │
    ▼
NASM
    │
    ▼
Flat binary
```

The semantic analyzer is important in `v0.3-alpha`.

It catches Sentinel-level errors before NASM sees broken assembly.

---

# 8. Output Model

Sentinel currently generates:

| Output | Status |
| :--- | :--- |
| NASM assembly | Working |
| Flat binary | Working |
| ELF | Not stable |
| PE | Not supported |
| Object files | Not current focus |
| Self-hosted compiler | Future |

The current compiler flow uses NASM flat binary output.

```text
nasm -f bin file.asm -o file.bin
```

---

# 9. Architecture Modes

Sentinel supports architecture mode declarations.

```sl
x16
x32
x64
```

## 9.1 x16

```sl
x16
```

Target:

- BIOS bootloader experiments
- 16-bit real mode
- boot sector style output

Current status:

| Feature | Status |
| :--- | :--- |
| Basic x16 output | Working |
| Boot signature output | Working |
| BIOS text printing | Working |
| Full x16 OS runtime | Not complete |

Example boot style:

```sl
custing(silk)
x16

local msg = "Hello from Bootloader!"

create boot()
    (1) print(msg)
    (2) low-code:
            cli
            halt

start boot()
```

Expected output style:

```asm
BITS 16
ORG 0x7C00

times 510-($-$$) db 0
dw 0xAA55
```

## 9.2 x32

```sl
x32
```

Target:

- protected mode experiments
- future kernel transition work

Current status:

```text
Experimental / not main tested path.
```

## 9.3 x64

```sl
x64
```

Target:

- modern kernel experiments
- main compiler testing
- VGA text output
- function calls
- arrays
- loops
- semantic hardening

Current strongest path:

```text
x64 + type(console)
```

---

# 10. Output Type

Sentinel supports output type declarations.

Current stable path:

```sl
type(console)
```

## 10.1 type(console)

```sl
type(console)
```

Means:

- console-style output is enabled
- x64 target uses VGA text output
- x16 target uses BIOS text output

Example:

```sl
x64
type(console)

console_print("hello")
```
# 10.1 lib(std)

Sentinel `v0.4-alpha-stable` introduces the first built-in OSDev helper library:

```sl
lib(std)
```

Example:

```sl
lib(std)
x64
type(console)

vga_print("std online")
halt()
```

`lib(std)` is currently x64-only.

Invalid:

```sl
lib(std)
x16

halt()
```

Semantic error:

```text
[SEMANTIC S026] `lib(std)` currently supports x64 mode only in v0.4-alpha.
```

`lib(std)` is not a DLL system.

It is not a runtime package manager.

It is a compile-time Sentinel command pack that unlocks built-in OSDev helpers.

## 10.2 Planned Types

Future types may include:

```sl
type(kernel)
type(raw)
type(not_out)
```

Possible meaning:

| Type | Meaning |
| :--- | :--- |
| `type(kernel)` | Kernel-oriented output mode |
| `type(raw)` | No default output helpers |
| `type(not_out)` | No console output support |

These are planned ideas, not stable `v0.3-alpha` features.

## 10.3 Not Planned As Separate Type

These are not expected to be separate core types:

```text
type(driver)
type(network)
type(app)
type(service)
type(library)
```

Drivers, networking, and libraries should be handled through Sentinel code and libraries, not special compiler modes.

---

# 11. Comments

Sentinel supports comments using double dots:

```sl
.. this is a comment ..
```

Comments can be used for documentation and notes.

Example:

```sl
.. boot state ..
local boot_stage = 0
```

---

# 12. Core Language Model

Sentinel `v0.3-alpha` uses a flat storage model.

This is intentional.

Sentinel does not currently behave like a classical scoped language.

Core rules:

```text
local = declare storage
redo  = mutate existing storage
create = declare function
start = call function or function step
get = call function and read result path
```

---

# 13. Flat Storage Model

Sentinel storage is flat at the source-file level.

Example:

```sl
local counter = 0
```

This declares one storage symbol:

```asm
sl_var_counter dq 0
```

Current rule:

```text
A storage name must be unique in one Sentinel source file.
```

This means the following is invalid:

```sl
local a = 10
local a = 20
```

Semantic error:

```text
[SEMANTIC S003] Storage `a` already exists.
```

---

# 14. Why Flat Storage Exists

Sentinel is not trying to copy C, Python, Lua, Rust, or JavaScript scoping.

In Sentinel, storage is closer to a named low-level memory cell.

This makes low-level output easier to understand:

```sl
local boot_stage = 0
redo: boot_stage to boot_stage + 1
```

Generated idea:

```asm
sl_var_boot_stage dq 0
mov [sl_var_boot_stage], rax
```

The programmer should know what storage exists.

---

# 15. Local Declaration

Syntax:

```sl
local name = value
```

Examples:

```sl
local a = 10
local b = 20
local ready = 0
local message = "hello"
```

`local` declares storage.

It does not mean “temporary local variable” in the classical scoped-language sense.

---

# 16. Local Types

Sentinel parser currently recognizes type hints.

Examples:

```sl
local a int = 10
local b int64 = 20
local ok bool = true
local name str = "kernel"
```

Supported type hint names:

```text
int
int8
int16
int32
int64
float
str
bool
```

Current status:

```text
Type checking is incomplete.
```

Type hints exist syntactically, but full semantic type enforcement is future work.

---

# 17. Mutation With redo

Syntax:

```sl
redo: name to expression
```

Example:

```sl
local counter = 0

redo: counter to counter + 1
```

`redo` modifies existing storage.

It cannot create storage.

Invalid:

```sl
redo: missing to 1
```

Semantic error:

```text
[SEMANTIC S008] Cannot modify unknown storage `missing`.
```

---

# 18. redo Operators

Supported mutation forms include:

```sl
redo: x to value
redo: x buff value
redo: x shift_left value
redo: x shift_right value
redo: x bit_and value
redo: x bit_or value
redo: x bit_xor value
```

Internal operator mapping:

| Sentinel | Meaning |
| :--- | :--- |
| `to` | assignment |
| `buff` | addition-style mutation |
| `shift_left` | bit shift left |
| `shift_right` | bit shift right |
| `bit_and` | bitwise AND |
| `bit_or` | bitwise OR |
| `bit_xor` | bitwise XOR |

---

# 19. Values

Supported literal values include:

```sl
10
0xFF
0b1010
3.14
"hello"
true
false
null
```

Current strongest value support:

| Value | Status |
| :--- | :--- |
| Integer | Working |
| Hex integer | Working |
| Binary integer | Working |
| Float | Parsed / experimental |
| String | Working for output/storage |
| Bool | Parsed |
| Null | Parsed |

---

# 20. Identifiers

Identifiers can contain:

```text
letters
digits
underscore
```

Examples:

```sl
local boot_stage = 0
local irq_count = 0
local memory_ready = 1
```

Recommended style:

```text
snake_case
```

Good:

```sl
local boot_stage = 0
local memory_ready = 0
local irq_counter = 0
```

Bad:

```sl
local x = 0
local thing = 0
local aaa = 0
```

Short names are allowed, but large Sentinel programs are easier to maintain with explicit names.

---

# 21. Reserved Names

Reserved names cannot be used as storage, function, or parameter names.

Examples of reserved words:

```text
local
redo
create
start
get
result
use
struct
if
then
else
end
while
repeat
break
skip
try
catch
to
buff
true
false
null
x16
x32
x64
console_print
FREERAM
type
todo
```

Invalid:

```sl
local while = 10
```

Semantic error:

```text
[SEMANTIC S001] Cannot use reserved keyword `while` as storage name.
```

---

# 22. Arrays

Array syntax:

```sl
local values = [1, 2, 3]
```

Array indexing:

```sl
local first = values[0]
local second = values[1]
```

Variable indexing is supported:

```sl
local index = 2
local value = values[index]
```

Current status:

| Feature | Status |
| :--- | :--- |
| Numeric arrays | Working |
| Literal indexing | Working |
| Variable indexing | Working |
| Bounds checking | Not implemented |
| Nested arrays | Not stable |

---

# 23. Expressions

Sentinel supports numeric expressions.

Examples:

```sl
local a = 10 + 5
local b = a - 3
local c = a * b
local d = c / 2
local e = c % 2
```

Comparison expressions:

```sl
a == b
a != b
a > b
a < b
a >= b
a <= b
```

Logical operators:

```sl
and
or
not
```

Current strongest path:

```text
Integer arithmetic and numeric comparisons.
```

---

# 24. If Statements

Syntax:

```sl
if condition then
    statement
end
```

Example:

```sl
local health = 100

if health == 100 then
    console_print("health ok")
end
```

Nested example:

```sl
if console_ready == 1 then
    if memory_ready == 1 then
        console_print("system ready")
    end
end
```

Current status:

| Feature | Status |
| :--- | :--- |
| Numeric conditions | Working |
| Nested if | Working |
| Else block | Working |
| Boolean type checking | Incomplete |

---

# 25. Else Statements

Syntax:

```sl
if condition then
    statement
else
    statement
end
```

Example:

```sl
if boot_stage == 4 then
    console_print("boot complete")
else
    console_print("boot incomplete")
end
```

---

# 26. While Loops

Syntax:

```sl
while condition
    statement
end
```

Example:

```sl
local counter = 0

while counter < 5
    redo: counter to counter + 1
end
```

Current status:

```text
Working for numeric loop conditions.
```

---

# 27. Repeat Loops

Syntax:

```sl
repeat(count)
    statement
end
```

Example:

```sl
local counter = 0

repeat(3)
    redo: counter to counter + 1
end
```

Variable count:

```sl
local limit = 3
local score = 0

repeat(limit)
    redo: score to score + 10
end
```

Current status:

| Repeat Count | Status |
| :--- | :--- |
| Literal count | Working |
| Variable count | Working |
| Complex expression count | Experimental |

---

# 28. Break and Skip

Sentinel recognizes:

```sl
break
skip
```

Current status:

```text
Parsed, but runtime behavior is limited/experimental.
```

---

# 29. Functions

Function declaration syntax:

```sl
create name()
    (1) statement
    (2) statement
```

Example:

```sl
create boot_console()
    (1) console_print("console begin")
    (2) redo: console_ready to 1
```

Functions use numbered steps.

---

# 30. Function Steps

Sentinel functions are step-based.

Example:

```sl
create boot_sequence()
    (1) console_print("cpu")
    (2) console_print("memory")
    (3) console_print("drivers")
    (4) console_print("done")
```

Each step has a number.

Step numbers must be unique inside the function.

Invalid:

```sl
create test()
    (1) console_print("a")
    (1) console_print("b")
```

Semantic error:

```text
[SEMANTIC S018] Function `test` already has step `(1)`.
```

---

# 31. Why Steps Exist

Steps are useful for OSDev-style programs.

Boot and kernel code often follows explicit stages:

```text
1. clear screen
2. initialize memory
3. initialize interrupts
4. initialize scheduler
5. start kernel loop
```

Sentinel represents this directly:

```sl
create kernel_boot()
    (1) console_print("screen")
    (2) console_print("memory")
    (3) console_print("interrupts")
    (4) console_print("scheduler")
    (5) console_print("done")
```

---

# 32. Full Function Calls

Syntax:

```sl
start function_name()
```

Example:

```sl
create boot()
    (1) console_print("boot")

start boot()
```

This calls the full function.

---

# 33. Function Step Calls

Syntax:

```sl
start function_name(step_number)
```

Example:

```sl
create debug_boot()
    (1) console_print("cpu")
    (2) console_print("memory")
    (3) console_print("drivers")

start debug_boot(2)
```

This calls only step `(2)`.

Generated idea:

```asm
call sl_func_debug_boot_L2
```

---

# 34. Step Call Validation

Sentinel `v0.3-alpha` validates requested steps.

Invalid:

```sl
create boot()
    (1) console_print("boot")

start boot(9)
```

Semantic error:

```text
[SEMANTIC S012] Function `boot` has no step `(9)`.
```

This prevents NASM errors like:

```text
symbol `sl_func_boot_L9` not defined
```

---

# 35. Function Parameters

Syntax:

```sl
create add(a, b)
    (1) redo: result_storage to a + b
```

Example:

```sl
local left = 10
local right = 20
local result_storage = 0

create add(a, b)
    (1) redo: result_storage to a + b

start add(left, right)
```

Current x64 argument registers:

| Argument | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

---

# 36. Argument Validation

Sentinel checks function argument count.

Invalid:

```sl
local a = 10

create add(x, y)
    (1) console_print("add")

start add(a)
```

Semantic error:

```text
[SEMANTIC S017] Function `add` expects 2 argument(s), got 1.
```

---

# 37. Parameters Are Temporary Inputs

Function parameters are not storage.

They are temporary input names mapped to registers.

Example:

```sl
create add(left, right)
    (1) redo: add_out to left + right
```

Here:

```text
left  = input name
right = input name
add_out = flat storage
```

The output should go into declared storage:

```sl
local add_out = 0
```

---

# 38. Parameter / Storage Conflict

A function parameter cannot conflict with existing storage.

Invalid:

```sl
local a = 10

create test(a)
    (1) console_print("bad")
```

Semantic error:

```text
[SEMANTIC S005] Parameter `a` conflicts with storage declared on line 1.
```

Recommended:

```sl
local a = 10

create test(a_input)
    (1) console_print("ok")
```

---

# 39. Duplicated Parameters

Invalid:

```sl
create add(a, a)
    (1) console_print("bad")
```

Semantic error:

```text
[SEMANTIC S004] Parameter `a` is duplicated in function `add`.
```

---

# 40. Redoing Parameters

Parameters cannot be directly mutated with `redo`.

Invalid:

```sl
create test(a)
    (1) redo: a to a + 1
```

Semantic error:

```text
[SEMANTIC S007] Cannot `redo` parameter `a` directly.
```

Correct pattern:

```sl
local test_out = 0

create test(a)
    (1) redo: test_out to a + 1
```

---

# 41. Local Inside Function

In `v0.3-alpha`, `local` inside a function is blocked.

Invalid:

```sl
create test()
    (1) local x = 10
```

Semantic error:

```text
[SEMANTIC S011] `local` inside function `test` is not allowed in v0.3-alpha flat-storage mode.
```

Reason:

```text
local allocates storage.
Function steps generate labels.
Allocating storage inside function bodies can generate duplicate NASM labels.
```

Correct pattern:

```sl
local x = 0

create test()
    (1) redo: x to 10
```

---

# 42. Unsafe Step Calls On Parameterized Functions

Step calls on functions with parameters are unsafe because step labels do not prepare argument registers.

Invalid:

```sl
local a = 10
local b = 20
local out = 0

create add(x, y)
    (1) console_print("add")
    (2) redo: out to x + y

start add(2)
```

Semantic error:

```text
[SEMANTIC S020] Cannot step-call function `add` because it has parameters.
```

Reason:

```text
Step labels do not prepare rdi/rsi/rdx/rcx/r8/r9.
Calling a step directly may use stale registers.
```

Correct:

```sl
start add(a, b)
```

Or make a no-parameter wrapper:

```sl
local a = 10
local b = 20
local out = 0

create add_wrapper()
    (1) start add(a, b)

create add(x, y)
    (1) redo: out to x + y

start add_wrapper()
```

---

# 43. Mixing Step Selectors And Arguments

In `start func(...)`, numeric literals are treated as step selectors.

Named values are treated as arguments.

Invalid mixed call:

```sl
local a = 10

create test(x)
    (1) console_print("test")

start test(1, a)
```

Semantic error:

```text
[SEMANTIC S016] `start test(...)` mixes step selectors and arguments.
```

Correct step call:

```sl
start test(1)
```

Correct argument call:

```sl
start test(a)
```

But if the function has parameters, direct step calls are blocked by `S020`.

---

# 44. Numeric Data In Function Calls

Because numeric literals in `start func(1)` mean step selectors, pass numeric data through storage.

Wrong if `5` is meant as data:

```sl
start add(5)
```

Correct:

```sl
local add_value = 5
start add(add_value)
```

This rule makes Sentinel step calls clear and predictable.

---

# 45. get ... result()

Syntax:

```sl
local output = get function_name(args) result()
```

Example:

```sl
local left = 7
local right = 8
local result_storage = 0
local call_result_value = 0

create result_add(a, b)
    (1) redo: result_storage to a + b

local call_result_value = get result_add(left, right) result()
```

Current status:

```text
Experimental.
```

`get ... result()` depends on the current generated `rax` value.

---

# 46. get Result Steps

Syntax idea:

```sl
get function_name(args) result(1)
```

Sentinel validates result steps.

Invalid:

```sl
create calc(a)
    (1) console_print("calc")

local out = get calc(a) result(9)
```

Semantic error:

```text
[SEMANTIC S012] Function `calc` has no step `(9)`.
```

For `result(...)`, fix suggestions should mention existing result steps.

---

# 47. Recursion

Direct recursion is not supported in `v0.3-alpha`.

Invalid:

```sl
create loop()
    (1) start loop()
```

Semantic error:

```text
[SEMANTIC S010] Recursive call to `loop` is not supported in v0.3-alpha.
```

Use loops instead:

```sl
while counter < limit
    redo: counter to counter + 1
end
```

---

# 48. Console Output

Sentinel supports console output.

High-level command:

```sl
console_print("hello")
```

General print command:

```sl
print(value)
```

Example:

```sl
x64
type(console)

console_print("kernel online")
```

In x64 console mode, this emits VGA text output.

---

# 49. x64 Print Register Preservation

In `v0.3-alpha`, generated x64 string print calls preserve `rsi`.

Reason:

- `rsi` is also used as the second function argument register.
- `console_print` loads string pointer into `rsi`.
- Without preservation, printing before using the second parameter destroys the argument.

Bad old pattern:

```asm
lea  rsi, [rel sl_pstr_0]
call sl_print_str

mov  rax, rsi
```

Fixed pattern:

```asm
push rsi
lea  rsi, [rel sl_pstr_0]
call sl_print_str
pop  rsi
```

This protects functions like:

```sl
local left = 10
local right = 20
local out = 0

create add(x, y)
    (1) console_print("before add")
    (2) redo: out to x + y

start add(left, right)
```

Expected result:

```text
out = 30
```

---

# 50. Low-Code Blocks

Sentinel supports low-level blocks.

Syntax:

```sl
low-code:
    emit 0x90
    emit 0x90
```

Generated NASM style:

```asm
db 0x90
db 0x90
```

Some selected commands may be supported depending on backend mode:

```sl
low-code:
    cli
    halt
```

Current stable rule:

```text
emit-based byte output is stable.
Selected low-level commands are backend-dependent.
Full raw inline assembly is not stable yet.
```

---

# 51. Bootloader Example

Example:

```sl
custing(silk)
x16

local msg = "Hello from Bootloader!"

create boot()
    (1) low-code:
            cli
            emit 0x31, 0xC0
            emit 0x8E, 0xD8
            emit 0x8E, 0xC0
            emit 0x8E, 0xD0
            emit 0xBC, 0x00, 0x7C
            sti
    (2) print(msg)
    (3) low-code:
            cli
            halt

start boot()
```

Expected target style:

```text
16-bit boot sector
ORG 0x7C00
512 bytes
0xAA55 signature
```

This is one of Sentinel’s strongest early niches.

---

# 52. try / catch

Syntax:

```sl
try
    statement
catch err
    statement
end
```

Example:

```sl
try
    console_print("try block")
catch err
    console_print("catch block")
end
```

Current status:

```text
Syntax-only.
No real exception runtime yet.
```

---

# 53. FREERAM

Syntax:

```sl
FREERAM(name)
```

Example:

```sl
local buffer = 10
FREERAM(buffer)
```

Current behavior:

```text
Experimental.
Currently clears variable storage.
```

Invalid:

```sl
FREERAM(missing)
```

Semantic error:

```text
[SEMANTIC S019] Cannot FREERAM unknown storage `missing`.
```

---

# 54. use

Syntax:

```sl
use "file.sl"
```

Current status:

```text
Parsed / future library integration path.
```

Large library system is planned for `v0.4-alpha`.

---

# 55. struct

Syntax idea:

```sl
struct Point
    x int
    y int
end
```

Current status:

```text
Parsed / experimental.
Full struct layout and codegen are not stable.
```

---

# 56. GUI Blocks

The parser has GUI block syntax support.

Example idea:

```sl
local screen = {
    "line one"
    "line two"
}
```

Current status:

```text
Experimental.
Not a main v0.3-alpha feature.
```

---

# 57. Semantic Analyzer

Sentinel `v0.3-alpha` adds a semantic analyzer.

Purpose:

```text
Catch Sentinel mistakes before NASM.
```

It checks:

- reserved names
- duplicate functions
- duplicate storage
- duplicate parameters
- parameter/storage collisions
- unknown storage
- unknown functions
- invalid redo targets
- missing function steps
- recursive calls
- invalid local inside function
- invalid argument count
- mixed step selectors and arguments
- unsafe step calls on parameterized functions
- invalid FREERAM targets

---

# 58. Semantic Error Format

Semantic errors use readable diagnostics.

General format:

```text
[SEMANTIC CODE] Line N: message
```

Example:

```text
[SEMANTIC S012] Line 8: Function `boot` has no step `(6)`.
```

Errors may include:

```text
Details:
  - extra explanation

Possible fixes:
  1. fix suggestion
  2. fix suggestion
```

---

# 59. Semantic Error Codes

Current known semantic codes:

| Code | Meaning |
| :--- | :--- |
| `S001` | Reserved keyword used as name |
| `S002` | Duplicate function |
| `S003` | Duplicate storage |
| `S004` | Duplicate function parameter |
| `S005` | Parameter conflicts with storage |
| `S006` | Reserved / legacy parameter conflict slot |
| `S007` | Cannot redo parameter directly |
| `S008` | Cannot modify unknown storage |
| `S009` | Unknown function |
| `S010` | Recursive call unsupported |
| `S011` | `local` inside function is blocked |
| `S012` | Missing function step |
| `S013` | Invalid redo target |
| `S014` | Storage conflicts with function |
| `S015` | Unknown storage symbol |
| `S016` | Mixed step selectors and arguments |
| `S017` | Wrong argument count |
| `S018` | Duplicate function step |
| `S019` | FREERAM unknown storage |
| `S020` | Unsafe step-call on parameterized function |
| `S021` | Unknown library |
| `S022` | std command/expression used without `lib(std)` |
| `S023` | Unknown std command |
| `S024` | Wrong std command argument count |
| `S025` | Reserved / legacy dynamic port restriction |
| `S026` | `lib(std)` used outside supported mode |
`S025` was used during early `write_port()` hardening.

In `v0.4-alpha-stable`, `write_port()` supports expression arguments, so `S025` is reserved / legacy.

---

# 60. Examples Of Semantic Errors

## 60.1 Unknown Function

Source:

```sl
x64
type(console)

start no_such_function()
```

Error:

```text
[SEMANTIC S009] Unknown function `no_such_function`.
```

## 60.2 Missing Step

Source:

```sl
x64
type(console)

create boot_memory()
    (1) console_print("boot memory begin")
    (2) console_print("boot memory ok")

start boot_memory(6)
```

Error:

```text
[SEMANTIC S012] Function `boot_memory` has no step `(6)`.
```

## 60.3 Duplicate Storage

Source:

```sl
x64
type(console)

local a = 10
local a = 20
```

Error:

```text
[SEMANTIC S003] Storage `a` already exists.
```

## 60.4 Unknown Storage Mutation

Source:

```sl
x64
type(console)

redo: x to 1
```

Error:

```text
[SEMANTIC S008] Cannot modify unknown storage `x`.
```

## 60.5 Local Inside Function

Source:

```sl
x64
type(console)

create test()
    (1) local x = 10
```

Error:

```text
[SEMANTIC S011] `local` inside function `test` is not allowed.
```

## 60.6 Unsafe Step Call

Source:

```sl
x64
type(console)

local a = 10
local b = 20
local out = 0

create add(x, y)
    (1) console_print("add")
    (2) redo: out to x + y

start add(2)
```

Error:

```text
[SEMANTIC S020] Cannot step-call function `add` because it has parameters.
```

---
## 60.7 Unknown Library

Source:

```sl
lib(kernel)
x64
type(console)

halt()
```

Error:

```text
[SEMANTIC S021] Unknown library `kernel`.
```

## 60.8 std Command Without lib(std)

Source:

```sl
x64
type(console)

halt()
```

Error:

```text
[SEMANTIC S022] Cannot use std command `halt` without `lib(std)`.
```

## 60.9 read_port Without lib(std)

Source:

```sl
x64
type(console)

local key = read_port(0x60)
```

Error:

```text
[SEMANTIC S022] Cannot use std expression `read_port` without `lib(std)`.
```

## 60.10 Wrong std Argument Count

Source:

```sl
lib(std)
x64
type(console)

irq_enable(1)
```

Error:

```text
[SEMANTIC S024] `irq_enable` expects 0 argument(s), got 1.
```

## 60.11 lib(std) Outside x64

Source:

```sl
lib(std)
x16

halt()
```

Error:

```text
[SEMANTIC S026] `lib(std)` currently supports x64 mode only in v0.4-alpha.
```

# 61. Valid v0.3-alpha Style

Recommended style:

```sl
x64
type(console)

local boot_stage = 0
local boot_health = 100
local console_ready = 0
local memory_ready = 0

create boot_console()
    (1) console_print("console begin")
    (2) redo: console_ready to 1
    (3) redo: boot_stage to boot_stage + 1
    (4) console_print("console ok")

create boot_memory()
    (1) console_print("memory begin")
    (2) redo: memory_ready to 1
    (3) redo: boot_health to boot_health - 1
    (4) redo: boot_stage to boot_stage + 1
    (5) console_print("memory ok")

start boot_console()
start boot_memory()

if boot_stage == 2 then
    console_print("boot stages ok")
end

if boot_health < 100 then
    console_print("health changed")
end
```

This style matches Sentinel’s flat-storage model.

---

# 62. Invalid v0.3-alpha Style

Avoid this:

```sl
create add(a, b)
    (1) local sum = a + b
```

Reason:

```text
local inside function is blocked in v0.3-alpha.
```

Use this:

```sl
local sum = 0

create add(a, b)
    (1) redo: sum to a + b
```

---

# 63. ABI Model

Current x64 ABI is internal and experimental.

Function arguments use registers:

```text
rdi, rsi, rdx, rcx, r8, r9
```

Return/result behavior:

```text
rax is used as current expression/result register.
```

Important:

```text
This is not a stable public ABI yet.
```

---

# 64. Register Safety Rules

Current known rules:

| Register | Role |
| :--- | :--- |
| `rax` | expression result |
| `rbx` | temporary arithmetic helper |
| `rdi` | first argument / print helper internal |
| `rsi` | second argument / string pointer |
| `rdx` | third argument |
| `rcx` | fourth argument / loop and VGA helper |
| `r8` | fifth argument |
| `r9` | sixth argument |

Important `v0.3-alpha` fix:

```text
Generated x64 print calls preserve rsi.
```

Future hardening should continue checking:

- `rdi` preservation when needed
- `rdx` preservation when nested calls expand
- `rcx` conflicts with loops / fourth argument
- stack consistency
- function step ABI behavior
- `rax` result reliability

---

# 65. Generated NASM Style

Sentinel generated NASM is intentionally explicit.

Example Sentinel:

```sl
local x = 10
local y = 20
local out = 0

create add(a, b)
    (1) redo: out to a + b

start add(x, y)
```

Generated style:

```asm
mov  rax, [sl_var_x]
mov  rdi, rax

mov  rax, [sl_var_y]
mov  rsi, rax

call sl_func_add
```

Function style:

```asm
sl_func_add:
    push rbp
    mov  rbp, rsp
    ; param a -> rdi
    ; param b -> rsi

.line_1:
    mov  rax, rdi
    push rax
    mov  rax, rsi
    pop  rbx
    add  rax, rbx
    mov  [sl_var_out], rax

    pop  rbp
    ret
```

Step label style:

```asm
sl_func_add_L1:
    ...
    ret
```

---

# 66. Step Labels

Function steps generate labels.

Example:

```sl
create boot()
    (1) console_print("one")
    (2) console_print("two")
```

Generated labels:

```asm
sl_func_boot_L1:
sl_func_boot_L2:
```

Step labels allow:

```sl
start boot(1)
start boot(2)
```

But step calls are safe only for no-parameter functions in `v0.3-alpha`.

---

# 67. Why NASM Errors Should Be Rare

Before `v0.3-alpha`, invalid Sentinel could reach NASM and fail with errors like:

```text
label `sl_var_a` inconsistently redefined
symbol `sl_func_boot_L9` not defined
```

Now, these should be caught earlier as Sentinel errors:

```text
[SEMANTIC S003] Storage `a` already exists.
[SEMANTIC S012] Function `boot` has no step `(9)`.
```

Goal:

```text
Broken Sentinel should fail as Sentinel, not as NASM.
```

---
# std Commands

`v0.4-alpha-stable` adds the first `lib(std)` command pack.

Current std commands:

| Command | Kind | Description |
| :--- | :--- | :--- |
| `vga_print(value)` | statement | Prints through VGA console output |
| `vga_clear()` | statement | Clears VGA text buffer |
| `nop()` | statement | Emits `nop` |
| `halt()` | statement | Emits safe halt loop |
| `io_wait()` | statement | Emits classic port `0x80` wait |
| `read_port(port)` | expression | Reads byte from I/O port |
| `write_port(port, value)` | statement | Writes byte to I/O port |
| `pic_eoi()` | statement | Sends EOI to master PIC |
| `irq_disable()` | statement | Emits `cli` |
| `irq_enable()` | statement | Emits `sti` |

## read_port

`read_port(port)` is an expression.

Example:

```sl
lib(std)
x64
type(console)

local key = read_port(0x60)
```

It returns a byte value in `rax`.

## write_port

`write_port(port, value)` is a statement.

Example:

```sl
lib(std)
x64
type(console)

local port = 0x20
local value = 0x20

write_port(port, value)
```

## pic_eoi

`pic_eoi()` is a convenience command.

It is equivalent to:

```sl
write_port(0x20, 0x20)
```

Use `pic_eoi()` when the meaning is specifically “send End Of Interrupt to master PIC”.

# 68. Current Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| Lexer | Working | Tokenizes Sentinel source |
| Parser | Working | Builds AST |
| AST | Working | Internal representation |
| Semantic analyzer | Working | v0.3-alpha hardening |
| NASM codegen | Working | Main backend |
| Flat binary pipeline | Working | Uses NASM `-f bin` |
| x64 mode | Working | Main tested path |
| x16 boot output | Working | Boot sector experiments |
| x32 mode | Experimental | Not main path |
| type(console) | Working | VGA / BIOS output |
| local | Working | Flat storage declaration |
| redo | Working | Existing storage mutation |
| if / then / else / end | Working | Numeric conditions |
| while | Working | Numeric loops |
| repeat | Working | Literal and variable counts |
| create | Working | Step-based functions |
| start | Working | Full calls and safe step calls |
| Function args | Working | x64 register-based |
| Argument validation | Working | S017 |
| Step validation | Working | S012 / S020 |
| get result | Experimental | Depends on `rax` |
| Arrays | Working | Numeric arrays |
| Array indexing | Working | Literal and variable index |
| console_print | Working | x64 `rsi` preservation fixed |
| low-code | Working | `emit` stable |
| try/catch | Syntax-only | No runtime exceptions |
| FREERAM | Experimental | Clears storage |
| structs | Experimental | Parsed, not full codegen |
| libraries | Planned | v0.4-alpha |
| self-hosting | Future | Long-term |
| lib(std) | Working | First x64 OSDev helper pack |
| StdCall | Working | std statement commands |
| ReadPortExpr | Working | `read_port()` as expression |
| vga_print | Working | std VGA output helper |
| vga_clear | Working | clears VGA text buffer |
| halt | Working | emits safe halt loop |
| nop | Working | emits `nop` |
| io_wait | Working | emits port `0x80` wait |
| read_port | Working | reads byte from I/O port |
| write_port | Working | writes byte to I/O port |
| pic_eoi | Working | sends EOI to master PIC |
| irq_disable | Working | emits `cli` |
| irq_enable | Working | emits `sti` |
| std x64 guard | Working | rejects `lib(std)` outside x64 |

---

# 69. Known Limitations

| Area | Limitation |
| :--- | :--- |
| Type system | Type checking incomplete |
| Memory safety | Not implemented |
| Bounds checking | Arrays have no bounds checks |
| Return values | No explicit `return` keyword |
| get result | Depends on generated `rax` |
| Exceptions | `try/catch` is syntax-only |
| Structs | Not stable |
| Libraries | Not added yet |
| Inline ASM | Full raw inline ASM not stable |
| ABI | Experimental |
| Optimizer | Basic |
| Debug info | Not stable |
| Multi-file projects | Planned through libraries/use |
| Self-hosting | Future |
| lib(std) | x64-only in v0.4-alpha-stable |
| std | Small first OSDev helper pack, not a full standard library |
| read_port/write_port | Basic byte port I/O only |
| Networking | Not implemented yet |

---

# 70. Flat Storage Model Summary

Current model:

```text
local name = value
```

Means:

```text
Declare one flat storage symbol.
```

Current mutation:

```text
redo: name to value
```

Means:

```text
Mutate existing storage.
```

Function params:

```text
Temporary input names.
```

Function steps:

```text
Explicit numbered stage labels.
```

---

# 71. Recommended Naming

Good names:

```sl
local boot_stage = 0
local boot_health = 100
local irq_count = 0
local memory_ready = 0
local scheduler_ready = 0
local math_add_out = 0
```

For function outputs:

```sl
local add_out = 0

create add(add_left, add_right)
    (1) redo: add_out to add_left + add_right
```

For boot systems:

```sl
local boot_stage = 0
local boot_error = 0
local boot_health = 100
```

For driver-like code:

```sl
local keyboard_status = 0
local keyboard_scancode = 0
local keyboard_ready = 0
```

---

# 72. Recommended Program Structure

Recommended order:

```text
1. mode
2. output type
3. storage declarations
4. function declarations
5. main execution flow
```

Example:

```sl
x64
type(console)

local counter = 0
local score = 0

create tick()
    (1) redo: counter to counter + 1
    (2) redo: score to score + 10

start tick()

if counter == 1 then
    console_print("tick ok")
end
```

---

# 73. Avoid Declaration Spam

Sentinel code should stay readable.

Bad style:

```sl
local a = 0
local b = 0
local c = 0
local d = 0
local e = 0

start one()
start two()
start three()
start four()
```

Better:

```sl
local boot_stage = 0
local boot_health = 100

create boot_console()
    (1) console_print("console")
    (2) redo: boot_stage to boot_stage + 1

create boot_memory()
    (1) console_print("memory")
    (2) redo: boot_stage to boot_stage + 1

start boot_console()
start boot_memory()
```

Sentinel is strongest when code is logically grouped.

---

# 74. Stress Testing Status

Sentinel `v0.3-alpha` has passed large compiler stress tests.

Known test groups:

| Test | Purpose | Result |
| :--- | :--- | :--- |
| Hello x64 | Basic output | Passed |
| Repeat Test | `repeat()` loops | Passed |
| While Test | `while` loops | Passed |
| Function Test | `create/start` | Passed |
| Result Test | `get result()` | Passed |
| Array Test | arrays/indexing | Passed |
| Beast Test | medium stress | Passed |
| Ultra Beast Test | large stress | Passed |
| Turtle Abomination | heavy control-flow stress | Passed |
| Semantic Killer | semantic edge cases | Passed |
| Register Clobber Test | print vs function args | Passed |
| Core Hardening Beast | flat storage + ABI stress | Passed |
| std Smoke Test | basic `lib(std)` commands | Passed |
| std Port Test | `read_port` / `write_port` | Passed |
| std IRQ Test | `irq_disable` / `irq_enable` / `pic_eoi` | Passed |
| std Big Stress Test | all v0.4 std commands together | Passed |
| std Error Tests | S021 / S022 / S024 / S026 | Passed |

---

# 75. v0.3-alpha Important Fixes

## 75.1 Semantic Diagnostics

Broken Sentinel now fails earlier.

Before:

```text
NASM error: label redefined
```

Now:

```text
[SEMANTIC S003] Storage already exists.
```

## 75.2 Missing Step Detection

Before:

```text
NASM error: symbol sl_func_x_L9 not defined
```

Now:

```text
[SEMANTIC S012] Function has no step `(9)`.
```

## 75.3 Unsafe Step Calls Blocked

Before:

```text
call sl_func_add_L2
```

could use stale argument registers.

Now:

```text
[SEMANTIC S020] Cannot step-call function with parameters.
```

## 75.4 x64 Print Preserves rsi

Before:

```text
console_print could overwrite second argument.
```

Now:

```text
print emits push/pop rsi.
```

---

# 76. v0.4-alpha-stable Important Additions

`v0.4-alpha-stable` adds the first working `lib(std)` OSDev helper layer.

Important additions:

- `lib(std)` library declaration
- `StdCall` statement commands
- `ReadPortExpr` expression node
- `vga_print()`
- `vga_clear()`
- `nop()`
- `halt()`
- `io_wait()`
- `read_port()`
- `write_port()`
- `pic_eoi()`
- `irq_disable()`
- `irq_enable()`
- `S021–S026` diagnostics
- x64-only std guard

This is the first Sentinel version where the language starts providing direct OSDev helper commands instead of only raw core syntax.

# 77. Library Model

Sentinel libraries are planned as compile-time command providers.

They should not behave like DLLs.

Expected idea:

```sl
lib(std)
```

Meaning:

```text
Compiler enables commands from std.
```

Libraries should inject or unlock low-level commands at compile time.

Not:

```text
dynamic runtime dependency
DLL loading
large hidden framework
```

This fits OSDev because early kernels and bootloaders cannot rely on a normal operating system runtime.

---

# 78. Driver Direction

Sentinel should not need a special `driver` mode.

Drivers should be Sentinel programs using low-level libraries.

Example future style:

```sl
lib(std)
x64
type(kernel)

local keyboard_status = 0
local keyboard_scancode = 0

create keyboard_poll()
    (1) redo: keyboard_status to read_port(0x64)
    (2) redo: keyboard_scancode to read_port(0x60)
```

Driver support should come from:

```text
libraries + low-level commands + kernel mode
```

not from:

```text
type(driver)
```

---

# 79. Graphics Direction

VESA is not the best long-term target.

Future graphics should prefer:

```text
GOP / framebuffer
```

Possible future concepts:

```sl
lib(gfx)

type(kernel)

framebuffer_clear()
framebuffer_put_pixel(x, y, color)
framebuffer_rect(x, y, w, h, color)
```

Current status:

```text
Future.
```

---

# 80. Networking Direction

Networking is not a v0.4-alpha target.

A real network stack is large.

Possible future layers:

```text
PCI
NIC driver
Ethernet
ARP
IPv4
ICMP
UDP
DHCP
DNS
TCP
HTTP
```

Recommended roadmap:

```text
First: std and hardware helpers.
Then: keyboard/timer/storage helpers.
Later: network stack.
```

---

# 81. Self-Hosting Direction

Self-hosting is a long-term goal.

Meaning:

```text
Sentinel compiler written in Sentinel.
```

This requires:

- stable syntax
- stable semantics
- stable ABI
- file I/O
- string handling
- memory management
- parser support
- code generation support
- enough libraries

Self-hosting should not be rushed.

The compiler core must be hardened first.

---

# 82. Safety Direction

Sentinel is not memory-safe yet.

Future safety ideas:

- stronger type checking
- array bounds options
- explicit memory zones
- safer storage declarations
- checked low-code mode
- optional diagnostics for dangerous patterns
- panic support
- debug mode

Current truth:

```text
Sentinel is low-level and experimental.
Programmer responsibility is high.
```

---

# 83. AI Compatibility Rules

A major goal of the specification is to make Sentinel understandable to humans and AI assistants.

When generating Sentinel code, follow these rules:

## 83.1 Always Declare Storage First

Good:

```sl
local out = 0

create add(a, b)
    (1) redo: out to a + b
```

Bad:

```sl
create add(a, b)
    (1) local out = a + b
```

## 83.2 Do Not Use Function Locals

Bad:

```sl
create test()
    (1) local x = 10
```

Good:

```sl
local x = 0

create test()
    (1) redo: x to 10
```

## 83.3 Do Not Step-Call Functions With Parameters

Bad:

```sl
start add(2)
```

if `add` has parameters.

Good:

```sl
start add(left, right)
```

## 83.4 Numeric Literals In start() Are Steps

This:

```sl
start boot(2)
```

means:

```text
call step 2
```

not:

```text
pass number 2 as data
```

To pass number as data:

```sl
local value = 2
start boot(value)
```

## 83.5 Use Explicit Names

Good:

```sl
local boot_stage = 0
local boot_health = 100
```

Bad:

```sl
local a = 0
local b = 100
```

unless the code is tiny.

---

# 84. Example: Clean Boot Flow

```sl
x64
type(console)

local boot_stage = 0
local boot_health = 100
local console_ready = 0
local memory_ready = 0
local irq_ready = 0
local scheduler_ready = 0

create init_console()
    (1) console_print("console begin")
    (2) redo: console_ready to 1
    (3) redo: boot_stage to boot_stage + 1
    (4) console_print("console ok")

create init_memory()
    (1) console_print("memory begin")
    (2) redo: memory_ready to 1
    (3) redo: boot_health to boot_health - 1
    (4) redo: boot_stage to boot_stage + 1
    (5) console_print("memory ok")

create init_irq()
    (1) console_print("irq begin")
    (2) redo: irq_ready to 1
    (3) redo: boot_health to boot_health - 2
    (4) redo: boot_stage to boot_stage + 1
    (5) console_print("irq ok")

create init_scheduler()
    (1) console_print("scheduler begin")
    (2) redo: scheduler_ready to 1
    (3) redo: boot_health to boot_health - 3
    (4) redo: boot_stage to boot_stage + 1
    (5) console_print("scheduler ok")

start init_console()
start init_memory()
start init_irq()
start init_scheduler()

if boot_stage == 4 then
    console_print("boot stage ok")
end

if boot_health < 100 then
    console_print("boot health changed")
end

if console_ready == 1 then
    if memory_ready == 1 then
        if irq_ready == 1 then
            if scheduler_ready == 1 then
                console_print("kernel core ready")
            end
        end
    end
end
```

---

# 85. Example: Function Arguments

```sl
x64
type(console)

local left_value = 10
local right_value = 20
local add_out = 0

create add(add_left, add_right)
    (1) console_print("add begin")
    (2) redo: add_out to add_left + add_right
    (3) console_print("add done")

start add(left_value, right_value)

if add_out == 30 then
    console_print("add result ok")
end
```

This verifies:

- function arguments
- print before argument use
- `rsi` preservation
- output storage mutation

---

# 86. Example: Arrays

```sl
x64
type(console)

local index_zero = 0
local index_one = 1
local index_two = 2

local values = [3, 6, 9]

local value_zero = values[index_zero]
local value_one = values[index_one]
local value_two = values[index_two]

if value_zero == 3 then
    console_print("value zero ok")
end

if value_one == 6 then
    console_print("value one ok")
end

if value_two == 9 then
    console_print("value two ok")
end
```

---

# 87. Example: repeat

```sl
x64
type(console)

local repeat_limit = 3
local repeat_counter = 0
local repeat_score = 0

repeat(repeat_limit)
    redo: repeat_counter to repeat_counter + 1
    redo: repeat_score to repeat_score + 10
end

if repeat_counter == 3 then
    console_print("repeat counter ok")
end

if repeat_score == 30 then
    console_print("repeat score ok")
end
```

---

# 88. Example: while

```sl
x64
type(console)

local while_limit = 4
local while_counter = 0
local while_score = 0

while while_limit > 0
    redo: while_limit to while_limit - 1
    redo: while_counter to while_counter + 1
    redo: while_score to while_score + 2
end

if while_limit == 0 then
    console_print("while limit ok")
end

if while_counter == 4 then
    console_print("while counter ok")
end

if while_score == 8 then
    console_print("while score ok")
end
```

---

# 89. Example: Safe Step Calls

Safe step calls are allowed for functions without parameters.

```sl
x64
type(console)

create debug_steps()
    (1) console_print("step one")
    (2) console_print("step two")
    (3) console_print("step three")

start debug_steps(1)
start debug_steps(2)
start debug_steps(3)
```

Unsafe:

```sl
create add(a, b)
    (1) console_print("add")
    (2) redo: out to a + b

start add(2)
```

This is blocked because `add` has parameters.

---

# 90. Example: low-code NOP Block

```sl
x64
type(console)

console_print("before nop")

low-code:
    emit 0x90
    emit 0x90
    emit 0x90

console_print("after nop")
```

---

# 91. Current Best Use Cases

Sentinel `v0.3-alpha` is best for:

| Use Case | Fit |
| :--- | :--- |
| x64 kernel experiments | Strong |
| bootloader experiments | Strong / experimental |
| OSDev learning | Strong |
| VGA text output demos | Strong |
| compiler stress tests | Strong |
| low-level logic prototypes | Good |
| drivers | Future |
| networking | Future |
| desktop apps | Future |
| game engines | Future |
| self-hosting | Long-term |

---

# 92. Current Bad Use Cases

Sentinel `v0.3-alpha` is not yet good for:

| Use Case | Reason |
| :--- | :--- |
| Production OS | Too early |
| Production drivers | Libraries missing |
| Web apps | Not target |
| Desktop GUI apps | No desktop libs yet |
| Large app ecosystem | No package/library system yet |
| Safe memory-heavy software | Memory safety incomplete |
| Complex string processing | String system incomplete |

---

# 93. Compiler Header

Generated assembly header should identify the compiler version.

Current target header:

```asm
; Generated by Sentinel Lang Compiler v0.3-alpha
```

Old headers mentioning `v0.2-alpha` should be updated when releasing `v0.3-alpha`.

---

# 94. Release Criteria For v0.3-alpha

A release can be considered valid when:

- README says `v0.3-alpha`
- SPECIFICATION says `v0.3-alpha`
- ROADMAP says `v0.3-alpha` current
- TEST_REPORT includes semantic tests
- status file says `v0.3-alpha`
- compiler header updated to `v0.3-alpha`
- semantic analyzer is active before codegen
- known broken semantic cases fail before NASM
- large valid stress tests compile
- register clobber test compiles correctly

---

# 95. v0.3-alpha Final Statement

Sentinel `v0.3-alpha` is a core hardening milestone.

It proves that the compiler can reject many broken programs before NASM, preserve important x64 argument behavior around generated prints, validate function steps, validate argument counts, and compile large low-level stress programs.

It is still alpha.

But the core is now much harder to break than earlier versions.

---

# 96. Roadmap Snapshot

| Version | Goal |
| :--- | :--- |
| `v0.1-alpha` | Basic compiler foundation |
| `v0.2-alpha` | Working x64 compiler core |
| `v0.3-alpha` | Core hardening and semantic diagnostics |
| `v0.4-alpha-stable` | First `lib(std)` OSDev command pack |
| `v0.5-alpha` | Demo kernel / mini OS and GitHub Pages documentation site |
| `v0.6-alpha` | Runtime and low-level library expansion |
| `v0.7-alpha` | Driver and hardware helper experiments |
| `v0.8-alpha` | Host tooling research |
| `v0.9-beta` | Testing and documentation hardening |
| `v1.0` | Stable experimental OSDev language |
---

# 97. Future Static Documentation Site

Sentinel should eventually have a static documentation site.

Suggested structure:

```text
Home
Guide
Specification
Examples
Compiler Pipeline
OSDev Tutorials
Semantic Errors
Roadmap
Changelog
```

Recommended pages:

| Page | Purpose |
| :--- | :--- |
| Home | Short explanation of Sentinel |
| Getting Started | First `.sl` program |
| Language Basics | `local`, `redo`, `if`, loops |
| Functions | `create`, steps, `start`, arguments |
| OSDev Examples | bootloader/kernel examples |
| Semantic Errors | S001-S020 explanations |
| Low-Code | `emit` and low-level commands |
| Roadmap | Future versions |
| Tests | Stress-test status |
| Philosophy | Why Sentinel exists |

The static site should be generated from the specification and examples, not replace them.

The specification remains the full source of truth.

---

# 98. Final Notes

Sentinel is young, experimental, and intentionally low-level.

`v0.3-alpha` hardened the compiler core.

`v0.4-alpha-stable` adds the first working OSDev helper layer through `lib(std)`.

Current strength:

```text
Small core.
Readable low-level syntax.
Real NASM output.
Semantic diagnostics.
Flat storage discipline.
First std hardware helpers.
```

Sentinel should continue growing carefully.

The next major step is:

```text
v0.5-alpha = demo kernel / mini OS + GitHub Pages documentation site.
```

After that, Sentinel can grow toward richer libraries, driver helpers, graphics, networking, tooling, and eventually self-hosting.

```text
Readable.
Low-level.
OSDev-first.
Close to the machine.
```
