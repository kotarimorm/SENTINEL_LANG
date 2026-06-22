# Sentinel Lang Status

> Current development status for Sentinel Lang.

---

## Current Version

| Field | Value |
| :--- | :--- |
| **Version** | `v0.3-alpha` |
| **Main target** | `x64` |
| **Secondary target** | `x16` boot-sector experiments |
| **Main mode** | `type(console)` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Stability** | Alpha |
| **Primary focus** | OSDev / kernel experiments |

---

## Status Summary

```text
Lexer           Working
Parser          Working
AST             Working
Semantic checks Working
x64 codegen     Working
x16 boot output Working / experimental
Flat binary     Working
Optimizer       Working
Libraries       Planned for v0.4-alpha
```

Sentinel `v0.3-alpha` focuses on compiler core hardening.

The compiler now catches several invalid semantic patterns before NASM.

---

## Core Status

| Area | Status | Notes |
| :--- | :--- | :--- |
| Lexer | Working | Tokenizes Sentinel source |
| Parser | Working | Builds AST |
| AST | Working | Internal representation |
| Semantic analyzer | Working | Rejects invalid Sentinel before NASM |
| x64 codegen | Working | Main tested backend |
| x16 codegen | Experimental | Boot-sector style output works |
| Optimizer | Working | Simple ASM-level optimization pass |
| NASM pipeline | Working | Produces flat binaries |
| Diagnostics | Improved | Semantic errors now include fixes |
| Register safety | Improved | Generated print preserves `rsi` |
| Libraries | Planned | `lib(std)` begins in `v0.4-alpha` |

---

## Working Language Features

| Feature | Status | Notes |
| :--- | :--- | :--- |
| `x16` | Experimental | BIOS / bootloader path |
| `x32` | Experimental | Protected-mode experiments |
| `x64` | Working | Main tested mode |
| `type(console)` | Working | VGA-style console output |
| `local` | Working | Flat storage declaration |
| `redo` | Working | Mutation of existing storage |
| `if / then / end` | Working | Numeric conditions |
| `while` | Working | Numeric loops |
| `repeat` | Working | Literal and variable counts |
| `create` functions | Working | Numbered function steps |
| `start` calls | Working | Normal calls and safe step calls |
| Function arguments | Working | x64 register-based |
| `get ... result()` | Experimental | Depends on `rax` |
| Arrays | Working | Numeric arrays |
| Array indexing | Working | Literal and variable indexing |
| `low-code` | Working | `emit` and selected low-level commands |
| `try/catch` | Syntax-only | No runtime exception model |
| `FREERAM` | Experimental | Clears variable storage |

---

## v0.3-alpha Semantic Diagnostics

| Code | Meaning | Status |
| :--- | :--- | :--- |
| `S001` | Reserved keyword used as name | Working |
| `S002` | Duplicate function | Working |
| `S003` | Duplicate storage | Working |
| `S004` | Duplicate parameter | Working |
| `S005` | Parameter/storage collision | Working |
| `S007` | Cannot `redo` parameter | Working |
| `S008` | Unknown storage mutation | Working |
| `S009` | Unknown function | Working |
| `S010` | Recursive call unsupported | Working |
| `S011` | `local` inside function blocked | Working |
| `S012` | Missing function step | Working |
| `S013` | Invalid `redo` target | Working |
| `S014` | Storage/function collision | Working |
| `S015` | Unknown storage symbol | Working |
| `S016` | Mixed step selector and args | Working |
| `S017` | Wrong function argument count | Working |
| `S018` | Duplicate function step | Working |
| `S019` | `FREERAM` unknown storage | Working |
| `S020` | Unsafe step-call on parameterized function | Working |

---

## Important v0.3-alpha Fixes

### Semantic Errors Before NASM

Invalid Sentinel should fail as Sentinel, not as NASM.

Examples now caught before codegen/NASM:

```text
unknown functions
unknown storage
duplicate storage
missing function steps
wrong function argument counts
unsafe parameterized step calls
```

---

### Flat Storage Discipline

Sentinel does not use classical lexical scopes in `v0.3-alpha`.

Current model:

```text
local = flat storage declaration
redo  = mutation of existing storage
params = temporary input names
```

Function-local `local` declarations are blocked for now because storage allocation inside function steps can create unsafe duplicate NASM labels.

Recommended style:

```sl
local result = 0

create add(a, b)
    (1) redo: result to a + b

start add(x, y)
```

---

### Register Preservation

Generated print calls now preserve `rsi`.

This prevents `console_print` from destroying the second x64 function argument.

Expected generated shape:

```asm
push rsi
lea  rsi, [rel sl_pstr_0]
call sl_print_str
pop  rsi
```

---

### Safe Step Calls

Step calls are allowed for no-parameter functions:

```sl
create boot_report()
    (1) console_print("one")
    (2) console_print("two")

start boot_report(2)
```

Step calls are blocked for parameterized functions:

```sl
create add(a, b)
    (1) console_print("add")
    (2) redo: result to a + b

start add(2)
```

This fails with `S020`.

---

## Known Limitations

| Area | Current Limitation |
| :--- | :--- |
| Standard libraries | Planned for `v0.4-alpha` |
| `get result()` | Still depends on `rax` |
| Type system | Incomplete |
| String comparison | Not stable |
| Array bounds | Not checked |
| Exceptions | `try/catch` is syntax-only |
| Memory safety | Not implemented |
| Networking | Not implemented |
| Filesystem | Not implemented |
| Full inline ASM | Backend-dependent / not fully stable |

---

## Recommended v0.3-alpha Style

Use ordered flat-storage style:

```sl
x64
type(console)

local counter = 0
local limit = 3

create tick()
    (1) redo: counter to counter + 1
    (2) console_print("tick")

repeat(limit)
    start tick()
end

if counter == 3 then
    console_print("ok")
end
```

Rules:

| Rule | Reason |
| :--- | :--- |
| Declare storage with top-level `local` | Keeps flat storage explicit |
| Mutate with `redo` | Avoids duplicate declarations |
| Use named args for data | Keeps `start func(N)` as step selector |
| Use step calls only on no-param functions | Avoids stale argument registers |
| Keep functions ordered by boot stage | Improves OSDev readability |

---

## v0.4-alpha Direction

`v0.4-alpha` should begin the first OSDev command library work.

Initial direction:

```text
lib(std)
```

Possible commands:

```text
halt()
nop()
panic(msg)
read_port(port)
write_port(port, value)
io_wait()
pic_eoi()
vga_clear()
vga_print(msg)
```

`v0.4-alpha` should not try to become a full standard library.

It should provide small compile-time OSDev commands that lower directly into low-level code.

---

## Public Repository Status

| Item | Status |
| :--- | :--- |
| README | Updating for `v0.3-alpha` |
| Specification | Needs v0.3 semantic/ABI update |
| Roadmap | Needs v0.3/v0.4 refresh |
| Test report | Updated for `v0.3-alpha` |
| Compiler source | Private |
| Examples | Needs ordered v0.3 examples |
| Generated ASM | Private / local testing |

---

## Final Status

Sentinel Lang `v0.3-alpha` is a real experimental compiler stage.

It can compile large ordered flat-storage programs into NASM assembly and flat binary output.

It now includes semantic diagnostics before NASM and has passed core hardening tests.

Current priority:

```text
Finish v0.3-alpha docs.
Keep the core stable.
Begin v0.4-alpha lib(std) planning.
```
