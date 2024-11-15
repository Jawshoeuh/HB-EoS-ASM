; -------------------------------------------------------------------------
; Jawshoeuh 12/01/2024 - Confirmed Working 11/15/2024
; Chanegs the target's ability to Simple. Adex-8x's implementaion
; will function identically most of the time, but this one check for
; fails on Truant. It should also fail when the ability is already
; Simple, but this is not neccessary.
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
.definelabel TryEndStatusWithAbility, 0x22FA7DC
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryEndStatusWithAbility, 0x22FB1E8
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel DUNGEON_PTR, 0x2354138


; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel TRUANT_ABILITY_ID, 42 ; 0x2A
.definelabel SIMPLE_ABILITY_ID, 97 ; 0x61
.definelabel MULTITYPE_ABILITY_ID, 116 ; 0x74
.definelabel NONE_ABILITY_ID, 0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,FALSE
        
        ; Preemptively substitute strings.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        
        ; Check for Truant and Multitype manually since we don't want to
        ; accidentally change it even if it is suppressed by Gastro Acid!
        ldr   r3,[r4,#0xB4] ; entity->monster
        ldrb  r1,[r3,#0x60] ; monster->abilities[0]
        ldrb  r2,[r3,#0x61] ; monster->abilities[1]
        cmp   r1,TRUANT_ABILITY_ID
        cmpne r2,TRUANT_ABILITY_ID
        cmpne r1,MULTITYPE_ABILITY_ID
        cmpne r2,MULTITYPE_ABILITY_ID
        beq   failed_ability_reciever
        
        mov r10,TRUE
        ; Change Ability To Simple
        ldr  r0,[r4,#0xB4]
        mov  r1,SIMPLE_ABILITY_ID
        mov  r2,NONE_ABILITY_ID
        strb r1,[r0,#0x60] ; First Ability -> Simple
        strb r2,[r0,#0x61] ; Secon Ability -> None
        
        ; Set flag for dungeon to check artificial weather abilities.
        mov   r0,#0x1
        ldr   r1,=DUNGEON_PTR
        ldr   r2,[r1,#0x0]
        strb  r0,[r2,#0xE] ; dungeon->activate_artificial_weather_flag = true
        
        ldr r2,=simplebeam_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress
        
        failed_ability_reciever:
        ldr r2,=failed_simplebeam_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        
        b   MoveJumpAddress
        .pool
    simplebeam_str:
        .asciiz "[string:1]'s ability became Simple!"
    failed_simplebeam_str:
        .asciiz "[string:1]'s ability can't[R]be changed!"
    .endarea
.close
