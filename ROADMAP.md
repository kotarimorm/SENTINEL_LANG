# Sentinel Lang Roadmap

> Development roadmap for Sentinel Lang from `v0.3-alpha` toward `v1.0`.

Sentinel Lang is an experimental OSDev-first low-level language for bootloaders, kernels, flat binaries, and direct NASM-oriented code generation.

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
core hardening + semantic diagnostics
    │
    ▼
v0.4-alpha
    │
    ▼
first lib(std) OSDev command pack
    │
    ▼
v0.5-alpha
    │
    ▼
demo kernel / mini OS direction
    │
    ▼
v0.6 - v0.8
    │
    ▼
runtime, drivers, host tooling, larger experiments
    │
    ▼
v0.9-beta
    │
    ▼
hardening before beta/stable work
    │
    ▼
v1.0
    │
    ▼
stable experimental OSDev language
```

---

## Version Status

| Version | Status | Main Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 language core |
| `v0.3-alpha` | Current | Core hardening and semantic diagnostics |
| `v0.4-alpha` | Planned | First `lib(std)` OSDev command pack |
| `v0.5-alpha` | Planned | Demo kernel / mini OS direction |
| `v0.6-alpha` | Planned | Runtime and low-level library expansion |
| `v0.7-alpha` | Planned | Driver and hardware helper experiments |
| `v0.8-alpha` | Planned | Host tooling research |
| `v0.9-beta` | Planned | Testing, diagnostics, and documentation hardening |
| `v1.0` | Long-term | Stable experimental OSDev release |

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
Sentinel became a real compiler prototype.
```

---

## v0.2-alpha — Working Language Core

Goal: make the language core usable for non-trivial programs.

| Area | Status |
| :--- | :--- |
| Variables / flat storage | Done |
| `redo` mutation | Done |
| Numeric expressions | Done |
| `if` statements | Done |
| `while` loops | Done |
| `repeat` loops | Done |
| Function declarations | Done |
| Function calls | Done |
| Function arguments | Done |
| `get ... result()` | Experimental |
| Arrays | Done |
| Array indexing | Done |
| Low-code byte emission | Done |
| Large stress tests | Done |

Result:

```text
Sentinel can compile non-trivial x64 programs into NASM and flat binaries.
```

Known weakness at this stage:

```text
Invalid semantic patterns could still fall through to NASM errors.
```

---

## v0.3-alpha — Core Hardening and Diagnostics

Goal: harden the compiler core before adding larger OSDev libraries.

`v0.3-alpha` is not a classical scope-system release.

Sentinel uses flat storage discipline.

### Completed Work

| Area | Status |
| :--- | :--- |
| Semantic analyzer | Working |
| Flat storage validation | Working |
| Duplicate storage diagnostics | Working |
| Unknown storage diagnostics | Working |
| Function existence diagnostics | Working |
| Function step validation | Working |
| Argument count validation | Working |
| Unsafe parameterized step-call protection | Working |
| `local` inside function diagnostic | Working |
| x64 `rsi` print preservation fix | Working |
| Core Hardening Beast v0.3.1 | Passed |

### Main Target

```text
No more NASM-level crashes for known simple Sentinel semantic errors.
```

### Design Rule

```text
Broken Sentinel should fail as Sentinel.
Valid ordered flat-storage code should still compile.
```

---

## v0.4-alpha — First OSDev Command Pack

Goal: add the first small compile-time OSDev command library.

The first library target is:

```sl
lib(std)
```

`lib(std)` should not become a huge standard library.

It should provide small low-level commands that lower directly into NASM or backend-specific snippets.

### Planned Commands

| Command | Purpose |
| :--- | :--- |
| `halt()` | Stop CPU safely |
| `nop()` | No-op instruction |
| `panic(msg)` | Print error and halt |
| `read_port(port)` | Read from I/O port |
| `write_port(port, value)` | Write to I/O port |
| `io_wait()` | Small I/O delay |
| `pic_eoi()` | Send PIC end-of-interrupt |
| `vga_clear()` | Clear text output |
| `vga_print(msg)` | Minimal VGA/debug output |

### Non-Goals For v0.4

| Not Planned | Reason |
| :--- | :--- |
| Full network stack | Too large for first library stage |
| Full filesystem | Needs runtime and disk model first |
| Full driver framework | Drivers need lower-level primitives first |
| Desktop APIs | Not an OSDev-core feature |
| VESA-first graphics | Future graphics direction should prefer GOP/framebuffer |
| `type(driver)` | Drivers should be normal code using libraries |

---

## v0.5-alpha — Demo Kernel / Mini OS Direction

Goal: build a small Sentinel-powered OSDev prototype.

Possible target:

```text
Sentinel OS v0.1
```

### Planned Pieces

| Piece | Purpose |
| :--- | :--- |
| Boot sequence | Show Sentinel-driven boot flow |
| Kernel entry | Start x64 kernel code |
| VGA output | Debug text output |
| Panic path | Stop safely with message |
| Interrupt stubs | Prepare for IRQ work |
| Timer smoke | Basic timing experiment |
| Keyboard smoke | Basic input experiment |
| Memory map stub | Prepare future memory work |

Result target:

```text
A small Sentinel-written kernel experiment.
```

---

## v0.6-alpha — Runtime and Low-Level Library Expansion

Goal: grow beyond first micro-commands.

Possible work:

| Area | Purpose |
| :--- | :--- |
| Memory helpers | Basic memory operations |
| Buffer helpers | Safer low-level buffers |
| Better result model | More predictable function results |
| More builtins | Reduce raw low-code needs |
| Basic driver helpers | Build on `lib(std)` |
| x16/x64 boot flow research | Prepare stronger OS prototypes |

---

## v0.7-alpha — Driver and Hardware Helper Experiments

Goal: explore driver-level abstractions without creating a separate driver language mode.

Drivers should be normal Sentinel code using libraries.

Possible work:

| Area | Purpose |
| :--- | :--- |
| Keyboard helpers | Read PS/2 keyboard data |
| Timer helpers | PIT / timer experiments |
| Disk helpers | ATA or sector-read experiments |
| PCI helpers | Device discovery |
| PIC helpers | Interrupt controller utilities |
| Driver examples | Small OSDev modules |

No `type(driver)` is planned.

---

## v0.8-alpha — Host Tooling Research

Goal: research host-side workflows without abandoning OSDev-first design.

Possible work:

| Area | Purpose |
| :--- | :--- |
| Better CLI | Compiler UX |
| More dumps | AST / tokens / ASM |
| Better diagnostics | More helpful errors |
| Test runner | Regression testing |
| Host experiments | Controlled host-side tooling |

Desktop application support is not a near-term goal.

---

## v0.9-beta — Hardening Before Stable Experimental Release

Goal: prepare the language for serious beta-stage use.

| Area | Purpose |
| :--- | :--- |
| Regression tests | Prevent old bugs from returning |
| Error messages | Clear diagnostics |
| Documentation | Complete and consistent |
| Examples | More real programs |
| Compiler stability | Fewer crashes |
| Language cleanup | Remove broken syntax |
| Library cleanup | Stabilize OSDev commands |

---

## v1.0 — Stable Experimental OSDev Release

Goal: release a stable experimental OSDev-first language.

`v1.0` should include:

| Area | Requirement |
| :--- | :--- |
| Compiler | Stable core pipeline |
| Syntax | Documented and consistent |
| Semantics | Predictable flat storage model |
| Diagnostics | Good source-level errors |
| x64 | Stable main target |
| x16 | Documented boot-sector path |
| OSDev libs | Usable low-level command library |
| Examples | Real working projects |
| Tests | Regression suite |
| Docs | README, spec, status, roadmap, test report |

Final goal:

```text
A practical experimental language for OSDev and low-level systems programming.
```

---

## Long-Term Vision

Sentinel should become a language for writing low-level systems code with readable syntax while still understanding what happens close to the machine.

The long-term dream:

```text
Readable syntax
    +
Low-level control
    +
OSDev command libraries
    +
Native flat output
    =
Sentinel Lang
```

---

## Current Priority

```text
1. Finish v0.3-alpha documentation
2. Keep core hardening tests passing
3. Begin v0.4-alpha lib(std) planning
4. Build first OSDev command pack
5. Move toward a Sentinel OS prototype
```

Core correctness comes before libraries.

Libraries come before larger OS experiments.

Sentinel stays OSDev-first.
