# Sentinel Lang

Experimental low-level programming language for OSDev, bootloaders, kernels, and direct hardware-oriented code generation.

Sentinel compiles readable `.sl` source code into inspectable NASM assembly and then into a flat binary.

```text
Sentinel source
      |
      v
Lexer / Parser / AST
      |
      v
Semantic Analyzer
      |
      v
NASM Code Generator
      |
      v
Optimizer
      |
      v
NASM
      |
      v
Flat binary
```

Sentinel is designed as a practical middle ground between readable high-level structure and explicit low-level control.

---

## Current Status

| Field | Value |
| :--- | :--- |
| **Version** | `v0.6-alpha` |
| **Release date** | September 1, 2026 |
| **Milestone** | Core Language Completion |
| **Main target** | `x64` |
| **Secondary target** | `x16` boot sectors |
| **Incomplete target** | `x32` |
| **Output** | NASM assembly / flat binary |
| **Compiler backend** | Private experimental compiler |
| **Project type** | OSDev-first systems language |
| **Stability** | Alpha |

Current strongest language path:

```sl
lib(std)
x64
type(console)
```

Confirmed bootable path:

```sl
custing(silk)
lib(std)
x16
type(console)
```

---

## Documentation

### Sentinel Lang Wiki

```text
https://kotarimorm.github.io/SENTINEL_LANG/
```

### Public Repository

```text
https://github.com/kotarimorm/SENTINEL_LANG
```

Main documents:

- `SPECIFICATION.md` — complete current language specification
- `ROADMAP.md` — public development direction
- `TEST_REPORT.md` — compiler validation results
- `status.md` — current implementation status
- `site/` — GitHub Pages wiki
- `site/anti_manual.pdf` — Sentinel Anti-Manual

---

## v0.6-alpha

`v0.6-alpha` is the **Core Language Completion** milestone.

The release introduces an explicit model for temporary function values and step-to-step data flow.

Main additions:

- `stand` temporary function storage
- `give to (N)` explicit step transfer
- x64 stack frames for stand values
- final `result expression` semantics
- `get function(arguments)` result retrieval
- ascending numbered-step validation
- protection against direct stand-dependent step calls
- removal of unsafe stand-dependent wrappers
- strict rejection of unknown source characters
- x16 per-command `lib(std)` validation
- improved parameter symbol restoration
- updated semantic diagnostics through `S037`

Short version:

```text
v0.4-alpha-stable = first built-in OSDev std commands
v0.5-alpha        = Kernel Beast and x64 hardening
v0.6-alpha        = stand/give and core language completion
```

---

## Transparent Build Model

The Sentinel compiler backend is currently private.

Generated NASM output remains explicit and inspectable.

Users can:

- inspect generated `.asm`
- compare Sentinel source with generated assembly
- manually assemble generated NASM
- debug the resulting binary
- inspect register usage
- inspect stack-frame allocation
- verify emitted runtime helpers

Trust boundary:

```text
Sentinel generates assembly.
NASM generates machine code.
```

Sentinel does not ask users to blindly trust an opaque machine-code backend.

```text
.sl -> readable NASM -> NASM -> flat binary
```

---

## What Sentinel Is

Sentinel is an experimental systems programming language focused on low-level development.

It is intended for:

- bootloader experiments
- kernel prototypes
- hardware-oriented code
- OSDev helper libraries
- direct port I/O
- explicit execution stages
- readable NASM-backed programs
- compiler and language architecture experiments

Sentinel does not try to hide the hardware.

Its goal is:

```text
Make low-level experiments faster, clearer, and harder to misuse.
```

---

## What Sentinel Is Not

Sentinel is currently not:

| Not A | Reason |
| :--- | :--- |
| **Production-ready language** | The language remains alpha |
| **Complete C/C++ replacement** | ABI, ecosystem, optimizer, and targets remain incomplete |
| **Rust replacement** | Full memory safety is not implemented |
| **Complete OS framework** | Drivers, filesystems, networking, and graphics libraries are unfinished |
| **Desktop framework** | Desktop development is not the current focus |
| **Stable ABI language** | The current ABI is experimental |
| **Complete x86 toolchain** | x32 remains incomplete |
| **Self-hosted compiler** | The compiler is not written in Sentinel |
| **Automatic boot-image builder** | Image composition remains external |
| **Complete x64 boot environment** | A long-mode loader is not implemented yet |

Current honest description:

```text
A real experimental OSDev-first compiler with readable syntax,
semantic diagnostics, NASM output, and flat binary generation.
```

---

## Core Language Model

Sentinel now separates persistent and temporary values.

| Concept | Meaning |
| :--- | :--- |
| `local` | Persistent flat program storage |
| `stand` | Temporary storage for one function invocation |
| `give` | Explicitly transfers a stand value to a later step |
| `redo` | Mutates persistent storage or an active stand |
| `create` | Declares a function |
| `start` | Executes a function or safe independent step |
| `get` | Executes a function and retrieves its result |
| `result` | Produces the final function value |
| `lib(std)` | Enables built-in OSDev commands |
| `type(console)` | Selects console-oriented output |
| `x16`, `x32`, `x64` | Select compilation target |

Core distinction:

```text
local = persistent state
stand = temporary function state
```

---

## Persistent Storage

`local` declares persistent flat storage.

```sl
local counter = 0
local status = 1
```

Top-level storage may be accessed from functions:

```sl
x64

local counter = 0

create update()
    (1) redo: counter to counter + 1

start update()
```

Sentinel does not currently use classical lexical scopes for `local`.

A top-level `local` exists for the complete program.

---

## Temporary Function Storage

`stand` declares a temporary value inside one x64 function invocation.

```sl
create calculate(a, b)
    (1) stand: temporary = a + b
```

A stand value:

- lives inside the current function stack frame
- does not become global storage
- disappears when the function returns
- receives a separate value for each invocation
- may be transferred to another step using `give`

Generated direction:

```asm
push rbp
mov  rbp, rsp
sub  rsp, 16

mov  [rbp-8], rax
```

`stand` is currently x64-only.

---

## Explicit Step Transfer

Use `give to (N)` to transfer a stand value to a later numbered step.

```sl
create calculate(a, b)
    (1) stand: temporary = a + b give to (2)
    (2) result temporary * 2
```

Execution:

```text
Step 1 creates temporary.
Step 1 gives temporary to step 2.
Step 2 reads temporary.
Step 2 returns the final result.
```

Current rules:

- the target step must exist
- the target must be inside the same function
- the target must come after the source step
- backward transfers are forbidden
- the stand keeps the same name
- the value exists only during the current invocation
- direct calls to dependent steps are rejected

---

## Direct Step Safety

Consider:

```sl
create pipeline()
    (1) stand: temporary = 30 give to (2)
    (2) result temporary * 2
```

This is valid:

```sl
start pipeline()
```

This is invalid:

```sl
start pipeline(2)
```

The second call skips the step that creates `temporary`.

Expected diagnostic:

```text
[SEMANTIC S036]
Step `(2)` requires stand values from earlier steps.
```

The code generator also skips unsafe independent wrappers:

```asm
; step wrapper sl_func_pipeline_L2 skipped:
; requires incoming stand values
```

---

## Function Results

`result` produces the final function value.

```sl
create add(a, b)
    (1) result a + b
```

Current rules:

- `result` is only valid inside a function
- `result` must appear in the final function step
- `result` must be the final statement
- functions used with `get` must contain a result
- the x64 result is returned through `rax`

Retrieve the result using `get`:

```sl
local left = 10
local right = 20
local answer = get add(left, right)
```

Generated direction:

```asm
call sl_func_add
mov  [sl_var_answer], rax
```

---

## start Versus get

| Command | Purpose |
| :--- | :--- |
| `start function()` | Execute for side effects |
| `get function()` | Execute and retrieve the result |

Side-effect function:

```sl
create show()
    (1) vga_print("Sentinel online")

start show()
```

Value function:

```sl
create calculate(a, b)
    (1) result a + b

local answer = get calculate(left, right)
```

Using `start` on a result-producing function ignores the returned value.

Using `get` on a function without `result` is rejected.

---

## Stand Beast

The primary `v0.6-alpha` validation program:

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
base    = 10 + 20 = 30
doubled = 30 * 2  = 60
mixed   = 60 + 5  = 65
result  = 65 * 3  = 195
```

Confirmed compiler behavior:

- parsing succeeds
- semantic analysis succeeds
- three stack slots are allocated
- the stack frame is aligned to 32 bytes
- the result is returned through `rax`
- unsafe dependent step wrappers are omitted
- NASM assembly succeeds
- flat x64 binary generation succeeds

---

## Function Steps

Functions use numbered steps.

```sl
create boot()
    (1) vga_clear()
    (2) vga_print("Sentinel online")
```

Step numbers must be ascending.

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

Duplicate steps remain invalid:

```text
[SEMANTIC S018]
```

---

## Function Declaration Order

Functions must be declared before use.

Valid:

```sl
create boot()
    (1) print("boot")

start boot()
```

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

This applies to both `start` and `get`.

---

## Function Parameters

Current experimental x64 parameter mapping:

| Argument | Register |
| :--- | :--- |
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

Parameters are temporary input names.

They are not persistent storage and cannot be mutated directly:

```sl
create test(value)
    (1) redo: value to value + 1
```

Expected diagnostic:

```text
[SEMANTIC S007]
```

Use a stand value instead:

```sl
create test(value)
    (1) stand: changed = value + 1
```

---

## lib(std)

`lib(std)` enables built-in OSDev-oriented commands.

### x64 Commands

| Command | Purpose |
| :--- | :--- |
| `vga_print(value)` | Print through VGA text output |
| `vga_clear()` | Clear VGA text output |
| `halt()` | Emit a safe halt loop |
| `nop()` | Emit `nop` |
| `panic(value)` | Print panic information and halt |
| `io_wait()` | Perform an I/O delay |
| `read_port(port)` | Read one byte from an I/O port |
| `write_port(port, value)` | Write one byte to an I/O port |
| `pic_eoi()` | Send PIC end-of-interrupt |
| `irq_disable()` | Emit `cli` |
| `irq_enable()` | Emit `sti` |

### x16 Subset

The current x16 subset contains:

```text
halt
nop
vga_clear
vga_print
```

Unsupported commands are rejected before NASM.

Example:

```sl
custing(silk)
lib(std)
x16

write_port(0x20, 0x20)
```

Expected diagnostic:

```text
[SEMANTIC S026]
std command `write_port` is not supported in x16 mode.
```

---

## x16 Boot Sector

Confirmed bootable example:

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

The generated boot sector contains:

```asm
times 510-($-$$) db 0
dw 0xAA55
```

Confirmed result:

```text
Binary size: 512 bytes
Boot signature: 0xAA55
QEMU execution: passed
BIOS text output: passed
```

---

## Important x64 Boot Limitation

Sentinel can generate a separate x64 kernel binary:

```text
kernel.sl -> kernel.asm -> kernel.bin
```

However, the current x16 bootloader does not yet:

- load `kernel.bin` from disk
- place it at its expected memory address
- create a GDT
- create page tables
- enter protected mode
- enter long mode
- transfer control to the x64 `_start`

Simply combining binaries does not perform these operations.

```text
bootloader.bin + kernel.bin != complete boot chain
```

A proper loader remains future work.

The old experimental source-level protocol using:

```sl
receive("bootloader.sl")
give("kernel.sl")
x16 goto x32
```

has been removed.

The current `give` keyword is used only for stand transfer:

```sl
stand: value = expression give to (2)
```

---

## Semantic Diagnostics

Current diagnostics include:

| Code | Meaning |
| :--- | :--- |
| `S001` | Reserved keyword used as a name |
| `S002` | Duplicate function |
| `S003` | Duplicate persistent storage |
| `S004` | Duplicate parameter |
| `S005` | Parameter conflicts with storage |
| `S007` | Parameter mutated directly |
| `S008` | Unknown mutation target |
| `S009` | Unknown function |
| `S010` | Recursive call unsupported |
| `S011` | Function-local `local` blocked |
| `S012` | Missing function step |
| `S013` | Invalid redo target |
| `S014` | Storage conflicts with function |
| `S015` | Unknown storage symbol |
| `S016` | Step selectors mixed with arguments |
| `S017` | Wrong argument count |
| `S018` | Duplicate numbered step |
| `S019` | Unknown FREERAM target |
| `S020` | Unsafe parameterized step call |
| `S021` | Unknown library |
| `S022` | std used without `lib(std)` |
| `S023` | Unknown std command |
| `S024` | Wrong std argument count |
| `S026` | std command unsupported by target |
| `S027` | Function called before declaration |
| `S028` | `get` used on function without result |
| `S029` | `result` used outside function |
| `S030` | Invalid result position |
| `S031` | Function steps are not ascending |
| `S032` | Invalid stand declaration position |
| `S033` | Duplicate stand name |
| `S034` | Invalid or missing stand target |
| `S035` | Stand name conflict |
| `S036` | Stand value unavailable |
| `S037` | stand used outside x64 |

Unknown characters are also rejected:

```sl
local value = 10 @ 20
```

Result:

```text
[PARSE ERROR] Unknown character `@`
```

---

## Validation Status

| Test | Result |
| :--- | :--- |
| Kernel Beast | Passed |
| Stand Beast compilation | Passed |
| x16 boot sector compilation | Passed |
| x16 QEMU boot | Passed |
| x64 regression compilation | Passed |
| Unknown character rejection | Passed |
| Unsupported x16 std rejection | Passed |
| Missing stand target rejection | Passed |
| Direct dependent-step rejection | Passed |
| x16 stand rejection | Passed |

Important distinction:

```text
x64 code generation is tested through NASM compilation.
Direct x64 QEMU execution still requires a long-mode loader.
```

---

## Current Feature Matrix

| Feature | Status | Notes |
| :--- | :--- | :--- |
| Lexer | Working | Unknown characters rejected |
| Parser | Working | Current v0.6 syntax |
| AST | Working | Includes stand/result nodes |
| Semantic analyzer | Working | Diagnostics through S037 |
| NASM codegen | Working | Main backend |
| Optimizer | Basic | Early peephole passes |
| Flat binary output | Working | Through NASM |
| x64 | Main target | Strongest compiler path |
| x16 | Working experimental path | Boot sectors and small std subset |
| x32 | Incomplete | Planned for later work |
| `local` | Working | Persistent flat storage |
| `stand` | Working | x64 temporary stack storage |
| `give` | Working | Forward step transfer |
| `redo` | Working | Mutation |
| `create` | Working | Function declaration |
| `start` | Working | Function and safe step calls |
| `get` | Working | Function result retrieval |
| `result` | Working | Final function result |
| Conditions | Working | `if / else / end` |
| Loops | Working | `while` and `repeat` |
| Arrays | Basic | No bounds checking |
| Structs | Experimental | Not a current focus |
| `try/catch` | Experimental | Not a complete exception runtime |
| `lib(std)` x64 | Working | Main OSDev command set |
| `lib(std)` x16 | Minimal | Four-command subset |
| Port I/O | x64 | `read_port` / `write_port` |
| IRQ helpers | x64 | CLI, STI, PIC EOI |
| x64 boot chain | Missing | Required for direct kernel execution |

---

## Current Limitations

| Area | Limitation |
| :--- | :--- |
| x64 boot | No complete long-mode loader |
| x32 | Backend incomplete |
| x16 | Small std subset |
| `stand` | x64-only |
| Stand typing | Automatic scalar-sized slots |
| Type system | Incomplete |
| Memory safety | Incomplete |
| Recursion | Unsupported |
| Function-local `local` | Forbidden; use `stand` |
| Function arguments | First six x64 register arguments |
| Strings | No complete string runtime |
| Arrays | No bounds checking |
| Structs | Experimental |
| Exceptions | Experimental |
| Optimizer | Basic |
| ABI | Experimental |
| Graphics | VGA text helpers only |
| Filesystems | Not implemented |
| Networking | Not implemented |
| Driver framework | Not implemented |
| Library ecosystem | Not released |
| Self-hosting | Not implemented |

---

## Why Sentinel Exists

Sentinel explores one primary question:

```text
Can OSDev code become easier to read and faster to write
without hiding the machine?
```

C, C++, Rust, Zig, and assembly already have:

- mature compilers
- stronger optimizers
- larger ecosystems
- established ABI support
- extensive OSDev knowledge
- real production use

Sentinel is much younger.

Its current strengths are narrower:

- readable low-level syntax
- explicit numbered execution stages
- semantic diagnostics before NASM
- inspectable generated assembly
- built-in OSDev commands
- explicit persistent versus temporary state
- fast kernel and bootloader prototyping

Sentinel is not currently better than mature systems languages in every area.

It is attempting to become unusually effective in one area:

```text
Fast, readable, explicit OSDev experimentation.
```

---

## Roadmap

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 compiler core |
| `v0.3-alpha` | Completed | Semantic diagnostics and hardening |
| `v0.4-alpha-stable` | Completed | First built-in std command pack |
| `v0.5-alpha` | Completed | Kernel Toolkit Preview and Kernel Beast |
| `v0.6-alpha` | Current | Core Language Completion and stand/give |
| `v0.6.1-alpha` | Planned | v0.6 fixes and library ecosystem foundation |
| `v0.7-alpha` | Planned | x32 backend and optimizer foundation |
| `v0.7.1-alpha` | Planned | Targeted Output Pruning |
| `v0.8-alpha` | Planned | Tooling and playground |
| `v0.9-beta` | Planned | Tests, ABI, stability, and documentation |
| `v1.0-beta` | Future | Stable experimental OSDev-first platform |

Potential future library families:

```text
graphics
files
BTK
syler
```

These are architectural directions, not current built-in libraries.

---

## Next Technical Boundary

The next major technical boundary is not another syntax command.

It is a complete x64 boot chain:

```text
BIOS
  |
  v
x16 boot sector
  |
  v
Load kernel from disk
  |
  v
Protected mode
  |
  v
Page tables
  |
  v
Long mode
  |
  v
x64 Sentinel kernel
```

After that boundary, Sentinel can begin demonstrating:

- real x64 QEMU kernel execution
- framebuffer graphics
- keyboard-driven programs
- rotating wireframe models
- interrupts and driver experiments
- library-based OS development

---

## Project Position

Sentinel remains alpha software.

The compiler is experimental.

The compiler backend is private.

The public repository contains documentation, status information, test reports, the project roadmap, and the GitHub Pages wiki.

Generated output should still be inspected.

Current best uses:

```text
OSDev experiments
boot-sector programs
kernel-style prototypes
compiler architecture research
NASM-backed low-level code generation
```

---

## License

See `LICENSE`.

---

## Final Summary

Sentinel `v0.6-alpha` completes the first version of the core function data-flow model.

It introduces:

- persistent storage through `local`
- temporary function storage through `stand`
- explicit transfer through `give`
- mutation through `redo`
- final values through `result`
- result retrieval through `get`
- target-aware std validation
- stronger semantic diagnostics
- safer x64 stack-frame generation

Sentinel now has:

- a working compiler pipeline
- readable NASM output
- flat binary generation
- a working x16 boot-sector path
- a strong x64 code-generation path
- built-in OSDev commands
- Kernel Beast regression coverage
- Stand Beast validation
- explicit temporary function state

It is still incomplete, but it is no longer only a syntax experiment.

```text
Sentinel Lang
OSDev-first. NASM-backed. Explicit by design.
```
