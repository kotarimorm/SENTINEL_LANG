# Sentinel Lang Test Report

> Test status for Sentinel Lang `v0.2-alpha`.

This document tracks compiler stress tests, language feature checks, and known failures discovered during testing.

---

## Summary

| Field | Value |
| :--- | :--- |
| **Version** | `v0.2-alpha` |
| **Main target** | `x64` |
| **Main mode** | `type(console)` |
| **Output** | NASM / flat binary |
| **Test focus** | Compiler stability and codegen correctness |

---

## Test Results

| Test | Purpose | Result |
| :--- | :--- | :--- |
| **Hello x64** | Basic compile and output | Passed |
| **Repeat Test** | `repeat()` loops | Passed |
| **While Test** | `while` loops | Passed |
| **Nested If Test** | Nested control flow | Passed |
| **Function Test** | `create` / `start` | Passed |
| **Function Args Test** | x64 function arguments | Passed |
| **Result Test** | `get ... result()` | Passed |
| **Array Test** | Array declaration | Passed |
| **Array Index Test** | Array indexing | Passed |
| **Low-Code Test** | `low-code` with `emit` | Passed |
| **Try/Catch Syntax Test** | `try/catch` parsing | Passed |
| **Beast Test** | Medium stress program | Passed |
| **Ultra Beast Test** | Large stress program | Passed |
| **Turtle Test** | Small correctness test | Passed |
| **Turtle Abomination** | Heavy control-flow stress | Passed |
| **Semantic Killer** | Scope collision edge case | Found bug |

---

## Passed Feature Groups

| Feature Group | Status |
| :--- | :--- |
| Variables | Passed |
| Numeric expressions | Passed |
| `redo` mutation | Passed |
| `if` statements | Passed |
| Nested branches | Passed |
| `while` loops | Passed |
| `repeat` loops | Passed |
| Functions | Passed |
| Function arguments | Passed |
| Function result access | Passed |
| Arrays | Passed |
| Array indexing | Passed |
| Console output | Passed |
| Low-code byte emission | Passed |

---

## Known Failure

### Scope Collision

The most important discovered bug is incomplete scope handling.

Example:

```sl
local a = 10

create test(a)
    (1) local a = a + 1
```

This may generate duplicate NASM labels:

```asm
sl_var_a dq 10
sl_var_a dq 0
```

NASM error:

```text
label `sl_var_a` inconsistently redefined
```

Status:

```text
Known bug
Target fix: v0.3-alpha
```

---

## Current Test Confidence

| Area | Confidence |
| :--- | :--- |
| Small programs | High |
| Medium programs | Medium-High |
| Large stress programs | Medium |
| Runtime semantics | Medium-Low |
| Scope correctness | Low |
| x64 codegen | Medium |
| Parser stability | Medium-High |

---

## Next Test Targets

| Target | Purpose |
| :--- | :--- |
| Scope tests | Verify global/local/param separation |
| Function collision tests | Prevent duplicate NASM labels |
| Invalid syntax tests | Improve compiler diagnostics |
| Array bounds tests | Document unsafe behavior |
| String comparison tests | Confirm unsupported behavior |
| Result semantics tests | Stabilize `get result()` |
| OSDev builtins tests | Future `v0.4-alpha` libraries |

---

## Final Notes

Sentinel Lang `v0.2-alpha` has passed multiple non-trivial compiler stress tests.

The compiler can generate NASM output for large Sentinel programs, but semantic correctness is still being hardened.

Current priority:

```text
Fix scopes.
Improve diagnostics.
Then build OSDev libraries.
```
