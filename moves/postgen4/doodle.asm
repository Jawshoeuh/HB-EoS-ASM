; ------------------------------------------------------------------------------
; Jawshoeuh 11/29/2022 - Confirmed Working 11/30/2022
; Doodle changes the abilities of all allies to the ability of the target.
; Unfortunately, we need to check for an enemy for every target which is
; a bit wasteful, but I don't see a way around it...
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
.definelabel DIRECTIONS_XY, 0x0235171C
.definelabel GetTile, 0x023360FC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DIRECTIONS_XY, 0x02352328
;.definelabel GetTile, 0x2336CCC


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Attempt to find a target in front of user.
        ; Get User Direction,X,Y
        ldr  r0, [r9,#0xb4]
        ldrb r12,[r0,#0x4c] ; User Direction
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
        
        ; Check tile for monster.
        bl    GetTile
        ldr   r12,[r0,#0xc]
        cmp   r12,#0
        movne r10,#1
        moveq r10,#0
        beq   MoveJumpAddress ; failed, no monster
        
        ; Load that monsters abiilities
        ldr  r0,[r12,#0xb4]
        ldrb r1,[r0,#0x60]
        ldrb r0,[r0,#0x61]
        
        ; Store that monsters abilities
        ldr  r2,[r4,#0xb4]
        strb r1,[r2,#0x60]
        strb r0,[r2,#0x61]
        
        ; When giving self ability, display feedback message.
        ; The order is specific! Because r12 is a scratch register!
        cmp r9,r4
        bne MoveJumpAddress
        mov r0,#1
        mov r1,r12
        mov r2,#0
        bl  ChangeString ; Target
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  ChangeString ; User
        mov r0,r9
        ldr r1,=doodle_str
        bl  SendMessageWithStringLog
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    doodle_str:
        .asciiz "[string:0] gave all nearby allies[R]the abilities of [string:1]!" 
    .endarea
.close
