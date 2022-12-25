; ------------------------------------------------------------------------------
; Jawshoeuh 12/24/2022 - Confirmed Working 12/25/2022
; Court Change swaps the ownership of nearby traps (Enemy -> Ally &
; Ally -> Enemy) and swaps Light Screen, Reflect, Mist, Safeguard.
; WARNING: This attack is only built to be used on ONE target at a time.
; Using this on multiple opponents will swap the traps MULTIPLE TIMES.
; Causing the traps to sometimes stay in their alignment.
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
.definelabel IsFullFloorFixedRoom, 0x023361D4
.definelabel GetTileAtEntity, 0x022E1628
.definelabel HasDropeyeStatus, 0x02301F50
.definelabel UpdateStatusIconFlags, 0x022E3AB4
.definelabel UpdateMinimap, 0x02339CE8
.definelabel UpdateDisplay, 0x02336F4C
.definelabel GetTileSafe, 0x02336164

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel IsFullFloorFixedRoom, 0x02336DA4
;.definelabel GetTileAtEntity, 0x022E1F68
;.definelabel HasDropeyeStatus, 0x0230297C
;.definelabel UpdateStatusIconFlags, 0x022E4464
;.definelabel UpdateMinimap, 0x????????
;.definelabel UpdateDisplay, 0x????????
;.definelabel GetTileSafe, 0x02336D34


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Get User & Target Protections
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0xD5]  ; Protections (Reflect, Aqua Ring, etc)
        ldrb r10,[r0,#0xD6] ; Turns of Protection (User)
        ldr  r2,[r4,#0xB4]
        ldrb r3,[r2,#0xD5]  ; Protections (Reflect, Aqua Ring, etc)
        ldrb r12,[r2,#0xD6] ; Turns of Protection (Target)
        
        ; Give our protections to target.
        cmp    r1,#0x1
        cmpne  r1,#0x2
        cmpne  r1,#0x3
        cmpne  r1,#0xE
        streqb r1,[r2,#0xD5]
        streqb r10,[r2,#0xD6]
        moveq  r1,#0x0
        streqb r1,[r0,#0xD5]
        streqb r1,[r0,#0xD6]
        
        ; Get our target's protections.
        cmp    r3,#0x1
        cmpne  r3,#0x2
        cmpne  r3,#0x3
        cmpne  r3,#0xE
        streqb r3,[r0,#0xD5]
        streqb r12,[r0,#0xD6]
        moveq  r1,#0x0
        streqb r1,[r2,#0xD5]
        streqb r1,[r2,#0xD6]
        
        ; Update after.
        mov r0,r9
        bl  UpdateStatusIconFlags
        mov r0,r4
        bl  UpdateStatusIconFlags
        
        ; Check if this if a fixed room.
        bl    IsFullFloorFixedRoom
        cmp   r0,#0x0
        mov   r10,#1
        bne   MoveJumpAddress ; failed, don't work in fixed rooms
        
        ; Init loop to check for traps!
        push r5,r6,r7,r8,r9
        mov  r0,r9
        bl   GetTileAtEntity
        mov  r5,r0
        ldrb r0,[r0,#0x7]
        cmp  r0,#0xFF
        beq  init_area
        mov  r0,r9
        bl   HasDropeyeStatus ; I guess is the user is blinded, remove
        cmp  r0,#0x0          ; traps around target instead of in the room?
        beq  init_room
    init_area:
        bl    0x022E333C      ; Function gets some data from the dungeon
        ldrsh r2,[r4,#0x4]    ; pointer, not sure what...
        ldrsh r1,[r4,#0x6] 
        sub   r8,r2,r0
        sub   r9,r1,r0
        add   r7,r2,r0
        add   r5,r1,r0
        b     continue_init
    init_room: ; Get room corners to clear traps from.
        ldr   r0,=DungeonBaseStructurePtr
        ldrb  r2,[r5,#0x7]
        ldr   r0,[r0]
        mov   r1,#0x1C
        add   r0,r0,#0x2E8
        add   r0,r0,#0xEC00
        mla   r0,r2,r1,r0
        ldrsh r3,[r0,#0x2]
        ldrsh r2,[r0,#0x4]
        ldrsh r1,[r0,#0x6]
        ldrsh r0,[r0,#0x8]
        sub   r8,r3,#0x1
        sub   r9,r2,#0x1
        add   r7,r1,#0x1
        add   r5,r0,#0x1
    continue_init:
        ldr  r0,=#0x02352B38 ; Will definelabel for this when I have a good
        ldrh r1,[r0,#0x0]    ; name to describe it.
        ldrh r0,[r0,#0x2]
        b    check_outer_loop
    init_inner_loop:
        mov r0,r8, lsl #0x10
        mov r0,r0, asr #0x10
        mov r6,r9
        b   check_inner_loop
        
    body_loop:
        mov  r0,r8
        mov  r1,r6
        bl   GetTileSafe
        ldr  r0,[r0,#0x10]
        cmp  r0,#0x0
        beq  iter_inner_loop
        ldr  r1,[r0,#0x0]
        cmp  r1,#0x2
        bne  iter_inner_loop
        ldr  r1,[r0,#0xB4] ; original trap buster calls a function for this
        ldrb r2,[r1,#0x2]
        tst  r2,#0x1       ; can break trap flag
        bne  iter_inner_loop
        ldrb r2,[r1,#0x0]
        cmp  r2,#0x11 ; Check if this 'trap' is actually a wonder tile.
        beq  iter_inner_loop
        ldrb r2,[r1,#0x1] ; get trap alignment
        eor  r2,r2,#0x1   ; swap trap alignment
        strb r2,[r1,#0x1] ; save new trap alignment
        mov  r3,#0x1
        strb r3,[r0,#0x20] ; make trap visible
        
    iter_inner_loop:
        add r6,r6,#0x1
    check_inner_loop:
        cmp r6,r5
        ble body_loop
        add r8,r8,#1
    check_outer_loop:
        cmp r8,r7
        ble init_inner_loop
    
        ; Update minimap and displayed tiles.
        bl UpdateMinimap
        bl UpdateDisplay
        
        mov r10,#1
        pop r5,r6,r7,r8,r9
        b MoveJumpAddress
        .pool
    .endarea
.close

; Notes for modifying DoMoveTrapBuster for defog.
; r8  -> r8
; r11 -> r9
; r4  -> r7
; r5  -> r5
; r6  -> r6