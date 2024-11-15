; -------------------------------------------------------------------------
; Jawshoeuh 11/29/2022 - Untested
; Snowscape causes the weather to be snow.
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
.definelabel TryActivateWeather, 0x023354C4
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel WEATHER_MOVE_TURN_COUNT, 0x22C4654 ; (3000 by default)
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryActivateWeather, 0x02335F04
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel WEATHER_MOVE_TURN_COUNT, 0x22C4FAC ; (3000 by default)
;.definelabel DUNGEON_PTR, 0x2354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel WEATHER_UNCHANGED_STR, 3781 ; 0xEC5

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,TRUE
        
        ldr   r3,=WEATHER_MOVE_TURN_COUNT
        ldrsh r3,[r3,#0x0]
        ldr   r2,=DUNGEON_PTR
        ldr   r2,[r2,#0x0]
        add   r2,r2,#0xCD00
        strh  r3,[r2,#0x48]
        mov   r0,TRUE
        mov   r1,FALSE
        bl    TryActivateWeather
        
        cmp   r0,FALSE
        bne   MoveJumpAddress
        
        ldr r2,=WEATHER_UNCHANGED_STR
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        
        b   MoveJumpAddress
        .pool
    .endarea
.close
