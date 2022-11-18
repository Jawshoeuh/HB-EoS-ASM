; 
; ------------------------------------------------------------------------------
; A template to code your own move effects
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
.definelabel GetTilePointer, 0x23360FC
.definelabel ExecuteMoveEffect, 0x232E864

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetTilePointer, 0x????????
;.definelabel ExecuteMonsterAction, 0x????????
;.definelabel SetMonsterActionFields, 0x????????
;.definelabel ClearMonsterActionFields, 0x????????
;.definelabel SetActionRegularAttack, 0x????????
;.definelabel SetActionUseMoveAI, 0x????????

; File creation
.create "./code_out.bin", 0x02330134 ; For EU: 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

        
        ; Grab target position.
        ldrb r12,[r4,#+0x4c] ; Target Direction
        ldrh r0,[r4,#+0x4] ; Target X Pos
        ldrh r1,[r4,#+0x6] ; Target Y Pos
        
        ;Get tile offset to check.
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
       
       
check_tile:
        ; Check tile for Monster.
        bl    GetTilePointer
        ldr   r1,[r0,#+0xc]
        cmp   r1,#0 
        moveq r10,#0 ;failed, no monster
        beq   end
        
        ; Check if friend or enemy.
        ldr   r12,[r0,#+0xb4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r3,r0,r2 ; 1 = enemy, 0 = friend
        ldrb  r0,[r4,#0x6] ;
        ldrb  r2,[r4,#0x8] ;
        eor   r2,r0,r2 ; 1 = enemy, 0 = friend
        cmp   r3,r2
        moveq r10,#0 ; failed, friendly fire
        beq   end
        
        ;Attempt something?
        add r2,r4,#0x124
        mov r1,r4
        bl ExecuteMoveEffect
        
        ;Debug message
        mov r0,r9
		ldr r1,=debug_ins
		bl SendMessageWithStringLog
end:         
        ; Always branch at the end
        b MoveJumpAddress
        
		.pool
	debug_ins:
		.asciiz "Debug instruct end!" 
	.endarea
.close