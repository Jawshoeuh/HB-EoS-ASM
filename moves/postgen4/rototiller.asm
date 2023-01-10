; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - WIP
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GravityIsActive, 0x02338F60
;.definelabel DefenderAbilityIsActive, 0x22FA0D8

; Universal
.definelabel GrassTypeID, 4
.definelabel FlyingTypeID, 10
.definelabel LevitateAbilityID, 0x37

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Check Gravity first.
        bl  GravityIsActive
        mov r3,r0
        
        ; Find target type.
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        cmp   r0,GrassTypeID
        cmpne r1,GrassTypeID
        mov   r10,#0
        bne   MoveJumpAddress ; failed, not a grass type
        
        ; If gravity is active, skip more complex checks.
        cmp r3,#0
        bne raise_defense
        
        ; Check for Flying type.
        cmp   r0,FlyingTypeID
        cmpne r1,FlyingTypeID
        beq   MoveJumpAddress
        
        ; Check for Magnet Rise.
        ldrb r0,[r12,#0xF7]
        cmp  r0,#0x1
        beq  MoveJumpAddress
        
        ; Check for active Levitate.
        mov r0,r9
        mov r1,r4
        mov r2,LevitateAbilityID
        mov r3,#1
        bl  DefenderAbilityIsActive
        cmp r0,#0
        bne MoveJumpAddress
        
    raise_defense:
        ; Raise defense.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; defense
        mob r3,#1 ; 1 stage
        bl DefenseStatUp
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    .endarea
.close