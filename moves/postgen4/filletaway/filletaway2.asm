; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Tested 6/17/2024
; Fillet Away empties the users belly (like belly drum) and boosts
; attack, special attack, and speed by 2 stages. This function is based
; on DoMoveBellyDrum @ 0x0232AC54 (NA)
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel IntToFixedPoint32, 0x2050FF8 ; Undocumented function in pmdsky-debug as of 6/17/2024
.definelabel CeilFixedPoint, 0x02051064
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUser, 0x234B2A4
.definelabel UpdateStatusIconFlags, 0x022E3AB4
.definelabel BoostOffensiveStat, 0x0231399C
.definelabel BoostSpeed, 0x2314810

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel IntToFixedPoint32, 0x???????? ; Undocumented function in pmdsky-debug as of 6/17/2024
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUser, 0x234BEA4
;.definelabel UpdateStatusIconFlags, 0x022E4464
;.definelabel BoostOffensiveStat, 0x023143FC
;.definelabel BoostSpeed, 0x2315270

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel BELLY_TOO_LOW_STR_ID, 3819 ; 0xEEB

; File creation
.create "./code_out.bin", 0x02330134 ; Currently EU Incompatible.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Get Belly Values
        ldr  r2,[r4,#0xB4] ; entity->monster
        add  r2,r2,#0x100
        ldrh r1,[r2,#0x46] ; monster->belly (integer part)
        strh r1,[sp,#0x0]
        ldrh r0,[r2,#0x48] ; monster->belly_thousandths
        strh r0,[sp,#0x2]
        ldr  r0,[sp,#0x0]
        bl   CeilFixedPoint
        cmp  r0,#1
        bgt  success
    
        ; Failure!
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags
        mov r0,r4
        ldr r1,=BELLY_TOO_LOW_STR_ID
        bl  LogMessageByIdWithPopupCheckUser
        b   return
    
  success:
        mov r10,TRUE
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
    
        ; Lower belly to 1. To keep parity with the game, do this anyway
        ; despite knowing the result beforehand.
        mov  r0,#1
        bl   IntToFixedPoint32
        strh r0,[sp,#0x0]
        mov  r0,r0, lsr #0x10 ; Right shift by 16
        strh r0,[sp,#0x2]
        ldrh r2,[sp,#0x0]
        ldrh r1,[sp,#0x2]
        ldr  r3,[r4,#0xB4] ; entity->monster
        add  r3,r3,#0x100
        strh r2,[r3,#0x46] ; monster->monster->belly (integer part)
        strh r1,[r3,#0x48] ; monster->belly_thousandths
    
        ; Belly Drum in the base game does not give a message. For parity,
        ; no message about hunger is shown. Feel free to add one.
        
    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close