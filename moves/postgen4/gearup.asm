; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - Confirmed Working 3/23/2023
; Magnetic Flux only raises the Attack/Special Attack of Pokemon with the
; ability Plus/Minus.
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
.definelabel PlusAbilityID, 0x38
.definelabel MinusAbilityID, 0x3F

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Check for Plus
        mov r0,r4
        mov r1,PlusAbilityID
        bl  HasAbility
        cmp r0,#0
        bne success
        
        ; Check for Minus
        mov r0,r4
        mov r1,MinusAbilityID
        bl  HasAbility
        cmp r0,#0
        bne success
        
        mov r10,#0
        b   MoveJumpAddress
        
    success:
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; attack
        mov r3,#1 ; 1 stage
        bl  AttackStatUp
        
        ; Raise special defense.
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; special attack
        mov r3,#1 ; 1 stage
        bl  AttackStatUp
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    .endarea
.close