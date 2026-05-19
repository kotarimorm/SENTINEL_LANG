# SENTINEL_LANG

Experimental low-level programming language designed for operating systems, bootloaders and direct hardware interaction.

Sentinel Lang compiles directly into NASM x86/x64 flat binaries with minimal abstraction and explicit hardware control.

---

## Compilation Pipeline

```txt
.sl  ->  compiler.py  ->  .asm  ->  NASM  ->  flat binary
```

---

## Design Goals

* minimal syntax
* direct hardware access
* predictable compilation
* explicit memory control
* integrated low-level blocks
* flat binary generation
* no runtime dependencies

---

## Architecture

| Mode | Description           | Primary Usage            |
| ---- | --------------------- | ------------------------ |
| x16  | 16-bit Real Mode      | BIOS / Bootloaders       |
| x32  | 32-bit Protected Mode | Experimental kernels     |
| x64  | 64-bit Long Mode      | Modern operating systems |

---

## Screenshots

### IDE / Editor

Place inside:

```txt
/screenshots/ide.png
```

---

### ASM Generation

Place inside:

```txt
/screenshots/asm_generation.png
```

---

### QEMU Boot

Place inside:

```txt
/screenshots/qemu_boot.png
```

---

## Example — Sentinel Lang

```lua
x64
type(console)

local msg = "Hello from Sentinel Kernel!"

create kernel_main()
    (1) console_print(msg)
    (2) low-code:
            cli
            halt

start kernel_main()
```

---

## Generated NASM Output

```asm
mov rsi, msg
call sl_print_str

cli
hlt
```

---

## Low-Code Block

Sentinel Lang supports direct inline low-level instructions through the `low-code` block.

```lua
low-code:
    cli
    emit 0x31, 0xC0
    emit 0x8E, 0xD8
    sti
```

This allows direct hardware interaction without leaving the language environment.

---

## Features

* direct NASM generation
* x16 / x32 / x64 support
* bootloader-oriented architecture
* VGA / VESA graphics modes
* inline low-level instruction blocks
* explicit memory management
* integrated debugging modes
* AST / ASM dumping
* flat binary compilation pipeline

---

## Build

```bash
python3 compiler.py file.sl

nasm -f bin file.asm -o file.bin

qemu-system-x86_64 -drive format=raw,file=file.bin -no-reboot
```

---

## Repository Structure

```txt
examples/       Sentinel Lang source examples
generated/      Generated NASM output
screenshots/    IDE and runtime screenshots
architecture/   Internal compiler documentation
```

---

## Documentation

* `SPECIFICATION.md` — full language specification
* `ROADMAP.md` — future plans and architecture direction

---

## Status

Experimental systems-language project under active development.

Core compiler backend remains private.
