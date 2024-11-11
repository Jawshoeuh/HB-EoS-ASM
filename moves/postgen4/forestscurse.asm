; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 10/30/2024
; Forest's Curse normally adds the grass type. However, that's not exactly
; easy to do. As a compromise, I overwrite the secondary type with
; the Grass type.
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
.definelabel ENUM_TYPE_ID_GRASS, 0x4

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
        ; Forecast is active. Not sure why it allows it if it's
        ; disabled by Gastro Acid though? Perhaps that's an oversight.
        mov r0,r4
        mov r1,FORECAST_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,TRUE
        beq failed_forecast
        
        ; Check for a grass type.
        ldr   r3,[r4,#0xB4] ; entity->monster
        ldrb  r0,[r3,#0x5E] ; monster->types[0]
        ldrb  r1,[r3,#0x5F] ; monster->types[1]
        cmp   r0,ENUM_TYPE_ID_GRASS
        cmpne r1,ENUM_TYPE_ID_GRASS
        beq   failed_grass
        
        ; Replace secondary type.
        mov   r10,TRUE
        mov   r0,ENUM_TYPE_ID_GRASS
        strb  r0,[r3,#0x5F]  ; monster->types[1] = Grass
        strb  r10,[r3,#0xFF] ; monster->type_changed = TRUE
        
        ; Log message.
        ldr r2,=forestscurse_str
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
        
    failed_grass:
        ldr r2,=forestscurse_fail_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   MoveJumpAddress
        .pool
    forestscurse_str:
        .asciiz "[string:1]'s secondary type converted[R]to the Grass type!"
    forestscurse_fail_str:
        .asciiz "[string:1] is aleady Grass type!"
    .endarea
.close
