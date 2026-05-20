custing(silk)
x16
type(console)

.. =====================================================
   Sentinel OS Bootloader v0.1
   Inits segments, prints banner, loads kernel
   ===================================================== ..

local msg1 = "================================"
local msg2 = "  Sentinel OS v0.1 - Booting..."
local msg3 = "================================"
local msg4 = "Loading kernel from disk..."
local msg5 = "OK! Jumping to kernel..."

create init_cpu()
    (1) low-code:
            cli
            emit 0x31, 0xC0
            emit 0x8E, 0xD8
            emit 0x8E, 0xC0
            emit 0x8E, 0xD0
            emit 0xBC, 0x00, 0x7C
            sti

create enable_a20()
    (1) low-code:
            emit 0xE4, 0x92
            emit 0x0C, 0x02
            emit 0xE6, 0x92

create load_kernel()
    (1) low-code:
            .. Load 32 sectors from LBA 1 into 0x1000:0x0000 ..
            emit 0xB8, 0x00, 0x10
            emit 0x8E, 0xC0
            emit 0xB4, 0x02
            emit 0xB0, 0x20
            emit 0xB5, 0x00
            emit 0xB6, 0x00
            emit 0xB1, 0x02
            emit 0xBB, 0x00, 0x00
            emit 0xB2, 0x80
            emit 0xCD, 0x13

create jump_to_kernel()
    (1) low-code:
            emit 0xEA, 0x00, 0x00, 0x00, 0x10

start init_cpu()
start enable_a20()
console_print(msg1)
console_print(msg2)
console_print(msg3)
console_print(msg4)
start load_kernel()
console_print(msg5)
start jump_to_kernel()
