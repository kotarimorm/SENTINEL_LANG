
# Sentinel Lang Roadmap

**Current version:** `v0.6-alpha`  
**Current milestone:** Core Language Completion  
**Current date:** September 1, 2026  
**Main target:** `x64`  
**Secondary target:** `x16` boot sectors  
**Project status:** Experimental alpha

---

## Roadmap Philosophy

Sentinel is an experimental OSDev-first systems language.

The roadmap is intentionally staged.

The goal is not to add every possible feature immediately.

The goal is to build Sentinel in layers:

```text
Compiler foundation
        |
        v
Working x64 language core
        |
        v
Semantic hardening
        |
        v
Built-in OSDev helpers
        |
        v
Kernel stress testing
        |
        v
Temporary function storage
        |
        v
Complete boot execution path
        |
        v
Library ecosystem
        |
        v
Additional targets and optimizer
        |
        v
Stable experimental platform
```

Each milestone should solve one real architectural boundary.

New syntax should not be added only because it looks useful.

A feature should answer at least one of these questions:

- Does it make OSDev code meaningfully easier?
- Does it remove an unsafe ambiguity?
- Does it unlock a real executable capability?
- Does it improve generated NASM?
- Does it strengthen the compiler architecture?
- Does it make libraries possible without weakening the core?

---

## Current Position

Sentinel currently has:

- a working lexer
- a working parser
- an internal AST
- semantic analysis before NASM
- readable NASM generation
- flat binary generation
- a basic optimizer
- a working x64 language path
- a working x16 boot-sector path
- a minimal x16 `lib(std)` subset
- a larger x64 `lib(std)` implementation
- persistent storage through `local`
- temporary x64 function storage through `stand`
- explicit step transfer through `give`
- final values through `result`
- function result retrieval through `get`
- Kernel Beast regression coverage
- Stand Beast validation

Sentinel does not yet have:

- a complete x64 boot chain
- a complete x32 backend
- a stable ABI
- full memory safety
- a framebuffer graphics library
- a filesystem library
- a complete driver framework
- a public package ecosystem
- a production-grade optimizer
- self-hosting

Current honest description:

```text
Sentinel is a real experimental compiler with a working
x64 language core and a working x16 boot-sector path.
```

---

# Completed Milestones

## v0.1-alpha — Compiler Foundation

**Status:** Completed

Main work:

- initial compiler structure
- lexer foundation
- parser foundation
- early AST
- early NASM output
- first `.sl` source files
- first flat binary experiments

Result:

```text
Sentinel became a compilable language prototype.
```

---

## v0.2-alpha — Working x64 Core

**Status:** Completed

Main work:

- working x64 code generation
- `type(console)`
- basic VGA text output
- `local`
- `redo`
- `create`
- `start`
- basic expressions
- conditions
- loops
- NASM integration
- flat binary generation

Result:

```text
Sentinel gained its first working x64 compiler path.
```

---

## v0.3-alpha — Core Hardening

**Status:** Completed

Main work:

- semantic analyzer
- duplicate symbol detection
- flat storage validation
- function-step validation
- function argument validation
- unsafe parameterized step-call protection
- x64 register preservation fixes
- clearer Sentinel-level failures before NASM

Important diagnostics included:

```text
S001 — reserved keyword used as name
S002 — duplicate function
S003 — duplicate storage
S008 — unknown mutation target
S011 — local inside function blocked
S012 — missing function step
S017 — wrong argument count
S020 — unsafe parameterized step call
```

Result:

```text
Broken Sentinel programs began failing as Sentinel errors
instead of reaching NASM with known structural problems.
```

---

## v0.4-alpha-stable — First lib(std)

**Status:** Completed

Main work:

- `lib(std)` syntax
- std semantic validation
- built-in OSDev commands
- VGA text helpers
- halt and NOP helpers
- IRQ helpers
- PIC EOI
- port input/output
- target-aware code generation foundation

Commands introduced during this line:

```text
vga_print()
vga_clear()
panic()
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
Sentinel gained its first built-in OSDev helper layer.
```

---

## v0.5-alpha — Kernel Toolkit Preview

**Status:** Completed

Main work:

- Kernel Beast stress test
- larger x64 kernel-style compilation
- function declaration-order enforcement
- no forward `start` calls
- no forward `get` calls
- `S027`
- top-level `local` order clarification
- x64 shift code-generation fixes
- stronger register-pressure validation
- continued `lib(std)` testing

Important rule:

```text
A function must be declared before start/get references it.
```

Important code-generation fix:

```text
Dynamic x64 shifts use CL instead of invalid RAX operands.
```

Main result:

```text
Kernel Beast Test: Passed
```

Meaning:

```text
The x64 compiler path survived a larger kernel-style
program containing functions, loops, arrays, conditions,
port I/O, IRQ helpers, bitwise operations, and register pressure.
```

---

## v0.6-alpha — Core Language Completion

**Status:** Current / Completed Current Validation

Release date:

```text
September 1, 2026
```

Main goal:

```text
Introduce a real temporary function-storage model
without converting local into hidden scoped allocation.
```

Main additions:

- `stand`
- `give to (N)`
- x64 stand stack frames
- multiple stand values
- explicit stand lifetime
- stand name validation
- forward-only step transfer
- dependent-step protection
- unsafe wrapper elimination
- final `result expression`
- improved `get` expression support
- ascending function-step validation
- unknown-token rejection
- per-command x16 std validation
- parameter symbol restoration after code generation

Core model:

```text
local = persistent flat state
stand = temporary function state
```

Example:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

Generated direction:

```text
temporary -> [rbp-8]
result    -> rax
```

Main diagnostics added:

```text
S028 — get used on function without result
S029 — result used outside function
S030 — invalid result position
S031 — function steps are not ascending
S032 — invalid stand position
S033 — duplicate stand
S034 — invalid stand target
S035 — stand name conflict
S036 — stand value unavailable
S037 — stand used outside x64
```

Additional hardening:

- unknown lexer characters now produce parse errors
- x16 rejects unsupported std commands before NASM
- stand-dependent independent step labels are not emitted
- direct calls cannot skip required stand-producing steps

Main validation:

```text
Stand Beast compilation: Passed
x64 regression compilation: Passed
x16 boot-sector compilation: Passed
x16 QEMU boot: Passed
```

Result:

```text
Sentinel gained an explicit temporary function data-flow model.
```

---

# Current Technical Boundary

## Complete x64 Boot Chain

Sentinel can currently generate:

```text
bootloader.bin
kernel.bin
```

The x16 boot sector is independently bootable.

The x64 kernel binary compiles successfully through NASM.

However, the current boot sector does not yet:

- load the x64 kernel from disk
- place it at the expected physical address
- enable A20
- create a GDT
- enter protected mode
- create page tables
- enable long mode
- jump to the x64 kernel entry point

Important:

```text
Concatenating binaries does not automatically load the kernel.
```

Required execution chain:

```text
BIOS
  |
  v
x16 boot sector
  |
  v
Disk read
  |
  v
Kernel loaded into memory
  |
  v
Protected mode
  |
  v
Page tables
  |
  v
Long mode
  |
  v
x64 Sentinel kernel
```

This is the next major engineering boundary.

It must be solved before Sentinel can honestly demonstrate:

- direct x64 execution in QEMU
- framebuffer graphics
- keyboard-driven x64 programs
- a rotating wireframe cube
- x64 interrupt handling
- real driver-library integration

The boot-chain work may land in a `v0.6.x` release or receive its own milestone after implementation complexity is measured.

---

# Next Planned Milestone

## v0.6.1-alpha — Core Patch and Library Foundation

**Status:** Planned

Main goals:

```text
Stabilize the v0.6 core and define the first public library model.
```

Core patch work may include:

- bugs found after the first stand release
- stronger stand control-flow validation
- additional result/get regression tests
- cleaner stack-frame output
- better error wording
- documentation corrections
- removal of obsolete compatibility paths
- central compiler version metadata
- more consistent generated headers

Library foundation work may include:

- Library Authoring Specification
- `sentinel-lib.json`
- one library per repository
- supported Sentinel version metadata
- target support metadata
- documented register clobbers
- documented unsafe behavior
- examples and tests
- dependency declarations
- library status labels

Possible repository structure:

```text
sentinel-example-library/
├─ sentinel-lib.json
├─ README.md
├─ commands/
├─ examples/
├─ tests/
└─ docs/
```

Possible library statuses:

```text
Official
Approved
Community
Experimental
Unsafe
Deprecated
```

Possible review direction:

```text
GitHub stars may make a library a review candidate.
Stars do not automatically make a library approved.
```

Approval should depend on:

- manifest validity
- readable implementation
- clear license
- working examples
- tests
- supported Sentinel version
- supported target modes
- documented unsafe behavior
- documented register effects
- predictable generated output

Result target:

```text
Sentinel gains a documented public extension model
without opening or weakening the private compiler core.
```

---

# Planned Library Families

These are architectural directions, not current built-in libraries.

## graphics

Possible responsibilities:

- framebuffer initialization metadata
- pixel drawing
- line drawing
- rectangles
- text rendering
- image blitting
- double buffering
- primitive 2D rendering
- future wireframe rendering support

Minimum useful direction:

```text
clear()
pixel()
line()
present()
```

Dependencies:

- working x64 boot chain
- framebuffer information
- memory layout rules
- input support
- stable calling conventions

---

## files

Possible responsibilities:

- disk-sector access
- storage abstractions
- simple filesystem structures
- directory and file operations
- filesystem metadata
- basic read/write helpers

This library must not pretend storage is safe before:

- disk I/O rules are defined
- buffer ownership is defined
- filesystem corruption behavior is documented
- failure paths are testable

---

## BTK

`BTK` is a planned low-level data/input and device-building direction.

Possible responsibilities:

- structured input tokens
- device data decoding
- PCI-oriented helper construction
- keyboard and mouse data handling
- controller state processing
- reusable driver-building primitives

The final BTK architecture and exact name expansion remain subject to design.

---

## syler

`syler` is a planned low-level system organization library.

Possible responsibilities:

- memory-region composition
- register-transfer planning
- queue-oriented system work
- cache-aware data placement
- reusable kernel layout structures
- controlled low-level orchestration

This direction requires significant architecture work and should not be treated as a simple utility library.

---

# Future Milestones

## v0.7-alpha — x32 Backend and Optimizer Foundation

**Status:** Planned

Main target:

```text
Repair the x32 backend while introducing a cleaner optimizer structure.
```

x32 work may include:

- target-specific register generation
- 32-bit expression codegen
- 32-bit stack behavior
- 32-bit function arguments
- target-specific std support decisions
- invalid x64-register prevention
- x32 NASM regression tests
- x32 binary validation

Optimizer foundation may include:

- unused runtime-helper removal
- string literal deduplication
- unused safe step-wrapper removal
- redundant stack-operation cleanup
- label cleanup
- basic constant simplification
- more focused peephole passes
- separation of readable and compact output goals

Result target:

```text
Sentinel gains a usable x32 backend and a structured
foundation for smaller generated assembly.
```

---

## v0.7.1-alpha — Targeted Output Pruning

**Status:** Planned

Working name:

```text
TOP = Targeted Output Pruning
```

Possible responsibilities:

- remove unreachable emitted blocks
- emit only required runtime helpers
- deduplicate repeated strings
- deduplicate repeated generated bodies
- remove unused function-step wrappers
- simplify generated control flow
- reduce unnecessary register saves
- reduce unnecessary stack allocation
- provide readable and compact output modes

Important rule:

```text
Optimization must not make generated assembly impossible to inspect.
```

Sentinel should remain transparent even when output becomes smaller.

---

## v0.8-alpha — Tooling and Developer Experience

**Status:** Planned

Possible goals:

- browser playground
- improved public editor
- syntax highlighting
- generated ASM viewer
- diagnostic explorer
- project templates
- example runner
- documentation-integrated examples
- command reference search
- downloadable starter projects
- compiler build metadata
- easier test execution
- library discovery interface

The current local IDE is experimental and is not a release blocker.

The public tooling should only become a priority after the compiler and execution paths are stable enough to demonstrate.

---

## v0.9-beta — Stability, ABI, and Documentation

**Status:** Planned

Main goal:

```text
Freeze the core language behavior before v1.0-beta.
```

Possible work:

- larger regression suite
- stable syntax rules
- stable semantic rules
- stable core diagnostics
- documented x64 ABI
- documented stack alignment
- documented register clobbers
- documented library format
- complete error reference
- complete examples
- version compatibility policy
- migration guides
- contribution rules
- public issue templates
- release automation
- documentation review
- removal of dead experimental syntax

Beta rule:

```text
New features become less important than predictable behavior.
```

---

## v1.0-beta — Stable Experimental OSDev Platform

**Status:** Future

Main goal:

```text
Provide a stable experimental OSDev-first Sentinel platform.
```

Possible release requirements:

- stable documented syntax
- stable core semantics
- stable diagnostic meanings
- reliable x64 execution path
- documented boot process
- documented ABI
- tested `lib(std)` baseline
- tested library format
- usable graphics and input direction
- reliable generated NASM
- complete public examples
- complete specification
- complete wiki
- clear unsupported behavior
- migration policy
- reproducible release tests

`v1.0-beta` does not mean Sentinel replaces every mature systems language.

It means:

```text
The core Sentinel model becomes stable enough
for serious experimental OS development.
```

---

# Priority Rules

When roadmap goals conflict, use this priority order:

1. Correctness
2. Executable capability
3. Semantic safety
4. Compiler architecture
5. Documentation
6. Libraries
7. Optimization
8. Tooling
9. Marketing

Examples:

```text
A real boot chain is more important than adding ten graphics commands.
```

```text
Correct stand lifetime is more important than shorter syntax.
```

```text
A tested library format is more important than a large Library Hub.
```

```text
A clear compiler error is more important than allowing ambiguous code.
```

---

# Release Validation Rules

A Sentinel release should not be considered complete only because the compiler starts.

Each release should have:

- one primary positive stress test
- focused negative semantic tests
- NASM compilation validation
- target-specific validation
- generated assembly inspection
- documentation updates
- roadmap updates
- status updates
- a preserved release backup

Current major validation programs:

| Test | Purpose |
| :--- | :--- |
| Kernel Beast | Large x64 regression |
| Stand Beast | Temporary function-state validation |
| x16 Sentinel boot | Boot-sector and QEMU validation |

Important:

```text
One large meaningful example is preferred over
dozens of tiny public examples with no architectural connection.
```

Small internal negative tests remain useful for diagnostics.

---

# Explicit Non-Goals

The following are not immediate goals:

- replacing C everywhere
- replacing C++ everywhere
- replacing Rust everywhere
- hiding generated machine behavior
- adding desktop application frameworks
- adding a garbage-collected runtime
- building every possible library into the compiler
- supporting every architecture before x86 paths are stable
- creating a package hub before the library format works
- claiming production safety during alpha development

Sentinel should remain focused.

---

# Version Table

| Version | Status | Main Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 core |
| `v0.3-alpha` | Completed | Semantic hardening |
| `v0.4-alpha-stable` | Completed | First built-in std commands |
| `v0.5-alpha` | Completed | Kernel Toolkit Preview |
| `v0.6-alpha` | Current | Core Language Completion |
| `v0.6.1-alpha` | Planned | Core patch and library foundation |
| `v0.7-alpha` | Planned | x32 backend and optimizer foundation |
| `v0.7.1-alpha` | Planned | Targeted Output Pruning |
| `v0.8-alpha` | Planned | Tooling and playground |
| `v0.9-beta` | Planned | Stability, ABI, tests, and documentation |
| `v1.0-beta` | Future | Stable experimental OSDev platform |

The x64 boot chain is the current critical engineering track and may receive a dedicated `v0.6.x` milestone when its implementation scope is finalized.

---

# Current Public Position

Sentinel remains experimental alpha software.

It is not production-ready.

It is not a complete operating system framework.

It does not yet have a complete x64 boot execution path.

However, Sentinel now has:

- a real compiler pipeline
- readable NASM output
- flat binary generation
- semantic diagnostics before NASM
- a working x16 boot-sector path
- a strong x64 language and code-generation path
- persistent flat storage
- temporary function stack storage
- explicit step data flow
- result-producing functions
- a built-in OSDev command layer
- passed Kernel Beast validation
- passed Stand Beast compilation validation
- a documented route toward libraries and complete kernel execution

Current honest description:

```text
Sentinel is an experimental OSDev-first compiler
that has moved beyond syntax experiments and is now
building the execution, library, and tooling layers
required for serious low-level development.
```
````
