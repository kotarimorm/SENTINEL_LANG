# SENTINEL_LANG

Experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel Lang is an experimental systems programming language that compiles `.sl` source code into NASM assembly and then into a flat binary.

It is designed as a practical middle ground between readable high-level syntax and low-level assembly control.

## Transparent Build Model

Sentinel does not directly hide machine code behind an opaque backend.

The current build path is:

~~~text
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
~~~

The Sentinel compiler backend is currently private, but the generated NASM output is explicit and inspectable.

Users can:

- inspect generated `.asm` files
- modify generated NASM manually
- assemble the output with NASM themselves
- compare Sentinel source with generated assembly
- debug the resulting binary using normal low-level tools

Sentinel does not ask users to blindly trust hidden machine code.

The trust boundary is NASM:

~~~text
Sentinel generates assembly.
NASM generates the final binary.
~~~

If you trust NASM and inspect the generated assembly, you can verify what Sentinel is asking NASM to build.

> Sentinel compiler core is private, but Sentinel output is transparent: `.sl → readable NASM → NASM → flat binary`.
---
## Documentation

Sentinel Lang Wiki:

https://kotarimorm.github.io/SENTINEL_LANG/

## Current Status

| Field | Value |
| :--- | :--- |
| **Version** | `v0.4-alpha-stable` |
| **Main target** | `x64` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Project type** | Experimental systems language |
| **Main focus** | OSDev / kernel experiments |
| **Stability** | Alpha stable milestone |

---

## v0.4-alpha-stable Overview

Sentinel `v0.4-alpha-stable` introduces the first built-in OSDev helper library:

```sl
lib(std)
```

This release builds on the `v0.3-alpha` compiler hardening work and adds a small, direct, hardware-oriented standard command pack.

The goal is not to create a huge standard library yet.

The goal is simple:

```text
Give Sentinel its first clean OSDev helper layer.
Keep generated code explicit.
Keep broken programs rejected before NASM.
```

Key improvements:

| Area | Status |
| :--- | :--- |
| **Library declaration syntax** | Working |
| **`lib(std)` support** | Working |
| **std command parsing** | Working |
| **std semantic validation** | Working |
| **std x64 codegen** | Working |
| **Port I/O helpers** | Working |
| **VGA helpers** | Working |
| **IRQ helpers** | Working |
| **x64-only std guard** | Working |
| **Large std stress tests** | Passed |

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
| **C/Rust replacement** | Core semantics are still evolving |
| **Complete OS framework** | OS libraries are still early |
| **Safe language yet** | Type checking and memory safety are incomplete |
| **Full inline ASM system** | `low-code` is currently limited |
| **Desktop app framework** | Future work |
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
.sl  ->  Lexer  ->  Parser  ->  AST  ->  Semantics  ->  NASM  ->  .bin
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

Current `lib(std)` rule:

```text
lib(std) is x64-only in v0.4-alpha-stable.
```

---

## v0.4-alpha-stable Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Lexer** | Working | Tokenizes Sentinel source |
| **Parser** | Working | Builds AST |
| **AST** | Working | Internal program representation |
| **Semantic analyzer** | Working | Catches invalid Sentinel before NASM |
| **NASM codegen** | Working | Generates NASM output |
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
| **lib(std)** | Working | First x64 OSDev helper pack |
| **read_port()** | Working | std expression |
| **write_port()** | Working | std statement with expression args |
| **pic_eoi()** | Working | Sends EOI to master PIC |
| **irq_disable/enable** | Working | Emits `cli` / `sti` |
| **vga_print/vga_clear** | Working | std VGA helpers |

---

## lib(std)

`v0.4-alpha-stable` adds the first built-in standard OSDev command pack:

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

This fails with semantic error `S026`.

---

## std Commands

Current `lib(std)` commands:

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

---

## std Example

```sl
lib(std)
x64
type(console)

local pic_port = 0x20
local pic_value = 0x20

local keyboard_port = 0x60
local keyboard_value = 0

create keyboard_poll()
    (1) vga_print("keyboard poll")
    (2) redo: keyboard_value to read_port(keyboard_port)
    (3) write_port(pic_port, pic_value)
    (4) pic_eoi()
    (5) vga_print("keyboard done")

vga_clear()
vga_print("std begin")

irq_disable()
start keyboard_poll()
irq_enable()

vga_print("std done")
halt()
```

---

## Port I/O

Sentinel can now express basic port I/O through `lib(std)`.

Read from port:

```sl
local key = read_port(0x60)
```

Write to port:

```sl
write_port(0x20, 0x20)
```

Write using storage:

```sl
local port = 0x20
local value = 0x20

write_port(port, value)
```

This generates direct x64 NASM-style port I/O.

---

## Step Functions

One unique Sentinel idea is numbered function stages.

```sl
create boot_sequence()
    (1) vga_print("boot: cpu")
    (2) vga_print("boot: memory")
    (3) vga_print("boot: drivers")
    (4) vga_print("boot: done")

start boot_sequence()
```

This is useful for OSDev-style debugging where each stage of initialization matters.

Safe no-parameter step calls are supported:

```sl
start boot_sequence(2)
```

Parameterized function step calls are blocked because step labels do not prepare argument registers.

---

## Flat Storage Model

Sentinel currently uses flat source-file storage.

```sl
local counter = 0
redo: counter to counter + 1
```

Important rule:

```text
local = flat storage declaration
redo  = mutation of existing storage
```

In `v0.4-alpha-stable`, function-local `local` declarations are still rejected.

Correct pattern:

```sl
local result = 0

create add(a, b)
    (1) redo: result to a + b
```

Invalid:

```sl
create add(a, b)
    (1) local result = a + b
```

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

> `low-code` supports emit-based byte output and selected low-level commands. Full raw inline assembly is not stable yet.

---

## Semantic Diagnostics

Sentinel rejects many invalid programs before NASM.

Examples:

```text
[SEMANTIC S009] Unknown function
[SEMANTIC S012] Function has no requested step
[SEMANTIC S017] Wrong argument count
[SEMANTIC S020] Unsafe parameterized step-call
[SEMANTIC S021] Unknown library
[SEMANTIC S022] std command used without lib(std)
[SEMANTIC S024] Wrong std command argument count
[SEMANTIC S026] lib(std) used outside supported mode
```

The goal is:

```text
Broken Sentinel should fail as Sentinel, not as NASM.
```

---

## Stress Tests

Sentinel `v0.4-alpha-stable` has survived multiple compiler stress tests and semantic hardening checks.

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
| **Core Hardening Beast v0.3** | flat-storage and ABI hardening stress test | Passed |
| **std Stress Test v0.4** | `lib(std)` commands, ports, IRQ helpers | Passed |
| **std Error Tests v0.4** | `S021`, `S022`, `S024`, `S026` | Passed |

---

## Known Limitations

| Area | Current Limitation |
| :--- | :--- |
| **lib(std)** | x64-only in v0.4-alpha-stable |
| **Type system** | Type checking is incomplete |
| **Memory safety** | Not implemented yet |
| **Return values** | No explicit `return` keyword yet |
| **Result access** | `get result()` depends on generated `rax` value |
| **Strings** | No real string comparison yet |
| **Arrays** | No bounds checking yet |
| **Exceptions** | `try/catch` is syntax-only |
| **Structs** | Parsed / experimental |
| **Inline ASM** | Only `emit` and selected low-level commands are stable |
| **Networking** | Not implemented yet |
| **Self-hosting** | Long-term goal |

---

## Important v0.4-alpha-stable Fix

`v0.4-alpha-stable` adds the first working `lib(std)` OSDev helper layer.

Example:

```sl
lib(std)
x64
type(console)

local key = read_port(0x60)

vga_print("read ok")
halt()
```

Generated style:

```asm
push rdx
mov  rax, 96
mov  dx, ax
in   al, dx
movzx rax, al
pop  rdx
mov  [sl_var_key], rax
```

This gives Sentinel a clean way to talk to hardware ports without writing raw assembly in every program.

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
v0.4-alpha-stable
    │
    ▼
first lib(std) OSDev command pack
    │
    ▼
v0.5-alpha
    │
    ▼
demo kernel / mini OS + documentation site
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
| **v0.4-alpha-stable** | First `lib(std)` OSDev command pack |
| **v0.5-alpha** | Demo kernel / mini OS and GitHub Pages documentation site |
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
| **Bootloader research** | Working / experimental |
| **VGA text output** | Working |
| **Basic port I/O** | Working through `lib(std)` |
| **IRQ/PIC experiments** | Early support through `pic_eoi()` |
| **OSDev learning** | Good target |
| **Driver experiments** | Future |
| **Networking** | Future |
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

Sentinel is still early, but the `v0.4-alpha-stable` compiler now has a hardened experimental core, semantic diagnostics, flat storage validation, safer function step rules, x64 register preservation fixes, and the first working `lib(std)` OSDev helper pack.
