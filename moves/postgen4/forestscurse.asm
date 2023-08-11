; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 08/02/2023
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
.definelabel FORECAST_ABILITY_ID, 37 ; 0x25
.definelabel GRASS_TYPE_ID, 4

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
        
        ; Check for a grass type.
        ldr   r3,[r4,#0xB4]
        ldrb  r0,[r3,#0x5E] ; Type 1
        ldrb  r1,[r3,#0x5F] ; Type 2
        cmp   r0,GRASS_TYPE_ID
        cmpne r1,GRASS_TYPE_ID
        beq   failed_grass
        
        ; Replace secondary type.
        mov   r10,TRUE
        mov   r0,GRASS_TYPE_ID
        strb  r0,[r3,#0x5F]  ; Type 2 = Grass
        strb  r10,[r3,#0xFF] ; type_changed = TRUE
        
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
        .asciiz "[string:1] secondary type converted[R]to the Grass type!"
    forestscurse_fail_str:
        .asciiz "[string:1] is aleady Grass type!"
    .endarea
.close
