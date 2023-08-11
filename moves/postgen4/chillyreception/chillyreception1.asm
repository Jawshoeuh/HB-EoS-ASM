; -------------------------------------------------------------------------
; Jawshoeuh 11/27/2022 - Confirmed Working 07/07/2023
; Chilly Reception causes the user to summon a snowstorm, and swap with
; an ally behind them. For a version that causes hail, look at
; chillyreception2.asm
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
.definelabel TrySwitchPlace, 0x022EB178
.definelabel TryActivateWeather, 0x023354C4
.definelabel GetTile, 0x023360FC
.definelabel DEFAULT_WEATHER_TURNS_MOVE, 0x022C4654 ; 0xBB8 (3000)
.definelabel DIRECTIONS_XY, 0x0235171C
.definelabel DUNGEON_PTR, 0x02353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TrySwitchPlace, 0x022EBB28
;.definelabel TryActivateWeather, 0x02335F04
;.definelabel GetTile, 0x2336CCC
;.definelabel DEFAULT_WEATHER_TURNS_MOVE, 0x022C4FAC ; 0xBB8 (3000)
;.definelabel DIRECTIONS_XY, 0x2352328
;.definelabel DUNGEON_PTR, 0x02354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel NULL, 0x0
.definelabel WEATHER_UNCHANGED_STR_ID, 3781 ; 0xEC5

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,TRUE
        
        ; Attempt to set weather to snow.
        ldr   r3,=DEFAULT_WEATHER_TURNS_MOVE
        ldrsh r3,[r3,#0x0]
        ldr   r2,=DUNGEON_PTR
        ldr   r2,[r2,#0x0]
        add   r2,r2,#0xCD00
        mov   r0,TRUE  ; Yes, log a message and play animation.
        mov   r1,FALSE ; Don't force the animation
        strh  r3,[r2,#0x0048]
        bl    TryActivateWeather
        
        ; Get User Direction and Flip
        ldr  r0, [r4,#0xB4]
        ldrb r12,[r0,#0x4C] ; User Direction
        add  r12,r12,#0x4
        and  r12,r12,#0x7   ; Flip Direction
        
        ldr   r1,=DIRECTIONS_XY   ; See Note 1
        mov   r2,r12, lsl #0x2    ; Array Offset For Dir Value
        add   r3,r1,r12, lsl #0x2 ; Array Offset For Dir Value
        ldrsh r0,[r1,r2]          ; X Offset
        ldrsh r1,[r3,#0x2]        ; Y Offset
        ldrh  r2,[r4,#0x4]        ; Target X Pos
        ldrh  r3,[r4,#0x6]        ; Target Y Pos
        
        ; Get position behind user.
        add r0,r0,r2
        add r1,r1,r3
        
        ; Check tile at that position for monster.
        bl    GetTile
        ldr   r1,[r0,#0xC]
        cmp   r1,NULL
        beq   MoveJumpAddress ; failed, no monster
        
        ; Check if friend or enemy.
        ldr   r12,[r1,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r3,r0,r2  ; 1 = enemy, 0 = friend
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r12,r0,r2 ; 1 = enemy, 0 = friend
        cmp   r12,r3
        bne   MoveJumpAddress ; failed, not on same team
        
        ; Try to swap places
        mov r0,r4
        ; Monster behind still in r1.
        bl  TrySwitchPlace

        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: Visualization of values loaded from direction array.
; 5   4   3   (y-1)
;   \ | /
; 6 - E - 2   (y)
;   / | \
; 7   0   1   (y+1)
;
; x   x   x
; -       +
; 1       1