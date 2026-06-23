# Sentinel Lang Roadmap

**Current version:** `v0.4-alpha-stable`  
**Current phase:** First OSDev std helper pack  
**Main target:** `x64`

---

## Roadmap Philosophy

Sentinel is an experimental OSDev-first systems language.

The roadmap is intentionally staged.

The goal is not to add everything at once.

The goal is to grow from:

```text
compiler core
```

to:

```text
OSDev helper libraries
```

to:

```text
demo kernel / mini OS
```

to:

```text
stable experimental OSDev language core
```

Each version should harden one important layer before the next layer is added.

---

## Current Milestone

```text
v0.4-alpha-stable
```

Main result:

```text
First working lib(std) OSDev helper pack.
```

Current `std` command set:

```text
vga_print()
vga_clear()
nop()
halt()
io_wait()
read_port()
write_port()
pic_eoi()
irq_disable()
irq_enable()
```

Current status:

```text
Passed current validation.
```

---

## Completed Milestones

### v0.1-alpha — Compiler Foundation

Status:

```text
Completed
```

Focus:

- basic compiler structure
- lexer foundation
- parser foundation
- early AST
- early NASM output path

Result:

```text
Sentinel became compilable as an experimental language prototype.
```

---

### v0.2-alpha — Working x64 Core

Status:

```text
Completed
```

Focus:

- working x64 path
- `type(console)`
- basic VGA output
- `local`
- `redo`
- functions
- loops
- arrays
- generated NASM output
- flat binary pipeline

Result:

```text
Sentinel became capable of compiling non-trivial x64 programs.
```

---

### v0.3-alpha — Core Hardening

Status:

```text
Completed
```

Focus:

- semantic analyzer
- readable Sentinel-level errors
- flat storage validation
- duplicate storage detection
- function validation
- step validation
- argument validation
- unsafe step-call protection
- x64 register preservation fixes

Important diagnostics:

```text
S001–S020
```

Result:

```text
Broken Sentinel started failing as Sentinel instead of NASM.
```

---

### v0.4-alpha-stable — First lib(std)

Status:

```text
Completed
```

Focus:

- `lib(std)` syntax
- std command parsing
- std semantic validation
- std x64 codegen
- port I/O helpers
- VGA helpers
- IRQ helpers
- `read_port()` as expression
- `write_port()` with expression arguments
- x64-only std guard

Important diagnostics:

```text
S021–S026
```

Current std commands:

```text
vga_print()
vga_clear()
nop()
halt()
io_wait()
read_port()
write_port()
pic_eoi()
irq_disable()
irq_enable()
```

Result:

```text
Sentinel gained its first practical OSDev helper command pack.
```

---

## Next Milestone

### v0.5-alpha — Demo Kernel / Mini OS + Documentation Site

Status:

```text
Planned
```

Primary goals:

- create first demo kernel / mini OS prototype
- build a GitHub Pages documentation site
- add clear getting-started guide
- add public examples
- document `lib(std)` usage
- show real OSDev flow in Sentinel
- prove that Sentinel can be used for a small readable OSDev system

Expected demo focus:

```text
x64
type(console)
lib(std)
```

Possible demo kernel features:

- boot message
- VGA clear/print
- simple boot stages
- keyboard port polling experiment
- PIC EOI usage
- IRQ enable/disable demo
- safe halt loop

Example direction:

```sl
lib(std)
x64
type(console)

vga_clear()
vga_print("Sentinel kernel boot")

halt()
```

Documentation site goals:

- Home page
- Getting Started
- Language Guide
- `lib(std)` Reference
- Semantic Errors
- Examples
- Roadmap
- Specification link

The full `SPECIFICATION.md` should remain the source of truth.

The website should make it easier to read.

---

## Future Milestones

### v0.6-alpha — Runtime And Low-Level Library Expansion

Status:

```text
Planned
```

Possible goals:

- expand `lib(std)`
- improve ABI consistency
- improve codegen helpers
- add more kernel utility commands
- improve `panic()` behavior
- improve string / output helpers
- add safer helper wrappers for common OSDev actions

Possible additions:

```text
panic()
vga_newline()
vga_set_color()
mem_zero()
mem_copy()
```

---

### v0.7-alpha — Driver And Hardware Helper Experiments

Status:

```text
Planned
```

Possible goals:

- keyboard helper layer
- timer helper layer
- PIC / IRQ helper expansion
- early driver patterns
- hardware command packs
- better examples for port-driven devices

Important note:

```text
Drivers should be normal Sentinel code using libraries.
A separate type(driver) mode is not currently planned.
```

---

### v0.8-alpha — Host Tooling Research

Status:

```text
Planned
```

Possible goals:

- better CLI
- better IDE integration
- improved diagnostics display
- project templates
- example runner
- generated ASM viewer
- local docs tooling

---

### v0.9-beta — Testing And Documentation Hardening

Status:

```text
Planned
```

Possible goals:

- larger regression test suite
- stable examples
- full semantic error documentation
- public docs cleanup
- compatibility hardening
- beta preparation
- reduce known edge-case failures

---

### v1.0 — Stable Experimental OSDev Language Core

Status:

```text
Long-term goal
```

Possible goals:

- stable core syntax
- stable compiler behavior
- stable documentation
- stable OSDev examples
- stronger type validation
- stronger ABI rules
- larger library foundation
- better testing discipline

Important:

```text
v1.0 does not mean Sentinel becomes a C/C++ replacement.
v1.0 means Sentinel has a stable experimental OSDev language core.
```

---

## Long-Term Direction

After `v1.0`, possible long-term tracks include:

- self-hosting research
- richer standard libraries
- driver helper packs
- framebuffer / GOP graphics direction
- networking research
- package/module system research
- larger OSDev systems
- Sentinel-written tooling
- Sentinel IDE experiments

Self-hosting remains a long-term goal.

It should happen only after the language core, ABI rules, libraries, and tooling are strong enough.

---

## Graphics Direction

Old VESA-focused planning is not the main future direction.

Preferred long-term graphics direction:

```text
GOP / framebuffer
```

Possible future graphics helpers:

```text
framebuffer_clear()
framebuffer_put_pixel()
framebuffer_rect()
framebuffer_text()
```

This is not a `v0.5` target.

---

## Networking Direction

Networking is important, but not an early target.

A real network stack requires multiple layers:

```text
PCI
NIC driver
Ethernet
ARP
IPv4
ICMP
UDP
DHCP
DNS
TCP
HTTP
```

Networking should come after stronger driver/hardware foundations.

It is not a `v0.5` target.

---

## Documentation Direction

Current docs:

- `README.md`
- `SPECIFICATION.md`
- `ROADMAP.md`
- `TEST_REPORT.md`
- `status.md`

Planned for `v0.5-alpha`:

```text
GitHub Pages documentation site
```

Site sections should include:

- Home
- Getting Started
- Language Guide
- Specification
- `lib(std)` Reference
- Semantic Errors
- Examples
- Roadmap

Later optional section:

```text
Anti-Manual
```

The Anti-Manual should remain separate from official technical documentation.

---

## Roadmap Summary

| Version | Status | Goal |
| :--- | :--- | :--- |
| `v0.1-alpha` | Completed | Compiler foundation |
| `v0.2-alpha` | Completed | Working x64 core |
| `v0.3-alpha` | Completed | Core hardening and semantic diagnostics |
| `v0.4-alpha-stable` | Completed | First `lib(std)` OSDev helper pack |
| `v0.5-alpha` | Planned | Demo kernel / mini OS + GitHub Pages docs |
| `v0.6-alpha` | Planned | Runtime and low-level library expansion |
| `v0.7-alpha` | Planned | Driver and hardware helper experiments |
| `v0.8-alpha` | Planned | Host tooling research |
| `v0.9-beta` | Planned | Testing and documentation hardening |
| `v1.0` | Long-term | Stable experimental OSDev language core |

---

## Final Roadmap Note

Sentinel should grow carefully.

The current direction is:

```text
core first
then std
then demo kernel
then docs/site
then larger OSDev helpers
then beta hardening
then stable experimental core
```

`v0.4-alpha-stable` is an important milestone because it is the first version where Sentinel has both:

```text
semantic stability
```

and:

```text
practical hardware helper commands
```
