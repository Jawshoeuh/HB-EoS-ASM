; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 11/02/2024
; Magnetic Flux only raises the Defense/Special Defense of Pokemon with the
; ability Plus/Minus.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel AbilityIsActive, 0x2301D10
.definelabel BoostDefensiveStat, 0x2313B08

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel AbilityIsActive, 0x230273C
;.definelabel BoostDefensiveStat, 0x2314568

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel PLUS_ABILITY_ID, 56 ; 0x38
.definelabel MINUS_ABILITY_ID, 63 ; 0x3F

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        
        ; Check for Plus
        mov r0,r4
        mov r1,PLUS_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,TRUE
        beq success
        
        ; Check for Minus
        mov r0,r4
        mov r1,MINUS_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,TRUE
        bne MoveJumpAddress
    
    success:
        mov r10,TRUE
        
        ; Raise defense 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostDefensiveStat
        
        ; Raise special defense 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1
        bl  BoostDefensiveStat
        
        b   MoveJumpAddress
        .pool
    .endarea
.close
