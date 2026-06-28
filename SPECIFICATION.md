# Sentinel Lang Specification

**Version:** `v0.5-alpha`  
**Status:** Experimental alpha  
**Milestone:** Kernel Toolkit Preview  
**Main target:** `x64`  
**Primary backend:** NASM assembly / flat binary  
**Compiler backend:** Private  
**Full specification:** `https://kotarimorm.github.io/SENTINEL_LANG/`

---

## 1. Purpose

Sentinel Lang is an experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel compiles:

```text
.sl source -> Sentinel compiler -> readable NASM -> NASM -> flat binary
```

The compiler backend is private, but generated NASM output is explicit and inspectable.

---

## 2. Current Version

Current version:

```text
v0.5-alpha
```

Current milestone:

```text
Kernel Toolkit Preview
```

Main result:

```text
Kernel Beast Test v0.5-alpha: Passed
```

`v0.5-alpha` focuses on:

- kernel-style stress testing
- x64 OSDev path hardening
- semantic validation before NASM
- function declaration order rules
- shift operation codegen fixes
- flat storage clarification

---

## 3. Build Model

Current build path:

```text
Sentinel source
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
.asm file
      |
      v
NASM
      |
      v
flat binary
```

Trust boundary:

```text
Sentinel generates assembly.
NASM generates the final binary.
```

Generated assembly should remain readable and inspectable.

---

## 4. What Sentinel Is

Sentinel is:

- OSDev-first
- low-level
- NASM-backed
- experimental
- flat-storage based
- designed for readable kernel / bootloader prototypes

Sentinel is currently best described as:

```text
Readable low-level language for OSDev experiments.
```

---

## 5. What Sentinel Is Not

Sentinel is currently not:

- production-ready
- a C/C++ replacement
- a Rust replacement
- a full OS framework
- a full package ecosystem
- a stable ABI language
- memory-safe
- self-hosted

---

## 6. Targets

Current target status:

| Target | Status |
| :--- | :--- |
| `x64` | Main tested path |
| `x16` | Experimental bootloader path |
| `x32` | Experimental |

Current primary mode:

```sl
x64
type(console)
```

---

## 7. Core Syntax

Mode:

```sl
x64
```

Output:

```sl
type(console)
```

Library:

```sl
lib(std)
```

Storage:

```sl
local counter = 0
```

Mutation:

```sl
redo: counter to counter + 1
```

Function:

```sl
create boot()
    (1) vga_print("boot")
```

Call:

```sl
start boot()
```

Step call:

```sl
start boot(1)
```

---

## 8. Flat Storage Model

Sentinel uses flat storage discipline.

Rule:

```text
local declares flat source-file storage.
```

Top-level `local` declarations may appear anywhere:

```sl
lib(std)
x64
type(console)

create boot()
    (1) vga_print("boot")

local status = 1

start boot()
halt()
```

Function-local `local` declarations are forbidden:

```sl
create bad()
    (1) local x = 10
```

Expected diagnostic:

```text
[SEMANTIC S011] local inside function is not allowed.
```

---

## 9. Function Declaration Order

`v0.5-alpha` requires functions to be declared before calls.

Valid:

```sl
lib(std)
x64
type(console)

create boot()
    (1) vga_print("boot")

start boot()
halt()
```

Invalid:

```sl
lib(std)
x64
type(console)

start boot()

create boot()
    (1) vga_print("boot")

halt()
```

Expected diagnostic:

```text
[SEMANTIC S027] Function `boot` is called before declaration.
```

This applies to:

- `start`
- `get`

---

## 10. Function Steps

Functions use numbered steps:

```sl
create boot()
    (1) vga_print("stage 1")
    (2) vga_print("stage 2")
```

Full call:

```sl
start boot()
```

Step call:

```sl
start boot(2)
```

Important:

```text
start func(1)
```

means:

```text
call step (1)
```

It does not mean:

```text
pass integer argument 1
```

To pass numeric data, use storage:

```sl
local amount = 1

create test(x)
    (1) vga_print("called")

start test(amount)
```

Parameterized step-calls are blocked.

---

## 11. Mutation Operators

Simple assignment:

```sl
redo: x to 10
```

Arithmetic:

```sl
redo: x to x + 1
redo: x to x - 1
redo: x to x * 2
redo: x to x / 2
```

Bitwise:

```sl
redo: flags bit_and 1
redo: flags bit_or 2
redo: flags bit_xor 4
```

Shift:

```sl
redo: score shift_left 3
redo: mask shift_right 1
```

`v0.5-alpha` fixes x64 NASM generation for `shift_left` and `shift_right`.

Valid generated patterns:

```asm
shl rbx, 3
```

```asm
shl rbx, cl
```

Invalid old pattern:

```asm
shl rbx, rax
```

---

## 12. lib(std)

`lib(std)` enables the first built-in OSDev helper pack.

Usage:

```sl
lib(std)
x64
type(console)
```

Current limitation:

```text
lib(std) is x64-only in v0.5-alpha.
```

Current commands:

| Command | Kind | Purpose |
| :--- | :--- | :--- |
| `vga_print(value)` | statement | VGA-style output |
| `vga_clear()` | statement | Clear VGA text output |
| `nop()` | statement | Emit `nop` |
| `halt()` | statement | Halt behavior |
| `io_wait()` | statement | I/O wait |
| `read_port(port)` | expression | Read byte from I/O port |
| `write_port(port, value)` | statement | Write byte to I/O port |
| `pic_eoi()` | statement | PIC end-of-interrupt |
| `irq_disable()` | statement | Emit `cli` |
| `irq_enable()` | statement | Emit `sti` |

Invalid:

```sl
lib(std)
x16

halt()
```

Expected diagnostic:

```text
[SEMANTIC S026] lib(std) currently supports x64 mode only.
```

---

## 13. read_port

`read_port(port)` is an expression.

Example:

```sl
lib(std)
x64
type(console)

local keyboard_port = 0x60
local keyboard_value = 0

redo: keyboard_value to read_port(keyboard_port)

halt()
```

---

## 14. write_port

`write_port(port, value)` is a statement.

Example:

```sl
lib(std)
x64
type(console)

write_port(0x20, 0x20)
halt()
```

Expression arguments are supported:

```sl
local pic_port = 0x20
local pic_value = 0x20

write_port(pic_port, pic_value)
```

---

## 15. x16 Bootloader Path

The x16 path is separate from `lib(std)`.

Example:

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

`lib(std)` is not supported in x16 in `v0.5-alpha`.

---

## 16. Semantic Diagnostics

Current diagnostics:

| Code | Meaning |
| :--- | :--- |
| `S001` | Reserved keyword used as name |
| `S002` | Duplicate function |
| `S003` | Duplicate storage |
| `S004` | Duplicate parameter |
| `S005` | Parameter conflicts with storage |
| `S006` | Reserved / legacy conflict slot |
| `S007` | Cannot redo parameter directly |
| `S008` | Cannot modify unknown storage |
| `S009` | Unknown function |
| `S010` | Recursive call unsupported |
| `S011` | `local` inside function blocked |
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
| `S027` | Function called before declaration |

---

## 17. Kernel Beast Test

`v0.5-alpha` uses the Kernel Beast Test as the main stress test.

It covers:

- `lib(std)`
- VGA output
- IRQ helpers
- PIC helpers
- port I/O
- arrays
- indexing
- loops
- nested conditionals
- function calls
- six-argument function pressure
- bitwise operations
- shift operations
- kernel-style boot sequencing

Result:

```text
Passed
```

---

## 18. Current Limitations

| Area | Limitation |
| :--- | :--- |
| `lib(std)` | x64-only |
| Type system | Incomplete |
| Memory safety | Not implemented |
| Return values | No stable explicit `return` keyword |
| `get result()` | Experimental |
| Strings | No full string system |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | Syntax-level / experimental |
| Optimizer | Basic |
| Library ecosystem | Planned for `v0.6-alpha` |
| Library Hub | Planned for `v0.6-alpha` |
| Networking | Not implemented |
| Driver stack | Not implemented |
| Self-hosting | Long-term goal |

---

## 19. Roadmap

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 core |
| `v0.3-alpha` | Completed | Core hardening and semantic diagnostics |
| `v0.4-alpha-stable` | Completed | First `lib(std)` OSDev command pack |
| `v0.5-alpha` | Current | Kernel Toolkit Preview |
| `v0.6-alpha` | Planned | Library Ecosystem Alpha |
| `v0.7-alpha` | Planned | Optimizer / ASM slimming |
| `v0.7.1-alpha` | Planned | Advanced TOP optimization pass |
| `v0.8-alpha` | Planned | Playground and tooling |
| `v0.9-beta` | Planned | Stability, tests, and docs hardening |
| `v1.0` | Future | Stable experimental OSDev-first core |

---

## 20. Full Specification

This file is the short GitHub specification.

The full Sentinel Lang specification lives in the official Wiki:

```text
https://kotarimorm.github.io/SENTINEL_LANG/
```

The full Wiki specification should include:

- complete syntax reference
- complete semantic rules
- full diagnostic reference
- full `lib(std)` reference
- examples
- Kernel Beast Test notes
- generated NASM notes
- roadmap
- future library ecosystem rules
