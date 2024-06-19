; -------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Tested 6/17/2024
; Fillet Away deals 1/2 max health damage to the user and boosts
; attack, special attack, and speed by 2 stages.
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
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageWithPopupCheckUser, 0x234B2E4
.definelabel UpdateStatusIconFlags, 0x022E3AB4
.definelabel BoostOffensiveStat, 0x0231399C
.definelabel BoostSpeed, 0x2314810

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageWithPopupCheckUser, 0x234BEE4
;.definelabel UpdateStatusIconFlags, 0x022E4464
;.definelabel BoostOffensiveStat, 0x023143FC
;.definelabel BoostSpeed, 0x2315270

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Calculate Health
        ldr   r0,[r4,#0xB4] ; entity->monster
        ldrsh r1,[r0,#0x12] ; monster->max_hp_stat
        ldrsh r2,[r0,#0x16] ; monster->max_hp_boost
        ldrsh r3,[r0,#0x10] ; monster->hp (current)
        add   r1,r1,r2      ; Max HP (max_hp_stat + max_hp_boost)
    
        ; Check if health cut is too much.
        lsr  r1,r1,#1 ; Max HP / 2
        subs r3,r3,r1 ; Current HP = Current HP - ((1/2) * Max Hp)
        bgt  success
    
        ; FAILED, HEALTH TOO LOW
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags
        mov r0,r4
        ldr r1,=filletaway_fail_str
        bl  LogMessageWithPopupCheckUser
        b   return
    
    success:
        ; Simply set our health lower and update our status icon flags.
        strh r3,[r0,#0x10] ; monster->hp (current)
        mov  r0,r4
        bl   UpdateStatusIconFlags
    
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#2
        bl  BoostOffensiveStat
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#2
        bl  BoostOffensiveStat
        
        ; Raise speed 
        mov r3,#0
        str r3,[sp,#0x0] ; Put fail message flag on stack
        mov r0,r9
        mov r1,r4
        mov r2,#2
        mov r3,#0 ; default turns
        bl  BoostSpeed
    
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags
        mov r0,r4
        ldr r1,=filletaway_pass_str
        bl  LogMessageWithPopupCheckUser
        
    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
            filletaway_pass_str:
                .asciiz "[string:0] cut its health by half!"
            filletaway_fail_str:
                .asciiz "But [string:0] didn't have enough health!"
    .endarea
.close