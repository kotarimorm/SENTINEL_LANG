# Sentinel Lang Status

**Current version:** `v0.6-alpha`  
**Current milestone:** Core Language Completion  
**Current date:** September 1, 2026  
**Main target:** `x64`  
**Secondary target:** `x16` boot sectors  
**Project status:** Experimental alpha  
**Compiler backend:** Private  
**Primary output:** NASM assembly / flat binary

---

## Summary

Sentinel Lang is an experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

`v0.6-alpha` introduces the first explicit temporary function-storage model.

Core distinction:

```text
local = persistent flat program storage
stand = temporary function storage
```

Temporary values may be transferred between numbered function steps using:

```sl
give to (step)
```

Current milestone result:

```text
Sentinel v0.6-alpha passed current compiler-level alpha validation.
```

Main validation programs:

```text
Kernel Beast — Passed
Stand Beast — Passed compilation and NASM validation
x16 Sentinel boot — Passed QEMU validation
```

---

## Current Core Status

| Area | Status |
| :--- | :--- |
| Lexer | Working |
| Parser | Working |
| AST | Working |
| Semantic analyzer | Working |
| NASM code generation | Working |
| Basic optimizer | Working |
| Flat binary generation | Working |
| x64 compiler path | Main tested path |
| x16 boot-sector path | Working experimental path |
| x32 backend | Incomplete |
| Generated NASM | Readable and inspectable |
| Compiler backend | Private |
| Public documentation | Available |
| GitHub Pages wiki | Available |

---

## v0.6-alpha Main Results

| Result | Status |
| :--- | :--- |
| `stand` parsing | Passed |
| `stand` semantic analysis | Passed |
| x64 stand stack allocation | Passed |
| Multiple stand values | Passed |
| `give to (N)` parsing | Passed |
| Forward stand transfer | Passed |
| Invalid target rejection | Passed |
| Direct dependent-step rejection | Passed |
| Unsafe wrapper elimination | Passed |
| `result expression` | Passed |
| `get function(arguments)` | Passed |
| Dynamic `local = get ...` | Passed |
| Ascending step validation | Implemented |
| Unknown character rejection | Passed |
| x16 std command validation | Passed |
| x16 stand rejection | Passed |
| Parameter mapping restoration | Implemented |
| x64 regression compilation | Passed |
| x16 boot-sector compilation | Passed |
| x16 QEMU boot | Passed |

---

## Current Language Status

| Feature | Status |
| :--- | :--- |
| `x64` | Main tested target |
| `x16` | Working experimental boot target |
| `x32` | Incomplete |
| `type(console)` | Working |
| `local` | Working persistent storage |
| `stand` | Working temporary x64 storage |
| `give` | Working forward step transfer |
| `redo` | Working mutation |
| `create` | Working function declaration |
| `start` | Working function and safe step calls |
| `get` | Working function result retrieval |
| `result` | Working final function value |
| Function parameters | Working, first six x64 registers |
| Numbered steps | Working |
| `if / then / else / end` | Working |
| `while` | Working |
| `repeat` | Working |
| Arrays | Basic support |
| Array indexing | Basic support |
| Structs | Experimental |
| `try/catch` | Experimental |
| `low-code` | Limited and unsafe |
| `lib(std)` x64 | Working |
| `lib(std)` x16 | Minimal subset |
| Port I/O | x64 |
| IRQ helpers | x64 |
| VGA text output | x16 and x64 |
| Pixel framebuffer | Not implemented |
| Complete x64 boot chain | Not implemented |

---

## Current Storage Model

Sentinel has two primary storage categories.

| Storage | Lifetime | Backend Location |
| :--- | :--- | :--- |
| `local` | Entire program | Static flat storage |
| `stand` | One function invocation | x64 stack frame |

Persistent storage:

```sl
local counter = 0
```

Temporary storage:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b
```

Explicit transfer:

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

Function-local `local` remains forbidden:

```sl
create invalid()
    (1) local temporary = 10
```

Expected diagnostic:

```text
[SEMANTIC S011]
```

Recommended replacement:

```sl
create valid()
    (1) stand: temporary = 10
```

---

## stand Status

`stand` is currently x64-only.

A stand value:

- belongs to one function invocation
- receives an x64 stack slot
- does not become global storage
- disappears when the function returns
- may be transferred to a later step
- cannot be read by an unrelated direct step call

Example generated direction:

```asm
push rbp
mov  rbp, rsp
sub  rsp, 16

mov  [rbp-8], rax
```

Multiple stands use separate slots:

```text
base    -> [rbp-8]
doubled -> [rbp-16]
mixed   -> [rbp-24]
```

The complete stack frame is aligned to 16 bytes.

---

## give Status

Current syntax:

```sl
stand: value = expression give to (2)
```

Current rules:

- the target step must exist
- the target must be inside the same function
- the target must follow the source step
- backward transfer is forbidden
- the stand keeps its original name
- the value remains temporary
- the value belongs only to the current invocation

Invalid:

```sl
create broken()
    (1) stand: value = 10 give to (9)
    (2) result value
```

Expected diagnostic:

```text
[SEMANTIC S034]
```

---

## Direct Step Safety

A direct step call creates an independent function invocation.

Invalid:

```sl
create pipeline()
    (1) stand: temporary = 30 give to (2)
    (2) result temporary * 2

start pipeline(2)
```

Expected diagnostic:

```text
[SEMANTIC S036]
```

Reason:

```text
Step 1 did not execute.
temporary was not created.
Step 2 cannot read it.
```

The code generator also removes the unsafe wrapper:

```asm
; step wrapper sl_func_pipeline_L2 skipped:
; requires incoming stand values
```

---

## result/get Status

Value-producing function:

```sl
create add(a, b)
    (1) result a + b
```

Result retrieval:

```sl
local answer = get add(left, right)
```

Current rules:

- `result` is valid only inside a function
- `result` must be the final statement
- `result` must be in the final function step
- `get` requires the function to contain a result
- the x64 result is returned through `rax`
- `start` ignores a returned value

Related diagnostics:

```text
S028 — function used with get has no result
S029 — result used outside function
S030 — result is not in the final position
```

---

## Function Order Status

Functions must be declared before use.

Invalid:

```sl
start boot()

create boot()
    (1) print("boot")
```

Expected diagnostic:

```text
[SEMANTIC S027]
```

This applies to:

- `start`
- `get`
- function calls inside other functions

Hidden forward function resolution is not currently supported.

---

## Function Step Status

Numbered steps must be ascending.

Valid:

```sl
create example()
    (1) print("one")
    (3) print("three")
    (8) print("eight")
```

Gaps are allowed.

Invalid:

```sl
create example()
    (2) print("two")
    (1) print("one")
```

Expected diagnostic:

```text
[SEMANTIC S031]
```

Duplicate steps remain rejected through:

```text
[SEMANTIC S018]
```

---

## Current lib(std) Status

`lib(std)` has target-specific support.

### x64

The main implementation contains:

```text
vga_print
vga_clear
panic
halt
nop
io_wait
read_port
write_port
pic_eoi
irq_disable
irq_enable
```

### x16

The minimal subset contains:

```text
vga_print
vga_clear
halt
nop
```

### x32

Current status:

```text
Unsupported / incomplete
```

Unsupported target-specific commands are rejected before NASM.

Example:

```sl
custing(silk)
lib(std)
x16

write_port(0x20, 0x20)
```

Result:

```text
[SEMANTIC S026]
```

---

## Current x16 Status

The x16 path can generate a BIOS boot sector.

Confirmed example:

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

Generated direction:

```asm
BITS 16
ORG 0x7C00
```

Confirmed result:

```text
Binary size: 512 bytes
Boot signature: 0xAA55
NASM: Passed
QEMU boot: Passed
BIOS text output: Passed
```

`stand` is rejected in x16 through:

```text
[SEMANTIC S037]
```

---

## Current x64 Status

The x64 backend currently supports:

- functions
- parameters
- persistent storage
- temporary stand storage
- result-producing functions
- conditions
- loops
- arrays
- bitwise operations
- shifts
- VGA text memory
- port I/O
- IRQ helper instructions
- NASM flat binary generation

The current x64 backend has passed:

- Kernel Beast
- x64 regression compilation
- Stand Beast compilation
- NASM validation

Important limitation:

```text
The x64 binary is not directly bootable yet.
```

A complete loader must:

- read the kernel from disk
- place it in memory
- enable A20
- create a GDT
- enter protected mode
- create page tables
- enable long mode
- jump to the x64 kernel entry point

---

## Removed Experimental Protocol

The old inter-file experiment using:

```sl
give("kernel.sl")
receive("bootloader.sl")
x16 goto x32
```

has been removed.

The current `give` keyword is used only for stand transfer:

```sl
stand: value = expression give to (2)
```

Kernel loading must eventually be implemented through a real bootloader and processor-mode transition path.

---

## Current Semantic Diagnostics

| Code | Meaning | Status |
| :--- | :--- | :--- |
| `S001` | Reserved keyword used as name | Working |
| `S002` | Duplicate function | Working |
| `S003` | Duplicate storage | Working |
| `S004` | Duplicate parameter | Working |
| `S005` | Parameter conflicts with storage | Working |
| `S006` | Legacy reserved slot | Reserved |
| `S007` | Parameter mutated directly | Working |
| `S008` | Unknown mutation target | Working |
| `S009` | Unknown function | Working |
| `S010` | Recursive call unsupported | Working |
| `S011` | Function-local `local` blocked | Working |
| `S012` | Missing function step | Working |
| `S013` | Invalid redo target | Working |
| `S014` | Storage conflicts with function | Working |
| `S015` | Unknown storage symbol | Working |
| `S016` | Arguments mixed with step selectors | Working |
| `S017` | Wrong argument count | Working |
| `S018` | Duplicate function step | Working |
| `S019` | Unknown FREERAM target | Working |
| `S020` | Unsafe parameterized step call | Working |
| `S021` | Unknown library | Working |
| `S022` | std used without `lib(std)` | Working |
| `S023` | Unknown std command | Working |
| `S024` | Wrong std argument count | Working |
| `S025` | Legacy reserved slot | Reserved |
| `S026` | std command unsupported by target | Working |
| `S027` | Function called before declaration | Working |
| `S028` | get used on function without result | Working |
| `S029` | result used outside function | Working |
| `S030` | Invalid result position | Working |
| `S031` | Steps are not ascending | Working |
| `S032` | Invalid stand position | Working |
| `S033` | Duplicate stand | Working |
| `S034` | Invalid stand target | Working |
| `S035` | Stand name conflict | Working |
| `S036` | Stand unavailable | Working |
| `S037` | stand used outside x64 | Working |

Unknown lexer characters are also rejected.

Example:

```sl
local value = 10 @ 20
```

Result:

```text
[PARSE ERROR] Unknown character `@`
```

---

## Current Validation Status

| Test | Result |
| :--- | :--- |
| Basic x64 compilation | Passed |
| Kernel Beast | Passed |
| Stand Beast compilation | Passed |
| x64 regression compilation | Passed |
| x16 boot-sector compilation | Passed |
| x16 QEMU execution | Passed |
| x16 VGA output | Passed |
| Unknown character rejection | Passed |
| Unsupported x16 std rejection | Passed |
| Invalid stand target rejection | Passed |
| Direct dependent-step rejection | Passed |
| x16 stand rejection | Passed |
| NASM output generation | Passed |
| Flat binary generation | Passed |

Current conclusion:

```text
Sentinel v0.6-alpha passed its current compiler-level
and x16 boot-level validation targets.
```

---

## Current Known Limitations

| Area | Limitation |
| :--- | :--- |
| x64 boot | Complete long-mode loader missing |
| x32 | Backend incomplete |
| x16 | Minimal std subset |
| `stand` | x64-only |
| Stand types | Automatic scalar-sized slots |
| Type system | Incomplete |
| Memory safety | Incomplete |
| Recursion | Unsupported |
| Function-local `local` | Forbidden |
| Function arguments | First six x64 registers |
| Strings | No complete string runtime |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | Experimental |
| Optimizer | Basic |
| ABI | Experimental |
| Graphics | VGA text only |
| Filesystems | Not implemented |
| Networking | Not implemented |
| Driver framework | Not implemented |
| Library ecosystem | Planned |
| Self-hosting | Not implemented |

---

## Roadmap Status

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 core |
| `v0.3-alpha` | Completed | Semantic hardening |
| `v0.4-alpha-stable` | Completed | First built-in std commands |
| `v0.5-alpha` | Completed | Kernel Toolkit Preview |
| `v0.6-alpha` | Current | Core Language Completion |
| `v0.6.1-alpha` | Planned | Core patch and library foundation |
| `v0.7-alpha` | Planned | x32 backend and optimizer foundation |
| `v0.7.1-alpha` | Planned | Targeted Output Pruning |
| `v0.8-alpha` | Planned | Tooling and playground |
| `v0.9-beta` | Planned | Stability, ABI, tests, and documentation |
| `v1.0-beta` | Future | Stable experimental OSDev platform |

The complete x64 boot chain is the current critical engineering boundary.

---

## Final Status

```text
Sentinel Lang v0.6-alpha
Core Language Completion
Status: Passed current alpha validation
```

Sentinel remains experimental software.

However, the compiler now has:

- a working x64 language core
- a working x16 boot-sector path
- persistent and temporary storage models
- explicit step data flow
- result-producing functions
- semantic diagnostics before NASM
- target-specific std validation
- readable NASM output
- flat binary generation
- large regression programs

Current position:

```text
Sentinel has moved beyond syntax experimentation
and is now building the execution and library layers
required for serious OS development.
```
