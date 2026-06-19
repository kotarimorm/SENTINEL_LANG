# Sentinel Lang Status

> Current development status for Sentinel Lang.

Sentinel Lang is currently in active experimental development.

This document tracks what works, what is experimental, what is broken, and what the next engineering targets are.

---

## Current Version

| Field | Value |
| :--- | :--- |
| **Version** | `v0.2-alpha` |
| **Main target** | `x64` |
| **Main mode** | `type(console)` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private |
| **Stability** | Alpha |
| **Primary focus** | OSDev / kernel experiments |

---

## Status Summary

```text
README          Updated
Specification   Updated
Compiler core   Working
x64 pipeline    Working
Stress tests    Passing
Scopes          Incomplete
OSDev libs      Planned
Desktop libs    Future
```

---

## Stability Rating

| Area | Rating | Notes |
| :--- | :--- | :--- |
| **Lexer** | High | Handles current syntax well |
| **Parser** | Medium-High | Handles large tests, but syntax is still evolving |
| **AST** | Medium-High | Stable enough for current codegen |
| **x64 Codegen** | Medium | Works, but semantics need cleanup |
| **NASM Output** | Medium-High | Generates valid NASM for tested cases |
| **Runtime Semantics** | Medium-Low | Some behavior depends on generated registers |
| **Scopes** | Low | Known collision issues |
| **Diagnostics** | Low-Medium | Some errors still surface from NASM |
| **Standard Library** | Low | Mostly not implemented yet |
| **Documentation** | Medium-High | Improving rapidly |

---

## Working Features

| Feature | Status | Notes |
| :--- | :--- | :--- |
| `x64` mode | Working | Main tested target |
| `type(console)` | Working | VGA-style console output |
| `local` variables | Working | Currently emitted as global labels |
| Numeric expressions | Working | Basic arithmetic works |
| `redo` | Working | Variable mutation works |
| `if / then / end` | Working | Numeric conditions work |
| Nested `if` | Working | Tested in stress programs |
| `while` | Working | Numeric loops work |
| `repeat(N)` | Working | Literal repeat count works |
| `repeat(variable)` | Working | Variable repeat count works |
| `create` functions | Working | Requires numbered steps |
| Numbered function steps | Working | Core Sentinel function model |
| `start function()` | Working | Normal function call |
| Function arguments | Working | x64 register-based |
| `get function() result()` | Experimental but working | Depends on `rax` |
| Arrays | Working | Numeric arrays work |
| Array indexing | Working | Fixed during `v0.2-alpha` |
| `console_print` | Working | String output works |
| `low-code` with `emit` | Working | Emits raw bytes |
| `FREERAM` | Experimental | Clears variable storage |
| `try/catch` syntax | Syntax-only | No real exception runtime yet |

---

## Experimental Features

| Feature | Status | Risk |
| :--- | :--- | :--- |
| `get result()` | Experimental | No explicit `return` model yet |
| Function-local variables | Experimental | Can collide with globals |
| `FREERAM` | Experimental | Not a real allocator |
| `try/catch` | Syntax-only | No throw/unwind/runtime handling |
| Division `/` | Experimental | Needs more tests |
| Modulo `%` | Experimental | Used in tests, needs hardening |
| `x16` mode | Experimental | Not current main path |
| `x32` mode | Experimental | Not current main path |
| Low-level byte emission | Experimental | Powerful but unsafe |

---

## Known Bugs

| Bug | Impact | Planned Fix |
| :--- | :--- | :--- |
| Function locals can collide with globals | NASM label redefinition | `v0.3-alpha` scope system |
| Function locals can collide with parameters | Wrong code or NASM error | Function-local label mangling |
| `result` cannot be used as normal variable name | Parser conflict | Better diagnostics |
| `get result()` depends on `rax` | Weak return semantics | Explicit return/result model |
| Arrays have no bounds checks | Unsafe memory reads | Runtime or compiler checks later |
| Strings cannot be compared safely | Pointer-like behavior | String library later |
| `try/catch` does not catch real errors | Misleading semantics | Real exception model later |
| Some invalid code fails at NASM stage | Poor UX | Semantic checker before codegen |

---

## Most Important Current Bug

### Scope Collision

Current problematic example:

```sl
local a = 10

create test(a)
    (1) local a = a + 1
```

Possible generated NASM conflict:

```asm
sl_var_a dq 10
sl_var_a dq 0
```

NASM error:

```text
label `sl_var_a` inconsistently redefined
```

### Planned Fix

| Source Concept | Planned Internal Label |
| :--- | :--- |
| Global variable | `sl_var_a` |
| Function parameter | register / stack slot |
| Function local | `sl_func_test_var_a` |
| Temporary value | `sl_tmp_0` |

This is the main target for `v0.3-alpha`.

---

## Stress Test Results

| Test | Purpose | Result |
| :--- | :--- | :--- |
| Hello x64 | Basic compile/output | Passed |
| Repeat Test | `repeat()` loop handling | Passed |
| While Test | `while` loop handling | Passed |
| Nested If Test | Nested control flow | Passed |
| Function Test | `create` / `start` | Passed |
| Result Test | `get result()` behavior | Passed |
| Array Test | Array declaration | Passed |
| Array Index Test | Array indexing codegen | Passed |
| Beast Test | Medium-size full language test | Passed |
| Ultra Beast Test | Large full language test | Passed |
| Turtle Test | Small correctness flow | Passed |
| Turtle Abomination | Heavy stress program | Passed |
| Semantic Killer | Scope edge case | Found bug |

---

## v0.2-alpha Achievement

Sentinel `v0.2-alpha` can now compile non-trivial programs containing:

```text
variables
numeric expressions
loops
nested branches
functions
function arguments
function result access
arrays
array indexing
low-code byte emission
console output
large stress tests
```

This means the compiler has moved beyond a simple hello-world stage.

It now has a working experimental language core.

---

## Current Reliability

| Category | State |
| :--- | :--- |
| Small programs | Usually compile |
| Medium programs | Compile if syntax follows spec |
| Large stress programs | Successfully tested |
| Invalid syntax | May produce parser or NASM errors |
| Invalid semantics | Not always detected early |
| Runtime safety | Not guaranteed |
| OSDev safety | Experimental |

---

## Current Recommended Coding Style

Use this style for `v0.2-alpha`:

```sl
x64
type(console)

local counter = 0
local limit = 3

create tick()
    (1) console_print("tick")

repeat(limit)
    redo: counter to counter + 1
end

if counter == 3 then
    start tick()
end
```

Recommended rules:

| Rule | Reason |
| :--- | :--- |
| Use `x64` | Most tested mode |
| Use `type(console)` | Most stable output mode |
| Use numeric conditions | String comparisons are not stable |
| Use unique variable names | Avoid scope collision |
| Avoid `result` as a variable name | Reserved keyword |
| Use numbered function steps | Required function syntax |
| Use `emit` only in `low-code` | Raw ASM is not stable |
| Avoid out-of-bounds array indexing | No bounds checks yet |

---

## Do Not Use Yet

Avoid these in `v0.2-alpha`:

```text
type(driver)
raw inline assembly text
return
throw
classes
full imports
string comparison
pointer syntax
interrupt handlers
driver declaration syntax
heap allocation APIs
desktop APIs
self-hosting code
```

---

## Next Engineering Target

The next major compiler milestone is:

```text
v0.3-alpha = scopes + semantic diagnostics
```

Main goals:

| Goal | Description |
| :--- | :--- |
| Scope system | Separate globals, parameters, locals, temporaries |
| Label mangling | Prevent NASM label collisions |
| Semantic checker | Detect invalid Sentinel before NASM |
| Better errors | Show Sentinel-level error messages |
| Reserved word diagnostics | Clear errors for names like `result` |
| Function result cleanup | Make `get result()` more predictable |

---

## Future Library Plan

Standard libraries are not the current focus of `v0.2-alpha`.

Planned direction:

| Version | Library Goal |
| :--- | :--- |
| `v0.4-alpha` | First OSDev micro-libs |
| `v0.4-stable` | Stable OSDev standard library |
| `v0.5-alpha` | Demo kernel / mini OS support |
| `v0.6-alpha` | Host target research |
| `v0.7-alpha` | Desktop primitives |
| `v0.8-alpha` | Desktop GUI libraries |

Possible future OSDev builtins:

```text
read_port(port)
write_port(port, value)
timer_wait(ticks)
halt()
nop()
panic(msg)
pic_eoi()
keyboard_read()
```

---

## Public Repository Status

| Item | Status |
| :--- | :--- |
| README | Updated for `v0.2-alpha` |
| Specification | Updated / strict |
| Roadmap | Needs refresh |
| Test report | Planned |
| Compiler source | Private |
| Examples | Needs more `v0.2-alpha` examples |
| Generated ASM | Needs updated stress output |

---

## Final Status

Sentinel Lang is currently a real experimental compiler project with a working `x64` language core.

It is not stable yet.

It is not production-ready.

But it can already compile large non-trivial Sentinel programs into NASM assembly and flat binary output.

Current priority:

```text
Correctness before features.
Scopes before libraries.
Diagnostics before magic.
```
