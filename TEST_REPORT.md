# Sentinel Lang Test Report

> Test status for Sentinel Lang `v0.3-alpha`.

This document tracks compiler stress tests, semantic diagnostics, language feature checks, and known limitations.

---

## Summary

| Field | Value |
| :--- | :--- |
| **Version** | `v0.3-alpha` |
| **Main target** | `x64` |
| **Secondary target** | `x16` boot-sector experiments |
| **Main mode** | `type(console)` |
| **Output** | NASM / flat binary |
| **Test focus** | Compiler core hardening and semantic diagnostics |

---

## v0.3-alpha Result

Sentinel `v0.3-alpha` focuses on hardening the compiler core.

Main result:

```text
Invalid Sentinel should fail before NASM.
Valid ordered flat-storage programs should still compile.
```

---

## Passed Feature Groups

| Feature Group | Status |
| :--- | :--- |
| Lexer | Passed |
| Parser | Passed |
| AST generation | Passed |
| Semantic analyzer | Passed |
| NASM codegen | Passed |
| Optimizer pass | Passed |
| x64 flat binary output | Passed |
| x16 boot-sector style output | Passed |
| Variables / flat storage | Passed |
| `redo` mutation | Passed |
| `if` statements | Passed |
| Nested branches | Passed |
| `while` loops | Passed |
| `repeat` loops | Passed |
| Functions | Passed |
| Function arguments | Passed |
| Function step calls | Passed |
| Function result access | Passed |
| Arrays | Passed |
| Array indexing | Passed |
| Variable array indexing | Passed |
| Console output | Passed |
| Low-code byte emission | Passed |
| Selected low-code commands | Passed |

---

## Semantic Diagnostics Tests

| Test | Expected | Result |
| :--- | :--- | :--- |
| Unknown function | `S009` | Passed |
| Missing function step | `S012` | Passed |
| Duplicate storage | `S003` | Passed |
| Unknown storage mutation | `S008` | Passed |
| `local` inside function | `S011` | Passed |
| Parameter/storage collision | `S005` | Passed |
| Wrong argument count | `S017` | Passed |
| Mixed step selector and args | `S016` | Passed |
| Step-call parameterized function | `S020` | Passed |
| Missing `get result(...)` step | `S012` | Passed |

---

## Core Hardening Tests

| Test | Purpose | Result |
| :--- | :--- | :--- |
| Register Clobber Test | Ensures generated print does not destroy `rsi` function argument | Passed |
| Double Print Register Test | Ensures repeated print calls preserve argument state | Passed |
| Six Argument Test | Verifies x64 argument passing through `rdi/rsi/rdx/rcx/r8/r9` | Passed |
| Core Hardening Beast v0.3.1 | Large flat-storage, ABI, arrays, loops, functions, and result stress test | Passed |

---

## Legacy Stress Tests

| Test | Purpose | Result |
| :--- | :--- | :--- |
| Hello x64 | Basic compile/output | Passed |
| Repeat Test | `repeat()` loop handling | Passed |
| While Test | `while` loop handling | Passed |
| Nested If Test | Nested control flow | Passed |
| Function Test | `create` / `start` | Passed |
| Function Args Test | x64 function arguments | Passed |
| Result Test | `get ... result()` | Passed |
| Array Test | Array declaration | Passed |
| Array Index Test | Array indexing | Passed |
| Low-Code Test | `low-code` with `emit` | Passed |
| Try/Catch Syntax Test | `try/catch` parsing | Passed |
| Beast Test | Medium stress program | Passed |
| Ultra Beast Test | Large stress program | Passed |
| Turtle Test | Small correctness test | Passed |
| Turtle Abomination | Heavy control-flow stress | Passed |
| Semantic Killer | Invalid semantic cases | Passed |

---

## Important v0.3-alpha Fixes

### Semantic Errors Before NASM

Before `v0.3-alpha`, some invalid programs could fail at NASM stage.

`v0.3-alpha` adds Sentinel-level semantic diagnostics for known bad patterns.

Example:

```sl
create boot()
    (1) console_print("boot")

start boot(9)
```

Now fails as:

```text
[SEMANTIC S012] Function `boot` has no step `(9)`.
```

---

### Register Preservation

A register clobber issue was found around generated print calls.

Problem shape:

```sl
create test(a, b)
    (1) console_print("before")
    (2) redo: out to a + b
```

On `x64`, the second argument is passed through `rsi`.

Generated print calls now preserve `rsi` around `console_print`.

Expected ASM shape:

```asm
push rsi
lea  rsi, [rel sl_pstr_0]
call sl_print_str
pop  rsi
```

---

### Unsafe Step Calls

Parameterized functions cannot be called through step labels.

Invalid:

```sl
create add(a, b)
    (1) console_print("add")
    (2) redo: out to a + b

start add(2)
```

Now fails as:

```text
[SEMANTIC S020] Cannot step-call function `add` because it has parameters.
```

---

## Current Test Confidence

| Area | Confidence |
| :--- | :--- |
| Small programs | High |
| Medium programs | High |
| Large ordered flat-storage programs | Medium-High |
| Semantic diagnostics | High |
| x64 codegen | Medium-High |
| x16 boot-sector experiments | Medium |
| Runtime semantics | Medium |
| Result semantics | Medium-Low |
| Type checking | Low |
| Memory safety | Low |

---

## Next Test Targets

| Target | Purpose |
| :--- | :--- |
| `lib(std)` command tests | Prepare `v0.4-alpha` OSDev command pack |
| Port I/O tests | Validate future `read_port` / `write_port` |
| Panic/halt tests | Validate basic kernel control helpers |
| Keyboard input smoke tests | Prepare driver-level experiments |
| More x16 boot tests | Harden boot-sector generation |
| More result tests | Stabilize `get result()` behavior |
| Bounds diagnostics | Document or detect unsafe array access |
| String behavior tests | Confirm unsupported string comparison |

---

## Final Notes

Sentinel Lang `v0.3-alpha` hardens the compiler core.

The compiler can now reject several invalid semantic patterns before NASM and still compile large valid ordered flat-storage programs.

Current priority:

```text
Core hardening before libraries.
Semantic diagnostics before magic.
v0.4-alpha begins the first OSDev command library work.
```
