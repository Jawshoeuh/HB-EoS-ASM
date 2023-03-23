; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - Confirmed Working 3/22/2023
; Rototiller raises the Attack and Special Attack of grounded Grass type
; Pokemon. They specifically have to be grounded. So, this really only
; applies (without a lot of effort) to Hoppip and Carnavine...
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
.definelabel DefenderAbilityIsActive, 0x022F96CC
.definelabel LevitateIsActive, 0x02301E18

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GravityIsActive, 0x02338F60
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel LevitateIsActive, 0x02302844

; Universal
.definelabel GrassTypeID, 4
.definelabel FlyingTypeID, 10
.definelabel LevitateAbilityID, 0x37

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        mov  r10,#0x0
    
        ; Check Gravity first.
        bl    GravityIsActive
        cmp   r0,#0x1
        beq   target_is_grounded ; Don't bother checking Levitate/Flying
        
        ; Check for Levitate
        mov   r0,r4
        bl    LevitateIsActive
        cmp   r0,#0x1
        beq   MoveJumpAddress ; Failed, not touching ground.
        
        ; Check for Flying Type
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        cmp   r0,FlyingTypeID
        cmpne r1,FlyingTypeID
        beq   MoveJumpAddress ; Failed, not touching ground.
        
    target_is_grounded:
        ; Find target type.
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        cmp   r0,GrassTypeID
        cmpne r1,GrassTypeID
        bne   MoveJumpAddress ; Failed, not a grass type.

        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        bl  AttackStatUp
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#1
        bl  AttackStatUp
        
        mov r10,#1
        b   MoveJumpAddress
        .pool
    .endarea
.close