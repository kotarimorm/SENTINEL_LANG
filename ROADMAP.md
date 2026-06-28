# Sentinel Lang Roadmap

**Current version:** `v0.5-alpha`  
**Current phase:** Kernel Toolkit Preview  
**Main target:** `x64`  
**Project status:** Experimental alpha

---

## Roadmap Philosophy

Sentinel is an experimental OSDev-first systems language.

The roadmap is intentionally staged.

The goal is not to add everything at once.

The goal is to grow from:

```text
compiler core
```

to:

```text
OSDev helper layer
```

to:

```text
kernel-style stress testing
```

to:

```text
library ecosystem
```

to:

```text
optimizer / tooling
```

to:

```text
stable experimental OSDev-first core
```

Each version should harden one important layer before the next layer is added.

---

## Current Milestone

```text
v0.5-alpha
```

Milestone name:

```text
Kernel Toolkit Preview
```

Main result:

```text
The current x64 OSDev path passed a large kernel-style stress test.
```

Main proof:

```text
Kernel Beast Test v0.5-alpha: Passed
```

Current focus:

- kernel-style compiler hardening
- large Sentinel source compilation
- semantic diagnostics before NASM
- stricter function declaration order
- flat storage model clarification
- shift operation codegen fix
- continued `lib(std)` x64 validation

---

## Completed Milestones

### v0.1-alpha — Compiler Foundation

Status:

```text
Completed
```

Focus:

- basic compiler structure
- lexer foundation
- parser foundation
- early AST
- early NASM output path

Result:

```text
Sentinel became compilable as an experimental language prototype.
```

---

### v0.2-alpha — Working x64 Core

Status:

```text
Completed
```

Focus:

- working x64 path
- `type(console)`
- basic VGA output
- `local`
- `redo`
- `create`
- `start`
- basic expressions
- flat binary generation

Result:

```text
Sentinel gained a working x64 compiler path.
```

---

### v0.3-alpha — Core Hardening

Status:

```text
Completed
```

Focus:

- semantic analyzer
- flat storage validation
- duplicate symbol detection
- function step validation
- argument count validation
- unsafe parameterized step-call protection
- x64 register preservation fixes

Important diagnostics:

- `S001` reserved keyword used as name
- `S002` duplicate function
- `S003` duplicate storage
- `S008` unknown storage mutation
- `S011` local inside function blocked
- `S012` missing function step
- `S017` wrong argument count
- `S020` unsafe step-call on parameterized function

Result:

```text
Broken Sentinel programs started failing as Sentinel errors before NASM.
```

---

### v0.4-alpha-stable — First lib(std)

Status:

```text
Completed
```

Focus:

- first built-in OSDev helper pack
- `lib(std)` syntax
- std semantic validation
- std x64 codegen
- x64-only std guard
- VGA helpers
- IRQ helpers
- port I/O helpers

Current `std` command set introduced:

```text
vga_print()
vga_clear()
nop()
halt()
io_wait()
read_port()
write_port()
pic_eoi()
irq_disable()
irq_enable()
```

Result:

```text
Sentinel gained its first working OSDev helper layer.
```

---

### v0.5-alpha — Kernel Toolkit Preview

Status:

```text
Current / passed current alpha validation
```

Focus:

- Kernel Beast stress test
- stronger x64 kernel-style compilation
- stricter function declaration order
- no forward calls through `start`
- no forward calls through `get`
- `S027` semantic diagnostic
- top-level `local` order clarification
- function-local `local` remains forbidden
- `shift_left` / `shift_right` x64 codegen fix
- continued `lib(std)` x64 validation

Main rule additions:

```text
create must appear before start/get calls that reference it.
```

```text
local may appear anywhere at top-level.
```

```text
local inside create functions is still forbidden.
```

Main diagnostic added:

```text
S027: Function called before declaration.
```

Main codegen fix:

```text
shift_left / shift_right now emit valid x64 NASM shift operands.
```

Result:

```text
Sentinel proved that the current x64 OSDev path can compile a larger kernel-style stress test.
```

---

## Next Milestone

### v0.6-alpha — Library Ecosystem Alpha

Status:

```text
Planned
```

Main goal:

```text
Give Sentinel a public library ecosystem model without opening the private compiler core.
```

Planned direction:

- Library Authoring Specification
- one library = one GitHub repository
- `sentinel-lib.json` manifest
- optional `.sentinel_lib_graph` visual metadata
- static Library Hub preview
- GitHub stars as the first rating signal
- website-based `create_libr` generator
- official / approved / community / experimental / unsafe / deprecated statuses
- review candidate flow
- first official example libraries

Core idea:

```text
Compiler core = controlled by GRAY_WHALE_CO
Library ecosystem = open community layer
```

Library model:

```text
sentinel-example-lib/
├─ sentinel-lib.json
├─ README.md
├─ commands/
├─ examples/
├─ tests/
├─ docs/
└─ .sentinel_lib_graph
```

Review model:

```text
0 stars   -> New / Community
1-4 stars -> Community
5+ stars  -> Review Candidate
approved  -> GRAY_WHALE_CO Approved
official  -> Official
```

Important:

```text
5 stars does not mean automatic approval.
5 stars means review candidate.
```

Approval should depend on:

- valid manifest
- clear license
- readable code
- working examples
- tests
- documented unsafe behavior
- supported Sentinel version
- documented register clobbers where relevant

Result target:

```text
Sentinel becomes not just a compiler experiment, but the start of an OSDev library ecosystem.
```

---

## Future Milestones

### v0.7-alpha — Optimizer / ASM Slimming

Status:

```text
Planned
```

Main goal:

```text
Reduce generated NASM size while preserving readability and correctness.
```

Possible optimizer targets:

- unused step-label elimination
- string literal deduplication
- emit only used runtime helpers
- label cleanup
- simple peephole optimization
- fewer unnecessary stack operations
- simpler expression output
- smaller generated NASM

Motivation:

```text
v0.5-alpha proved that large generated NASM works.
v0.7-alpha should make that NASM smaller and cleaner.
```

---

### v0.7.1-alpha — TOP Optimization Pass

Status:

```text
Planned
```

Possible meaning:

```text
TOP = Targeted Output Pruning
```

Main goal:

```text
Add a stronger optimization pass after the first v0.7 optimizer foundation.
```

Possible targets:

- deeper stack cleanup
- repeated body deduplication
- step body reuse
- compact output mode
- improved helper emission
- stronger peephole rules
- optional readable vs compact NASM mode

---

### v0.8-alpha — Playground And Tooling

Status:

```text
Planned
```

Possible goals:

- browser playground prototype
- better IDE experience
- example runner
- documentation-integrated examples
- syntax highlighting
- public demo flow
- improved generated ASM viewer
- beginner-friendly project templates

---

### v0.9-beta — Stability And Documentation Hardening

Status:

```text
Planned
```

Possible goals:

- larger regression suite
- stable docs structure
- stronger examples
- clearer error reference
- better versioning rules
- beta-level language behavior freeze
- public issue templates
- contribution guidelines for libraries

---

### v1.0 — Stable Experimental OSDev Core

Status:

```text
Future
```

Main goal:

```text
Provide a stable experimental OSDev-first Sentinel core.
```

Possible requirements:

- documented syntax
- documented semantics
- stable core diagnostics
- stable `lib(std)` baseline
- stable library format
- tested x64 path
- reliable generated NASM
- clear limitations
- public examples
- complete wiki

---

## Version Table

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 compiler core |
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

## Current Public Position

Sentinel is still experimental alpha software.

It is not production-ready.

It is not a C/C++ replacement.

It is not a complete OS framework.

However, Sentinel now has:

- working x64 NASM output
- flat binary generation
- semantic diagnostics before NASM
- a working x64 `lib(std)` OSDev helper pack
- a passed kernel-style stress test
- clearer language ordering rules
- a roadmap toward a public library ecosystem

Current honest description:

```text
Sentinel is a real experimental compiler for OSDev experiments.
```

Future target after `v0.6-alpha`:

```text
Sentinel becomes an OSDev-first compiler and library ecosystem.
```
