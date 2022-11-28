; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022
; Life Dew heals 1/4 of all allies health. The heal fails on allies with
; Water Absorb, Storm Drain, and Dry Skin
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
        
        ; Calculate Health
        ldr   r0,[r4,#0xb4]
        ldrsh r1,[r0,#0x12]
        ldrsh r0,[r0,#0x16]
        add r0,r0,r1
        
        ;Heal
        lsr r2,r0,#2 ; Divide health by 4
        mov r0,r9
        mov r1,r4
        mov r3,#0 ; Don't increasce temp max HP
        bl RaiseHP
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close