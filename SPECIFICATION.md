# Sentinel Lang Specification

> Specification for Sentinel Lang `v0.3-alpha`.

Sentinel Lang is an experimental OSDev-first low-level language designed for bootloaders, kernels, flat binaries, and direct NASM-oriented code generation.

This document describes the current language model, supported syntax, semantic rules, known limitations, and planned direction.

---

# Version

| Field | Value |
| :--- | :--- |
| **Language version** | `v0.3-alpha` |
| **Main tested target** | `x64` |
| **Secondary target** | `x16` boot-sector experiments |
| **Main output mode** | `type(console)` |
| **Output format** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Stability** | Alpha |
| **Main focus** | OSDev / kernel experiments |

---

# Design Goal

Sentinel exists to provide readable low-level syntax while still keeping the generated output close to the machine.

```text
Readable Sentinel code
        │
        ▼
Explicit compiler pipeline
        │
        ▼
Semantic diagnostics
        │
        ▼
NASM assembly
        │
        ▼
Flat binary
```

Sentinel is not designed to hide hardware.

It is designed to make low-level programming easier to write, inspect, and debug.

---

# What Sentinel Is

Sentinel is:

| Area | Meaning |
| :--- | :--- |
| OSDev-first | Designed around bootloaders, kernels, and low-level experiments |
| NASM-oriented | Generates readable NASM-style assembly |
| Flat-binary capable | Can produce flat binary output |
| Step-based | Functions use numbered stages |
| Explicit | State and mutation are visible |
| Experimental | Semantics are still evolving |

Sentinel is especially suited for:

```text
bootloaders
kernel experiments
flat binaries
VGA text output
low-level learning
hardware-near prototypes
OSDev stress tests
```

---

# What Sentinel Is Not

Sentinel is currently not:

| Not A | Reason |
| :--- | :--- |
| Production language | Still alpha |
| C/C++ replacement | Ecosystem and tooling are not comparable yet |
| Complete OS framework | OS libraries are planned later |
| Safe language | Memory safety is not implemented |
| Full standard library | `lib(std)` is planned for `v0.4-alpha` |
| Full inline ASM system | Low-code is still backend-dependent |
| Desktop app language | Desktop APIs are not a current target |
| Self-hosting compiler | Long-term goal, not current |

---

# Compilation Pipeline

```text
.sl source
    │
    ▼
Lexer
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
NASM Assembly
    │
    ▼
Flat Binary
```

Short version:

```text
.sl -> Lexer -> Parser -> AST -> Semantic Analyzer -> NASM -> .bin
```

---

# File Structure

A Sentinel source file usually follows this order:

```text
optional compiler mode / options
architecture mode
output mode
flat storage declarations
function declarations
program flow
```

Example:

```sl
x64
type(console)

local counter = 0

create main()
    (1) console_print("hello")
    (2) redo: counter to counter + 1

start main()
```

---

# Architecture Modes

Sentinel supports architecture mode declarations.

| Mode | Status | Description |
| :--- | :--- | :--- |
| `x16` | Experimental | 16-bit real mode / bootloader experiments |
| `x32` | Experimental | 32-bit protected mode experiments |
| `x64` | Main tested mode | 64-bit long mode / kernel experiments |

Current strongest path:

```sl
x64
type(console)
```

Boot-sector path exists experimentally:

```sl
custing(silk)
x16
```

---

# Output Modes

## `type(console)`

`type(console)` enables console-style output.

In `x64`, current console output uses VGA text buffer style output.

```sl
x64
type(console)

console_print("hello")
```

In `x16`, boot-sector style output may use BIOS text output.

```sl
custing(silk)
x16

local msg = "hello"

create boot()
    (1) print(msg)

start boot()
```

---

## Future Output Modes

The following output modes are planned or under consideration.

They are not guaranteed stable in `v0.3-alpha`.

| Mode | Status | Meaning |
| :--- | :--- | :--- |
| `type(kernel)` | Planned | Kernel context without default console setup |
| `type(raw)` | Planned | Minimal output, no automatic runtime/output setup |
| `type(boot)` | Planned / possible | Explicit boot-sector behavior |

No separate `type(driver)` mode is planned.

Drivers should be written as normal Sentinel code using OSDev libraries.

---

## Unsupported `type(...)` Values

The following must be treated as unsupported unless documented later:

```text
type(driver)
type(network)
type(app)
type(service)
type(library)
```

If a value is not explicitly supported by the compiler, tools and AI agents must not invent behavior for it.

---

# Comments

Sentinel supports comment blocks using double dots:

```sl
.. this is a comment ..
```

Multiline comment style:

```sl
..
    comment line 1
    comment line 2
..
```

Comments are ignored by the compiler.

---

# Core Model

Sentinel `v0.3-alpha` uses a flat storage model.

It does not use classical lexical scopes.

Core concepts:

| Concept | Meaning |
| :--- | :--- |
| `local` | Declares flat storage |
| `redo` | Mutates existing storage |
| Function parameter | Temporary input name |
| Function step | Numbered compiler-visible stage |
| Function name | Callable symbol |
| `start function(...)` | Function call or step call |
| `get function(...) result()` | Function call with result access |

Important:

```text
local is storage.
redo is mutation.
params are inputs.
steps are compiler-visible.
```

Sentinel code should be written as ordered flat machine logic.

---

# Flat Storage Discipline

Storage names are flat per source file.

Recommended:

```sl
local result = 0

create add(a, b)
    (1) redo: result to a + b

start add(x, y)
```

Avoid:

```sl
create add(a, b)
    (1) local result = a + b
```

In `v0.3-alpha`, `local` inside functions is rejected.

Reason:

```text
local allocates storage.
function steps generate labels.
function-local storage can create duplicate or unsafe NASM labels.
```

Use top-level storage and mutate it with `redo`.

---

# Reserved Names

Reserved keywords cannot be used as storage, function, or parameter names.

Examples:

```text
local
redo
create
start
get
result
if
then
else
end
while
repeat
try
catch
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
local result = 10
```

Recommended:

```sl
local math_result = 10
```

---

# Values

## Integers

Numeric values are the most stable value type.

```sl
local x = 10
local y = 20
```

Supported numeric operations:

| Operator | Meaning |
| :--- | :--- |
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division, experimental |
| `%` | Modulo, experimental |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater or equal |
| `<=` | Less or equal |
| `==` | Equal |
| `!=` | Not equal |

---

## Strings

String values are supported for storage and output.

```sl
local msg = "hello"

console_print(msg)
```

String comparison is not stable in `v0.3-alpha`.

Avoid:

```sl
if msg == "hello" then
    console_print("same")
end
```

Reason:

```text
String values may currently behave like labels / pointers, not full string objects.
```

---

## Boolean-Like Values

Boolean-like values may be represented numerically.

Recommended:

```sl
local enabled = 1
local disabled = 0
```

Use numeric checks:

```sl
if enabled == 1 then
    console_print("enabled")
end
```

---

## Null

`null` exists as a token-level concept, but complete null semantics are not stable yet.

---

# Variables

Variables are declared with `local`.

In Sentinel terminology, `local` currently means flat storage declaration.

```sl
local x = 10
local y = 20
local msg = "hello"
```

`local` does not create a classical scoped local variable.

It creates storage.

---

# Mutation

Variables are modified with `redo`.

```sl
local x = 0

redo: x to 10
redo: x to x + 1
redo: x to x - 1
redo: x to x * 2
```

`redo` requires existing storage.

Invalid:

```sl
redo: x to 1
```

If `x` was not declared, this fails with semantic error `S008`.

---

# Arrays

Numeric arrays are supported.

```sl
local values = [10, 20, 30, 40]
```

Array indexing is supported.

```sl
local picked = values[2]
```

Variable indexing is supported in tested x64 programs.

```sl
local index = 1
local picked = values[index]
```

Array bounds are not checked in `v0.3-alpha`.

Unsafe:

```sl
local arr = [1, 2, 3]
local x = arr[999]
```

Current behavior:

```text
No safety guarantee.
Generated code may read unrelated memory.
```

---

# Control Flow

Sentinel supports basic numeric control flow.

---

## If Statement

Syntax:

```sl
if condition then
    statement
end
```

Example:

```sl
local x = 10

if x > 5 then
    console_print("x is high")
end
```

Nested `if` statements are supported.

```sl
if x > 0 then
    if x > 5 then
        console_print("nested ok")
    end
end
```

---

## While Loop

Syntax:

```sl
while condition
    statement
end
```

Example:

```sl
local x = 3

while x > 0
    redo: x to x - 1
end
```

Recommended condition style:

```text
numeric variable comparison numeric value
```

String-based `while` conditions are not stable.

---

## Repeat Loop

Syntax:

```sl
repeat(count)
    statement
end
```

Literal repeat count:

```sl
repeat(5)
    console_print("tick")
end
```

Variable repeat count:

```sl
local limit = 3

repeat(limit)
    console_print("tick")
end
```

Recommended count values:

```text
positive integers
```

Avoid:

```sl
repeat(0)
repeat(-1)
```

These are not guaranteed to behave safely in `v0.3-alpha`.

---

# Functions

Functions are declared with `create`.

Sentinel functions are not free-form blocks.

Sentinel functions use numbered steps.

This is one of the most important parts of the language.

---

## Function Declaration

Syntax:

```sl
create function_name(param1, param2)
    (1) statement
    (2) statement
    (3) statement
```

Example:

```sl
local sum = 0

create add(a, b)
    (1) redo: sum to a + b
    (2) console_print("add done")
```

---

## Function Step Syntax

Numbered steps are part of Sentinel syntax.

They are not comments.

They are not optional labels.

They are not decorative numbering.

They define ordered function stages.

Valid:

```sl
create boot_sequence()
    (1) console_print("boot: cpu")
    (2) console_print("boot: memory")
    (3) console_print("boot: drivers")
    (4) console_print("boot: done")
```

Invalid:

```sl
create boot_sequence()
    console_print("boot: cpu")
    console_print("boot: memory")
```

The invalid example has no numbered steps and must not be considered valid Sentinel function syntax.

---

## Function Step Rules

Each function step starts with:

```text
(N)
```

Where `N` is a positive integer.

Rules:

| Rule | Description |
| :--- | :--- |
| Step markers are required | Function statements must belong to numbered steps |
| Step markers are syntax | They are not comments |
| Steps are ordered | `(1)` comes before `(2)` |
| Steps are useful for OSDev | They make boot/debug stages explicit |
| Steps are compiler-visible | Codegen can create labels from steps |

---

## Function Calls

Functions are called with `start`.

Normal call:

```sl
create hello()
    (1) console_print("hello")

start hello()
```

Call with named arguments:

```sl
local x = 1
local y = 2
local sum = 0

create add(a, b)
    (1) redo: sum to a + b

start add(x, y)
```

---

## Step Calls

Numeric values inside `start function(N)` are step selectors.

Example:

```sl
create report()
    (1) console_print("one")
    (2) console_print("two")

start report(2)
```

This calls step `(2)`.

Important:

```text
start function(2) means step 2.
start function(arg) means named argument.
```

If `2` is intended as data, declare it first:

```sl
local value = 2

start function(value)
```

---

## Unsafe Step Calls

In `v0.3-alpha`, direct step calls are blocked for parameterized functions.

Invalid:

```sl
local result = 0

create add(a, b)
    (1) console_print("add")
    (2) redo: result to a + b

start add(2)
```

This fails with `S020`.

Reason:

```text
Step labels do not prepare function argument registers.
Calling a step directly may use stale rdi/rsi/rdx/rcx/r8/r9 values.
```

Recommended:

```sl
local x = 10
local y = 20
local result = 0

create add(a, b)
    (1) console_print("add")
    (2) redo: result to a + b

start add(x, y)
```

---

## Function Arguments

In `x64`, the first arguments are currently passed through registers.

| Argument | Current x64 register |
| :--- | :--- |
| `arg1` | `rdi` |
| `arg2` | `rsi` |
| `arg3` | `rdx` |
| `arg4` | `rcx` |
| `arg5` | `r8` |
| `arg6` | `r9` |

More than six arguments are not stable in `v0.3-alpha`.

Argument count is validated by the semantic analyzer.

Wrong argument count fails with `S017`.

---

## Function Result Access

Sentinel supports experimental result access:

```sl
local value = get function_name(args) result()
```

Example:

```sl
local result_storage = 0
local left = 10
local right = 20

create add(a, b)
    (1) redo: result_storage to a + b

local value = get add(left, right) result()
```

Important:

```text
v0.3-alpha does not have a real return keyword yet.
get result() currently depends on the generated rax value.
```

This is experimental and may change.

---

## Result Step Selectors

`get ... result(N)` may refer to numbered result behavior.

Missing result steps are validated.

Example invalid case:

```sl
create calc()
    (1) console_print("one")

local value = get calc() result(9)
```

This fails with `S012`.

---

# Console Output

Sentinel supports console output through `console_print`.

```sl
console_print("hello")
```

String variable output:

```sl
local msg = "hello"

console_print(msg)
```

Numeric output is not guaranteed to be formatted as decimal text in all modes.

Recommended usage:

```sl
console_print("status message")
```

---

## x64 Print Register Preservation

In `v0.3-alpha`, generated print calls preserve `rsi`.

Reason:

```text
x64 arg2 uses rsi.
console_print also uses rsi as string pointer.
```

Expected generated shape:

```asm
push rsi
lea  rsi, [rel sl_pstr_0]
call sl_print_str
pop  rsi
```

This prevents `console_print` from destroying the second function argument.

---

# Low-Code Blocks

`low-code` allows low-level byte emission and selected low-level commands.

Current stable form:

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

Selected low-level commands may also be supported depending on backend.

Example from x16-style low-code:

```sl
low-code:
    cli
    emit 0x31, 0xC0
    halt
```

Important:

```text
emit is supported.
selected low-level commands may be supported.
full arbitrary inline NASM is backend-dependent and not guaranteed stable.
```

---

# Try / Catch

`try/catch` syntax exists in `v0.3-alpha`.

Example:

```sl
try
    console_print("try block")
catch err
    console_print("catch block")
end
```

Important:

```text
try/catch is syntax-only in v0.3-alpha.
There is no complete exception runtime yet.
```

This means:

| Feature | Status |
| :--- | :--- |
| `try` block parsing | Supported |
| `catch` block parsing | Supported |
| Real exception throw | Not supported |
| Runtime error routing | Not supported |
| Stack unwinding | Not supported |

---

# FREERAM

`FREERAM` is experimental.

Syntax:

```sl
FREERAM(variable)
```

Example:

```sl
local msg = "hello"

FREERAM(msg)
```

Current behavior may clear or reset variable storage depending on backend implementation.

It is not a complete heap allocator.

---

# Semantic Diagnostics

`v0.3-alpha` introduces semantic diagnostics before NASM generation.

Goal:

```text
Invalid Sentinel should fail as Sentinel.
```

---

## Semantic Error Codes

| Code | Meaning |
| :--- | :--- |
| `S001` | Reserved keyword used as name |
| `S002` | Duplicate function |
| `S003` | Duplicate storage |
| `S004` | Duplicate parameter |
| `S005` | Parameter/storage collision |
| `S007` | Cannot `redo` parameter |
| `S008` | Unknown storage mutation |
| `S009` | Unknown function |
| `S010` | Recursive call unsupported |
| `S011` | `local` inside function blocked |
| `S012` | Missing function step |
| `S013` | Invalid `redo` target |
| `S014` | Storage/function collision |
| `S015` | Unknown storage symbol |
| `S016` | Mixed step selector and args |
| `S017` | Wrong function argument count |
| `S018` | Duplicate function step |
| `S019` | `FREERAM` unknown storage |
| `S020` | Unsafe step-call on parameterized function |

`S006` is currently reserved / unused.

---

## Example Semantic Errors

Unknown function:

```sl
start missing()
```

Expected:

```text
[SEMANTIC S009] Unknown function `missing`.
```

Missing step:

```sl
create boot()
    (1) console_print("boot")

start boot(9)
```

Expected:

```text
[SEMANTIC S012] Function `boot` has no step `(9)`.
```

Duplicate storage:

```sl
local a = 1
local a = 2
```

Expected:

```text
[SEMANTIC S003] Storage `a` already exists.
```

Unsafe parameterized step call:

```sl
create add(a, b)
    (1) console_print("add")
    (2) console_print("done")

start add(2)
```

Expected:

```text
[SEMANTIC S020] Cannot step-call function `add` because it has parameters.
```

---

# ABI / Register Model

## x64 Function Arguments

Current x64 function arguments:

| Argument | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

## Result Register

Current result behavior uses:

```text
rax
```

`get ... result()` depends on generated `rax` behavior.

This is experimental.

## Print Preservation

Generated print calls preserve `rsi`.

This protects the second function argument from being overwritten by string printing.

---

# Supported v0.3-alpha Syntax Summary

## Stable / Mostly Working

```text
x64
x16 boot-sector experiments
type(console)
local
redo
if / then / end
while / end
repeat(...) / end
create function(...)
numbered function steps: (1), (2), (3)
start function(...)
start function(N) for no-param step calls
get function(...) result()
console_print(...)
print(...) in supported modes
numeric arrays
array indexing
low-code with emit
selected low-code commands
FREERAM(...)
```

---

## Experimental

```text
x16
x32
division
modulo
try/catch runtime behavior
FREERAM memory semantics
get result() return semantics
low-code raw command support
```

---

## Planned

```text
lib(std)
type(kernel)
type(raw)
OSDev command helpers
panic()
halt()
nop()
read_port()
write_port()
io_wait()
pic_eoi()
vga_clear()
vga_print()
```

---

## Not Supported In v0.3-alpha

The following features must not be invented:

```text
type(driver)
type(network)
type(app)
type(service)
raw arbitrary inline NASM as a guaranteed feature
return keyword
throw keyword
classes
interfaces
namespaces
full imports/modules
string comparison
interrupt handler syntax
on_interrupt(...)
irq(...)
port[0x60]
heap allocator API
Windows desktop app API
Linux syscall API
network stack
filesystem layer
self-hosting compiler
```

If a feature is not explicitly listed as supported, it must be treated as unsupported.

---

# AI Compatibility Rules

This section exists to prevent AI tools from inventing Sentinel syntax.

When generating Sentinel Lang `v0.3-alpha` code, use only documented features.

---

## Allowed AI Generation Set

AI tools may generate code using:

```text
x64
x16 boot examples if explicitly requested
type(console)
local numeric variables
local string variables for console_print
numeric arrays
array indexing
console_print(...)
redo: variable to expression
if numeric_condition then ... end
while numeric_condition ... end
repeat(number_or_variable) ... end
create function(...)
numbered function steps
start function(...)
start function(N) only for no-param step calls
get function(...) result()
low-code with emit
selected documented low-code commands
try/catch syntax only
FREERAM(variable)
```

---

## AI Must Not Generate

AI tools must not generate:

```text
type(driver)
type(service)
type(app)
type(network)
raw arbitrary assembly as guaranteed portable Sentinel
return
throw
class
interface
namespace
full module system
string comparisons
interrupt handlers
on_interrupt(...)
irq(...)
port[0x60]
heap allocation APIs
network APIs
filesystem APIs
desktop APIs
```

---

## Function Step Reminder

Valid Sentinel:

```sl
create init()
    (1) console_print("init begin")
    (2) console_print("init end")
```

Invalid Sentinel:

```sl
create init()
    console_print("init begin")
    console_print("init end")
```

Numbered steps are required.

They are not optional.

They are part of the language.

---

# Valid v0.3-alpha Example

```sl
x64
type(console)

local counter = 0
local limit = 3
local result = 0

create add(a, b)
    (1) redo: result to a + b
    (2) console_print("add done")

repeat(limit)
    redo: counter to counter + 1
end

start add(counter, limit)

if result > 0 then
    console_print("result ok")
end
```

---

# Valid Step Call Example

```sl
x64
type(console)

create boot_report()
    (1) console_print("boot line one")
    (2) console_print("boot line two")

start boot_report(2)
```

This is valid because `boot_report` has no parameters.

---

# Invalid Step Call Example

```sl
x64
type(console)

local result = 0

create add(a, b)
    (1) console_print("add")
    (2) redo: result to a + b

start add(2)
```

This is invalid in `v0.3-alpha`.

Reason:

```text
add has parameters.
step labels do not prepare argument registers.
```

Expected:

```text
S020
```

---

# Valid Boot-Sector Style Example

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

This path is experimental but important for Sentinel's OSDev direction.

---

# Testing Status

`v0.3-alpha` has passed:

```text
semantic diagnostics tests
register clobber tests
large ordered flat-storage stress tests
Core Hardening Beast v0.3.1
x64 NASM flat binary generation
x16 boot-sector style generation
```

See `TEST_REPORT.md` for test details.

---

# v0.4-alpha Direction

`v0.4-alpha` should begin the first OSDev command library work.

Primary planned library:

```sl
lib(std)
```

Possible commands:

```text
halt()
nop()
panic(msg)
read_port(port)
write_port(port, value)
io_wait()
pic_eoi()
vga_clear()
vga_print(msg)
```

`v0.4-alpha` should not become a huge standard library.

It should provide small compile-time OSDev commands that lower directly into low-level code.

---

# Graphics Direction

VESA is not a primary planned target.

Future graphics direction should prefer:

```text
GOP
framebuffer
raw pixel output
small graphics primitives
```

Near-term graphics support should remain simple.

---

# Driver Direction

No separate `type(driver)` mode is planned.

Drivers should be written as normal Sentinel code using OSDev libraries.

Example future style:

```sl
lib(std)

x64
type(kernel)

local key = 0

create read_key()
    (1) redo: key to read_port(0x60)

start read_key()
```

---

# Networking Direction

Networking is not planned for `v0.4-alpha`.

A future network stack would require:

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
```

First realistic target:

```text
ICMP ping on controlled hardware or emulator target
```

---

# Current Reliability

| Category | State |
| :--- | :--- |
| Small programs | High |
| Medium programs | High |
| Large ordered flat-storage programs | Medium-High |
| Invalid syntax | Parser errors |
| Known invalid semantics | Semantic errors |
| Unknown semantics | May still need hardening |
| Runtime safety | Not guaranteed |
| OSDev safety | Experimental |
| x64 codegen | Main tested path |
| x16 boot output | Experimental but working |

---

# Final Notes

Sentinel Lang `v0.3-alpha` is a real experimental compiler stage.

It is still alpha.

It is not production-ready.

But it can compile large ordered low-level programs into NASM assembly and flat binary output.

The current focus is:

```text
core hardening
semantic diagnostics
flat storage discipline
OSDev-first direction
```

Next major milestone:

```text
v0.4-alpha = first lib(std) OSDev command pack
```
