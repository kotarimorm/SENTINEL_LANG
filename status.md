# Sentinel Lang Status

**Current version:** `v0.5-alpha`  
**Current phase:** Kernel Toolkit Preview  
**Main target:** `x64`  
**Project status:** Experimental alpha milestone  
**Compiler backend:** Private  
**Primary output:** NASM assembly / flat binary

---

## Summary

Sentinel Lang is an experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

`v0.5-alpha` builds on `v0.4-alpha-stable`.

`v0.4-alpha-stable` introduced the first working built-in OSDev helper pack:

```sl
lib(std)
```

`v0.5-alpha` hardens the current x64 kernel-style path through stricter semantic rules and a larger stress test.

Current milestone result:

```text
Sentinel v0.5-alpha code core passed current alpha validation.
```

Main proof:

```text
Kernel Beast Test v0.5-alpha: Passed
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
| x64 output | Main tested path |
| x16 boot output | Experimental / working |
| x32 output | Experimental |
| Flat binary pipeline | Working |
| IDE integration | Working locally |
| Compiler backend | Private |
| Generated NASM | Readable / inspectable |

---

## v0.5-alpha Main Results

| Result | Status |
| :--- | :--- |
| Kernel Beast Test | Passed |
| x64 kernel-style compilation | Passed |
| `shift_left` codegen fix | Passed |
| `shift_right` codegen fix | Passed |
| Forward `start` call rejection | Passed |
| Forward `get` call rejection | Passed |
| `S027` semantic diagnostic | Working |
| Top-level `local` anywhere rule | Working |
| Function-local `local` rejection | Working |
| `lib(std)` x64-only rule | Preserved |
| Flat binary output | Passed |

---

## Current Language Status

| Feature | Status |
| :--- | :--- |
| `x16` | Experimental |
| `x32` | Experimental |
| `x64` | Main tested mode |
| `type(console)` | Working |
| `lib(std)` | Working / x64-only |
| `local` | Working |
| `redo` | Working |
| `create` | Working |
| `start` | Working |
| `get result()` | Experimental / working path |
| `if / then / else / end` | Working |
| `while` | Working |
| `repeat` | Working |
| Arrays | Working / basic indexing tested |
| Structs | Experimental |
| `try/catch` | Syntax-level / experimental |
| `low-code` | Limited / experimental |
| Function steps | Working |
| Step calls | Working with restrictions |
| Parameterized step calls | Blocked by semantic analyzer |
| Forward function calls | Blocked by `S027` |

---

## Current Storage Model

Sentinel currently uses flat storage discipline.

Rules:

```text
local declares flat source-file storage.
local may appear anywhere at top-level.
local inside create functions is forbidden.
```

Valid:

```sl
lib(std)
x64
type(console)

create boot()
    (1) vga_print("boot")

local status = 1

start boot()
halt()
```

Invalid:

```sl
lib(std)
x64
type(console)

create test()
    (1) local x = 10
```

Current diagnostic:

```text
[SEMANTIC S011] local inside function is not allowed.
```

---

## Current Function Order Rule

`v0.5-alpha` requires functions to be declared before they are called.

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

Current diagnostic:

```text
[SEMANTIC S027] Function `boot` is called before declaration.
```

This applies to:

- `start`
- `get`

---

## Current lib(std) Status

Current `lib(std)` rule:

```text
lib(std) is x64-only in v0.5-alpha.
```

Current command set:

| Command | Status | Notes |
| :--- | :--- | :--- |
| `vga_print(value)` | Working | VGA-style output |
| `vga_clear()` | Working | Clears VGA text output |
| `nop()` | Working | Emits `nop` |
| `halt()` | Working | Emits halt behavior |
| `io_wait()` | Working | I/O wait helper |
| `read_port(port)` | Working | Expression |
| `write_port(port, value)` | Working | Statement |
| `pic_eoi()` | Working | PIC end-of-interrupt helper |
| `irq_disable()` | Working | Emits `cli` |
| `irq_enable()` | Working | Emits `sti` |

Invalid:

```sl
lib(std)
x16

halt()
```

Expected diagnostic:

```text
[SEMANTIC S026] lib(std) currently supports x64 mode only.
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
| `S006` | Reserved / legacy conflict slot | Reserved |
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
| `S027` | Function called before declaration | Working |

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
| v0.4 std smoke tests | Passed |
| v0.4 port I/O tests | Passed |
| v0.4 IRQ helper tests | Passed |
| v0.4 std semantic error tests | Passed |
| v0.5 Kernel Beast Test | Passed |
| v0.5 shift codegen tests | Passed |
| v0.5 declaration-order tests | Passed |
| v0.5 top-level local order tests | Passed |

Current test conclusion:

```text
v0.5-alpha passed current alpha validation.
```

---

## Kernel Beast Test Status

The Kernel Beast Test is the main `v0.5-alpha` stress test.

It covers:

- `lib(std)`
- `x64`
- `type(console)`
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
Passed
```

Meaning:

```text
Sentinel can compile the current large x64 kernel-style stress test into NASM and flat binary output.
```

---

## Important v0.5-alpha Fix

`v0.5-alpha` fixes x64 shift operation code generation.

Old invalid pattern:

```asm
shl rbx, rax
```

Correct patterns:

```asm
shl rbx, 3
```

or:

```asm
shl rbx, cl
```

Current status:

```text
shift_left / shift_right generate valid NASM in current tested cases.
```

---

## Current x16 Status

The x16 bootloader path remains experimental and separate from `lib(std)`.

Example direction:

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

Current status:

```text
Experimental / working path.
```

Important:

```text
lib(std) is not supported in x16 in v0.5-alpha.
```

---

## Current Known Limitations

| Area | Limitation |
| :--- | :--- |
| `lib(std)` | x64-only |
| Type system | Incomplete |
| Memory safety | Not implemented |
| Return values | No stable explicit `return` keyword |
| `get result()` | Experimental |
| Strings | No full string system |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | `try/catch` is syntax-level / experimental |
| Optimizer | Basic only |
| Package ecosystem | Planned for `v0.6-alpha` |
| Library Hub | Planned for `v0.6-alpha` |
| Networking | Not implemented |
| Driver stack | Not implemented |
| Self-hosting | Long-term goal |

---

## Current Recommended Style

Recommended `v0.5-alpha` style:

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

Recommended ordering:

```text
1. lib / mode / type
2. top-level local declarations
3. create functions
4. more top-level local declarations if needed
5. start/get calls
6. halt
```

Required rule:

```text
create must appear before start/get calls that reference it.
```

---

## Roadmap Status

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 core |
| `v0.3-alpha` | Completed | Core hardening and semantic diagnostics |
| `v0.4-alpha-stable` | Completed | First `lib(std)` OSDev helper pack |
| `v0.5-alpha` | Current | Kernel Toolkit Preview |
| `v0.6-alpha` | Planned | Library Ecosystem Alpha |
| `v0.7-alpha` | Planned | Optimizer / ASM slimming |
| `v0.7.1-alpha` | Planned | Advanced TOP optimization pass |
| `v0.8-alpha` | Planned | Playground and tooling |
| `v0.9-beta` | Planned | Stability, tests, and docs hardening |
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
- website-based library package generator
- official / approved / community / experimental / unsafe / deprecated statuses

Review idea:

```text
5 GitHub stars = review candidate.
5 GitHub stars does not mean automatic approval.
```

Approval should depend on code quality, tests, examples, manifest validity, license clarity, and documented unsafe behavior.

---

## Final Status

```text
Sentinel Lang v0.5-alpha
Kernel Toolkit Preview
Status: Passed current alpha validation
```

Sentinel is still experimental alpha software.

However, the current compiler is now strong enough for OSDev experiments, kernel-style prototypes, and transparent `.sl -> NASM -> flat binary` testing.
