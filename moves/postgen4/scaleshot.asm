; -------------------------------------------------------------------------
; Jawshoeuh 06/18/2024 - Confirmed Working 11/13/2024
; Scale Shot does damage and lowers the user's defense. Specifically
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
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel DealDamage, 0x2332B20
.definelabel DefenderAbilityIsActive, 0x22F96CC
.definelabel LowerDefensiveStat, 0x2313814
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel DungeonRandOutcomeUserAction, 0x2324A20
.definelabel TWINEEDLE_HIT_TRACKER, 0x237CA6B

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel LowerDefensiveStat, 0x2314274
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel DungeonRandOutcomeUserAction, 0x2325488
;.definelabel TWINEEDLE_HIT_TRACKER, 0x237D66B


; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel SOUNDPROOF_ABILITY_ID, 60 ; 0x3C
.definelabel SOUNDPROOF_STR_ID, 3769 ; 0xEB9

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
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
		
		; Reuse the tracker for Twineedle to keep track if we have hit to
		; apply secondary effects.
        ldr  r0,=TWINEEDLE_HIT_TRACKER
        ldrb r1,[r0,#0x0]
        cmp  r1,#1
        beq  return
		mov  r1,#1
		strb r1,[r0,#0x0]
		
		; Check a user action.
		mov r0,r9
		mov r1,#0 ; Guaranteed, always
		bl  DungeonRandOutcomeUserAction
        
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