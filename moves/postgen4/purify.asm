; -------------------------------------------------------------------------
; Jawshoeuh 03/22/2023 - Confirmed Working 11/11/2024
; Purify will cleanse the target of negative effects. If it removes
; a negative effect, the user will heal 1/2 their HP.
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
.definelabel EndNegativeStatusConditionWrapper, 0x2305C28
.definelabel MonsterHasNegativeStatus, 0x2300634
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel TryIncreaseHp, 0x23152E4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel EndNegativeStatusConditionWrapper, 0x2306654
;.definelabel MonsterHasNegativeStatus, 0x2301060
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel TryIncreaseHp, 0x2315D44

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Check for a negative condition.
        mov r0,r4
        mov r1,FALSE
        bl  MonsterHasNegativeStatus
        cmp r0,TRUE
        beq remove_condition
        
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        ldr r2,=purify_failed_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   return
        
        remove_condition:
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        mov r3,TRUE
        bl  EndNegativeStatusConditionWrapper
        
        ldr   r2,[r9,#0xB4] ; entity->monster
        ldrsh r1,[r2,#0x12] ; monster->max_hp_stat
        ldrsh r2,[r2,#0x16] ; monster->max_hp_booost
        add   r2,r2,r1 ; Max HP
        lsl   r2,r2,#0x1 ; Max HP / 2
        mov r0,r9
        mov r1,r9
        ; heal hp already in r2 above
        mov r3,#0
        str r10,[sp,#0x0]
        bl  TryIncreaseHp
        mov r10,TRUE
        
    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    purify_failed_str:
        .asciiz "[string:0] can't purify [string:1]!"
    .endarea
.close
