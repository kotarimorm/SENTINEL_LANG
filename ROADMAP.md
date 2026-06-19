# Sentinel Lang Roadmap

> Development roadmap for Sentinel Lang from `v0.2-alpha` to `v1.0`.

Sentinel Lang is an experimental low-level systems programming language for OSDev, kernels, bootloaders, and direct NASM-oriented code generation.

This roadmap describes planned milestones.  
Features may change as the compiler evolves.

---

## Roadmap Overview

```text
v0.1-alpha
    │
    ▼
compiler foundation
    │
    ▼
v0.2-alpha
    │
    ▼
working x64 language core
    │
    ▼
v0.3-alpha
    │
    ▼
scopes + semantic diagnostics
    │
    ▼
v0.4-alpha / stable
    │
    ▼
OSDev libraries
    │
    ▼
v0.5-alpha
    │
    ▼
demo kernel / mini OS
    │
    ▼
v0.6 - v0.8
    │
    ▼
desktop and host libraries
    │
    ▼
v1.0
    │
    ▼
stable experimental systems language
```

---

## Version Status

| Version | Status | Main Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Current | Working x64 language core |
| `v0.3-alpha` | Planned | Scopes and semantic errors |
| `v0.4-alpha` | Planned | First OSDev micro-libs |
| `v0.4-stable` | Planned | Stable OSDev standard library |
| `v0.5-alpha` | Planned | Demo kernel / mini OS |
| `v0.6-alpha` | Planned | Host target research |
| `v0.7-alpha` | Planned | Desktop primitives |
| `v0.8-alpha` | Planned | GUI and application libraries |
| `v0.9-beta` | Planned | Hardening and ecosystem cleanup |
| `v1.0` | Long-term | Stable experimental release |

---

## v0.1-alpha — Compiler Foundation

Goal: build the first working compiler pipeline.

| Area | Status |
| :--- | :--- |
| Lexer | Done |
| Parser | Done |
| AST | Done |
| NASM code generation | Done |
| Basic optimizer | Done |
| x64 output | Done |
| Flat binary pipeline | Done |
| Basic console output | Done |

Result:

```text
Sentinel source can be compiled into NASM output.
```

---

## v0.2-alpha — Current Language Core

Goal: make the language compile real non-trivial programs.

| Feature | Status |
| :--- | :--- |
| `local` variables | Working |
| `redo` mutation | Working |
| `if` / `while` / `repeat` | Working |
| Functions with numbered steps | Working |
| Function arguments | Working |
| `get result()` | Experimental |
| Arrays | Working |
| Array indexing | Working |
| `low-code` with `emit` | Working |
| Large stress tests | Passing |

Main achievement:

```text
Sentinel now has a working experimental x64 language core.
```

Known weakness:

```text
Scopes are incomplete.
Function locals can collide with globals or parameters.
```

---

## v0.3-alpha — Scopes and Diagnostics

Goal: fix the compiler core before adding bigger libraries.

### Planned Work

| Area | Goal |
| :--- | :--- |
| Scope system | Separate globals, params, locals, temporaries |
| Label mangling | Prevent duplicate NASM labels |
| Semantic checker | Catch invalid Sentinel before NASM |
| Diagnostics | Better source-level error messages |
| Reserved words | Clear errors for names like `result` |
| Function locals | Stop emitting unsafe global collisions |
| Result model | Make `get result()` more predictable |

### Main Target

```text
No more NASM-level crashes for simple Sentinel semantic errors.
```

---

## v0.4-alpha — First OSDev Micro-Libs

Goal: stop forcing users to write raw `emit` bytes for common OSDev operations.

### Planned Builtins

| Builtin | Purpose |
| :--- | :--- |
| `read_port(port)` | Read from I/O port |
| `write_port(port, value)` | Write to I/O port |
| `io_wait()` | Small I/O delay |
| `halt()` | Stop CPU safely |
| `nop()` | No-op instruction |
| `panic(msg)` | Print error and halt |
| `pic_eoi()` | Send PIC end-of-interrupt |
| `timer_wait(ticks)` | Basic timer wait |
| `keyboard_read()` | Simple PS/2 polling helper |

Example future code:

```sl
x64
type(console)

local scancode = read_port(0x60)

if scancode == 1 then
    panic("ESC pressed")
end
```

---

## v0.4-stable — OSDev Standard Library

Goal: make the first stable low-level standard library.

### Planned Modules

| Module | Functions |
| :--- | :--- |
| `io` | `read_port`, `write_port`, `io_wait` |
| `cpu` | `halt`, `nop`, `cli`, `sti` |
| `debug` | `panic`, `assert`, `debug_print` |
| `pic` | `pic_remap`, `pic_mask`, `pic_unmask`, `pic_eoi` |
| `pit` | `timer_init`, `timer_wait` |
| `keyboard` | `keyboard_poll`, `keyboard_read_scancode` |
| `memory` | basic memory helpers |

Main target:

```text
Write simple drivers without manually knowing machine-code bytes.
```

---

## v0.5-alpha — Demo Kernel / Mini OS

Goal: prove Sentinel can be used for a real OSDev project.

### Planned Demo

| Component | Goal |
| :--- | :--- |
| Boot flow | Minimal controlled startup |
| Console | Text output |
| Panic system | Debug halt |
| Timer | Basic timing |
| Keyboard | Basic input |
| Memory helpers | Early memory experiments |
| Driver examples | Small OSDev modules |

Result target:

```text
A tiny demo kernel or mini OS using Sentinel code.
```

---

## v0.6-alpha — Host Target Research

Goal: begin exploring non-OSDev targets.

Possible research areas:

| Area | Purpose |
| :--- | :--- |
| Windows output | Native executable experiments |
| Linux output | ELF/syscall experiments |
| File I/O | Basic host interaction |
| Process model | Program entry/exit |
| Runtime layer | Minimal host runtime |

This stage is research-focused, not stable.

---

## v0.7-alpha — Desktop Primitives

Goal: begin building application-level foundations.

Possible features:

| Feature | Purpose |
| :--- | :--- |
| Window creation | Basic desktop apps |
| Event loop | Keyboard/mouse events |
| File dialogs | Simple app workflows |
| Text rendering | UI output |
| Timers | App timing |
| Input handling | Desktop input model |

---

## v0.8-alpha — GUI and Application Libraries

Goal: build higher-level desktop libraries.

Possible modules:

| Module | Purpose |
| :--- | :--- |
| `window` | Window management |
| `ui` | Buttons, labels, input fields |
| `canvas` | 2D rendering |
| `image` | Image loading / drawing |
| `audio` | Basic sound |
| `app` | App lifecycle helpers |

Long-term idea:

```text
Small native applications with simple Sentinel syntax.
```

---

## v0.9-beta — Hardening

Goal: prepare the language for a serious `v1.0`.

| Area | Goal |
| :--- | :--- |
| Test suite | Large regression tests |
| Error messages | Clear diagnostics |
| Documentation | Complete and consistent |
| Examples | More real projects |
| Compiler stability | Fewer crashes |
| Language cleanup | Remove broken syntax |
| Library cleanup | Stable APIs |

---

## v1.0 — Stable Experimental Release

Goal: release a stable experimental systems language.

`v1.0` should include:

| Area | Requirement |
| :--- | :--- |
| Compiler | Stable core pipeline |
| Syntax | Documented and consistent |
| Scopes | Correct variable isolation |
| Diagnostics | Good source-level errors |
| x64 | Stable main target |
| OSDev libs | Usable low-level library |
| Examples | Real working projects |
| Tests | Regression suite |
| Docs | README, spec, status, roadmap |

Final goal:

```text
A practical experimental language for OSDev and low-level systems programming.
```

---

## Long-Term Vision

Sentinel should become a language that allows developers to write low-level systems code with readable syntax while still understanding what happens close to the machine.

The long-term dream:

```text
Readable syntax
    +
Low-level control
    +
OSDev libraries
    +
Native output
    =
Sentinel Lang
```

---

## Current Priority

```text
1. Finish v0.2-alpha documentation
2. Fix scopes in v0.3-alpha
3. Improve diagnostics
4. Add OSDev micro-libs
5. Build the first Sentinel demo kernel
```

Correctness comes before magic.

Scopes come before libraries.

Libraries come before desktop apps.
