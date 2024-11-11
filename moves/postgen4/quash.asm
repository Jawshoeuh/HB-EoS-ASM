; -------------------------------------------------------------------------
; Jawshoeuh 01/03/2023 - Confirmed Working 11/11/2024
; Quash makes the target cringe (flinch). It's the only non-damaging flinch
; move in Pokemon Mystery Dungeon!
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
.definelabel TryInflictCringeStatus, 0x23143E8

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryInflictCringeStatus, 0x2314E48

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        
        ; Just cringe/flinch the target...
        mov   r0,r9
        mov   r1,r4
        mov   r2,TRUE
        mov   r3,FALSE
        bl    TryInflictCringeStatus
        mov   r10,r0
        
        b   MoveJumpAddress
        .pool
    .endarea
.close
