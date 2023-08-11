; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working XX/XX/XXXX
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
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel LogMessageWithPopupCheckUserTarget, 0x0234B3A4
.definelabel AbilityIsActive, 0x022F96CC

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel LogMessageWithPopupCheckUserTarget, 0x0234BFA4
;.definelabel AbilityIsActive, 0x022FA0D8

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel FORECAST_ACTIVE_STR_ID, 3523 ; 0xDC3
.definelabel FORECAST_ABILITY_ID, 37, ; 0x25
.definelabel PSYCHIC_TYPE_ID, 11
.definelabel NONE_TYPE_ID, 0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
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
        mov r0,r9
        mov r1,FORECAST_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,TRUE
        beq failed_forecast
        
        ; Check for a psychic type.
        ldr   r3,[r4,#0xB4]
        ldrb  r0,[r3,#0x5E] ; Type 1
        ldrb  r1,[r3,#0x5F] ; Type 2
        cmp   r0,PSYCHIC_TYPE_ID
        cmpne r1,NONE_TYPE_ID
        beq   failed_psychic
        
        ; Replace secondary type.
        mov   r10,TRUE
        mov   r0,PSYCHIC_TYPE_ID
        mov   r1,NONE_TYPE_ID
        strb  r0,[r3,#0x5E]   ; Type 1 = Grass
        strb  r0,[r3,#0x5F]   ; Type 2 = None
        strb  r10,[r12,#0xFF] ; type_changed = TRUE
        
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
