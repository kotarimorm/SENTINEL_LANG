# Sentinel Lang Test Report

**Version:** `v0.5-alpha`  
**Status:** Passed current alpha validation  
**Milestone:** Kernel Toolkit Preview  
**Main target:** `x64`  
**Main focus:** kernel-style stress testing, compiler hardening, and semantic validation

---

## Summary

Sentinel `v0.5-alpha` passed the current compiler and language validation set.

This release builds on `v0.4-alpha-stable`.

`v0.4-alpha-stable` introduced the first working `lib(std)` OSDev helper pack.

`v0.5-alpha` focuses on proving that the existing x64 OSDev path can survive a larger kernel-style stress test.

Main result:

```text
Kernel Beast Test v0.5-alpha: Passed
```

This report records:

- parser stability
- semantic diagnostics
- function and storage validation
- x64 register preservation
- `lib(std)` command validation
- port I/O command generation
- IRQ helper generation
- shift operation codegen fixes
- stricter function declaration order
- large kernel-style stress-test compilation

---

## Current Result

| Area | Result |
| :--- | :--- |
| **Lexer** | Passed |
| **Parser** | Passed |
| **AST generation** | Passed |
| **Semantic analyzer** | Passed |
| **Code generation** | Passed |
| **NASM assembly output** | Passed |
| **Flat binary pipeline** | Passed |
| **x64 console mode** | Passed |
| **v0.3 core hardening tests** | Passed |
| **v0.4 std tests** | Passed |
| **v0.5 Kernel Beast Test** | Passed |
| **v0.5 declaration-order tests** | Passed |
| **v0.5 shift codegen tests** | Passed |

Current status:

```text
Sentinel v0.5-alpha code core is ready for the current alpha milestone.
```

---

## v0.5-alpha Main Validation Result

`v0.5-alpha` is not a large new feature release.

It is a hardening milestone.

The main validation goal was:

```text
Can Sentinel compile a larger kernel-style OSDev program through the current x64 pipeline?
```

Result:

```text
Yes.
```

The Kernel Beast Test compiled successfully after the `shift_left` / `shift_right` codegen issue was fixed.

---

## v0.5-alpha Additions Tested

| Addition / Rule | Result |
| :--- | :--- |
| Kernel Beast stress test | Passed |
| `shift_left` x64 codegen fix | Passed |
| `shift_right` x64 codegen fix | Passed |
| `S027` forward `start` rejection | Passed |
| `S027` forward `get` rejection | Passed |
| Valid ordered function calls | Passed |
| Top-level `local` after function declaration | Passed |
| Function-local `local` rejection | Passed |
| `lib(std)` x64-only behavior | Preserved |
| Large x64 NASM output | Passed |
| Flat binary generation | Passed |

---

## Kernel Beast Test

The Kernel Beast Test is the main `v0.5-alpha` stress test.

It is a large kernel-style Sentinel source file that exercises the current OSDev path.

Covered features:

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

Test result:

```text
Passed
```

Meaning:

```text
Sentinel successfully compiled the current kernel-style stress test into NASM and flat binary output.
```

---

## Kernel Beast Coverage

| Area | Covered | Result |
| :--- | :--- | :--- |
| Boot banner flow | Yes | Passed |
| VGA initialization | Yes | Passed |
| IRQ enable / disable | Yes | Passed |
| PIC EOI flow | Yes | Passed |
| Keyboard port reads | Yes | Passed |
| Memory scoring logic | Yes | Passed |
| Device mask logic | Yes | Passed |
| Scheduler loop | Yes | Passed |
| Array indexing | Yes | Passed |
| Six-argument function call | Yes | Passed |
| Nested verification chain | Yes | Passed |
| Keyboard polling loop | Yes | Passed |
| Final report flow | Yes | Passed |
| `halt()` ending | Yes | Passed |

---

## v0.5 Codegen Bug Found And Fixed

During `v0.5-alpha` development, the Kernel Beast Test exposed a real NASM codegen bug.

Problem:

```text
shift_left / shift_right generated an invalid x64 shift operand combination.
```

Invalid generated pattern:

```asm
shl rbx, rax
```

Why invalid:

```text
x86/x64 shift counts may be immediate values or CL.
They cannot use RAX directly as the shift count.
```

Valid patterns:

```asm
shl rbx, 3
```

or:

```asm
shl rbx, cl
```

Fix result:

```text
shift_left / shift_right now emit valid NASM shift operands.
```

Test result:

```text
Passed
```

---

## v0.5 Function Declaration Order

`v0.5-alpha` adds a stricter function declaration rule.

Rule:

```text
Functions must be declared before start/get calls that reference them.
```

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

Expected diagnostic:

```text
[SEMANTIC S027] Function `boot` is called before declaration.
```

Test result:

```text
Passed
```

---

## v0.5 Flat Storage Order

`v0.5-alpha` clarifies top-level storage ordering.

Rule:

```text
local declarations may appear anywhere at top-level.
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

Reason:

```text
local declares flat source-file storage.
It is not function-local storage.
```

Test result:

```text
Passed
```

---

## Function-Local local Rejection

Function-local `local` declarations remain forbidden.

Invalid:

```sl
lib(std)
x64
type(console)

create test()
    (1) local x = 10

start test()
halt()
```

Expected diagnostic:

```text
[SEMANTIC S011] local inside function is not allowed.
```

Test result:

```text
Passed
```

---

## v0.3-alpha Regression Status

`v0.5-alpha` keeps the important `v0.3-alpha` hardening behavior.

| Feature | Result |
| :--- | :--- |
| Flat storage validation | Passed |
| Duplicate storage detection | Passed |
| Unknown storage mutation detection | Passed |
| Function declaration validation | Passed |
| Function step validation | Passed |
| Function argument count validation | Passed |
| Unsafe parameterized step-call protection | Passed |
| x64 `rsi` print preservation | Passed |

---

## v0.4-alpha-stable Regression Status

`v0.5-alpha` keeps the important `v0.4-alpha-stable` `lib(std)` behavior.

| Feature | Result |
| :--- | :--- |
| `lib(std)` syntax | Passed |
| `lib(std)` semantic validation | Passed |
| x64-only `lib(std)` guard | Passed |
| `vga_print()` | Passed |
| `vga_clear()` | Passed |
| `nop()` | Passed |
| `halt()` | Passed |
| `io_wait()` | Passed |
| `read_port()` | Passed |
| `write_port()` | Passed |
| `pic_eoi()` | Passed |
| `irq_disable()` | Passed |
| `irq_enable()` | Passed |

---

## Current Semantic Diagnostics Tests

| Code | Purpose | Result |
| :--- | :--- | :--- |
| `S001` | Reserved keyword used as name | Passed |
| `S002` | Duplicate function | Passed |
| `S003` | Duplicate storage | Passed |
| `S004` | Duplicate parameter | Passed |
| `S005` | Parameter conflicts with storage | Passed |
| `S006` | Reserved / legacy conflict slot | Reserved |
| `S007` | Cannot redo parameter directly | Passed |
| `S008` | Cannot modify unknown storage | Passed |
| `S009` | Unknown function | Passed |
| `S010` | Recursive call unsupported | Passed |
| `S011` | `local` inside function blocked | Passed |
| `S012` | Missing function step | Passed |
| `S013` | Invalid redo target | Passed |
| `S014` | Storage conflicts with function | Passed |
| `S015` | Unknown storage symbol | Passed |
| `S016` | Mixed step selectors and arguments | Passed |
| `S017` | Wrong argument count | Passed |
| `S018` | Duplicate function step | Passed |
| `S019` | FREERAM unknown storage | Passed |
| `S020` | Unsafe step-call on parameterized function | Passed |
| `S021` | Unknown library | Passed |
| `S022` | std command/expression without `lib(std)` | Passed |
| `S023` | Unknown std command | Available / defensive |
| `S024` | Wrong std command argument count | Passed |
| `S025` | Reserved / legacy dynamic port restriction | Reserved |
| `S026` | `lib(std)` outside x64 | Passed |
| `S027` | Function called before declaration | Passed |

---

## Current lib(std) Commands

Current `lib(std)` command set:

| Command | Kind | Result |
| :--- | :--- | :--- |
| `vga_print(value)` | statement | Passed |
| `vga_clear()` | statement | Passed |
| `nop()` | statement | Passed |
| `halt()` | statement | Passed |
| `io_wait()` | statement | Passed |
| `read_port(port)` | expression | Passed |
| `write_port(port, value)` | statement | Passed |
| `pic_eoi()` | statement | Passed |
| `irq_disable()` | statement | Passed |
| `irq_enable()` | statement | Passed |

Current limitation:

```text
lib(std) is x64-only in v0.5-alpha.
```

---

## std Smoke Test

Test purpose:

```text
Verify that lib(std) loads and basic std commands compile.
```

Source pattern:

```sl
lib(std)
x64
type(console)

vga_print("std online")
nop()
halt()
```

Expected behavior:

- `lib(std)` is accepted.
- `vga_print()` emits VGA print sequence.
- `nop()` emits `nop`.
- `halt()` emits halt behavior.

Result:

```text
Passed
```

---

## std VGA Test

Test purpose:

```text
Verify vga_print and vga_clear.
```

Source pattern:

```sl
lib(std)
x64
type(console)

vga_clear()
vga_print("screen reset")
halt()
```

Expected generated behavior:

- VGA memory clear sequence is emitted.
- Cursor state is reset.
- String printing preserves `rsi`.

Result:

```text
Passed
```

---

## std IRQ Test

Test purpose:

```text
Verify irq_disable, irq_enable, and pic_eoi.
```

Source pattern:

```sl
lib(std)
x64
type(console)

vga_print("irq test begin")
irq_disable()
nop()
irq_enable()
pic_eoi()
vga_print("irq test done")
halt()
```

Expected generated behavior:

```asm
cli
nop
sti
out dx, al
```

Result:

```text
Passed
```

---

## std Port I/O Test

Test purpose:

```text
Verify read_port and write_port.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local keyboard_port = 0x60
local keyboard_value = 0

redo: keyboard_value to read_port(keyboard_port)
write_port(0x20, 0x20)
halt()
```

Expected behavior:

- `read_port()` reads from the requested port.
- `write_port()` writes byte value to the requested port.
- helper registers are preserved according to current codegen rules.

Result:

```text
Passed
```

---

## Shift Codegen Test

Test purpose:

```text
Verify that shift_left and shift_right generate valid NASM.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local memory_score = 2
local device_mask = 8

redo: memory_score shift_left 3
redo: device_mask shift_right 1

halt()
```

Expected generated behavior:

```asm
shl rbx, 3
shr rbx, 1
```

or expression-based shift through `cl`.

Result:

```text
Passed
```

---

## Forward Start Error Test

Test purpose:

```text
Verify that start cannot call a function before declaration.
```

Source pattern:

```sl
lib(std)
x64
type(console)

start boot()

create boot()
    (1) vga_print("bad")

halt()
```

Expected result:

```text
[SEMANTIC S027] Function `boot` is called before declaration.
```

Result:

```text
Passed
```

---

## Forward Get Error Test

Test purpose:

```text
Verify that get cannot call a function before declaration.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local out = get boot() result()

create boot()
    (1) vga_print("bad")

halt()
```

Expected result:

```text
[SEMANTIC S027] Function `boot` is called before declaration.
```

Result:

```text
Passed
```

---

## Ordered Start Pass Test

Test purpose:

```text
Verify that ordered function declaration and call compiles.
```

Source pattern:

```sl
lib(std)
x64
type(console)

create boot()
    (1) vga_print("ok")

start boot()
halt()
```

Expected result:

```text
Compilation succeeds.
```

Result:

```text
Passed
```

---

## Top-Level Local After Function Test

Test purpose:

```text
Verify that top-level local declarations may appear after function declarations.
```

Source pattern:

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

Expected result:

```text
Compilation succeeds.
```

Result:

```text
Passed
```

---

## x64 Register Preservation Notes

Important register behavior preserved by current tests:

| Area | Register Rule |
| :--- | :--- |
| string printing | preserves `rsi` |
| `read_port()` | preserves `rdx` |
| `write_port()` | preserves `rdx`, `r10`, `r11` |
| `vga_clear()` | preserves helper registers used internally |
| function args | follow current experimental x64 argument-register behavior |

Current x64 argument register mapping:

| Arg | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

---

## x16 Bootloader Regression Status

The x16 bootloader path remains separate from `lib(std)`.

Current status:

```text
Experimental / working.
```

Important limitation:

```text
lib(std) is not supported in x16 in v0.5-alpha.
```

Example x16 pattern:

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

Result:

```text
Experimental path preserved.
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

## Test Conclusion

`v0.5-alpha` passed the current validation target.

Main conclusion:

```text
Sentinel can compile the current x64 Kernel Beast stress test and reject known invalid function-order patterns before NASM.
```

This makes `v0.5-alpha` a real compiler hardening milestone.

The compiler is still experimental, but the current alpha core is strong enough for OSDev experiments, kernel-style prototypes, and transparent `.sl -> NASM -> flat binary` testing.

---

## Next Testing Targets

Planned future testing direction:

| Version | Testing Focus |
| :--- | :--- |
| `v0.6-alpha` | external library format, library loading, Library Hub metadata |
| `v0.7-alpha` | optimizer correctness and ASM size reduction |
| `v0.7.1-alpha` | advanced TOP optimization pass |
| `v0.8-alpha` | tooling and playground validation |
| `v0.9-beta` | stability, regression suite, documentation hardening |

---

## Final Status

```text
Sentinel Lang v0.5-alpha
Kernel Toolkit Preview
Status: Passed current alpha validation
```

Sentinel remains experimental alpha software.

But `v0.5-alpha` confirms that the project now has:

- a working x64 OSDev helper layer
- stricter semantic validation
- fixed shift code generation
- a passed kernel-style stress test
- readable NASM output
- flat binary generation
- a clearer path toward a future library ecosystem
