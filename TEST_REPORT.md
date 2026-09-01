# Sentinel Lang Test Report

**Version:** `v0.6-alpha`  
**Status:** Passed current alpha validation  
**Milestone:** Core Language Completion  
**Test date:** September 1, 2026  
**Main target:** `x64`  
**Boot target:** `x16`  
**Main focus:** stand/give validation, x64 regression testing, x16 boot validation, and semantic hardening

---

## Summary

Sentinel `v0.6-alpha` passed the current compiler-level validation set.

This release builds on:

- `v0.4-alpha-stable` built-in OSDev commands
- `v0.5-alpha` Kernel Beast hardening
- the established x64 NASM pipeline
- the experimental x16 boot-sector pipeline

The main `v0.6-alpha` question was:

```text
Can Sentinel support temporary function-local values
without converting local into hidden scoped storage?
```

Result:

```text
Yes.
```

The implemented model is:

```text
local = persistent flat storage
stand = temporary function storage
give  = explicit step transfer
result = final function value
get = result retrieval
```

Main validation results:

```text
Stand Beast: Passed compiler and NASM validation
x64 regression: Passed
x16 boot sector: Passed
x16 QEMU boot: Passed
```

---

## Validation Scope

This report covers:

- lexer behavior
- parser behavior
- AST generation
- semantic analysis
- stand stack allocation
- give target validation
- result/get behavior
- function parameter behavior
- dependent-step protection
- target-specific std validation
- unknown character rejection
- generated NASM inspection
- flat binary generation
- x16 QEMU boot execution
- previous Kernel Beast regression coverage

---

## Current Result

| Area | Result |
| :--- | :--- |
| Lexer | Passed |
| Parser | Passed |
| AST generation | Passed |
| Semantic analyzer | Passed |
| x64 code generation | Passed |
| x16 code generation | Passed |
| NASM assembly | Passed |
| Flat binary generation | Passed |
| Basic optimizer | Passed current use |
| Kernel Beast regression | Passed |
| Stand Beast | Passed |
| x64 regression source | Passed |
| x16 boot sector | Passed |
| x16 QEMU execution | Passed |
| Negative semantic tests | Passed |

Current conclusion:

```text
Sentinel v0.6-alpha is ready for the current alpha milestone.
```

---

# Primary v0.6 Tests

## Stand Beast Test

The Stand Beast Test is the primary `v0.6-alpha` positive stress test.

Source:

```sl
lib(std)
x64
type(console)

create stand_beast(a, b, c)
    (1) stand: base = a + b give to (2)
    (2) stand: doubled = base * 2 give to (3)
    (3) stand: mixed = doubled + c give to (4)
    (4) result mixed * 3

local first = 10
local second = 20
local third = 5

local answer = get stand_beast(first, second, third)

if answer == 195 then
    vga_print("STAND BEAST PASSED")
else
    vga_print("STAND BEAST FAILED")
end

halt()
```

Expected calculation:

```text
base = 10 + 20
base = 30

doubled = 30 * 2
doubled = 60

mixed = 60 + 5
mixed = 65

result = 65 * 3
result = 195
```

Result:

```text
Passed
```

Confirmed behavior:

- source tokenization succeeded
- parsing succeeded
- AST construction succeeded
- semantic analysis succeeded
- three stand values were accepted
- stand transfers were accepted
- `get` was accepted inside a `local` initializer
- x64 stack slots were generated
- the stand frame was aligned
- the result remained in `rax`
- the result was stored in `answer`
- NASM assembly succeeded
- flat binary generation succeeded

---

## Stand Beast Stack Frame

Expected stand layout:

```text
base    -> [rbp-8]
doubled -> [rbp-16]
mixed   -> [rbp-24]
```

Observed generated direction:

```asm
push rbp
mov  rbp, rsp
sub  rsp, 32
```

Observed stand stores:

```asm
mov  [rbp-8], rax
mov  [rbp-16], rax
mov  [rbp-24], rax
```

Observed cleanup:

```asm
add  rsp, 32
pop  rbp
ret
```

Result:

```text
Passed
```

---

## Stand Wrapper Elimination

Test purpose:

```text
Verify that stand-dependent steps do not expose
unsafe independent assembly entry points.
```

For the Stand Beast function, step `(1)` may receive an independent wrapper.

Steps `(2)`, `(3)`, and `(4)` require stand values from previous steps.

Observed output:

```asm
; step wrapper sl_func_stand_beast_L2 skipped:
; requires incoming stand values

; step wrapper sl_func_stand_beast_L3 skipped:
; requires incoming stand values

; step wrapper sl_func_stand_beast_L4 skipped:
; requires incoming stand values
```

Result:

```text
Passed
```

---

## Basic stand/get Test

Source:

```sl
lib(std)
x64
type(console)

create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2

local left = 10
local right = 20
local answer = get calculate(left, right)

vga_print("stand compiled")
halt()
```

Expected result:

```text
answer = 60
```

Observed code-generation direction:

```asm
mov  [rbp-8], rax
mov  rax, [rbp-8]
imul rax, rbx
mov  [sl_var_answer], rax
```

Result:

```text
Passed
```

---

# x64 Regression Tests

## x64 Core Regression

Test purpose:

```text
Verify that v0.6 stand changes did not break the older
local, redo, start, get, result, condition, and std paths.
```

Source:

```sl
lib(std)
x64
type(console)

local counter = 10
local left = 7
local right = 5

create update_counter()
    (1) redo: counter to counter + 5
    (2) vga_print("counter updated")

create calculate(a, b)
    (1) result (a + b) * 2

start update_counter()

local answer = get calculate(left, right)

if counter == 15 and answer == 24 then
    vga_print("X64 REGRESSION PASSED")
else
    vga_print("X64 REGRESSION FAILED")
end

halt()
```

Expected values:

```text
counter = 15
answer = 24
```

Compilation result:

```text
Passed
```

Observed flat binary size during validation:

```text
526 bytes
```

Validated areas:

- persistent `local`
- `redo`
- side-effect function through `start`
- value function through `get`
- x64 parameters
- final `result`
- arithmetic expressions
- logical condition
- VGA output
- safe halt loop

---

## Kernel Beast Regression

The Kernel Beast remains the main large x64 regression inherited from `v0.5-alpha`.

Covered areas:

- `lib(std)`
- `x64`
- `type(console)`
- VGA output
- IRQ helpers
- PIC EOI
- port I/O
- arrays
- indexing
- loops
- nested conditions
- function calls
- six-argument register pressure
- bitwise operations
- shift operations
- kernel-style sequencing

Result:

```text
Passed
```

The test confirms that `v0.6-alpha` development did not intentionally replace the previous x64 core model.

---

## x64 Shift Regression

Previously invalid generated form:

```asm
shl rbx, rax
```

Valid forms:

```asm
shl rbx, 3
```

```asm
shl rbx, cl
```

Current result:

```text
Passed existing regression validation
```

---

# x16 Tests

## x16 Boot-Sector Compilation

Source:

```sl
custing(silk)
lib(std)
x16
type(console)

create boot()
    (1) vga_clear()
    (2) vga_print("Sentinel v0.6 boot passed")

start boot()
halt()
```

Expected generated properties:

```text
BITS 16
ORG 0x7C00
512-byte output
0xAA55 signature
```

Observed result:

```text
NASM: Passed
Binary generation: Passed
Binary size: 512 bytes
```

---

## x16 QEMU Boot

Test purpose:

```text
Verify that the generated x16 boot sector executes through BIOS.
```

Observed behavior:

```text
QEMU loaded the boot sector.
The boot program executed.
Sentinel text appeared on screen.
The generated halt loop remained active.
```

Result:

```text
Passed
```

This is the current directly bootable Sentinel path.

---

## x16 std Subset

Current supported x16 commands:

```text
vga_print
vga_clear
halt
nop
```

Result:

```text
Passed current subset validation
```

The full x64 std implementation is not emitted in x16.

---

# Negative Semantic Tests

## S026 — Unsupported x16 std Command

Source:

```sl
custing(silk)
lib(std)
x16

write_port(0x20, 0x20)
halt()
```

Expected result:

```text
[SEMANTIC S026]
std command `write_port` is not supported in x16 mode.
```

Observed result:

```text
Passed
```

Confirmed diagnostic details included the current x16 subset:

```text
halt
nop
vga_clear
vga_print
```

Importance:

```text
The compiler rejects unsupported x16 commands before
x64-only registers can reach BITS 16 NASM output.
```

---

## S034 — Missing stand Target

Source:

```sl
x64

create broken_pipeline()
    (1) stand: temporary = 10 give to (9)
    (2) result temporary
```

Expected result:

```text
[SEMANTIC S034]
Stand `temporary` is given to missing step `(9)`.
```

Observed result:

```text
Passed
```

Observed available-step report:

```text
Available steps: 1, 2
```

---

## S036 — Direct Dependent-Step Call

Source:

```sl
x64

create pipeline()
    (1) stand: temporary = 30 give to (2)
    (2) result temporary * 2

start pipeline(2)
```

Expected result:

```text
[SEMANTIC S036]
Step `(2)` requires stand values from earlier steps.
```

Observed result:

```text
Passed
```

Confirmed details:

- required stand was identified as `temporary`
- the diagnostic explained that direct step calls create new invocations
- the diagnostic explained that previous stand values are not preserved
- the compiler recommended calling the complete function

---

## S037 — stand Outside x64

Source:

```sl
custing(silk)
x16

create invalid_boot()
    (1) stand: temporary = 10

start invalid_boot()
```

Expected result:

```text
[SEMANTIC S037]
stand currently supports x64 mode only.
```

Observed result:

```text
Passed
```

The diagnostic correctly identified that:

- the current implementation uses the x64 function stack
- x16 stand support is deferred
- x32 remains planned for later work

---

## Unknown Character Rejection

Source:

```sl
x64

local value = 10 @ 20
```

Expected result:

```text
[PARSE ERROR]
Unknown character `@`
```

Observed result:

```text
Passed
```

Importance:

```text
Unknown lexer tokens are no longer silently ignored.
```

The parser stops before semantic analysis and NASM.

---

# Existing Semantic Regression Coverage

The following older diagnostics remain part of the compiler behavior:

| Diagnostic | Purpose |
| :--- | :--- |
| `S001` | Reserved name rejection |
| `S002` | Duplicate function rejection |
| `S003` | Duplicate storage rejection |
| `S004` | Duplicate parameter rejection |
| `S005` | Parameter/storage conflict |
| `S007` | Direct parameter mutation rejection |
| `S008` | Unknown mutation target |
| `S009` | Unknown function |
| `S010` | Recursive call rejection |
| `S011` | Function-local local rejection |
| `S012` | Missing function step |
| `S013` | Invalid redo target |
| `S014` | Function/storage name conflict |
| `S015` | Unknown storage symbol |
| `S016` | Mixed step selector and argument call |
| `S017` | Wrong argument count |
| `S018` | Duplicate numbered step |
| `S019` | Unknown FREERAM target |
| `S020` | Parameterized direct-step rejection |
| `S021` | Unknown library |
| `S022` | std used without lib(std) |
| `S023` | Unknown std command |
| `S024` | Wrong std argument count |
| `S027` | Function called before declaration |
| `S028` | get used on function without result |
| `S029` | result outside function |
| `S030` | Invalid result position |
| `S031` | Non-ascending function steps |
| `S032` | Invalid stand position |
| `S033` | Duplicate stand |
| `S035` | Stand name conflict |

Not every diagnostic received a separate public source example during the final `v0.6-alpha` session.

The report distinguishes directly observed tests from implemented semantic paths.

---

# Register and Stack Validation

## Current x64 Argument Mapping

| Argument | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

## Current Helper Preservation

| Helper | Preservation |
| :--- | :--- |
| String printing | Preserves `rsi` |
| `read_port()` | Preserves `rdx` |
| `write_port()` | Preserves `rdx`, `r10`, `r11` |
| `vga_clear()` | Preserves helper registers used internally |

## stand Frame

Validated behavior:

- `rbp` is saved
- `rsp` becomes the frame base
- stand storage is allocated before function statements
- frame size is aligned to 16 bytes
- stand names map to stack operands
- frame storage is released before return
- compiler symbol mappings are restored after function generation

Result:

```text
Passed current generated-assembly inspection
```

---

# Removed Experimental Behavior

The following experimental file-linking syntax is not part of `v0.6-alpha`:

```sl
give("kernel.sl")
receive("bootloader.sl")
x16 goto x32
```

It was removed during compiler rollback and cleanup.

The current `give` keyword is only:

```sl
stand: value = expression give to (step)
```

No inter-file linker protocol was validated as part of this release.

---

# Known Test Boundary

The x64 backend generates valid NASM and flat binaries for the current tests.

However:

```text
The x64 kernel binary was not directly executed in QEMU
through a complete Sentinel-generated long-mode boot chain.
```

Reason:

- the x16 boot sector does not load the x64 kernel
- protected-mode transition is not implemented
- page tables are not generated
- long mode is not enabled
- control is not transferred to the x64 entry point

Therefore the current result must be described accurately:

```text
x64 compiler and NASM validation: Passed
x64 complete boot execution: Not available
x16 boot execution: Passed
```

---

# Current Limitations

| Area | Limitation |
| :--- | :--- |
| x64 QEMU execution | Complete boot chain missing |
| x32 | Backend incomplete |
| x16 std | Four-command subset |
| stand | x64-only |
| Type system | Incomplete |
| Memory safety | Incomplete |
| Recursion | Unsupported |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | Experimental |
| Optimizer | Basic |
| ABI | Experimental |
| Pixel graphics | Not implemented |
| Filesystems | Not implemented |
| Networking | Not implemented |
| Driver framework | Not implemented |
| Library ecosystem | Planned |
| Self-hosting | Not implemented |

---

# Test Result Table

| Test | Target | Result |
| :--- | :--- | :--- |
| Kernel Beast | x64 | Passed |
| Stand Beast | x64 | Passed compilation |
| Basic stand/get | x64 | Passed |
| x64 core regression | x64 | Passed |
| x64 NASM assembly | x64 | Passed |
| x64 flat binary | x64 | Passed |
| x16 boot compile | x16 | Passed |
| x16 flat binary | x16 | Passed |
| x16 512-byte size | x16 | Passed |
| x16 boot signature | x16 | Passed |
| x16 QEMU execution | x16 | Passed |
| S026 unsupported std | x16 | Passed |
| S034 missing stand target | x64 | Passed |
| S036 dependent-step call | x64 | Passed |
| S037 x16 stand | x16 | Passed |
| Unknown `@` character | Parser | Passed |
| Wrapper elimination | x64 | Passed |

---

# Final Conclusion

`v0.6-alpha` passed its current validation target.

Main conclusion:

```text
Sentinel now supports explicit temporary x64 function storage,
forward step-to-step value transfer, final function results,
and result retrieval without breaking the existing x64 core
or the working x16 boot-sector path.
```

Confirmed release capabilities:

- persistent storage through `local`
- temporary function storage through `stand`
- explicit transfer through `give`
- mutation through `redo`
- final values through `result`
- retrieval through `get`
- x64 stack-frame allocation
- target-specific std validation
- strict unknown-character rejection
- readable NASM output
- flat binary generation
- working x16 QEMU boot

Final status:

```text
Sentinel Lang v0.6-alpha
Core Language Completion
Status: Passed current alpha validation
```

The next major test boundary is a complete x64 boot chain capable of executing the generated x64 kernel directly in QEMU.
