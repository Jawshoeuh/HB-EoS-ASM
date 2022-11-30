; ------------------------------------------------------------------------------
; Jawshoeuh 11/27/2022 - Confirmed Working 11/28/2022
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
.definelabel GetTile, 0x023360FC
.definelabel DoMoveRolePlay, 0x0232A188

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DoMoveRolePlay, 0x0232ABF4


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; I'm not sure why this has to be done as my ghidra wont
        ; show me what is in DoMoveRolePlay, but I suspect it's
        ; because it's not expected for role play to be called
        ; this way...
        mov r0,#0
		mov r1,r4
		mov r2,#0
		bl ChangeString ; Make target replace string 0 in roleplay msg.
    
        ; Attempt to find a target in front of user.
        ; Get User Direction,X,Y
        ldr  r0, [r9,#0xb4]
        ldrb r12,[r0,#0x4c] ; User Direction
        ldrh r0, [r9,#0x4]  ; User X Pos
        ldrh r1, [r9,#0x6]  ; User Y Pos
        
        ; This is a better way to visualize what happens to
        ; the values than loading the direction array.
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
        addeq r0,r0,#1 ; r12 = 1
        addle r1,r1,#1 ; r12 = 0,1
        ble   check_tile
        cmp   r12,#3
        subeq r1,r1,#1 ; r12 = 3
        addle r0,r0,#1 ; r12 = 2,3
        ble   check_tile
        cmp   r12,#5
        subeq r0,r0,#1 ; r12 = 5
        suble r1,r1,#1 ; r12 = 4,5
        ble   check_tile
        cmp   r12,#6
        sub   r0,r0,#1 ; r12 = 6,7
        beq   check_tile
        add   r1,r1,#1 ; r12 = 7
        
    check_tile:
        ; Check tile for monster.
        bl    GetTile
        ldr   r1,[r0,#0xc]
        cmp   r1,#0
        moveq r10,#0
        beq   MoveJumpAddress ; failed, no monster
        
        ; Replace target ability
        mov r0,r4
        ; Found monster is still in r1.
        mov r2,r8
        mov r3,r7
        bl DoMoveRolePlay
        
        ; Move return value appropriately.
        mov r10,r0
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
