# SENTINEL_LANG

Experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel Lang is an experimental systems programming language that compiles `.sl` source code into NASM assembly and then into a flat binary. It is designed as a practical middle ground between readable high-level syntax and low-level assembly control.

---

## Current Status

| Field | Value |
| :--- | :--- |
| **Version** | `v0.2-alpha` |
| **Main target** | `x64` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Project type** | Experimental systems language |
| **Main focus** | OSDev / kernel experiments |
| **Stability** | Alpha |

---

## What Sentinel Is

Sentinel is a low-level experimental language focused on operating system development. It is not a general-purpose scripting language and it is not trying to hide the hardware. Instead, it provides a simpler syntax over low-level concepts while still producing explicit NASM output.

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

### What Sentinel Is Not

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
Code Generator
    │
    ▼
NASM Assembly
    │
    ▼
 Flat Binary
```

**Short version:**
```text
.sl  ->  Lexer  ->  Parser  ->  AST  ->  NASM  ->  .bin
```

---

## Architecture Modes

| Mode | Description | Target Use |
| :--- | :--- | :--- |
| **x16** | 16-bit real mode | BIOS / bootloader experiments |
| **x32** | 32-bit protected mode | experimental kernels |
| **x64** | 64-bit long mode | modern kernel experiments |

**Current strongest path:**
```text
x64 + type(console)
```

---

## v0.2-alpha Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Lexer** | Working | Tokenizes Sentinel source |
| **Parser** | Working | Builds AST |
| **NASM codegen** | Working | Generates x64 NASM output |
| **Flat binary pipeline** | Working | Uses NASM -f bin |
| **x64 mode** | Working | Main tested mode |
| **type(console)** | Working | VGA text output |
| **local** | Working | Global storage currently |
| **redo** | Working | Numeric mutation |
| **if / then / end** | Working | Numeric conditions |
| **while** | Working | Numeric loops |
| **repeat** | Working | Literal and variable count |
| **create functions** | Working | Step-based functions |
| **start function calls** | Working | Normal calls |
| **Function arguments** | Working | x64 register-based |
| **get ... result()** | Experimental | Uses current rax result |
| **Arrays** | Working | Numeric arrays |
| **Array indexing** | Working | Fixed in v0.2-alpha |
| **low-code** | Working | emit bytes only |
| **try/catch** | Syntax-only | No real exception runtime yet |
| **FREERAM** | Experimental | Currently clears variable storage |

---

```md
## Example

```sl
x64
type(console)

local x = 10
local y = 5

create add(a, b)
    (1) local sum = a + b
    (2) console_print("add done")

local math_result = get add(x, y) result()

if math_result > 10 then
    console_print("result ok")
end
```

```md
### Generated NASM Style

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

Sentinel supports low-level byte emission through low-code.

```sl
low-code:
    emit 0x90
    emit 0x90
    emit 0x90
```

**Generated NASM:**
```asm
db 0x90
db 0x90
db 0x90
```

**Current rule:**
> `low-code` supports emit-based byte output. Full raw inline assembly is not stable yet.

---

## Stress Tests

Sentinel v0.2-alpha has survived multiple large compiler stress tests.

```md
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
| **Semantic Killer** | scope collision edge case | Found bug |

---

## Known Limitations

| Area | Current Limitation |
| :--- | :--- |
| **Scopes** | Function locals can still collide with globals |
| **Locals** | Function locals are emitted as global labels |
| **Return values** | No explicit return keyword yet; `get result()` depends on generated rax value |
| **Strings** | No real string comparison yet |
| **Arrays** | No bounds checking yet |
| **Exceptions** | `try/catch` is syntax-only |
| **Type system** | Type checking is incomplete |
| **Inline ASM** | Only emit is stable |
| **Safety** | Memory safety is not implemented yet |

### Important v0.2-alpha Bug Found

The compiler currently has incomplete scope handling.

**Example:**
```sl
local a = 10
create test(a)
    (1) local a = a + 1
```

This can generate duplicate NASM labels:
```asm
sl_var_a dq 10
sl_var_a dq 0
```

**NASM error:**
```text
label `sl_var_a` inconsistently redefined
```

This is planned to be fixed in `v0.3-alpha` with proper scope-aware label generation.

### Planned Scope Model

| Source Concept | Planned Internal Label |
| :--- | :--- |
| **Global variable** | `sl_var_counter` |
| **Function local** | `sl_func_math_var_sum` |
| **Function parameter** | register / stack slot |
| **Temporary value** | `sl_tmp_0` |

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
scopes + semantic errors
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

### Roadmap Snapshot

| Version | Goal |
| :--- | :--- |
| **v0.2-alpha** | Working x64 compiler core |
| **v0.3-alpha** | Scope system and semantic diagnostics |
| **v0.4-alpha** | Better OSDev helpers |
| **v0.5-alpha** | Demo kernel / mini OS |
| **v0.6-alpha** | Low-level standard libraries |
| **v0.7-beta** | Testing and documentation hardening |
| **v0.8-beta** | Host tooling research |
| **v1.0** | Stable experimental OSDev language |

---

## Repository Structure

```text
examples/       Sentinel source examples
generated/      Generated NASM output
screenshots/    IDE and compiler screenshots
README.md       Project overview
ROADMAP.md      Development roadmap
SPECIFICATION.md Language specification
```

---

## Example Use Cases

| Use Case | Status |
| :--- | :--- |
| **x64 kernel experiments** | Good target |
| **bootloader research** | Planned / experimental |
| **VGA text output** | Working |
| **OSDev learning** | Good target |
| **driver experiments** | Future |
| **desktop applications** | Future |
| **self-hosting** | Long-term goal |

---

## Design Philosophy

Sentinel follows a simple rule:
> **Be readable, but stay close to the machine.**

The language should make low-level programming easier to write, but not hide what the generated code does.

---

## Final Goal

The long-term goal is to build a practical low-level language that can be used to experiment with kernels, bootloaders, drivers, and eventually larger OSDev systems.

Sentinel is still early, but the `v0.2-alpha` compiler already has a working core pipeline and can generate real NASM output from non-trivial programs.
