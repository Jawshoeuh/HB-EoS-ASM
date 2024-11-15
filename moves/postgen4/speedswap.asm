; -------------------------------------------------------------------------
; Jawshoeuh 03/22/2023 - Confirmed Working 11/15/2024
; Speed Swap ... swaps the speed of the target and user.
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
.definelabel CalcSpeedStageWrapper, 0x22FFF4C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel CalcSpeedStageWrapper, 0x2300978

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6
        mov r10,TRUE
        
        ldr  r5,[r9,#0xB4] ; entity->monster
        ldr  r6,[r4,#0xB4] ; entity->monster
        
        mov r12,#0
        loop_copy_speeds_stages:
            add  r0,r5,r12
            add  r1,r6,r12
            ldrb r2,[r0,#0x114]
            ldrb r3,[r1,#0x114]
            strb r3,[r0,#0x114]
            strb r2,[r1,#0x114]
            ldrb r2,[r0,#0x119]
            ldrb r3,[r1,#0x119]
            strb r3,[r0,#0x119]
            strb r2,[r1,#0x119]
            add  r12,r12,#1
            cmp  r12,#5
            blt  loop_copy_speeds_stages
        
        mov r0,r9
        bl  CalcSpeedStageWrapper
        mov r0,r4
        bl  CalcSpeedStageWrapper
        
        pop r5,r6
        b   MoveJumpAddress
        .pool
    .endarea
.close
