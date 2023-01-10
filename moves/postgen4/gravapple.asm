; ------------------------------------------------------------------------------
; Jawshoeuh 1/8/2023 - WIP
; Grav Apple deals (more if gravity is in effect) and reduced defense
; by one stage.
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
.definelabel GravityIsActive, 0x02338390

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GravityIsActive, 0x02338F60

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x8
        
        ; Check for gravity.
        bl    GravityIsActive
        cmp   r0,#0
        moveq r3,#0x100 ; 1.0x
        movne r3,#0x180 ; 1.5x
        
        ; Damage!
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        ; damage in r3 from above
        bl  DealDamage
        
        ;Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq unallocate_memory
        mov r10,#1
        
        ; Basiclly just a valid/shield dust check.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; guaranteed
        bl  RandomChanceUT
        cmp r0,#0
        beq unallocate_memory
        
        ; Lower defense.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; defense
        str r2,[sp,#0x4]
        mov r3,#1
        str r3,[sp,#0x0]
        bl DefenseStatDown
        
    unallocate_memory:
        add sp,sp,#0x8
        b MoveJumpAddress
        .pool
    .endarea
.close
