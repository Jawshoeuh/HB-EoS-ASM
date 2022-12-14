; ------------------------------------------------------------------------------
; Jawshoeuh 12/19/2022 - Confirmed Working 12/19/2022
; While a water type move, scald works internally similar to fire type
; moves. It thaws the target and has a 30% chance to burn.
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
.definelabel BurnChance, 30

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryThawTarget, 0x02307C78
;.definelabel BurnChance, 30


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Try to thaw target.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl  TryThawTarget
    
        ; Deal damage.
        sub sp,sp,#0x4
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        add sp,sp,#0x4
        
        ; Check for succesful hit.
        cmp r0,#0 ; 0 means we didn't deal any damage
        mov r10,#0
        beq MoveJumpAddress
        mov r10,#1
        
        ; Check if we shouuld burn with 30%
        mov r0,r9
        mov r1,r4
        mov r2,BurnChance
        bl  RandomChanceUT
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Burn if chance passes.
        mov r3,#0
        str r3,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#0
        bl  Burn

        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close