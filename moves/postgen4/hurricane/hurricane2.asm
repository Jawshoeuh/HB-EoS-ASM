; -------------------------------------------------------------------------
; Jawshoeuh 07/31/2023 - Confirmed Working XX/XX/XXXX
; This version does not have an accurate way to skip an accuracy check
; without the addition of a SkyPatch; however, it doesn't use any ill
; advised practices and still uses the normal accuracy hit check. For an
; easily importable version that doesn't require a SkyPatch to the game,
; see hurricane1.asm
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
.definelabel DealDamage, 0x02332B20
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x02324934
.definelabel TryInflictConfusedStatus, 0x02314F38

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x0232539C
;.definelabel TryInflictConfusedStatus, 0x02315998


; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        beq return
        mov r10,TRUE
        
        ; Attempt to apply secondary effects (fails if the target has
        ; fainted or has Shield Dust).
        mov r0,r9
        mov r1,r4
        mov r2,#30 ; 30% chance
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
        
        ; Confuse target (or try, I guess).
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        mov r3,FALSE
        bl  TryInflictConfusedStatus

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1