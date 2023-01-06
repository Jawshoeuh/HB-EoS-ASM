; ------------------------------------------------------------------------------
; Jawshoeuh 11/27/2022 - Confirmed Working 12/1/2022
; Chilly Reception causes the user to summon a snowstorm, and swap with
; an ally behind them. There is a working, less optimized version
; that causes hail in the legacy folder. If you wanted to cause hail,
; with this version, change line 54 from #0x48 to 0x44.
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
.definelabel TrySwitchPlace, 0x022EB178
.definelabel WeatherChanged, 0x023354C4
.definelabel DIRECTIONS_XY, 0x0235171C
.definelabel GetTile, 0x023360FC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TrySwitchPlace, 0x022EBB28
;.definelabel WeatherChanged, 0x????????
;.definelabel DIRECTIONS_XY, 0x2352328
;.definelabel GetTile, 0x2336CCC

; Universal
.definelabel WeatherUnchangedStr, 0xEC5 ; 3781

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Attempt to set weather to snow.
        ldr   r3,=0xBB8 ; Probably turn count.
        ldr   r2,=DungeonBaseStructurePtr
        ldr   r2,[r2] ; DungeonBaseStrPtr
        add   r2,r2,#0xCD00
        mov   r0,#0x1
        mov   r1,#0x0
        strh  r3,[r2,#0x48]
        bl    WeatherChanged
        
        ; Return if weather changed succesfully.
        cmp   r0,#0
        mov   r10,#1 ; 0x023260D0 (DoMoveRainDance) returns 1
        beq   failed_change
        
        ; Get User Direction and Flip
        ldr  r0, [r9,#0xB4]
        ldrb r12,[r0,#0x4C] ; User Direction
        add  r12,r12,#0x4
        and  r12,r12,#0x7   ; Flip Direction
        
        ; Visualization of values loaded from direction array.
        ; 5   4   3   (y-1)
        ;   \ | /
        ; 6 - E - 2   (y)
        ;   / | \
        ; 7   0   1   (y+1)
        ;
        ; x   x   x
        ; -       +
        ; 1       1
        ldr   r10,=DIRECTIONS_XY
        mov   r2,r12, lsl #0x2     ; Array Offset For Dir Value
        add   r3,r10,r12, lsl #0x2 ; Array Offset For Dir Value
        ldrsh r0,[r10,r2]          ; X Offset
        ldrsh r1,[r3,#0x2]         ; Y Offset
        ldrh  r2,[r9,#0x4]         ; User X Pos
        ldrh  r3,[r9,#0x6]         ; User Y Pos
        
        ; Add values together
        add r0,r0,r2
        add r1,r1,r3
        
        ; Check tile for Monster.
        bl    GetTile
        ldr   r1,[r0,#0xc]
        cmp   r1,#0
        beq   MoveJumpAddress ; failed, no monster
        
        ; Check if friend or enemy.
        ldr   r12,[r1,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r3,r0,r2 ; 1 = enemy, 0 = friend
        ldr   r12,[r9,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r12,r0,r2 ; 1 = enemy, 0 = friend
        cmp   r12,r3
        bne   MoveJumpAddress ; failed, not on same team
        
        ; Try to swap places
        mov r0,r9
        ; Monster behind still in r1.
        bl TrySwitchPlace
        
        ; TODO: Make the swapping animation prettier.
        ; Currently, it's very jarring...
        
        b MoveJumpAddress
        
    failed_change:
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
