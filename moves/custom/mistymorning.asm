; ------------------------------------------------------------------------------
; Jawshoeuh 11/29/2022 - Confirmed Working 11/30/2022
; Misty Morning causes the weather to be fog. Changed to match Adex-8x's
; better naming convention and loading the turn count from the source.
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; Uncomment the correct version

; For US
.include "lib/stdlib_us.asm"
.include "lib/dunlib_us.asm"
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel WeatherTurnValue, 0x022C4654 ; 0xBB8 (3000) by default.
.definelabel TryActivateWeather, 0x023354C4

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel WeatherTurnValue, 0x022C4FAC ; 0xBB8 (3000) by default.
;.definelabel TryActivateWeather, 0x02335F04

; Universal
.definelabel WeatherUnchangedStr, 0xEC5 ; 3781

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Attempt to set weather to fog.
        ldr   r3,=WeatherTurnValue
        ldrsh r3,[r3]
        ldr   r2,=DungeonBaseStructurePtr
        ldr   r2,[r2] ; DungeonBaseStrPtr
        add   r2,r2,#0xCD00
        mov   r0,#0x1
        mov   r1,#0x0
        strh  r3,[r2,#0x46]
        bl    WeatherChanged
        
        ; Return if weather changed succesfully.
        cmp r0,#0
        mov r10,#1 ; 0x023260D0 (DoMoveRainDance) returns 1
        bne MoveJumpAddress
        
        ; Log that the weather stayed the same.
        ldr r2,=WeatherUnchangedStr
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog

        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
