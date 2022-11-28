; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022
; Inferno deals damage and guarantees burn (if it hits).
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
        
        ; Deal damage.
        mov r0,r0
        mov r1,r4
        mov r2,r8
        mov r3,#0x100
        bl DealDamage
        
        ;Check for succesful hit.
        cmp r0,#0
        beq MoveJumpAddress
        
        ;If so, lower burn.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        str r2,[r13]
        bl Burn
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close