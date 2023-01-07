; ------------------------------------------------------------------------------
; Jawshoeuh 12/19/2022 - Confirmed Working 12/19/2022
; An example of a damaging fire type move. They should first try to
; thaw the target!
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
.definelabel TryThawTarget, 0x02307C78

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryThawTarget, 0x????????

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
    
        ; Try to thaw target.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl TryThawTarget

        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; Normal 1.0x Damage
        bl  DealDamage
        
        ; Return r10
        cmp r0,#0
        moveq r10,#0 ; Failure
        movne r10,#1 ; Success
        
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close