; -------------------------------------------------------------------------
; Jawshoeuh 01/03/2023 - Confirmed Working 11/15/2024
; Shift gear increasces attack by 1 and speed by 2.
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
.definelabel BoostSpeed, 0x2314810

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel BoostOffensiveStat, 0x23143FC
;.definelabel BoostSpeed, 0x2315270

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,TRUE
        
        mov r0,r9
        mov r1,r4
        mov r2,#2
        mov r3,#0
        str r10,[sp,#0x0]
        bl  BoostSpeed
        
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close
