; ------------------------------------------------------------------------------
; Jawshoeuh 1/8/2023 - WIP
; Play Rough does damage and has a 10% chance to lower attack of target.
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

; Universal
.definelabel AttackDropChance, 10

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x8
        
        ; Damage!
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
        
        ; Basiclly just a valid/shield dust check.
        mov r0,r9
        mov r1,r4
        mov r2,AttackDropChance
        bl  RandomChanceUT
        cmp r0,#0
        beq unallocate_memory
        
        ; Lower attack if hit target.
        str r10,[sp,#0x4] ; don't display message on failure, r10 = 0 here
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; attack
        str r2,[sp,#0x0] ; check items/abilities
        mov r3,#1 ; 1 stage
        bl  AttackStatDown
        
        mov r10,#1
    unallocate_memory:
        add sp,sp,#0x8
        b MoveJumpAddress
        .pool
    .endarea
.close
