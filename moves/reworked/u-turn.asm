; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022
; U-turn deals damage and then the user swaps with an ally behind them.
; NOT FINISHED YET
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		
        ; Deal damage.
        mov r0,r0
        mov r1,r4
        mov r2,r8
        mov r3,#0x100
        bl DealDamage
        
        ; Check for succesful hit.
        cmp   r0, #0
        mov   r10,r0
        beq MoveJumpAddress
        
        ; Get User Direction,X,Y
        ldr  r0, [r9,#0xb4]
        ldrb r12,[r0,#0x4c] ; User Direction
        ldrh r0, [r9,#0x4]  ; User X Pos
        ldrh r1, [r9,#0x6]  ; User Y Pos
        
        ; This is a better way to visualize what happens to
        ; the values than loading the direction array. Because
        ; we are looking behind, the values are opposite.
        ; 5   4   3   (y-1)
        ;   \ | /
        ; 6 - E - 2   (y)
        ;   / | \
        ; 7   0   1   (y+1)
        ;
        ; x   x   x
        ; -       +
        ; 1       1
        cmp   r12,#1
        subeq r0,r0,#1 ; r12 = 1
        suble r1,r1,#1 ; r12 = 0,1
        ble check_tile
        cmp   r12,#3
        addeq r1,r1,#1 ; r12 = 3
        suble r0,r0,#1 ; r12 = 2,3
        ble check_tile
        cmp   r12,#5
        addeq r0,r0,#1 ; r12 = 5
        addle r1,r1,#1 ; r12 = 4,5
        ble check_tile
        cmp   r12,#6
        add   r0,r0,#1 ; r12 = 6,7
        beq check_tile
        sub   r1,r1,#1 ; r12 = 7
        
    check_tile:
    
        ; Check tile for Monster.
        bl    GetTile
        ldr   r1,[r0,#+0xc]
        cmp   r1,#0
        beq   MoveJumpAddress ; failed, no monster
        
        ; Check if friend or enemy.
        ldr   r12,[r1,#0xb4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r3,r0,r2 ; 1 = enemy, 0 = friend
        ldr   r12,[r9,#0xb4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r12,r0,r2 ; 1 = enemy, 0 = friend
        cmp   r12,r3
        bne   MoveJumpAddress ; failed, not on same team
        
        ; Try to swap places
        ; Monster behind still in r1.
        mov r0,r9
        bl TrySwitchPlace
        
        ; TODO: Make the swapping animation prettier.
        ; Currently, it's very jarring...
        
		; Always branch at the end
		b MoveJumpAddress
		.pool
	.endarea
.close
