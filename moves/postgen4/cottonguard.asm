; -------------------------------------------------------------------------
; Jawshoeuh 01/05/2023 - Tested 6/18/2024
; Cotton Guard raises the user's defense 3 (count 'em 3) stages!
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
.definelabel BoostDefensiveStat, 0x2313B08

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel BoostDefensiveStat, 0x2314568

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        
        ; Boost defense (but a lot).
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#3
        bl  BoostDefensiveStat
        
        mov r10,TRUE
        b   MoveJumpAddress
        .pool
    .endarea
.close
