; -------------------------------------------------------------------------
; Jawshoeuh 01/07/2023 - Confirmed Working 07/02/2023
; Clangorous Soul boosts all stats (except evasion/accuracy) and costs
; 1/3 of the players health. Is a sound move, so check for Soundproof.
; Also a minor abuse of fixed point multiplication to divide by 3. While
; a bit odd, doubtful it will cause problems.
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
.definelabel UpdateStatusIconFlags, 0x022E3AB4
.definelabel DefenderAbilityIsActive, 0x022F96CC
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel BoostDefensiveStat, 0x02313B08
.definelabel BoostOffensiveStat, 0x0231399C
.definelabel BoostSpeedOneStage, 0x0231493C
.definelabel LogMessageWithPopupCheckUserTarget, 0x0234B3A4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel UpdateStatusIconFlags, 0x22E4464
;.definelabel DefenderAbilityIsActive, 0x022FA0D8
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel BoostDefensiveStat, 0x02314568
;.definelabel BoostOffensiveStat, 0x023143FC
;.definelabel BoostSpeedOneStage, 0x0231539C
;.definelabel LogMessageWithPopupCheckUser, 0x0234BFA4

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
        bne fail_soundproof
        
        ; Calculate Health
        ldr   r12,[r4,#0xB4]
        ldrsh r1,[r12,#0x12]
        ldrsh r2,[r12,#0x16]
        ldrsh r3,[r12,#0x10]  ; Current HP
        add   r1,r1,r2        ; Max HP
        
        ldr   r2,=div3_magic_number
        ldr   r2,[r2]
        umull r10,r0,r1,r2
        subs  r3,r3,r0
        ble   fail_hp_too_low
        
        mov r10,TRUE
        ; Simply set our health lower and update.
        strh r3,[r12,#0x10]
        mov  r0,r4
        bl   UpdateStatusIconFlags
        
        ; Raise attack
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 Stage
        bl  BoostOffensiveStat
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 Stage
        bl  BoostOffensiveStat
        
        ; Raise defense.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 Stage
        bl  BoostDefensiveStat
        
        ; Raise special defense.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 Stage
        bl  BoostDefensiveStat
        
        ; Raise speed
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; default number of turns
        mov r3,FALSE
        bl  BoostSpeedOneStage
        
        ; Health cut message.
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Sub Target
        mov r0,r4
        mov r1,r9
        ldr r2,=clangoroussoul_pass_str
        bl  LogMessageWithPopupCheckUserTarget
        b MoveJumpAddress   
        
    fail_soundproof:
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Sub Target
        ldr r2,=SOUNDPROOF_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        b   MoveJumpAddress
        
    fail_hp_too_low:
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Sub Target
        mov r0,r4
        mov r1,r9
        ldr r2,=clangoroussoul_fail_str
        bl  LogMessageWithPopupCheckUserTarget
        
        b MoveJumpAddress
        .pool
    div3_magic_number:
        .word 1431655766 ; Fixed point multiplication number
    clangoroussoul_pass_str:
        .asciiz "[string:1] cut its health by a third!" 
    clangoroussoul_fail_str:
        .asciiz "But [string:1] didn't have enough health!" 
    .endarea
.close
