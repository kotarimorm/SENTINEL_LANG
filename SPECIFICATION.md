# Sentinel Lang v0.1 — Full Specification

Sentinel Lang is an experimental low-level systems programming language designed for operating systems, bootloaders and direct hardware interaction.

The language compiles directly into NASM x86/x64 flat binaries with minimal abstraction and explicit low-level control.

---

# 1. File Structure

Every source file follows this structure:

1. `custing(...)` — optional logging mode
2. `xNN` — compilation mode (required)
3. `type(...)` — output mode (optional)
4. remaining program code

Example:

```lua id="4ew4i8"
custing(silk)
x16
type(console)

local msg = "Hello!"
```

---

# 2. Compilation Modes

| Mode  | Description           | Usage                    |
| ----- | --------------------- | ------------------------ |
| `x16` | 16-bit Real Mode      | BIOS / Bootloaders       |
| `x32` | 32-bit Protected Mode | Experimental kernels     |
| `x64` | 64-bit Long Mode      | Modern operating systems |

Compilation process:

```bash id="h4jw4q"
python3 compiler.py myfile.sl

nasm -f bin myfile.asm -o myfile.bin
```

---

# 3. Output Modes — type()

Defined after compilation mode.

## Console Mode

```lua id="8t4h0h"
type(console)
```

* x16 → BIOS INT 10h teletype output
* x64 → direct VGA text buffer output (`0xB8000`)

---

## Graphical Mode

```lua id="3lq8an"
type(gui)(VGA)
type(gui)(VESA)
```

| Mode   | Description                    |
| ------ | ------------------------------ |
| `VGA`  | VGA Mode 13h — 320x200x256     |
| `VESA` | VESA framebuffer — 1024x768x32 |

---

## Runtime Switching

```lua id="m4gq7z"
type todo(VGA)
type todo(VESA)
type todo(console)
```

Example:

```lua id="1k0y0z"
type(console)

console_print("Loading...")

type todo(VGA)

.. graphics mode ..

type todo(console)
```

---

# 4. Logging — custing()

```lua id="ckjlwm"
custing(silk)
custing(sink)
```

| Mode   | Description                     |
| ------ | ------------------------------- |
| `silk` | crash location + registers only |
| `sink` | full execution log              |

If used, logging must always be the first line.

---

# 5. Variables

## Declaration

```lua id="rxw1wi"
local x = 10
local y = 3.14
local s = "text"
local f = true
local n = null
local arr = [1, 2, 3]
```

---

## Explicit Types

```lua id="jlwm4r"
local x int   = func()
local y float = other()
local s str   = get_name()
```

---

## Data Types

| Type    | Description            |
| ------- | ---------------------- |
| `int`   | default 64-bit integer |
| `int8`  | 8-bit integer          |
| `int16` | 16-bit integer         |
| `int32` | 32-bit integer         |
| `int64` | 64-bit integer         |
| `float` | 64-bit double          |
| `str`   | null-terminated string |
| `bool`  | true / false           |
| `null`  | empty value            |

---

## Numeric Literals

```lua id="xwvkj9"
42
0xFF
0b11001111
1_000_000
```

---

# 6. Value Modification — redo

```lua id="ubv3pl"
redo: x to 42
redo: x to x + 10
redo: x to x - 5
redo: x to x * 2
redo: x to x / 4
redo: x to x % 3

redo: x buff 3

redo: x shift_left  2
redo: x shift_right 2

redo: x bit_and 0xFF
redo: x bit_or  0x01
redo: x bit_xor 0xFF
```

---

# 7. Functions

## Declaration

```lua id="mtf5w0"
create func_name(param1, param2)

    (1) local result = param1 + param2
    (2) console_print(result)
    (3) FREERAM(result)
```

Each line inside the function is indexed starting from `(1)`.

---

## Execution

```lua id="4m2y0d"
start func_name()

start func_name(1, 3)

start func_name(2)
```

---

## Result Access

```lua id="e7o8b5"
local r = get func_name() result()

local r = get func_name(1) result()

local r = get func_name(1, 3) result()
```

---

# 8. Conditions

## Single-line

```lua id="yylgjr"
if x > 10 then console_print("big")

if x == 0 then
    console_print("zero")
else
    console_print("nope")
```

---

## Multi-line

```lua id="3ojmgn"
if x > 10 then

    console_print("big")
    redo: x to x - 1

else

    console_print("small")

end
```

---

## Comparison Operators

```txt id="t9b6zy"
>   <   >=   <=   ==   !=   and   or   not
```

---

# 9. Loops

## Repeat N Times

```lua id="0f05sk"
repeat(10)

    console_print(x)

    redo: x to x + 1

end
```

---

## While Loop

```lua id="qg9d3d"
while x > 0

    redo: x to x - 1

end
```

---

## Loop Control

```txt id="njlwm8"
break    exit loop
skip     next iteration
```

---

# 10. Built-in Commands

## Output

```lua id="53o43d"
console_print("text")

console_print(x)

print("text")
```

---

## Memory

```lua id="bvrjcu"
FREERAM(x)
```

Explicit memory release without garbage collection.

---

# 11. Low-Code Block

Direct inline low-level instructions inside Sentinel Lang.

```lua id="8r5mrw"
low-code:

    cli
    sti
    halt
    nop

    push rax
    pop  rax

    call 0x7C00
    jump 0x7C00

    int 0x10

    emit 0x90
    emit 0xEB, 0x00

    align 16

    label: myLabel

    write 0xFF to port 0x60

    read port 0x60 to x

    reg rax to x

    x to reg rax
```

---

## x16 Segment Initialization Example

```lua id="6l2rbl"
low-code:

    cli

    emit 0x31, 0xC0
    emit 0x8E, 0xD8
    emit 0x8E, 0xC0
    emit 0x8E, 0xD0

    emit 0xBC, 0x00, 0x7C

    sti
```

---

# 12. Structures

```lua id="90fef8"
struct Point

    x int
    y int

end

struct Rect

    x int
    y int
    w int
    h int

    color int8

end

local p = Point(10, 20)

print(p.x)

redo: p.y to 50
```

---

# 13. Error Handling

```lua id="mjlwm4"
try

    local r = risky_func()

    console_print(r)

catch err

    console_print("Error!")

    console_print(err)

end
```

---

# 14. Arrays

```lua id="8aq0lx"
local arr = [1, 2, 3, 4, 5]

local arr int = [10, 20, 30]

print(arr[0])

redo: arr[2] to 99
```

---

# 15. Import System

```lua id="2qjlwm"
use "memory.sl"

use "drivers/keyboard.sl"
```

Compilation order:

```txt id="j2xgzm"
x16 -> x32 -> x64
```

---

# 16. Built-in Libraries

All libraries are embedded directly into the final binary.

---

## GDT

```txt id="rm7v7n"
sl_gdt_create
sl_gdt_install
```

---

## IDT

```txt id="jlwm11"
sl_idt_set_gate
sl_idt_install
```

---

## Paging

```txt id="jlwm12"
sl_page_map
```

---

## GUI x16 — VGA Mode 13h

```txt id="jlwm13"
sl_gui_clear
sl_gui_pixel
sl_gui_hline
sl_gui_vline
sl_gui_rect
sl_gui_box
```

---

## GUI x64 — Framebuffer

```txt id="jlwm14"
sl_fb_fill
sl_fb_put_pixel
sl_fb_draw_rect
```

---

## Output

```txt id="jlwm15"
sl_print16
sl_print_str
sl_print_int
```

---

# 17. Compiler Optimizations

Applied automatically during compilation.

| Original         | Optimized       |
| ---------------- | --------------- |
| `mov reg, 0`     | `xor reg, reg`  |
| `add reg, 0`     | removed         |
| `imul reg, 1`    | removed         |
| `push X + pop X` | removed if safe |
| dead code        | removed         |

---

# 18. File Extensions

| Extension | Description           |
| --------- | --------------------- |
| `.sl`     | Sentinel Lang source  |
| `.asm`    | generated NASM output |
| `.bin`    | final flat binary     |

---

# 19. Full Examples

## x16 Bootloader

```lua id="vf5w2t"
custing(silk)

x16

type(console)

local msg = "Sentinel OS booting..."

create boot()

    (1) low-code:

            cli

            emit 0x31, 0xC0
            emit 0x8E, 0xD8
            emit 0x8E, 0xC0
            emit 0x8E, 0xD0

            emit 0xBC, 0x00, 0x7C

            sti

    (2) console_print(msg)

    (3) low-code:

            cli
            halt

start boot()
```

---

## x64 Kernel

```lua id="k3g0tr"
x64

type(console)

local msg1 = "Hello from Sentinel Kernel!"

local msg2 = "x64 Long Mode. OK"

create kernel_main()

    (1) console_print(msg1)

    (2) console_print(msg2)

    (3) low-code:

            cli
            halt

start kernel_main()
```

---

## GUI Demo x16

```lua id="jlwm16"
custing(silk)

x16

type(gui)(VGA)

local bg_color = 1

local window_color = 15

create gui_main()

    (1) low-code:

            emit 0xB8, 0x13, 0x00
            emit 0xCD, 0x10

            emit 0xB8, 0x00, 0xA0
            emit 0x8E, 0xC0

    (2) low-code:

            emit 0x31, 0xFF

            emit 0xB0, 0x01

            emit 0xB9, 0x40, 0xFA

            emit 0xF3, 0xAA

    (3) low-code:

            cli
            halt

start gui_main()
```

---

## Runtime Mode Switching

```lua id="jlwm17"
x16

type(console)

local msg = "Switching to VGA..."

create demo()

    (1) console_print(msg)

    (2) type todo(VGA)

    (3) .. graphics mode ..

    (4) type todo(console)

    (5) console_print("Back to console")

start demo()
```

---

# 20. Compiler Commands

```bash id="jlwm18"
python compiler.py file.sl

python compiler.py file.sl --dump-asm

python compiler.py file.sl --dump-ast

nasm -f bin file.asm -o file.bin

qemu-system-x86_64 -drive format=raw,file=file.bin -no-reboot
```
