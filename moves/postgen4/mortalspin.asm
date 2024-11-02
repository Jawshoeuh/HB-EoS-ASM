; -------------------------------------------------------------------------
; Jawshoeuh 12/24/2022 - Confirmed Working 11/02/2024
; Mortal Spin removes entry hazards, removes any binding effects, removes
; leech seed, and poisons the target. In the base game, Rapid Spin will not
; activate the flag to remove binding effects or leech seed. This is most
; likely to stop the Shadow Tag ability from immobilizing the target and
; then having rapid spin instantly clear it. This implementation keeps that
; parity.
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
.definelabel DealDamage, 0x2332B20
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x2324934
.definelabel TryInflictPoisonedStatus, 0x2312664
.definelabel DungeonRandOutcomeUserAction, 0x2324A20
.definelabel IsFullFloorFixedRoom, 0x23361D4
.definelabel GetTileAtEntity, 0x22E1628
.definelabel HasDropeyeStatus, 0x2301F50
.definelabel GetVisibilityRange, 0x22E333C
.definelabel GetTileSafe, 0x2336164
.definelabel GetTrapInfo, 0x22E1608
.definelabel TryRemoveTrap, 0x22EDE7C
.definelabel LogMessageByIdWithPopupCheckUser, 0x234B2A4
.definelabel UpdateMinimap, 0x2339CE8
.definelabel UpdateTrapsVisibility, 0x2336F4C
.definelabel RAPID_SPIN_BINDING_REMOVAL, 0x237CA6D
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x232539C
;.definelabel TryInflictPoisonedStatus, 0x23130C4
;.definelabel DungeonRandOutcomeUserAction, 0x2325488
;.definelabel IsFullFloorFixedRoom, 0x2336DA4
;.definelabel GetTileAtEntity, 0x22E1F68
;.definelabel HasDropeyeStatus, 0x230297C
;.definelabel GetVisibilityRange, 0x22E3CEC
;.definelabel GetTileSafe, 0x2336D34
;.definelabel GetTrapInfo, 0x22E1F48
;.definelabel TryRemoveTrap, 0x22EE82C
;.definelabel LogMessageByIdWithPopupCheckUser, 0x234BEA4
;.definelabel UpdateMinimap, 0x233A8B8
;.definelabel UpdateTrapsVisibility, 0x2337B1C
;.definelabel RAPID_SPIN_BINDING_REMOVAL, 0x237D66D
;.definelabel DUNGEON_PTR, 0x2354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel NULL, 0x0
.definelabel ENUM_ENTITY_TYPE_TRAP, 0x2
.definelabel ENUM_TRAP_ID_WONDER_TILE, 0x11 ; 17
.definelabel NEARBY_TRAP_REMOVED_STR_ID, 0xF05 ; 3845

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6,r7,r8,r10,r11
        sub sp,sp,#0xC
        mov r10,FALSE
        
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        beq return
        mov r10,TRUE
        
        ; Attempt to apply secondary effects (fails if the target has
        ; fainted or has Shield Dust).
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq skip_poison
        
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        mov r3,FALSE
        bl  TryInflictPoisonedStatus
        
        skip_poison:
        mov r0,r9
        mov r1,#0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserAction
        cmp r0,FALSE
        beq return
        
        ; Flag for binding and leech seed to be removed.
        ; Unless the ability Shadow Tag activated.
        ldr   r0,[r9,#0xB4] ; entity->monster
        add   r0,r0,#0x100
        ldrh  r0,[r0,#0x92] ; monster->contact_ability_trigger_bitflags
        tst   r0,#0b10
        ldr   r0,=RAPID_SPIN_BINDING_REMOVAL
        movne r1,FALSE
        moveq r1,TRUE
        strb  r1,[r0,#0x0]
        
        ; Check if we can remove traps in the first place.
        bl  IsFullFloorFixedRoom
        cmp r0,TRUE
        beq return
        
        ; Check where we should remove traps from. If the user is in a
        ; hallway or has the dropeye status, we should only remove traps
        ; in their range of vision. Otherwise, remove traps across the
        ; entire room.
        mov  r0,r9
        bl   GetTileAtEntity
        ldrb r0,[r0,#0x7]
        mov  r11,r0
        cmp  r0,#0xFF
        beq  init_area_near_monster
        mov  r0,r9
        bl   HasDropeyeStatus
        cmp  r0,TRUE
        beq  init_area_near_monster
        
        ; Init the area in room.
        ldr r0,=DUNGEON_PTR
        ldr r0,[r0,#0x0]
        mov r1,#0x1C
        add r0,r0,#0x2E8
        add r0,r0,#0xEC00
        mla r0,r11,r1,r0   ; dungeon->room_data[r11];
        ldrsh r3,[r0,#0x2] ; room_data->top_left_corner.x
        ldrsh r2,[r0,#0x4] ; room_data->top_left_corner.y
        ldrsh r1,[r0,#0x6] ; room_data->bottom_right_corner.x
        ldrsh r0,[r0,#0x8] ; room_data->bottom_right_corner.y
        sub   r5,r3,#1 ; x start
        sub   r6,r2,#1 ; y start
        add   r7,r1,#1 ; x end
        add   r8,r0,#1 ; y end
        b     loop_init
        
        ; Init the area for the tiles in view.
        init_area_near_monster:
        bl    GetVisibilityRange
        ldrsh r2,[r4,#0x4] ; entity->pos.x
        ldrsh r1,[r4,#0x6] ; entity->pos.y
        sub   r5,r2,r0 ; x start
        sub   r6,r1,r0 ; y start
        add   r7,r2,r0 ; x end
        add   r8,r1,r0 ; y end

        loop_init:
        str   r6,[sp,#0x8]
        mov r11,FALSE ; r11 is used to check if we have removed any traps
        loop_tiles_x:
            ldr r6,[sp,#0x8]
            loop_tiles_y:
                mov  r0,r5
                mov  r1,r6
                bl   GetTileSafe
                ldr  r0,[r0,#0x10] ; tile->object
                cmp  r0,NULL
                beq  loop_tiles_y_iter
                ldr  r1,[r0,#0x0] ; entity->entity_type
                cmp  r1,ENUM_ENTITY_TYPE_TRAP
                bne  loop_tiles_y_iter
                bl   GetTrapInfo
                ldrb r1,[r0,#0x2] ; trap->flag
                tst  r1,#0b1      ; trap->flag.unbreakable
                bne  loop_tiles_y_iter
                ldrb r0,[r0,#0x0] ; trap->id
                cmp  r0,ENUM_TRAP_ID_WONDER_TILE
                beq  loop_tiles_y_iter
                add  r0,sp,#0x0
                mov  r1,FALSE
                strh r5,[sp,#0x0]
                strh r6,[sp,#0x2]
                bl   TryRemoveTrap
                mov  r11,TRUE
            loop_tiles_y_iter:
                add r6,r6,#1
                cmp r6,r8
                ble loop_tiles_y
        loop_tiles_x_iter:
            add r5,r5,#1
            cmp r5,r7
            ble loop_tiles_x
        
        ; Give feedback if a trap has been removed and update the minimap
        ; and visibility.
        cmp r11,TRUE
        bne return
        mov r0,r9
        ldr r1,=NEARBY_TRAP_REMOVED_STR_ID
        bl  LogMessageByIdWithPopupCheckUser
        bl  UpdateMinimap
        bl  UpdateTrapsVisibility
        
    return:
        add sp,sp,#0xC
        pop r5,r6,r7,r8,r10,r11
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1