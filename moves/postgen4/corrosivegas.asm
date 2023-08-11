; -------------------------------------------------------------------------
; Jawshoeuh 12/06/2022 - Confirmed Working 07/07/2023
; Corrosive Gas simple makes the targets item sticky. This was the
; best way I could think of for temporarily disabling the held item.
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
.definelabel ApplyStickyTrapEffect, 0x022EE434

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel ApplyStickyTrapEffect, 0x????????

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize

        ; Simply make item(s) sticky.
        mov r0,r9
        mov r1,r4
        bl  ApplyStickyTrapEffect
        
        mov r10,TRUE
        b   MoveJumpAddress
        .pool
    .endarea
.close
