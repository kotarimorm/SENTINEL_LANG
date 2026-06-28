# SENTINEL_LANG

Experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel Lang is an experimental systems programming language that compiles `.sl` source code into readable NASM assembly and then into a flat binary.

It is designed as a practical middle ground between readable low-level syntax and explicit assembly-level control.

---

## Current Status

| Field | Value |
| :--- | :--- |
| **Version** | `v0.5-alpha` |
| **Milestone** | Kernel Toolkit Preview |
| **Main target** | `x64` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Project type** | Experimental OSDev-first systems language |
| **Main focus** | Kernel-style stress testing and compiler hardening |
| **Stability** | Alpha |

---

## Documentation

Sentinel Lang Wiki:

```text
https://kotarimorm.github.io/SENTINEL_LANG/
```

Public repository:

```text
https://github.com/kotarimorm/SENTINEL_LANG
```

---

## Transparent Build Model

Sentinel does not directly hide machine code behind an opaque backend.

The current build path is:

```text
.sl source
    │
    ▼
Sentinel compiler
    │
    ▼
Readable NASM assembly
    │
    ▼
NASM
    │
    ▼
Flat binary
```

The Sentinel compiler backend is currently private, but the generated NASM output is explicit and inspectable.

Users can:

- inspect generated `.asm` files
- modify generated NASM manually
- assemble the output with NASM themselves
- compare Sentinel source with generated assembly
- debug the resulting binary using normal low-level tools

Sentinel does not ask users to blindly trust hidden machine code.

The trust boundary is NASM:

```text
Sentinel generates assembly.
NASM generates the final binary.
```

If you trust NASM and inspect the generated assembly, you can verify what Sentinel is asking NASM to build.

> Sentinel compiler core is private, but Sentinel output is transparent: `.sl → readable NASM → NASM → flat binary`.

---

## v0.5-alpha Overview

`v0.5-alpha` is the **Kernel Toolkit Preview** milestone.

This release does not try to add a huge new ecosystem layer.

Instead, it hardens the existing x64 OSDev path through a large kernel-style stress test and stricter semantic rules.

Main results:

| Area | Result |
| :--- | :--- |
| **Kernel Beast Test** | Passed |
| **x64 kernel-style compilation** | Strengthened |
| **`shift_left` / `shift_right` codegen** | Fixed |
| **Function declaration order** | Enforced |
| **Forward `start` calls** | Rejected with `S027` |
| **Forward `get` calls** | Rejected with `S027` |
| **Top-level `local` declarations** | May appear anywhere |
| **Function-local `local` declarations** | Still forbidden |
| **`lib(std)`** | Still x64-only |
| **Generated NASM** | Readable and inspectable |

Short version:

```text
v0.4-alpha-stable = first lib(std)
v0.5-alpha        = prove the kernel-style path holds under stress
v0.6-alpha        = library ecosystem
```

---

## What Sentinel Is

Sentinel is a low-level experimental language focused on operating system development.

It is not a general-purpose scripting language and it is not trying to hide the hardware.

Instead, it provides a simpler syntax over low-level concepts while still producing explicit NASM output.

```text
Readable source code
        │
        ▼
Compiler pipeline
        │
        ▼
NASM assembly
        │
        ▼
Flat binary
```

Sentinel is designed for people who want low-level control without writing every boot/kernel experiment directly in raw assembly.

---

## What Sentinel Is Not

Sentinel is currently not:

| Not A | Reason |
| :--- | :--- |
| **Production language** | Still alpha |
| **C/C++ replacement** | Ecosystem, optimizer, ABI, and tooling are not mature enough |
| **Rust replacement** | Full memory safety is not implemented |
| **Full OS framework** | OSDev libraries are still early |
| **Desktop app framework** | Not the current focus |
| **High-level scripting language** | Sentinel stays close to hardware |
| **Package ecosystem** | Planned for `v0.6-alpha` |
| **Self-hosted language** | Long-term goal only |

Sentinel is best understood as:

```text
Readable low-level language for OSDev experiments.
```

---

## Example

```sl
lib(std)
x64
type(console)

create boot()
    (1) vga_clear()
    (2) vga_print("Sentinel online")

start boot()
halt()
```

Current pipeline:

```text
demo.sl -> Sentinel compiler -> demo.asm -> NASM -> demo.bin
```

Example generated style:

```asm
BITS 64

_start:
    call sl_func_boot
    hlt
```

---

## Core Language Model

Sentinel uses a flat storage discipline.

This is intentional.

Core concepts:

| Keyword / Concept | Meaning |
| :--- | :--- |
| `local` | Declares flat source-file storage |
| `redo` | Mutates existing storage |
| `create` | Declares a function |
| `start` | Calls a function or function step |
| `get` | Calls a function and reads result path |
| `result` | Selects result step |
| `lib(std)` | Enables built-in OSDev helper commands |
| `type(console)` | Selects console-style output path |
| `x16` / `x32` / `x64` | Selects target mode |

Sentinel does not currently use classical lexical scopes.

Function-local storage is not supported in `v0.5-alpha`.

---

## Flat Storage

`local` declares flat storage.

A `local` declaration may appear anywhere at top-level:

```sl
lib(std)
x64
type(console)

local a = 10

create boot()
    (1) vga_print("boot")

local b = 20

start boot()
halt()
```

Both `a` and `b` are flat storage symbols.

Invalid:

```sl
lib(std)
x64
type(console)

create test()
    (1) local x = 10
```

Function-local `local` declarations are rejected because Sentinel does not currently have a function-local stack allocation model.

---

## Function Declaration Order

`v0.5-alpha` adds stricter function declaration order.

Functions must be declared before `start` or `get` calls that reference them.

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

This rule keeps Sentinel programs readable and avoids hidden forward-resolution behavior.

---

## Function Steps

Functions can contain numbered steps:

```sl
create boot()
    (1) vga_print("stage 1")
    (2) vga_print("stage 2")
```

A full function call:

```sl
start boot()
```

A step call:

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

It does **not** mean:

```text
pass integer value 1
```

To pass numeric data, declare storage first:

```sl
local amount = 1

create add_one(x)
    (1) vga_print("called")

start add_one(amount)
```

Parameterized step-calls are blocked in `v0.5-alpha` because step labels do not prepare function argument registers.

---

## Mutation With redo

Simple mutation:

```sl
local counter = 0

redo: counter to counter + 1
```

Bitwise operations:

```sl
redo: flags bit_and 1
redo: mask bit_or 4
redo: state bit_xor 2
```

Shift operations:

```sl
redo: memory_score shift_left 3
redo: device_mask shift_right 1
```

`v0.5-alpha` fixes the x64 NASM generation for `shift_left` and `shift_right`.

The compiler now emits valid shift counts:

```asm
shl rbx, 3
```

or:

```asm
shl rbx, cl
```

instead of invalid register combinations.

---

## lib(std)

`lib(std)` enables the first built-in OSDev helper layer.

```sl
lib(std)
x64
type(console)
```

Current rule:

```text
lib(std) is x64-only in v0.5-alpha.
```

Invalid:

```sl
lib(std)
x16

halt()
```

Expected diagnostic:

```text
[SEMANTIC S026] `lib(std)` currently supports x64 mode only.
```

Current `lib(std)` commands:

| Command | Kind | Purpose |
| :--- | :--- | :--- |
| `vga_print(value)` | statement | Print text/value using VGA-style output |
| `vga_clear()` | statement | Clear VGA text output |
| `nop()` | statement | Emit `nop` |
| `halt()` | statement | Emit halt behavior |
| `io_wait()` | statement | Emit I/O wait |
| `read_port(port)` | expression | Read byte from I/O port |
| `write_port(port, value)` | statement | Write byte to I/O port |
| `pic_eoi()` | statement | Send PIC end-of-interrupt |
| `irq_disable()` | statement | Emit `cli` |
| `irq_enable()` | statement | Emit `sti` |

Example:

```sl
lib(std)
x64
type(console)

local keyboard_status_port = 0x64
local key_status = 0
local key_ready = 0

create keyboard_poll()
    (1) redo: key_status to read_port(keyboard_status_port)
    (2) redo: key_ready to key_status
    (3) redo: key_ready bit_and 1

start keyboard_poll()
halt()
```

---

## x16 Bootloader Path

Sentinel still supports an experimental x16 boot-sector style path separately from `lib(std)`.

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

The x16 path can emit boot-sector style output such as:

```asm
BITS 16
ORG 0x7C00
```

and boot signature layout.

Important:

```text
lib(std) is not currently supported in x16.
```

---

## Kernel Beast Test

`v0.5-alpha` introduces the Kernel Beast Test as the main stress test.

The test is a large kernel-style Sentinel program covering:

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
Kernel Beast Test v0.5-alpha: Passed
```

This test proves that Sentinel can compile a larger kernel-style source file into NASM and flat binary output without relying on fake output or pseudo-code.

---

## Semantic Diagnostics

Sentinel rejects many broken programs before NASM.

Current semantic diagnostics include:

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

Example diagnostic:

```text
[SEMANTIC S027] Function `boot` is called before declaration.

Details:
  - Function `boot` is declared later in the file.
  - Sentinel v0.5-alpha requires functions to be declared before use.

Possible fixes:
  1. Move `create boot(...)` above this call.
  2. Or move this call below the function declaration.
```

---

## Current Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| Lexer | Working | Current alpha compiler |
| Parser | Working | Supports current syntax |
| AST | Working | Internal compiler model |
| Semantic analyzer | Working | Rejects many invalid programs before NASM |
| NASM codegen | Working | Main backend |
| Optimizer | Basic | Early simple optimizer |
| Flat binary output | Working | Through NASM |
| `x64` | Main tested mode | Strongest path |
| `x32` | Experimental | Not main focus |
| `x16` | Experimental | Boot-sector path |
| `type(console)` | Working | Main output style |
| `local` | Working | Flat storage |
| `redo` | Working | Mutation |
| `create` | Working | Function declaration |
| `start` | Working | Function/step call |
| `get result()` | Experimental | Result path |
| `if / else / end` | Working | Current conditional syntax |
| `while` | Working | Loop support |
| `repeat` | Working | Loop support |
| Arrays | Working | Basic indexing tested |
| Structs | Experimental | Not main focus |
| `try/catch` | Syntax-level / experimental | Not full exception system |
| `lib(std)` | Working | x64-only |
| Port I/O | Working | Through `read_port` / `write_port` |
| IRQ helpers | Working | `cli`, `sti`, `pic_eoi` |
| Kernel Beast Test | Passed | v0.5-alpha stress test |

---

## Current Limitations

| Area | Limitation |
| :--- | :--- |
| `lib(std)` | x64-only |
| Type system | Incomplete |
| Memory safety | Not implemented |
| Return values | No stable explicit `return` model |
| `get result()` | Experimental |
| Strings | No full string system |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | `try/catch` is not a full runtime exception system |
| Optimizer | Basic only |
| Package ecosystem | Planned for `v0.6-alpha` |
| Library Hub | Planned for `v0.6-alpha` |
| Driver stack | Future work |
| Networking | Future work |
| Self-hosting | Long-term goal |

---

## Why Sentinel Exists

Sentinel exists to explore a specific idea:

```text
Can OSDev code be more readable without hiding the machine?
```

The goal is not to replace C, C++, Rust, or assembly everywhere.

C and C++ still have:

- mature compilers
- large ecosystems
- decades of tooling
- powerful optimizers
- existing OSDev knowledge

Sentinel is much younger and much smaller.

But Sentinel can still be useful in a narrow area:

- readable boot/kernel prototypes
- explicit NASM-backed output
- semantic diagnostics before NASM
- simple OSDev helper commands
- inspectable low-level compilation
- fast experimental kernel-style coding

Sentinel does not replace C++ everywhere.

Sentinel can bite above its weight class in OSDev experiments.

---

## Roadmap

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 compiler core |
| `v0.3-alpha` | Completed | Core hardening and semantic diagnostics |
| `v0.4-alpha-stable` | Completed | First `lib(std)` OSDev command pack |
| `v0.5-alpha` | Current | Kernel Toolkit Preview / Kernel Beast hardening |
| `v0.6-alpha` | Planned | Library ecosystem alpha |
| `v0.7-alpha` | Planned | Optimizer / ASM slimming |
| `v0.7.1-alpha` | Planned | Advanced TOP optimization pass |
| `v0.8-alpha` | Planned | Playground and tooling |
| `v0.9-beta` | Planned | Stability, tests, and documentation hardening |
| `v1.0` | Future | Stable experimental OSDev-first core |

---

## v0.6-alpha Direction

`v0.6-alpha` is planned as the Library Ecosystem Alpha.

Planned direction:

- public library authoring specification
- one library = one GitHub repository
- GitHub stars as the first rating signal
- `sentinel-lib.json` manifest
- optional `.sentinel_lib_graph` visual metadata
- static Library Hub preview
- `Official`, `Approved`, `Community`, `Experimental`, `Unsafe`, and `Deprecated` statuses
- review candidate threshold based on GitHub stars
- website-based library package generator

Important:

```text
5 stars does not mean automatic approval.
5 stars means review candidate.
```

Approval should still depend on:

- valid manifest
- clear license
- readable code
- working examples
- tests
- documented unsafe behavior
- supported Sentinel version
- documented register clobbers where relevant

---

## v0.7-alpha Direction

`v0.7-alpha` is planned as the first real optimizer milestone.

Possible optimizer targets:

- unused step-label elimination
- string literal deduplication
- used-runtime-helper emission
- label cleanup
- simple peephole optimization
- fewer unnecessary stack operations
- smaller generated NASM

`v0.7.1-alpha` may become the advanced TOP optimization pass:

```text
TOP = Targeted Output Pruning
```

---

## Project Position

Sentinel is alpha software.

The compiler is experimental.

The backend is private.

The ecosystem is early.

The generated output should be inspected.

The language is not production-ready.

Current best use:

```text
OSDev experiments, bootloader tests, kernel-style prototypes, compiler research.
```

---

## License

See `LICENSE`.

---

## Final Summary

Sentinel `v0.5-alpha` is a kernel-toolkit hardening milestone.

It keeps the transparent `.sl → NASM → flat binary` model, strengthens the x64 OSDev path, fixes shift code generation, adds stricter function declaration rules, and proves the current compiler core through a larger Kernel Beast stress test.

Sentinel is still early, but it now has:

- readable low-level syntax
- explicit NASM-backed output
- semantic diagnostics before NASM
- working x64 `lib(std)` helpers
- flat storage discipline
- stricter function order rules
- a passed kernel-style stress test

```text
Sentinel Lang
OSDev-first. NASM-backed. Experimental.
```
