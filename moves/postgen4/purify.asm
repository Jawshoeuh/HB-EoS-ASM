; ------------------------------------------------------------------------------
; Jawshoeuh 3/22/2023 - WIP
; Purify will cleanse the target of negative effects. If it removes
; a negative effect, the user will heal 1/2 their HP.
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; Uncomment the correct version

; For US
.include "lib/stdlib_us.asm"
.include "lib/dunlib_us.asm"
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        ldr r0,[r4,#0xB4]
        mov r1,#0x1
        strb r1,[r0,#0x153]
        b MoveJumpAddress
        .pool
    .endarea
.close