; ------------------------------------------------------------------------------
; Jawshoeuh 12/24/2022 - Tested 6/18/2024
; Court Change swaps the ownership of nearby traps (Enemy -> Ally &
; Ally -> Enemy) and swaps Light Screen, Reflect, Mist, Safeguard.
; WARNING: This move was designed to only work when targetting one monster
; at a time. It will not work properly otherwise.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel UpdateStatusIconFlags, 0x22E3AB4
.definelabel GetTileAtEntity, 0x22E1628
.definelabel UpdateMinimap, 0x2339CE8
.definelabel GetTileSafe, 0x2336164
.definelabel HasDropeyeStatus, 0x2301F50
.definelabel GetVisibilityRange, 0x22E333C
.definelabel UpdateTrapVisibility, 0x2336F4C
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel UpdateStatusIconFlags, 0x22E4464
;.definelabel GetTileAtEntity, 0x22E1F68
;.definelabel UpdateMinimap, 0x233A8B8
;.definelabel HasDropeyeStatus, 0x230297C
;.definelabel GetTileSafe, 0x2336D34
;.definelabel GetVisibilityRange, 0x22E3CEC
;.definelabel UpdateTrapVisibility, 0x2337B1C
;.definelabel DUNGEON_PTR, 0x2354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6,r7,r8,r9
        
        ; Get User & Target Protections
        ldr  r0,[r9,#0xB4] ; entity->monster
        ldrb r1,[r0,#0xD5] ; monster->statuses->reflect (Protections (Reflect, Aqua Ring, etc))
        ldrb r5,[r0,#0xD6] ; monster->statuses->reflect_turns (Turns of Protection (User))
        ldr  r2,[r4,#0xB4] ; entity->monster
        ldrb r3,[r2,#0xD5] ; monster->statuses->reflect (Protections (Reflect, Aqua Ring, etc))
        ldrb r6,[r2,#0xD6] ; monster->statuses->reflect_turns (Turns of Protection (Target))
        
        ; Give our protections to target.
        cmp    r1,#0x1
        cmpne  r1,#0x2
        cmpne  r1,#0x3
        cmpne  r1,#0xE
        streqb r1,[r2,#0xD5]
        streqb r5,[r2,#0xD6]
        moveq  r1,#0x0
        streqb r1,[r0,#0xD5]
        streqb r1,[r0,#0xD6]
        
        ; Get our target's protections.
        cmp    r3,#0x1
        cmpne  r3,#0x2
        cmpne  r3,#0x3
        cmpne  r3,#0xE
        streqb r3,[r0,#0xD5] ; monster->statuses->reflect (Protections (Reflect, Aqua Ring, etc))
        streqb r6,[r0,#0xD6] ; monster->statuses->reflect_turns (Turns of Protection (User))
        moveq  r1,#0x0
        streqb r1,[r2,#0xD5] ; monster->statuses->reflect (Protections (Reflect, Aqua Ring, etc))
        streqb r1,[r2,#0xD6] ; monster->statuses->reflect_turns (Turns of Protection (Target))
        
        ; Update after.
        mov r0,r9
        bl  UpdateStatusIconFlags
        mov r0,r4
        bl  UpdateStatusIconFlags
        
        mov  r0,r9
        bl   GetTileAtEntity
        mov  r5,r0
        ldrb r0,[r0,#0x7] ; tile->room
        cmp  r0,#0xFF
        beq  init_area
        mov  r0,r9
        bl   HasDropeyeStatus ; If the player has bad visibility, only remove traps in the
        cmp  r0,#0x0          ; immediate area around them.
        beq  init_room
    init_area: ; Clear the area around for traps.
        bl    GetVisibilityRange
        ldrsh r2,[r4,#0x4]
        ldrsh r1,[r4,#0x6] 
        sub   r8,r2,r0
        sub   r9,r1,r0
        add   r7,r2,r0
        add   r5,r1,r0
        b check_outer_loop
    init_room: ; Clear the entire room for traps.
        ldr   r0,=DUNGEON_PTR
        ldrb  r2,[r5,#0x7] ; tile->room
        ldr   r0,[r0]
        mov   r1,#0x1C
        add   r0,r0,#0x2E8
        add   r0,r0,#0xEC00 ; dungeon->room_data
        mla   r0,r2,r1,r0
        ldrsh r3,[r0,#0x2]
        ldrsh r2,[r0,#0x4]
        ldrsh r1,[r0,#0x6]
        ldrsh r0,[r0,#0x8]
        sub   r8,r3,#0x1
        sub   r9,r2,#0x1
        add   r7,r1,#0x1
        add   r5,r0,#0x1
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
        ldr  r0,[r0,#0x10] ; tile->object
        cmp  r0,#0x0
        beq  iter_inner_loop
        ldr  r1,[r0,#0x0]
        cmp  r1,#0x2
        bne  iter_inner_loop
        ldr  r1,[r0,#0xB4] ; entity->trap
        ldrb r2,[r1,#0x2]  ; trap->0x2flags
        tst  r2,#0x1       ; trap->f_unbreakable
        bne  iter_inner_loop
        ldrb r2,[r1,#0x0]
        cmp  r2,#0x11     ; Check if this 'trap' is actually a wonder tile.
        beq  iter_inner_loop
        ldrb r2,[r1,#0x1] ; get trap alignment
        eor  r2,r2,#0x1   ; swap trap alignment
        strb r2,[r1,#0x1] ; save new trap alignment
        mov  r3,#0x1
        strb r3,[r0,#0x20] ; entity->is_visible = true
    iter_inner_loop:
        add r6,r6,#0x1
    check_inner_loop:
        cmp r6,r5
        ble body_loop
        add r8,r8,#1
    check_outer_loop:
        cmp r8,r7
        ble init_inner_loop
        
        ; Note: I disagree with pmdsky-debug that UpdateTrapVisibility only
        ; updates the visibility of traps. It appears to be too specific
        ; for the way the function is used. Appears to be used whenever
        ; the visual state of a tile is modifed on screen.
        bl UpdateMinimap
        bl UpdateTrapVisibility

        mov r10,TRUE
        pop r5,r6,r7,r8,r9
        b   MoveJumpAddress
        .pool
    .endarea
.close
