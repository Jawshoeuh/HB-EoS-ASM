; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - Confirmed Working 1/6/2023
; Fiery Dance thaws the target, deals damage, and has a 50% chance to raise
; the user's special attack.
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
.definelabel TryThawTarget, 0x02307C78

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryThawTarget, 0x????????

; Universal
.definelabel BoostSpecialAttackChance, 50

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
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        mov r10,#1
        
        ; Check to boost special attack (50% chance)
        mov r0,r9
        mov r1,r4
        mov r2,BoostSpecialAttackChance
        bl  RandomChanceUT
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Raise special attack
        mov r0,r9
        mov r1,r9
        mov r2,#1 ; special attack
        mov r3,#1 ; 1 stage
        bl  AttackStatUp
        
        ; Set 0x108 to 1 if 0 for user if stats get boosted.
        ldr    r3,[r9,#0xB4]
        ldrb   r0,[r3,#0x108]
        cmp    r0,#0x0
        moveq  r0,#0x1
        streqb r0,[r3,#0x108]
        
        b MoveJumpAddress
        .pool
    .endarea
.close