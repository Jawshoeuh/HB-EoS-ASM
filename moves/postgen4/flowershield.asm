; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working XX/XX/XXXX
; Flower Shield raises the defense of grass type Pokemon! I'm not sure if
; anyone will find usage for this move? Here for the sake of completion
; anyway.
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
.definelabel BoostDefensiveStat, 0x02313B08

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel BoostDefensiveStat, 0x02314568

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,FALSE
        
        ; Find target type.
        ldr   r3,[r4,#0xB4]
        ldrb  r0,[r3,#0x5E]
        ldrb  r1,[r3,#0x5F]
        cmp   r0,GrassTypeID
        cmpne r1,GrassTypeID
        bne   MoveJumpAddress ; failed, not a grass type
        
        ; Raise defense 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostDefensiveStat
        
        mov r10,TRUE
        b   MoveJumpAddress
        .pool
    .endarea
.close
