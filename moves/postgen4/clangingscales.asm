; -------------------------------------------------------------------------
; Jawshoeuh 01/07/2023 - Confirmed Working 07/08/2023
; Clanging Scales does damage and lowers the user's defense. Specifically
; designed to be used as a multi-hit move and drop defense only on the
; first hit. Also a sound based move.
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
.definelabel DefenderAbilityIsActive, 0x022F96CC
.definelabel LowerDefensiveStat, 0x02313814
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel DungeonRandOutcomeUserAction, 0x02324A20
.definelabel MULTIHIT_HIT_COUNTER, 0x0237CA78

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel DefenderAbilityIsActive, 0x022FA0D8
;.definelabel LowerDefensiveStat, 0x02314274
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel DungeonRandOutcomeUserAction, 0x02325488
;.definelabel MULTIHIT_HIT_COUNTER, 0x????????


; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel SOUNDPROOF_ABILITY_ID, 60 ; 0x3C
.definelabel SOUNDPROOF_STR_ID, 3769 ; 0xEB9

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
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
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        moveq r10,TRUE
        
        ; Check if the first hit.
        ldr r0,=MULTIHIT_HIT_COUNTER
        ldr r1,[r0,#0x0]
        cmp r1,#1
        bne return
        
        ; Lower defense stat one stage.
        mov r2,TRUE
        mov r3,FALSE
        str r2,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r9
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 Stage
        bl  LowerDefensiveStat

    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1