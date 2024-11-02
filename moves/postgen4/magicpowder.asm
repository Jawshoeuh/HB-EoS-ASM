; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 11/02/2024
; Magic Powder changes the target's type to psychic. Appropritely fail if
; the user has Forecast active.
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
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel AbilityIsActive, 0x2301D10

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel AbilityIsActive, 0x230273C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel FORECAST_ACTIVE_STR_ID, 3523 ; 0xDC3
.definelabel FORECAST_ABILITY_ID, 37 ; 0x25
.definelabel ENUM_TYPE_ID_PSYCHIC, 11
.definelabel ENUM_TYPE_ID_NONE, 0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        
        ; Preemptively substitute strings.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        
        ; Base game wont change the type of a monster with an active
        ; Forecast ability. To keep parity with the game, check if
        ; Forecast is active.
        mov r0,r4
        mov r1,FORECAST_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,TRUE
        beq failed_forecast
        
        ; Check for a psychic type.
        ldr   r3,[r4,#0xB4] ; entity->monster
        ldrb  r0,[r3,#0x5E] ; Type 1
        ldrb  r1,[r3,#0x5F] ; Type 2
        cmp   r0,ENUM_TYPE_ID_PSYCHIC
        cmpne r1,ENUM_TYPE_ID_PSYCHIC
        beq   failed_psychic
        
        ; Replace secondary type.
        mov   r10,TRUE
        mov   r0,ENUM_TYPE_ID_PSYCHIC
        mov   r1,ENUM_TYPE_ID_NONE
        strb  r0,[r3,#0x5E]   ; Type 1 = Psychic
        strb  r1,[r3,#0x5F]   ; Type 2 = None
        strb  r10,[r3,#0xFF] ; type_changed = TRUE
        
        ; Log message.
        ldr r2,=magicpowder_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress
        
    failed_forecast:
        ldr r2,=FORECAST_ACTIVE_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        b   MoveJumpAddress
        
    failed_psychic:
        ldr r2,=magicpowder_fail_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress
        .pool
    magicpowder_str:
        .asciiz "[string:1] became a Psychic type!"
    magicpowder_fail_str:
        .asciiz "[string:1] is aleady a Psychic type!"
    .endarea
.close
