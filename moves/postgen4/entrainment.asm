; -------------------------------------------------------------------------
; Jawshoeuh 12/02/2023 - Confirmed Working 07/08/2023
; Entrainment changes the target's ability to match the user's.
; While Adex-8x's version will function identically most of the time,
; this one checks for Truant, Trace, Forecast, and Flower Gift
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
.definelabel TryEndStatusWithAbility, 0x022FA7DC
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageWithPopupCheckUserTarget, 0x0234B3A4
.definelabel DUNGEON_PTR, 0x02353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryEndStatusWithAbility, 0x????????
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageWithPopupCheckUserTarget, 0x0234BFA4
;.definelabel DUNGEON_PTR, 0x02354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel FLOWERGIFT_ABILITY_ID, 113 ; 0x71
.definelabel FORECAST_ABILITY_ID, 37 ; 0x25
.definelabel TRACE_ABILITY_ID, 40 ; 0x28
.definelabel TRUANT_ABILITY_ID, 42 ; 0x2A

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
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

        ; Check for Truant manually since we don't want to accidentally
        ; share it even if it is suppressed by Gastro Acid!
        ldr   r3,[r4,#0xB4]
        ldrb  r1,[r3,#0x60]
        ldrb  r2,[r3,#0x61]
        cmp   r1,TRUANT_ABILITY_ID
        cmpne r2,TRUANT_ABILITY_ID
        beq   failed_ability_truant
        
        ; Check abilities manually since we don't want to accidentally
        ; share illegal abilities if the ability is suppresed.
        ; Load our abilities.
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0x60]
        ldrb r2,[r0,#0x61]
        
        ; Check for illegal abilities.
        cmp   r1,FLOWERGIFT_ABILITY_ID
        cmpne r1,FORECAST_ABILITY_ID
        cmpne r1,TRACE_ABILITY_ID
        cmpne r2,FLOWERGIFT_ABILITY_ID
        cmpne r2,FORECAST_ABILITY_ID
        cmpne r2,TRACE_ABILITY_ID
        beq   failed_ability ; failed, banned entrainment ability!
        
        ; Give our abilities.
        mov  r10,TRUE
        strb r1,[r3,#0x60]
        strb r2,[r3,#0x61]
        
        ; Set flag for dungeon to check artificial weather abilities.
        mov   r0,#0x1
        ldr   r1,=DUNGEON_PTR
        ldr   r2,[r1,#0x0]
        strb  r0,[r2,#0xE]
        
        ldr r2,=entrainment_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        
        ; Double check if this new ability would end statuses.
        mov r0,r9
        mov r1,r4
        bl  TryEndStatusWithAbility
        b   MoveJumpAddress
        
    failed_ability:
        ldr r2,=failed_entrainment_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress

    failed_ability_truant:
        ldr r2,=failed_entrainment_truant_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress
        .pool
    entrainment_str:
        .asciiz "[string:0] shared its ability[R]with [string:1]"
    failed_entrainment_truant_str:
        .asciiz "[string:1]'s Truant ability[R]can't be changed!"
    failed_entrainment_str:
        .asciiz "[string:0]'s abilities can't be shared!"
    .endarea
.close
