# SENTINEL_LANG

Experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel Lang is an experimental systems programming language that compiles `.sl` source code into NASM assembly and then into a flat binary.

It is designed as a practical middle ground between readable high-level syntax and low-level assembly control.

---

## Current Status

| Field | Value |
| :--- | :--- |
| **Version** | `v0.3-alpha` |
| **Main target** | `x64` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Project type** | Experimental systems language |
| **Main focus** | OSDev / kernel experiments |
| **Stability** | Alpha |

---

## v0.3-alpha Core Hardening

Sentinel `v0.3-alpha` focuses on compiler core stability.

This release hardens the language core before larger OSDev libraries are added.

Key improvements:

| Area | Status |
| :--- | :--- |
| **Semantic diagnostics** | Working |
| **Flat storage validation** | Working |
| **Function step validation** | Working |
| **Argument count validation** | Working |
| **Unsafe step-call protection** | Working |
| **x64 register preservation fixes** | Working |
| **Large core hardening tests** | Passed |

`v0.3-alpha` does not introduce large standard libraries yet.

The goal is simple:

```text
Reject broken Sentinel before NASM.
Keep valid low-level programs compiling.
Make the core harder to break.
```

---
## What Sentinel Is

Sentinel is an OSDev-first low-level language focused on bootloaders, kernels, flat binaries, and direct NASM-oriented output.

It is designed to make low-level code easier to write without hiding the machine.

```text
Readable Sentinel source
        │
        ▼
Compiler pipeline
        │
        ▼
Semantic checks
        │
        ▼
NASM assembly
        │
        ▼
Flat binary
```

---

## What Sentinel Is Not

Sentinel is currently not:

| Not A | Reason |
| :--- | :--- |
| **Production language** | Still alpha |
| **C/Rust replacement** | Core semantics are still evolving |
| **Complete OS framework** | OS libraries are planned later |
| **Safe language yet** | Type checking and memory safety are incomplete |
| **Full inline ASM system** | `low-code` is currently limited |
| **Public compiler backend** | Compiler source is private for now |

---

## Compilation Pipeline

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

## Architecture Modes

| Mode | Description | Target Use |
| :--- | :--- | :--- |
| **x16** | 16-bit real mode | BIOS / bootloader experiments |
| **x32** | 32-bit protected mode | experimental kernels |
| **x64** | 64-bit long mode | modern kernel experiments |

Current strongest path:

```text
x64 + type(console)
```

---

## v0.3-alpha Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Lexer** | Working | Tokenizes Sentinel source |
| **Parser** | Working | Builds AST |
| **AST** | Working | Internal program representation |
| **Semantic analyzer** | Working | Catches invalid Sentinel before NASM |
| **NASM codegen** | Working | Generates x64 NASM output |
| **Flat binary pipeline** | Working | Uses NASM `-f bin` |
| **x64 mode** | Working | Main tested mode |
| **x16 boot sector output** | Working | Can generate boot-sector style binaries |
| **type(console)** | Working | VGA text output |
| **local** | Working | Declares flat storage |
| **redo** | Working | Mutates existing storage |
| **if / then / end** | Working | Numeric conditions |
| **while** | Working | Numeric loops |
| **repeat** | Working | Literal and variable count |
| **create functions** | Working | Step-based functions |
| **start function calls** | Working | Normal calls and safe step calls |
| **Function arguments** | Working | x64 register-based |
| **Argument validation** | Working | Checks function argument counts |
| **Function step validation** | Working | Detects missing or unsafe step calls |
| **Register preservation** | Improved | Protects `rsi` around generated print calls |
| **get ... result()** | Experimental | Uses current `rax` result |
| **Arrays** | Working | Numeric arrays |
| **Array indexing** | Working | Literal and variable indexing |
| **low-code** | Working | `emit` and selected low-level commands |
| **try/catch** | Syntax-only | No real exception runtime yet |
| **FREERAM** | Experimental | Currently clears variable storage |

---

## Example

```sl
x64
type(console)

local x = 10
local y = 5
local sum = 0

create add(a, b)
    (1) redo: sum to a + b
    (2) console_print("add done")

start add(x, y)

if sum > 10 then
    console_print("result ok")
end
```

---

## Generated NASM Style

Sentinel generates NASM-style output:

```asm
mov  rax, [sl_var_x]
mov  rdi, rax

mov  rax, [sl_var_y]
mov  rsi, rax

call sl_func_add
mov  [sl_var_math_result], rax
```

Generated binaries are intentionally low-level and explicit.

---

## Step Functions

One unique Sentinel idea is numbered function stages.

```sl
create boot_sequence()
    (1) console_print("boot: cpu")
    (2) console_print("boot: memory")
    (3) console_print("boot: drivers")
    (4) console_print("boot: done")

start boot_sequence()
```

This is useful for OSDev-style debugging where each stage of initialization matters.

---

## Low-Code Blocks

Sentinel supports low-level byte emission through `low-code`.

```sl
low-code:
    emit 0x90
    emit 0x90
    emit 0x90
```

Generated NASM:

```asm
db 0x90
db 0x90
db 0x90
```

Current rule:

> `low-code` supports `emit` and selected low-level commands. Full arbitrary inline assembly is backend-dependent and not stable yet.

---

## Stress Tests

Sentinel `v0.3-alpha` has survived multiple compiler stress tests and semantic hardening checks.

| Test | Purpose | Result |
| :--- | :--- | :--- |
| **Hello x64** | Basic output | Passed |
| **Repeat Test** | `repeat()` loops | Passed |
| **While Test** | `while` loops | Passed |
| **Function Test** | `create/start` | Passed |
| **Result Test** | `get result()` | Passed |
| **Array Test** | arrays and indexing | Passed |
| **Beast Test** | medium stress program | Passed |
| **Ultra Beast Test** | large stress program | Passed |
| **Turtle Abomination** | heavy control-flow stress | Passed |
| **Semantic Killer** | invalid semantic cases | Passed |
| **Register Clobber Test** | verifies print does not destroy function arguments | Passed |
| **Core Hardening Beast v0.3.1** | large flat-storage and ABI hardening stress test | Passed |

---

## Known Limitations

| Area | Current Limitation |
| :--- | :--- |
| **Standard libraries** | Large libraries are not included yet |
| **Return values** | No explicit `return` keyword yet |
| **Result access** | `get result()` still depends on generated `rax` value |
| **Strings** | No real string comparison yet |
| **Arrays** | No bounds checking yet |
| **Exceptions** | `try/catch` is syntax-only |
| **Type system** | Type checking is incomplete |
| **Inline ASM** | Full arbitrary inline ASM is not stable yet |
| **Memory safety** | Memory safety is not implemented yet |
| **Networking** | No network stack yet |
| **Filesystem** | No filesystem layer yet |

---

## Important v0.3-alpha Fix

Sentinel `v0.3-alpha` adds semantic diagnostics before NASM code generation.

The compiler now rejects known invalid semantic patterns earlier, with readable Sentinel-level errors.

Example:

```sl
local a = 10

create test(a)
    (1) console_print("bad")
```

This now fails before NASM:

```text
[SEMANTIC S005] Parameter `a` conflicts with storage declared on line 1.
```

Another example:

```sl
create boot()
    (1) console_print("boot")

start boot(9)
```

This now fails before NASM:

```text
[SEMANTIC S012] Function `boot` has no step `(9)`.
```

The goal of `v0.3-alpha` is not a classical scope system.

Sentinel uses flat storage discipline:

```text
local = flat storage declaration
redo  = mutation of existing storage
```

Broken Sentinel should fail as Sentinel, not as NASM.

---
## Flat Storage Model

Sentinel does not use classical lexical scopes in `v0.3-alpha`.

Storage is flat and explicit.

| Source Concept | Meaning |
| :--- | :--- |
| **Top-level `local`** | Declares flat storage |
| **`redo`** | Mutates existing storage |
| **Function parameter** | Temporary input name passed through registers |
| **Function step** | Numbered compiler-visible function stage |
| **Function storage** | Use top-level storage and mutate with `redo` |

Recommended style:

```sl
local result = 0

create add(a, b)
    (1) redo: result to a + b

start add(x, y)
```
---

## Project Direction

```text
v0.1-alpha
    │
    ▼
basic compiler foundation
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
kernel-oriented helpers
    │
    ▼
v0.5-alpha
    │
    ▼
first demo OS prototype
    │
    ▼
v1.0
    │
    ▼
stable OSDev language core
```

---

## Roadmap Snapshot

| Version | Goal |
| :--- | :--- |
| **v0.2-alpha** | Working x64 compiler core |
| **v0.3-alpha** | Core hardening and semantic diagnostics |
| **v0.4-alpha** | First `lib(std)` OSDev command pack |
| **v0.5-alpha** | Demo kernel / mini OS |
| **v0.6-alpha** | Runtime and low-level library expansion |
| **v0.7-alpha** | Driver and hardware helper experiments |
| **v0.8-alpha** | Host tooling research |
| **v0.9-beta** | Testing and documentation hardening |
| **v1.0** | Stable experimental OSDev language |
---

## Repository Structure

```text
README.md         Project overview
SPECIFICATION.md  Full language specification
ROADMAP.md        Development roadmap
TEST_REPORT.md    Compiler and language test status
status.md         Current development status
LICENSE           Project license
```

---

## Example Use Cases

| Use Case | Status |
| :--- | :--- |
| **x64 kernel experiments** | Good target |
| **Bootloader research** | Planned / experimental |
| **VGA text output** | Working |
| **OSDev learning** | Good target |
| **Driver experiments** | Future |
| **Desktop applications** | Future |
| **Self-hosting** | Long-term goal |

---

## Design Philosophy

Sentinel follows a simple rule:

> **Be readable, but stay close to the machine.**

The language should make low-level programming easier to write, but not hide what the generated code does.

Sentinel is not designed to replace C or C++ directly.

It is designed as an OSDev-first systems language for people who want readable low-level code while still understanding the generated output.

---

## Final Goal

The long-term goal is to build a practical low-level language for bootloaders, kernels, drivers, and larger OSDev systems.

Sentinel is still early, but the `v0.3-alpha` compiler now has a hardened experimental core with semantic diagnostics, flat storage validation, safer function step rules, x64 register preservation fixes, and successful large stress-test compilation.
