; -------------------------------------------------------------------------
; Jawshoeuh 01/03/2023 - Confirmed Working 08/02/2023
; Hone Claws simply raises attack and accuracy.
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
.definelabel BoostOffensiveStat, 0x0231399C
.definelabel BoostHitChanceStat, 0x023140E4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel BoostOffensiveStat, 0x023143FC
;.definelabel BoostHitChanceStat, 0x02314B44

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel ACCURACY_STAT, 0x0
.definelabel EVASION_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x0
        
        ; Raise attack 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
        ; Raise accuracy 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,ACCURACY_STAT
        mov r3,#1
        bl  BoostHitChanceStat

    return:
        add sp,sp,#0x0
        b   MoveJumpAddress
        .pool
    .endarea
.close
