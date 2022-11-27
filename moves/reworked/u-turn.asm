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
        cmp r0,#0
        beq MoveJumpAddress
        
        ; User X/Y Pos
        ldrb r12,[r4,#+0x4c] ; User Direction
        ldrh r0,[r9,#+0x4] ; User X Pos
        ldrh r1,[r9,#+0x6] ; User Y Pos
        
        ; This is a better way to visualize what happens to
        ; the values than loading the direction array. 
        ; 5   4   3   (y+1)
        ;   \ | /
        ; 6 - E - 2   (y+0)
        ;   / | \
        ; 7   0   1   (y-1)
        ;
        ; x   x   x
        ; +   +   -
        ; 1   0   1
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
        
		; Always branch at the end
		b MoveJumpAddress
		.pool
	.endarea
.close
