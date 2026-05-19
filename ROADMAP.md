# SENTINEL_LANG — ROADMAP

> Experimental development roadmap for Sentinel Lang.
>
> This document represents current development goals and research directions.
> Features, architecture and priorities may change over time during compiler and systems research.

---

# Legend

```txt id="a1z8qw"
[x] Completed
[-] In Progress
[ ] Planned
```

---

# v0.1 — FOUNDATION (Current Version)

## Compiler

```txt id="r2m9xp"
[x] Lexer — full language tokenization
[x] Parser — AST generation
[x] Code generator — x16 / x32 / x64 flat binaries
[x] Optimizer — peephole + dead-code removal
[x] Pure NASM generation without section directives
[x] Windows compatibility fixes (UTF-8 / cp1251 handling)
```

---

## Language

```txt id="m8x2vr"
[x] local / redo / create / start / get result
[x] if / then / else / end
[x] while / repeat / break / skip
[x] try / catch
[x] low-code blocks (direct ASM integration)
[x] console_print / print / FREERAM
[x] custing(silk/sink) logging system
[x] type(console/gui) output modes
[x] type todo(VGA/VESA/console) runtime switching
[x] Numeric literals: decimal / hex / binary / separators
[x] Arrays, structures and imports
```

---

## Built-in Libraries

```txt id="t5w1kq"
[x] GDT builder (sl_gdt_create / sl_gdt_install)
[x] IDT builder (sl_idt_set_gate / sl_idt_install)
[x] Paging utilities (sl_page_map)

[x] GUI x16:
    pixel / hline / vline / rect / box / clear

[x] GUI x64:
    framebuffer fill / pixel / rect

[x] VGA print x16 (BIOS INT 10h)
[x] VGA print x64 (direct 0xB8000 access)
```

---

## IDE

```txt id="p9v4zm"
[x] Syntax highlighting editor
[x] Line numbering
[x] F5 compilation + ASM output
[x] Console logging
[x] Multi-tab support
[x] Snippet system
```

---

# v0.2 — BOOTLOADER & KERNEL BASE

## Compiler

```txt id="x7m2qa"
[ ] x16 -> x32 transition helpers (enter_pm())
[ ] x32 -> x64 transition helpers (enter_lm())
[ ] Validation of invalid mode transition order
[ ] Inline functions (inline create func())
[ ] Constants (const X = 42)
[ ] Macro system (#define-style)
[ ] Improved compiler diagnostics with line tracking
```

---

## Language

```txt id="c8w5lr"
[ ] enter_pm() — Real Mode -> Protected Mode
[ ] enter_lm() — Protected Mode -> Long Mode

[ ] Full namespace imports:
    use "kbd" as keyboard

[ ] Bitfields inside structures
[ ] Pointer support:
    ptr<int> p = 0x1000

[ ] Inline ASM register access:
    reg[rax] = x
```

---

## Built-in Libraries

```txt id="v2k8pa"
[ ] A20 enable helpers (a20_enable())
[ ] E820 memory map support (mmap_get())
[ ] PIC 8259 initialization (pic_init())
[ ] PIT timer support (pit_set_freq())
[ ] Basic heap allocator (alloc / free)
```

---

## IDE

```txt id="n4x1mz"
[ ] Keyword autocomplete
[ ] Inline editor diagnostics
[ ] QEMU execution directly from IDE
[ ] Project file tree
[ ] Ctrl+F file search
```

---

# v0.3 — DRIVERS & INTERRUPTS

## Language

```txt id="f8v3qw"
[ ] on_interrupt(N) handlers
[ ] Integrated port I/O:
    port[0x60] = 0xFF

[ ] Async handlers (async create)
[ ] volatile variables
```

---

## Built-in Libraries

```txt id="k1m8ax"
[ ] PS/2 keyboard driver
[ ] PS/2 mouse driver
[ ] ATA/PIO disk access
[ ] UART / COM serial support
[ ] RTC real-time clock access
```

---

## File Systems

```txt id="u5p2rm"
[ ] FAT12 reader
[ ] FAT32 reader
[ ] Basic VFS layer
```

---

# v0.4 — MULTITASKING

## Language

```txt id="g3x9kl"
[ ] create_task(func)
[ ] yield()
[ ] Task priorities
[ ] Mutex support
[ ] Semaphore support
```

---

## Built-in Libraries

```txt id="d8w2vp"
[ ] Round-robin scheduler
[ ] TSS context switching
[ ] Timer-interrupt preemption
[ ] Thread-local storage
[ ] Basic IPC
```

---

# v0.5 — GUI LIBRARY

## Concept

Integrated GUI library without external dependencies.
Everything compiles directly into the final binary.

---

## Components

```txt id="y7q1mz"
[ ] Window manager
[ ] Double buffering
[ ] Compositor system
[ ] PSF bitmap fonts

[ ] Basic widgets:
    [ ] window(...)
    [ ] button(...)
    [ ] label(...)
    [ ] textbox(...)
    [ ] scrollbar(...)
    [ ] checkbox(...)
    [ ] progressbar(...)

[ ] Icon system
[ ] Mouse cursor support
[ ] Taskbar
[ ] Desktop environment
[ ] Menus
[ ] Dialog windows
```

---

## Themes

```txt id="b2m8xr"
[ ] Sentinel Classic (Windows XP-inspired)
[ ] Sentinel Dark
[ ] Custom .theme support
```

---

# v0.6 — NETWORK STACK

```txt id="m7x3wa"
[ ] Ethernet drivers (RTL8139 / virtio-net)
[ ] ARP
[ ] IPv4
[ ] ICMP
[ ] UDP
[ ] TCP
[ ] DHCP client
[ ] DNS resolver
[ ] HTTP client
[ ] Socket API
```

---

# v0.7 — REAL-TIME & OPTIMIZATION

```txt id="r4p8zk"
[ ] RTOS mode
[ ] Deadline scheduler
[ ] Lock-free structures
[ ] SIMD optimizations (SSE / AVX)
[ ] Integrated profiler
[ ] Link-time optimization (LTO)
```

---

# v1.0 — SELF-HOSTING

Primary milestone:
Sentinel Lang compiles itself.

```txt id="q9w2vp"
[ ] Compiler written in Sentinel Lang
[ ] Standard library fully rewritten in Sentinel Lang
[ ] Package manager
[ ] Documentation generation from source
[ ] Integrated testing framework
```

---

# Long-Term Goals

## Architectures

```txt id="u1m8ra"
[ ] ARM64
[ ] RISC-V
[ ] WebAssembly backend
```

---

## SentinelOS

```txt id="x5v2pl"
[ ] Minimal console operating system
[ ] Full GUI operating system
[ ] Real-time edition
[ ] Embedded edition
```

---

## Tooling

```txt id="p3w7kq"
[ ] sentinel-dbg debugger
[ ] sentinel-dis disassembler
[ ] Integrated emulator
[ ] LSP server for editors
```

---

# Current Priorities

```txt id="n8q4rm"
1. Bootloader validation in QEMU
2. x64 VGA output testing
3. GUI library v1 for VGA Mode 13h
4. enter_pm() / enter_lm() transitions
5. First keyboard driver implementation
```
