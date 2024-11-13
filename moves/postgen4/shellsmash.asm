; -------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 11/13/2024
; Shell Smashes raises the User's Attack, Special Attack and Speed by 2 but
; also lowers the User's Defense and Special Defense by 1.
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
.definelabel BoostSpeedOneStage, 0x231493C
.definelabel LowerDefensiveStat, 0x2313814

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel BoostOffensiveStat, 0x23143FC
;.definelabel BoostSpeedOneStage, 0x231539C
;.definelabel LowerDefensiveStat, 0x2314274

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
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
        
        ; Raise speed.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; Use default number of turns.
        mov r3,TRUE
        bl  BoostSpeedOneStage
        
        ; Lower defense one stage.
        mov r3,FALSE
        str r3,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 Stage
        bl  LowerDefensiveStat
        
        ; Lower special defense one stage.
        mov r3,FALSE
        str r3,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 Stage
        bl  LowerDefensiveStat
        
    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close
