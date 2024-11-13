; -------------------------------------------------------------------------
; Jawshoeuh 01/06/2023 - Confirmed Working 11/12/2024
; Relic Song deals damage and has 10% chance to sleep the target. It's also
; a sound based move.
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
.definelabel DefenderAbilityIsActive, 0x22F96CC
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x02324934
.definelabel DealDamage, 0x2332B20
.definelabel CalcStatusDuration, 0x22EAB80
.definelabel TryInflictSleepStatus, 0x23118D8
.definelabel SLEEP_TURN_RANGE, 0x22C4720

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x0232539C
;.definelabel DealDamage, 0x2333560
;.definelabel CalcStatusDuration, 0x22EB530
;.definelabel TryInflictSleepStatus, 0x2312338
;.definelabel SLEEP_TURN_RANGE, 0x22C5078

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel SOUNDPROOF_ABILITY_ID, 60 ; 0x3C
.definelabel SOUNDPROOF_STR_ID, 3769 ; 0xEB9

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; There is a list of sound moves in the base game. A skypatch could
        ; be added to add a move ID to the list of sound moves in game, but
        ; this is easier for people to implement and doesn't require a
        ; custom skypatch.
        mov r0,r9
        mov r1,r4
        mov r2,SOUNDPROOF_ABILITY_ID
        mov r3,TRUE
        bl  DefenderAbilityIsActive
        cmp r0,FALSE
        beq not_blocked
        
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Sub Target
        ldr r2,=SOUNDPROOF_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        b   return
        
        not_blocked:
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
        
        mov r0,r9
        mov r1,r4
        mov r2,#10
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
        
        mov r0,r4
        ldr r1,=SLEEP_TURN_RANGE
        mov r2,TRUE
        bl  CalcStatusDuration
        
        mov r2,r0
        mov r0,r9
        mov r1,r4
        mov r3,FALSE
        bl  TryInflictSleepStatus
        
    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1