; -------------------------------------------------------------------------
; Jawshoeuh 01/08/2023 - Confirmed Working 11/11/2024
; Quiver Dance raises special attack, special defense, and speed by 1.
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
.definelabel BoostOffensiveStat, 0x231399C
.definelabel BoostDefensiveStat, 0x2313B08
.definelabel BoostSpeedOneStage, 0x231493C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel BoostOffensiveStat, 0x23143FC
;.definelabel BoostDefensiveStat, 0x2314568
;.definelabel BoostSpeedOneStage, 0x231539C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 stage
        bl  BoostOffensiveStat
        
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 stage
        bl  BoostDefensiveStat
        
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; 0 turns means to use the default turn count
        mov r3,FALSE
        bl  BoostSpeedOneStage
        
        mov r10,TRUE
        b   MoveJumpAddress
        .pool
    .endarea
.close
