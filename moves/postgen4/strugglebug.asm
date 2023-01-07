; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - Confirmed Working 1/6/2023
; Struggle Bug deals damage and lowers the opponent's special attack.
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
        sub sp,sp,#0x8
        
        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ;Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq unallocate_memory
        
        ; Lower special attack if hit target.
        str r10,[sp,#0x4] ; don't display message on failure, r10 = 0 here
        mov r10,#1        ; set r10 early to also use its value to store
        str r10,[sp,#0x0] ; check items/abilities
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; special attack
        mov r3,#1 ; 1 stage
        bl  AttackStatDown
        
    unallocate_memory:
        add sp,sp,#0x8
        b MoveJumpAddress
        .pool
    .endarea
.close
