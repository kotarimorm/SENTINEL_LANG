# Sentinel Lang Status

**Current version:** `v0.4-alpha-stable`  
**Current phase:** First OSDev std helper pack  
**Main target:** `x64`  
**Project status:** Experimental alpha-stable milestone

---

## Summary

Sentinel Lang is an experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

`v0.4-alpha-stable` builds on the `v0.3-alpha` compiler hardening milestone and adds the first working built-in OSDev helper pack:

```sl
lib(std)
```

Current milestone result:

```text
Sentinel v0.4-alpha-stable code core is ready.
```

---

## Current Core Status

| Area | Status |
| :--- | :--- |
| Lexer | Working |
| Parser | Working |
| AST | Working |
| Semantic analyzer | Working |
| NASM codegen | Working |
| Optimizer | Basic / working |
| x64 output | Working |
| x16 boot output | Experimental / working |
| Flat binary pipeline | Working |
| IDE integration | Working locally |
| Compiler backend | Private |

---

## Language Status

| Feature | Status |
| :--- | :--- |
| `x16` | Experimental |
| `x32` | Experimental |
| `x64` | Main tested mode |
| `type(console)` | Working |
| `local` | Working |
| `redo` | Working |
| `if / then / else / end` | Working |
| `while` | Working |
| `repeat` | Working |
| `create` functions | Working |
| Numbered function steps | Working |
| `start` full calls | Working |
| Safe no-param step calls | Working |
| Function arguments | Working |
| `get ... result()` | Experimental |
| Arrays | Working |
| Array indexing | Working |
| `low-code` | Working / limited |
| `try/catch` | Syntax-only |
| `FREERAM` | Experimental |
| `lib(std)` | Working / x64-only |

---

## v0.3-alpha Hardening Status

`v0.3-alpha` introduced the semantic hardening layer.

Still active in `v0.4-alpha-stable`:

| Hardening Area | Status |
| :--- | :--- |
| Duplicate storage detection | Working |
| Unknown storage mutation detection | Working |
| Unknown function detection | Working |
| Missing function step detection | Working |
| Function argument count validation | Working |
| Parameter/storage collision detection | Working |
| Unsafe parameterized step-call protection | Working |
| x64 `rsi` print preservation | Working |

---

## v0.4-alpha-stable std Status

`v0.4-alpha-stable` adds the first built-in OSDev command pack.

Current std commands:

| Command | Status | Notes |
| :--- | :--- | :--- |
| `vga_print(value)` | Working | VGA console output helper |
| `vga_clear()` | Working | Clears VGA text buffer |
| `nop()` | Working | Emits `nop` |
| `halt()` | Working | Emits safe halt loop |
| `io_wait()` | Working | Emits port `0x80` wait |
| `read_port(port)` | Working | Expression, returns byte in `rax` |
| `write_port(port, value)` | Working | Statement, supports expressions |
| `pic_eoi()` | Working | Sends EOI to master PIC |
| `irq_disable()` | Working | Emits `cli` |
| `irq_enable()` | Working | Emits `sti` |

Current std limitation:

```text
lib(std) is x64-only in v0.4-alpha-stable.
```

---

## Current Semantic Diagnostics

| Code | Meaning | Status |
| :--- | :--- | :--- |
| `S001` | Reserved keyword used as name | Working |
| `S002` | Duplicate function | Working |
| `S003` | Duplicate storage | Working |
| `S004` | Duplicate parameter | Working |
| `S005` | Parameter conflicts with storage | Working |
| `S006` | Reserved / legacy parameter conflict slot | Reserved |
| `S007` | Cannot redo parameter directly | Working |
| `S008` | Cannot modify unknown storage | Working |
| `S009` | Unknown function | Working |
| `S010` | Recursive call unsupported | Working |
| `S011` | `local` inside function blocked | Working |
| `S012` | Missing function step | Working |
| `S013` | Invalid redo target | Working |
| `S014` | Storage conflicts with function | Working |
| `S015` | Unknown storage symbol | Working |
| `S016` | Mixed step selectors and arguments | Working |
| `S017` | Wrong argument count | Working |
| `S018` | Duplicate function step | Working |
| `S019` | FREERAM unknown storage | Working |
| `S020` | Unsafe step-call on parameterized function | Working |
| `S021` | Unknown library | Working |
| `S022` | std command/expression without `lib(std)` | Working |
| `S023` | Unknown std command | Defensive / available |
| `S024` | Wrong std command argument count | Working |
| `S025` | Reserved / legacy dynamic port restriction | Reserved |
| `S026` | `lib(std)` outside supported mode | Working |

---

## Current Testing Status

| Test Group | Result |
| :--- | :--- |
| Basic x64 compile | Passed |
| Function tests | Passed |
| Loop tests | Passed |
| Array tests | Passed |
| Result tests | Passed |
| Semantic error tests | Passed |
| Register clobber tests | Passed |
| v0.3 core hardening tests | Passed |
| std smoke tests | Passed |
| std port I/O tests | Passed |
| std IRQ helper tests | Passed |
| std big stress test | Passed |
| std semantic error tests | Passed |

Current test conclusion:

```text
v0.4-alpha-stable passed current validation.
```

---

## Known Limitations

| Area | Limitation |
| :--- | :--- |
| `lib(std)` | x64-only |
| Type system | Incomplete |
| Memory safety | Not implemented |
| Return values | No explicit `return` keyword |
| `get result()` | Depends on generated `rax` |
| Strings | No real string comparison |
| Arrays | No bounds checking |
| Exceptions | `try/catch` is syntax-only |
| Structs | Experimental |
| Inline ASM | `low-code` is limited |
| Networking | Not implemented |
| Driver stack | Not implemented |
| Self-hosting | Long-term goal |

---

## Recommended Current Style

Recommended `v0.4-alpha-stable` style:

```sl
lib(std)
x64
type(console)

local keyboard_port = 0x60
local keyboard_value = 0

create keyboard_poll()
    (1) vga_print("keyboard poll")
    (2) redo: keyboard_value to read_port(keyboard_port)
    (3) pic_eoi()

start keyboard_poll()

halt()
```

Core style rules:

```text
Declare storage with local.
Mutate storage with redo.
Use lib(std) for OSDev helpers.
Use x64 with lib(std).
Use step calls only for no-param functions.
```

---

## Next Target

Next planned milestone:

```text
v0.5-alpha
```

Primary goals:

- demo kernel / mini OS
- GitHub Pages documentation site
- better public examples
- clearer getting-started guide
- first real OSDev tutorial flow
- expanded docs for `lib(std)`

`v0.5-alpha` should focus on proving that Sentinel can be used to build a small readable OSDev prototype.

---

## Project Direction

```text
v0.1-alpha
    ↓
basic compiler foundation

v0.2-alpha
    ↓
working x64 compiler core

v0.3-alpha
    ↓
core hardening + semantic diagnostics

v0.4-alpha-stable
    ↓
first lib(std) OSDev helper pack

v0.5-alpha
    ↓
demo kernel / mini OS + documentation site

v1.0
    ↓
stable experimental OSDev language core
```

---

## Final Status

Sentinel `v0.4-alpha-stable` is the first version where the language has both:

```text
a hardened compiler core
```

and:

```text
a working OSDev helper library layer
```

This makes `v0.4-alpha-stable` an important transition point.

Sentinel is still alpha, but it is now moving from pure compiler core work toward practical OSDev usage.
