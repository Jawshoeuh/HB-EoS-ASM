; ------------------------------------------------------------------------------
; Jawshoeuh 11/29/2022 - Confirmed Working 11/30/2022
; Overcast Night causes the weather to be cloudy.
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
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel WeatherChanged, 0x023354C4

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Attempt to set weather to snow.
        ldr   r3,=0xBB8 ; Set to this by DoMoveRainDance
        ldr   r2,=DungeonBaseStructurePtr
        ldrsh r3,[r3,#0x0]
        ldr   r2,[r2,#0x0] ; DungeonBaseStrPtr
        add   r2,r2,#0xCD00
        mov   r0,#0x1
        mov   r1,#0x0
        strh  r3,[r2,#0x40]
        bl    WeatherChanged
        
        ; Return if weather changed succesfully.
        cmp r0,#0
        mov r10,#1 ; 0x023260D0 (DoMoveRainDance) returns 1
        bne MoveJumpAddress
        
        ; Log that the weather stayed the same.
        ldr r2,=0xEC5 ; Weather did not change string
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget

        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
