; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working XX/XX/XXXX
; Gear Up only raises the Attack/Special Attack of Pokemon with the
; ability Plus/Minus.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel AbilityIsActive, 0x022F96CC
.definelabel BoostOffensiveStat, 0x0231399C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel AbilityIsActive, 0x022FA0D8
;.definelabel BoostOffensiveStat, 0x023143FC

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel PLUS_ABILITY_ID, ; 0x38
.definelabel MINUS_ABILITY_ID, ; 0x3F

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x0
        
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
        
        ; Raise attack 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
        ; Raise special attack 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
        b   MoveJumpAddress
        .pool
    .endarea
.close
