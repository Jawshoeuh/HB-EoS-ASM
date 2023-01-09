; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - WIP
; Diamond Storms deals damage and has a 50% chance to raise the user's
; defense by 2. (Only 1 stage in Gen VI).
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
.definelabel DefenseBoostChance, 50

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset gas this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
        
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
        mov r10,#1
        
        ; Check to Defense boost.
        mov r0,r9 ; DoMoveSteelWing does this... So I guess if the target
        mov r1,r4 ; faints, we don't get a defense boost at all? :(
        mov r2,DefenseBoostChance
        bl  RandomChanceUT
        cmp r0,#0
        beq unallocate_memory
        
        ; Actually boost defense now.
        mov r0,r9
        mov r1,r9
        mov r2,#0 ; defense
        mov r3,#2 ; 2 stages!
        bl  DefenseStatUp
        
    unallocate_memory:
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close
