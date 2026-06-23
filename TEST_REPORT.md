# Sentinel Lang Test Report

**Version:** `v0.4-alpha-stable`  
**Status:** Passed current alpha-stable validation  
**Main target:** `x64`  
**Main focus:** `lib(std)` OSDev helper pack + semantic stability

---

## Summary

Sentinel `v0.4-alpha-stable` passed the current compiler and language validation set.

This release builds on the `v0.3-alpha` core hardening milestone and adds the first working built-in OSDev helper library:

```sl
lib(std)
```

The goal of this test report is to record:

- parser stability
- semantic diagnostics
- function and storage validation
- x64 register preservation
- `lib(std)` command validation
- port I/O command generation
- IRQ helper generation
- large valid stress-test compilation

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

Current status:

```text
Sentinel v0.4-alpha-stable code core is ready.
```

---

## v0.3-alpha Regression Status

`v0.4-alpha-stable` keeps the important `v0.3-alpha` hardening behavior.

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

## Semantic Diagnostics Tests

| Code | Purpose | Result |
| :--- | :--- | :--- |
| `S001` | Reserved keyword used as name | Passed |
| `S002` | Duplicate function | Passed |
| `S003` | Duplicate storage | Passed |
| `S004` | Duplicate parameter | Passed |
| `S005` | Parameter conflicts with storage | Passed |
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

---

## v0.4-alpha-stable std Commands

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
- `halt()` emits safe halt loop.

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
mov dx, 0x20
mov al, 0x20
out dx, al
```

Result:

```text
Passed
```

---

## read_port Test

Test purpose:

```text
Verify read_port works as an expression.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local key = read_port(0x60)

vga_print("read port ok")
halt()
```

Expected generated behavior:

```asm
push rdx
mov  rax, 96
mov  dx, ax
in   al, dx
movzx rax, al
pop  rdx
mov  [sl_var_key], rax
```

Result:

```text
Passed
```

---

## read_port Inside Function Test

Test purpose:

```text
Verify read_port works inside function bodies and with storage port values.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local keyboard_port = 0x60
local keyboard_value = 0

create keyboard_poll()
    (1) vga_print("keyboard poll")
    (2) redo: keyboard_value to read_port(keyboard_port)
    (3) vga_print("keyboard read ok")

start keyboard_poll()

halt()
```

Expected behavior:

- Function compiles.
- `vga_print()` preserves `rsi`.
- `read_port()` preserves `rdx`.
- `keyboard_value` receives `rax`.

Result:

```text
Passed
```

---

## write_port Literal Test

Test purpose:

```text
Verify write_port works with literal port/value arguments.
```

Source pattern:

```sl
lib(std)
x64
type(console)

write_port(0x20, 0x20)
halt()
```

Expected generated behavior:

```asm
mov dx, 0x20
mov al, 0x20
out dx, al
```

Result:

```text
Passed
```

---

## write_port Dynamic Test

Test purpose:

```text
Verify write_port works with storage expressions.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local pic_port = 0x20
local pic_value = 0x20

vga_print("write dynamic begin")
write_port(pic_port, pic_value)
vga_print("write dynamic ok")
halt()
```

Expected generated behavior:

```asm
mov  rax, [sl_var_pic_port]
mov  r10, rax
mov  rax, [sl_var_pic_value]
mov  r11, rax
mov  dx, r10w
mov  al, r11b
out  dx, al
```

Result:

```text
Passed
```

---

## write_port Function Argument Test

Test purpose:

```text
Verify write_port works with function arguments.
```

Source pattern:

```sl
lib(std)
x64
type(console)

local port_value = 0x20
local eoi_value = 0x20

create send_eoi(port_arg, value_arg)
    (1) vga_print("send eoi begin")
    (2) write_port(port_arg, value_arg)
    (3) vga_print("send eoi done")

start send_eoi(port_value, eoi_value)

halt()
```

Expected behavior:

- `port_arg` maps through `rdi`.
- `value_arg` maps through `rsi`.
- `vga_print()` preserves `rsi`.
- `write_port()` emits `out dx, al`.

Result:

```text
Passed
```

---

## std Big Stress Test

Test purpose:

```text
Verify all v0.4 std commands work together in one valid program.
```

Covered features:

- `lib(std)`
- `vga_clear()`
- `vga_print()`
- `nop()`
- `io_wait()`
- `read_port()`
- `write_port()`
- `pic_eoi()`
- `irq_disable()`
- `irq_enable()`
- function calls
- function arguments
- safe no-parameter step calls
- flat storage mutation
- `halt()`

Result:

```text
Passed
```

Conclusion:

```text
The v0.4 std command pack passed combined stress validation.
```

---

## Error Test: Unknown Library

Source pattern:

```sl
lib(kernel)
x64
type(console)

halt()
```

Expected:

```text
[SEMANTIC S021] Unknown library `kernel`.
```

Result:

```text
Passed
```

---

## Error Test: std Command Without lib(std)

Source pattern:

```sl
x64
type(console)

halt()
```

Expected:

```text
[SEMANTIC S022] Cannot use std command `halt` without `lib(std)`.
```

Result:

```text
Passed
```

---

## Error Test: read_port Without lib(std)

Source pattern:

```sl
x64
type(console)

local key = read_port(0x60)
```

Expected:

```text
[SEMANTIC S022] Cannot use std expression `read_port` without `lib(std)`.
```

Result:

```text
Passed
```

---

## Error Test: Wrong std Argument Count

Source pattern:

```sl
lib(std)
x64
type(console)

irq_enable(1)
```

Expected:

```text
[SEMANTIC S024] `irq_enable` expects 0 argument(s), got 1.
```

Result:

```text
Passed
```

---

## Error Test: lib(std) Outside x64

Source pattern:

```sl
lib(std)
x16

halt()
```

Expected:

```text
[SEMANTIC S026] `lib(std)` currently supports x64 mode only in v0.4-alpha.
```

Result:

```text
Passed
```

---

## Register Preservation Notes

`v0.4-alpha-stable` keeps the important `v0.3-alpha` register preservation fix.

String printing preserves `rsi`:

```asm
push rsi
lea  rsi, [rel sl_pstr_0]
call sl_print_str
pop  rsi
```

This prevents generated print calls from destroying the second function argument.

`read_port()` preserves `rdx`.

`write_port()` preserves internal helper registers used by its generated sequence.

---

## Known Test Limitations

| Area | Limitation |
| :--- | :--- |
| Runtime hardware behavior | Not fully validated on every real machine |
| std x16/x32 | Intentionally rejected |
| Networking | Not implemented |
| Full driver stack | Not implemented |
| Type safety | Incomplete |
| Memory safety | Incomplete |
| Exception runtime | Not implemented |

---

## Final Test Status

Current validated milestone:

```text
Sentinel v0.4-alpha-stable
```

Result:

```text
PASSED
```

Summary:

```text
v0.3-alpha hardened the compiler core.
v0.4-alpha-stable adds the first working lib(std) OSDev helper pack.
```

The compiler now supports both:

```text
core language stability
```

and:

```text
early hardware-oriented std commands
```

This makes `v0.4-alpha-stable` the first Sentinel version where the language begins moving from pure compiler core toward practical OSDev helper tooling.
