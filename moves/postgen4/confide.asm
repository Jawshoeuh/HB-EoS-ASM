; -------------------------------------------------------------------------
; Jawshoeuh 01/07/2023 - Confirmed Working 07/07/2023
; Confide lowers special attack, but it's a sound move!
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
.definelabel DefenderAbilityIsActive, 0x022F96CC
.definelabel LowerOffensiveStat, 0x023135FC
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DefenderAbilityIsActive, 0x022FA0D8
;.definelabel LowerOffensiveStat, 0x0231405C
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50

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
        ; Simply lower special attack 1 stage.
        mov r3,TRUE
        str r3,[sp,#0x4]
        str r3,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1
        bl  LowerOffensiveStat
        
        mov r10,TRUE
    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close
