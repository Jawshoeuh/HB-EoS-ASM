; -------------------------------------------------------------------------
; Jawshoeuh 1/7/2023 - Tested 6/18/2024
; This version of Eerie Spell stays more true to the original games by
; Zeroing PP like the move Spite. Look at eeriespell2.asm for a version
; that just lowers PP a little.
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
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x2324934

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x232539C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel SOUNDPROOF_ABILITY_ID, 60 ; 0x3C
.definelabel SOUNDPROOF_STR_ID, 3769 ; 0xEB9
.definelabel PP_ZEROED_STR_ID, 3790 ; 0xECE

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
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
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp   r0,#0
        beq   return
        mov   r10,TRUE
  
        ; Attempt to apply secondary effects (fails if the target has
        ; fainted or has Shield Dust).
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
  
        ; Could branch to DoMoveSpite, but I personally like doing the
        ; work by 'hand' in the ASM effect itself (for precise control).
        ldr r12,[r4,#0xB4] ; entity->monster
        add r12,r12,#0x124 ; monster->moves
        mov r3,#0  ; Iterator
    loop:
        add  r0,r12,r3, lsl #0x3
        ldrb r1,[r0]
        tst  r1,#0b1     ; move->f_exists
        beq  iter_loop   ; invalid move, try again
        tst  r1,#0b10000 ; move->f_last_used
        beq  iter_loop   ; not last used, try again
        mov  r2,#0
        strb r2,[r0,#0x6] ; Set PP to 0!
        mov  r0,r9
        mov  r1,r4
        ldr  r2,=PP_ZEROED_STR_ID
        bl   LogMessageByIdWithPopupCheckUserTarget
        b    return
    iter_loop:
        add r3,r3,#1
        cmp r3,#4
        blt loop

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1