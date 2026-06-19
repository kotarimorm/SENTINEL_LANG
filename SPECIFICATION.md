# Sentinel Lang Specification

> Specification for Sentinel Lang `v0.2-alpha`.

Sentinel Lang is an experimental low-level systems programming language designed for OSDev, bootloader experiments, kernel experiments, and direct NASM-oriented code generation.

This document describes what Sentinel Lang currently supports, what is experimental, and what is explicitly not supported.

---

## Version

| Field | Value |
| :--- | :--- |
| **Language version** | `v0.2-alpha` |
| **Main tested target** | `x64` |
| **Main output mode** | `type(console)` |
| **Output format** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Stability** | Alpha |

---

## Design Goal

Sentinel exists to provide a readable low-level syntax while still keeping the generated output close to the machine.

```text
Readable Sentinel code
        │
        ▼
Explicit compiler pipeline
        │
        ▼
NASM assembly
        │
        ▼
Flat binary
```

Sentinel is not intended to hide the hardware completely.

It is designed for controlled low-level experiments.

---

## Compilation Pipeline

```text
.sl source file
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
Code Generator
      │
      ▼
NASM Assembly
      │
      ▼
Flat Binary
```

Short form:

```text
.sl  ->  Lexer  ->  Parser  ->  AST  ->  NASM  ->  .bin
```

---

## File Structure

A Sentinel source file usually follows this order:

```text
mode
type(...)
program body
```

Example:

```sl
x64
type(console)

local msg = "hello"

console_print(msg)
```

---

## Compilation Modes

| Mode | Status | Description |
| :--- | :--- | :--- |
| `x16` | Experimental | 16-bit real mode experiments |
| `x32` | Experimental | 32-bit protected mode experiments |
| `x64` | Main tested mode | 64-bit long mode experiments |

Current strongest and most tested path:

```sl
x64
type(console)
```

---

## Output Modes

### `type(console)`

Console mode enables text output through `console_print`.

```sl
x64
type(console)

console_print("hello")
```

Current `x64` console output uses VGA text buffer style output.

---

### Unsupported `type(...)` values

The following must be treated as unsupported in `v0.2-alpha`:

```text
type(driver)
type(network)
type(app)
type(service)
type(library)
```

If a value is not explicitly supported by the compiler, it must not be invented by tools, documentation generators, or AI agents.

---

## Comments

Sentinel supports comment blocks using double dots:

```sl
.. this is a comment ..
```

Multiline comment style:

```sl
.. 
   comment line 1
   comment line 2
   comment line 3
..
```

Comments are ignored by the compiler.

---

## Variables

Variables are declared with `local`.

```sl
local x = 10
local y = 5
local msg = "hello"
```

---

## Numeric Variables

Numeric variables are currently the most stable value type.

```sl
local x = 10
local y = 20
local z = x + y
```

Supported numeric operations:

| Operator | Meaning |
| :--- | :--- |
| `+` | addition |
| `-` | subtraction |
| `*` | multiplication |
| `/` | division, experimental |
| `%` | modulo, experimental |
| `>` | greater than |
| `<` | less than |
| `>=` | greater or equal |
| `<=` | less or equal |
| `==` | equal |
| `!=` | not equal |

---

## String Variables

String variables are supported for storage and output.

```sl
local msg = "hello"

console_print(msg)
```

String comparison is not stable in `v0.2-alpha`.

This is not guaranteed to work correctly:

```sl
if msg == "hello" then
    console_print("same")
end
```

Reason:

```text
String values may currently behave like pointers / labels, not full string objects.
```

---

## Boolean Values

Boolean-like values may be represented numerically.

Recommended style in `v0.2-alpha`:

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

## Arrays

Numeric arrays are supported.

```sl
local arr = [10, 20, 30, 40]
```

Array indexing is supported.

```sl
local picked = arr[2]
```

Example:

```sl
x64
type(console)

local values = [3, 6, 9]
local x = values[1]

if x == 6 then
    console_print("array index ok")
end
```

---

## Array Limitations

Array bounds are not checked in `v0.2-alpha`.

This may compile but is unsafe:

```sl
local arr = [1, 2, 3]
local x = arr[999]
```

Expected behavior:

```text
No safety guarantee.
The generated code may read unrelated memory.
```

---

## Variable Mutation

Variables are modified with `redo`.

```sl
local x = 0

redo: x to 10
redo: x to x + 1
redo: x to x - 1
redo: x to x * 2
```

Example:

```sl
local counter = 0

repeat(3)
    redo: counter to counter + 1
end
```

---

## Control Flow

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

Examples:

```sl
while x > 0
while counter < 10
while energy >= 1
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

These are not guaranteed to behave safely in `v0.2-alpha`.

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
create add(a, b)
    (1) local sum = a + b
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
    console_print("boot: drivers")
```

The invalid example has no numbered steps and must not be considered valid Sentinel function syntax.

---

## Function Step Rules

Each function step starts with a line marker:

```text
(N)
```

Where `N` is a positive integer.

Examples:

```sl
(1) console_print("stage 1")
(2) console_print("stage 2")
(3) console_print("stage 3")
```

Rules:

| Rule | Description |
| :--- | :--- |
| Step markers are required | Function statements must belong to numbered steps |
| Step markers are syntax | They are not comments |
| Steps are ordered | `(1)` comes before `(2)` |
| Steps are useful for OSDev | They make boot/debug stages explicit |
| Steps are compiler-visible | Code generation can create labels from steps |

---

## Function Body Rules

Recommended `v0.2-alpha` style:

```sl
create example()
    (1) console_print("first")
    (2) console_print("second")
    (3) console_print("third")
```

If multiple actions are needed, use multiple steps.

Recommended:

```sl
create init()
    (1) console_print("init begin")
    (2) local x = 10
    (3) console_print("init end")
```

Avoid writing many unrelated statements under one step.

---

## Function Calls

Functions are called with `start`.

```sl
create hello()
    (1) console_print("hello")

start hello()
```

Function call with arguments:

```sl
create print_sum(a, b)
    (1) local sum = a + b
    (2) console_print("sum done")

start print_sum(1, 2)
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

More than six arguments are not stable in `v0.2-alpha`.

---

## Function Result Access

Sentinel supports experimental result access:

```sl
local value = get function_name(args) result()
```

Example:

```sl
create add(a, b)
    (1) local sum = a + b
    (2) console_print("add done")

local math_result = get add(10, 20) result()
```

Important:

```text
v0.2-alpha does not have a real return keyword yet.
get result() currently depends on the generated rax value.
```

This is experimental and may change.

---

## Reserved Word: `result`

`result` is a keyword used by:

```sl
get function_name() result()
```

Do not use `result` as a variable name.

Invalid:

```sl
local result = 10
```

Recommended:

```sl
local math_result = 10
local call_result = get add(1, 2) result()
```

---

## Function Scope Limitations

Function-local variables are currently not fully scoped.

This means function locals can collide with globals or parameters.

Problematic example:

```sl
local a = 10

create test(a)
    (1) local a = a + 1
```

This may generate duplicate labels:

```asm
sl_var_a dq 10
sl_var_a dq 0
```

Known NASM error:

```text
label `sl_var_a` inconsistently redefined
```

This is a known `v0.2-alpha` limitation.

Planned fix for `v0.3-alpha`:

| Source Concept | Planned Internal Label |
| :--- | :--- |
| Global variable | `sl_var_counter` |
| Function local | `sl_func_math_var_sum` |
| Function parameter | register / stack slot |
| Temporary value | `sl_tmp_0` |

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

Numeric output is not guaranteed to be formatted as decimal text in `v0.2-alpha`.

Recommended usage:

```sl
console_print("status message")
```

---

# Low-Code Blocks

`low-code` allows low-level byte emission.

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

---

## Low-Code Rules

| Rule | Description |
| :--- | :--- |
| `emit` is supported | Emits raw byte values |
| Byte values should be numeric | Example: `0x90` |
| Raw NASM is not stable | Do not assume inline ASM works |
| Comments inside low-code are risky | Keep low-code minimal |

---

## Unsupported Low-Code Example

Do not assume this is supported:

```sl
low-code:
    in al, 0x60
    movzx rax, al
    out 0x20, al
```

Current recommended form:

```sl
low-code:
    emit 0x90
```

If raw inline ASM support is added later, it must be documented separately.

---

# Try / Catch

`try/catch` syntax exists in `v0.2-alpha`.

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
try/catch is syntax-only in v0.2-alpha.
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

# Supported v0.2-alpha Syntax Summary

## Stable / Mostly Working

```text
x64
type(console)
local
redo
if / then / end
while / end
repeat(...) / end
create function(...)
numbered function steps: (1), (2), (3)
start function(...)
get function(...) result()
console_print(...)
arrays with numeric literals
array indexing
low-code with emit
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
function-local variables
```

---

## Not Supported In v0.2-alpha

The following features must not be invented:

```text
type(driver)
raw inline NASM inside low-code
return keyword
throw keyword
classes
full imports/modules
string comparison
pointer syntax
interrupt handler syntax
driver declaration syntax
heap allocator API
Windows desktop app API
Linux syscall API
self-hosting compiler
```

If a feature is not explicitly listed as supported, it must be treated as unsupported.

---

# AI Compatibility Rules

This section exists to prevent AI tools from inventing Sentinel syntax.

When generating Sentinel Lang `v0.2-alpha` code, use only documented features.

---

## Allowed AI Generation Set

AI tools may generate code using:

```text
x64
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
get function(...) result()
low-code with emit only
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
raw assembly instructions inside low-code
return
throw
class
interface
namespace
import
use modules unless documented
string comparisons
interrupt handlers
on_interrupt(...)
irq(...)
port[0x60]
io_in8(...)
io_out8(...)
pointer types
heap allocation APIs
```

---

## Function Step Reminder For AI Tools

This is valid Sentinel:

```sl
create init()
    (1) console_print("init begin")
    (2) console_print("init end")
```

This is not valid Sentinel function syntax:

```sl
create init()
    console_print("init begin")
    console_print("init end")
```

The numbered steps are required.

They are not optional.

They are not comments.

They are part of the language.

---

# Example: Valid v0.2-alpha Program

```sl
x64
type(console)

local counter = 0
local limit = 3
local values = [10, 20, 30]
local picked = values[1]

console_print("program start")

create add(a, b)
    (1) local sum = a + b
    (2) console_print("add done")

repeat(limit)
    redo: counter to counter + 1
end

if picked == 20 then
    console_print("array ok")
end

local math_result = get add(5, 7) result()

if math_result > 0 then
    console_print("result ok")
end

low-code:
    emit 0x90
    emit 0x90

console_print("program done")
```

---

# Example: Invalid v0.2-alpha Program

```sl
x64
type(driver)

local status = "running"

create keyboard_driver()
    console_print("missing numbered step")

while status == "running"
    low-code:
        in al, 0x60
end
```

Reasons:

| Problem | Explanation |
| :--- | :--- |
| `type(driver)` | Not supported |
| Function has no numbered steps | Invalid function syntax |
| String comparison | Not stable |
| Raw ASM in `low-code` | Not supported |
| Driver semantics | Not implemented |

---

# Known v0.2-alpha Bugs

| Bug | Status |
| :--- | :--- |
| Function locals can collide with globals | Known |
| Function locals can collide with parameters | Known |
| `try/catch` has no real runtime behavior | Known |
| `get result()` has no explicit return model | Known |
| Arrays have no bounds checks | Known |
| Strings do not have full comparison semantics | Known |

---

# Planned v0.3-alpha Improvements

| Area | Goal |
| :--- | :--- |
| Scope system | Separate globals, params, locals, temporaries |
| Semantic errors | Catch invalid code before NASM |
| Better diagnostics | Report Sentinel source lines |
| Return model | Add explicit result semantics |
| Function locals | Avoid global label collisions |
| AI compatibility | Keep strict documented syntax |

---

# Final Notes

Sentinel Lang `v0.2-alpha` is a real experimental compiler stage.

It can compile non-trivial Sentinel programs into NASM output, but the language is still early.

The current priority is correctness, predictable semantics, clear diagnostics, and strict documentation.

The compiler should reject unsupported features instead of silently generating broken code.
