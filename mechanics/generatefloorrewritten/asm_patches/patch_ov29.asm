; ------------------------------------------------------------------------------
; Jawshoeuh 2/14/2023
; It may seem odd to rewrite the function, but I wanted this to serve as
; a basis for modifying the GenerateFloor and allow for much more varied
; and crazy dungeon generation without the restrictions set by the game.
; Dungeon generation should be indentical to base game; however, there
; could be differences. If you make your own function to generate floors
; (instead of using the base game functions), I highly suggest using
; overlay36 as there isn't enough space for that here.
; r4 = DUNGEON_PTR
; r5 = FLOOR_GENERATION_STATUS_PTR
; r9 = DUNGEON_FLOOR_PROPERTIES
; ------------------------------------------------------------------------------

.org GenerateFloor
.area 0x7A0 ; If run into space errors, use overlay 36, don't increase area here.
    stmdb sp!,{r4,r5,r6,r7,r8,r9,r10,r11,lr}
    sub   sp,sp,#0x54
    ; Load DUNGEON_PTR it will 'live' in r4 for this entire function.
    ldr r2,=PTR_DUNGEON_PTR
    ldr r4,[r2,0x0] ; DUNGEON_PTR in r4!
    add r7,r4,#0x12000 ; Save some instructions with this!
    
    ; Store 0 Into undefined field_0x12AA4
    mov r8,#0x0
    str r8,[r7,#0xAA4]
    
    ; Remember DUNGEON_FLOOR_PROPERTIES in r9 for a bit.
    ldr r0,=OFFSET_OF_DUNGEON_FLOOR_PROPERTIES
    add r9,r4,r0
    
    ; Set something in the entity table to NULL/0?
    add  r0,r7,#0x3F00
    strh r8,[r0,#0x0C2]
    
    ; Load Some Fixed Room Data
    bl LoadFixedRoomDataVeneer
    bl GetFixedRoomField0x8
    
    ; Store the ouput from above into undefined field_0x12AA4
    str r0,[r7,#0xAA4]
    
    ; Set bool has_monster_house, bool has_kecleon_shop, and bool has_maze
    ; to false (0)
    ldr  r5,=FLOOR_GENERATION_STATUS_PTR ; In r5 for entire function.
    strb r8,[r5,#0x1] ; bool has_monster_house
    strb r8,[r5,#0x3] ; bool has_kecleon_shop
    strb r8,[r5,#0x7] ; bool has_maze
    
    ; ResetHiddenStairsSpawn (trivial)
    bl ResetHiddenStairsSpawn
    
    ; Turn off enemy spawning if this is an OutlawMonsterHouseFloor.
    bl   IsOutlawMonsterHouseFloor
    strb r0,[r5,#0x8] ; bool no_enemy_spawns
    
    ; Determine the hidden stairs type and store in enum
    ; hidden_stairs_type hidden_stairs_type
    add r2,r4,#0x4000
    add r0,r2,#0x00C4
    mov r1,r9
    bl  GetHiddenStairsType
    str r0,[r5,#0x2C] ; enum hidden_stairs_type hidden_stairs_type
    
    ; Get the secondary terrain type for the Tileset ID of this Dungeon
    add   r0,r4,#0x4000
    ldrsh r1,[r0,#0x0D4] ; uint8_t tileset_id
    ldr   r0,=PTR_SECONDARY_TERRAIN_TYPES
    ldrb  r0,[r0,r1]
    
    ; If the secondary terrain type from above is 2, store 1 into
    ; bool has_chasms_as_secondary_terrain, otherwise store 0
    cmp   r0,#0x2
    moveq r2,#0x1
    movne r2,r8
    strb  r2,[r5,#0x4] ; bool has_chasms_as_secondary_terrain
    
    ; Set uint8_t stairs_room to 0xff
    mov  r1,#0xFF
    strb r1,[r5,#0x2] ; uint8_t stairs_room
    
    ; Set struct floor_size_8 floor_size to NULL (0)
    strb r1,[r5,#0x6]
    
    ; Using floor_properties->kecleon_shop_spawn_chance
    ; calculate floor_generation_status->kecleon_shop_spawn_chance.
    ldrb r0,[r9,#0x7] ; uint8_t kecleon_shop_spawn_chance
    bl   GetFinalKecleonShopSpawnChance
    strh r0,[r5,#0xC] ; int16_t kecleon_shop_spawn_chance

    ; Copy floor_properties->monster_house_spawn_chance
    ; to floor_generation_status->monster_house_spawn_chance
    ; but don't if bool no_enemy_spawns (set above after
    ; IsOutlawMonsterHouseFloor) is equal to 1 (true).
    ; The game does some wacky thing like check after setting item
    ; and then setting it to 100.
    ldrb   r0,[r5,#0x8]
    cmp    r0,#0x0
    ldreqb r0,[r9,#0x8] ; uint8_t monster_house_spawn_chance
    movne  r0,#0x64 ; (#100)
    strh   r0,[r5,#0x10]

    ; Set bool second_spawn to 0x1
    mov  r1,#0x1
    strb r1,[r5,#0x0]
    
    ; Set kecleon_shop_min_x, kecleon_shop_min_y, kecleon_shop_max_x,
    ; kecleon_shop_max_y to 0xFFFFFFFF. (all 4 are int's)
    sub r1,r1,#0x2
    str r1,[r5,#0x30]
    str r1,[r5,#0x34]
    str r1,[r5,#0x38]
    str r1,[r5,#0x3C]
    
    ; Just reset the floor (trivial)
    bl ResetFloor
    
    ; If a normal floor, allow enemy spawning. If not a normal floor,
    ; stop enemies from spawning.
    bl  IsNormalFloor
    add  r7,r4,#0x700 ; Save this offset to save one instruction...
    cmp  r0,#0x0
    bne  normal_floor_true
normal_floor_else:
    strh r8,[r7,#0x86]
    b normal_floor_check_end
normal_floor_true:
    ldrb r0,[r9,#0x6]
    bl   Abs
    strh r0,[r7,#0x86]
normal_floor_check_end:

    ; Set field_0x1, field_0x2, hidden_stairs_type in the
    ; dungeon_generation_info struct to 0
    add  r0,r4,#0x4000
    strb r8,[r0,#0xC5] ; undefined field_0x1
    strb r8,[r0,#0xC6] ; undefined field_0x2
    str  r8,[r0,#0xCC] ; enum hidden_stairs_type hidden_stairs_type
    
    ; Set n_normal_item_spawns to 0.
    ldr  r1,=OFFSET_OF_DUNGEON_N_NORMAL_ITEM_SPAWNS
    strh r8,[r0,r1] ; uint16_t n_normal_item_spawns
    
    ; Set floor_generation_status->secondary_structures_budget to
    ; floor_properties->max_secondary_structures
    ldrb r0,[r9,#0xC] ; uint8_t max_secondary_structures
    str  r0,[r5,#0x18] ; int secondary_structures_budget
    
    mov r7,#0x0 ; Iterator for spawn loop.
    ; The game branches to the check at the bottom to check and then
    ; back up here if it's less than 10. However, that's always true
    ; initally. So I don't bother branching to the check first.
dungeon_spawn_attempt_loop:
    mov r0,#0x0
    str r0,[sp,#0x0] ; Some type of thing after generation a fixed room?
    
    ; Reset important spawn positions in dungeon_generation_info gen_info
    add r0,r4,#0x4000
    add r0,r0,#0x00C4
    bl  ResetImportantSpawnPositions
    
    mov r6,#0x0 ; Iterator for generation loop.
dungeon_generation_attempt_loop:
    ; Check that fixed room thing, if this floor is a full floor fixed
    ; room generation is done.
    ldr  r0,[sp,#0x0]
    cmp  r0,#0x0
    beq  fixed_room_check_end
    add  r0,r4,#0x4000
    ldrb r0,[r0,#0x0DA]
    bl   IsNotFullFloorFixedRoom
    cmp  r0,#0x0
    beq  dungeon_generation_attempt_loop_end
    mov  r0,#0x0
    str  r0,[sp,#0x0] ; Set some fixed room flag/marker back to 0.
    
fixed_room_check_end:
    ; Copy the attempt number into
    ; dungeon_generation_info->floor_generation_attempts
    add   r0,r4,#0x4000
    strh  r6,[r0,#0x0DE]
    
    ; If the floor failed to generate before, don't generate
    ; additional secondary structures this time around in
    ; floor_generation_status->secondary_structures_budget
    cmp   r6,#0x1
    mov   r1,#0x0
    strge r1,[r5,#0x18] ; int secondary_structures_budget
    
    ; Mark this floor as valid in the generation status.
    strb  r1,[r5,#0x5] ; bool is_invalid
    
    ; Reset struct position hidden_stairs_spawn to default
    mvn   r10,#0x0
    strh  r10,[r5,#0x20]
    strh  r10,[r5,#0x22]
    
    ; Reset the floor for another generation attempt (trivial).
    bl ResetFloor
    
    ; Reset gen_info->position hidden_stairs_pos
    add r0,r4,#0xCC00
    strh r10,[r0,#0xE0] ; position->x
    strh r10,[r0,#0xE2] ; position->y
    
    ; Do not force monster house, gen_info->force_create_monster_house
    add  r0,r4,#0x4000
    mov  r3,#0x0
    strb r3,[r0,#0xC4] ; bool force_create_monster_house
    
    ; If gen_info->fixed_room_id is not 0, generate that fixed room.
    ; Then, mark that a fixed room has been generated. If the generation
    ; is succesful for a full floor fixed room, break.
    ldrb r0,[r0,#0xDA]
    cmp  r0,#0x0
    beq  fixed_room_generation_check_end
    mov  r1,r9
    bl   GenerateFixedRoom
    cmp  r0,#0x0
    bne  dungeon_generation_attempt_loop_end
    mov  r0,#0x1
    str  r0,[sp,#0x0]
    b    break_dungeon_layout_switch
fixed_room_generation_check_end:
    
    ; Init the dungeon grid dimension loop.
    mov  r11,#0x20
    ; Load the dungeon layout from floor_properties
    ldrb r10,[r9,#0x0] ; struct floor_layout_8 layout
dungeon_grid_dimension_loop:
    cmp   r10,#0x8 ; I have heavily modified this loop from the original
    mov   r0,#0x2  ; in the game. It SHOULD come to the same result as
    moveq r1,#0x5  ; the original one, but it is possible that my changes
    movne r1,#0x9  ; have incindentally caused them to differ slightly.
    bl    DungeonRandRange
    str   r0,[sp,#0x8]
    cmp   r10,#0x8
    mov   r0,#0x2
    moveq r1,#0x4
    movne r1,#0x8
    bl    DungeonRandRange
    str   r0,[sp,#4]
    cmp   r0,#0x4
    ldrle r0,[sp,#0x8]
    cmple r0,#0x6
    ble   dungeon_grid_dimension_loop_break
    subs  r11,r11,#0x1
    bne   dungeon_grid_dimension_loop
    mov   r0,#0x4      ; Default to 4 if we can't generate correct
    str   r0,[sp,#0x8] ; bounds within 32 tries
    str   r0,[sp,#0x4]
dungeon_grid_dimension_loop_break:

    ; r0 SHOULD be equal to [sp,#0x8] right now, but to future proof it
    ; for modification, load the value again anyway. Also, the base game
    ; calls DivideInt here originally. However, the X and Y of the dungeon
    ; is hard coded. So, I don't bother calling it and determine what
    ; values for grid x and grid y will fail for the original call.
    ; Double check that values for our grid don't break the dungeon
    ; generation algorithm. I don't think this ever comes into play in
    ; the base game. The above dungeon_grid_dimension_loop should always
    ; create valid values (could be wrong).
    mov   r2,#0x1
    ldr   r0,[sp,#0x8]
    ldr   r1,[sp,#0x4]
    cmp   r0,#0x7 ; 7 Is Last Legal Max X Grid Value
    strgt r2,[sp,#0x8]
    cmp   r1,#0x4 ; 4 Is Last Legal Max Y Grid Value
    strgt r2,[sp,#0x4] 
    
    ; I think this should still be 0 as we set it above in the function.
    ; However, I am not certain. Thus, we set this value back to 0 again.
    ; Do not force monster house, gen_info->force_create_monster_house
    ; No MH room #, gen_info->monster_house_room
    mov  r1,#0x0
    mov  r2,#0xFF
    add  r3,r4,#0x4000
    strb r1,[r3,#0xC4] ; bool force_create_monster_house
    strb r2,[r3,#0xC9] ; uint8_t monster_house_room
    
    ; Set secondary terrain to spawn by default. In the original version,
    ; this is kept in r8. Additionally, it's 0 by default but I make it 1
    ; by default since there are more generation types with it true.
    ; However, since it loaded 0xC from the stack a lot for looping, I
    ; decided to repurpose r8 for the loop to check for 2 rooms and 20
    ; floor tiles.
    mov  r0,#0x1
    str  r0,[sp,#0xC] ; Generate secondary terrain = true
    
    ; Store the current dungeon layout into 
    ; floor_generation_status->enum floor_layout layout
    str r10,[r5,#0x28]
    
    and r0,r10,#0xF ; 4 Bit Value
    ; Switch statement for the dungeon layout
    addls pc,pc,r0,lsl #2
    b generate_medium_large_floor ; Layout = INVALID (should be unreachable)
    b generate_medium_large_floor ; Layout = 0
    b generate_small_floor        ; Layout = 1
    b generate_one_room_mh_floor  ; Layout = 2
    b generate_outer_ring_floor   ; Layout = 3
    b generate_crossroad_floor    ; Layout = 4
    b generate_two_room_mh_floor  ; Layout = 5
    b generate_line_floor         ; Layout = 6
    b generate_cross_floor        ; Layout = 7
    b generate_medium_large_floor ; Layout = 8 (SMALL MEDIUM!)
    b generate_beetle_floor       ; Layout = 9
    b generate_outer_room_floor   ; Layout = 10
    b generate_medium_floor       ; Layout = 11
    b generate_medium_large_floor ; Layout = 12
    b generate_medium_large_floor ; sLayout = 13
    b generate_medium_large_floor ; Layout = 14
    b generate_medium_large_floor ; Layout = 15
    
generate_medium_large_floor:
    ldr r0,[sp,#8]
    ldr r1,[sp,#4]
    mov r2,r9
    bl  GenerateStandardFloor
    b   break_dungeon_layout_switch
    
generate_small_floor:
    mov  r0,#2
    bl   DungeonRandInt
    mov  r2,#0x1
    strb r2,[r5,#0x6] ; struct floor_size_8 floor_size
    add  r1,r0,#0x2
    mov  r0,#0x4
    mov  r2,r9
    bl   GenerateStandardFloor
    b    break_dungeon_layout_switch
    
generate_one_room_mh_floor:
    bl   GenerateOneRoomMonsterHouseFloor
    add  r1,r4,#0x4000
    mov  r0,#0x1
    strb r0,[r1,#0xC4] ; bool force_create_monster_house
    mov  r0,#0x0
    str  r0,[sp,#0xC] ; Generate secondary terrain = false
    b    break_dungeon_layout_switch

generate_outer_ring_floor:
    mov r0,r9
    bl  GenerateOuterRingFloor
    b   break_dungeon_layout_switch
    
generate_crossroad_floor:
    mov r0,r9
    bl  GenerateCrossroadsFloor
    b   break_dungeon_layout_switch
    
generate_two_room_mh_floor:
    mov  r0,r9
    bl   GenerateTwoRoomsWithMonsterHouseFloor
    add  r1,r4,#0x4000
    mov  r0,#0x1
    strb r0,[r1,#0xC4] ; bool force_create_monster_house
    mov  r0,#0x0
    str  r0,[sp,#0xC] ; Generate secondary terrain = false
    b    break_dungeon_layout_switch

generate_line_floor:
    mov r0,r9
    bl  GenerateLineFloor
    b   break_dungeon_layout_switch
    
generate_cross_floor:
    mov r0,r9
    bl  GenerateCrossFloor
    mov r0,#0x0
    str r0,[sp,#0xC] ; Generate secondary terrain = false
    b   break_dungeon_layout_switch

; The medium small floor generation would go here; however, it's a little
; different in that it just picks smaller numbers in the grid dimension
; loop. So, it just uses the same generation as a standard floor.

generate_beetle_floor:
    mov r0,r9
    bl  GenerateBeetleFloor
    mov r0,#0x0
    str r0,[sp,#0xC] ; Generate secondary terrain = false
    b   break_dungeon_layout_switch
    
generate_outer_room_floor:
    ldr r0,[sp,#8]
    ldr r1,[sp,#4]
    mov r2,r9
    bl  GenerateOuterRoomsFloor
    b   break_dungeon_layout_switch
    
generate_medium_floor:
    mov  r0,#0x2
    bl   DungeonRandInt
    mov  r2,#0x2
    strb r2,[r5,#0x6]
    add  r1,r0,#0x2
    mov  r0,#0x4
    mov  r2,r9
    bl   GenerateStandardFloor

break_dungeon_layout_switch:
    ; Ensure that our generation has not accidentally destroyed some of
    ; the edge tiles. Make all edge tiles walls (and that we haven't
    ; made some impassable tiles into hallways)
    bl  ResetInnerBoundaryTileRows
    bl  EnsureImpassableTilesAreWalls
    
    ; If the dungeon generation failed, iterate and try again.
    ldrb r0,[r5,#0x5] ; bool is_invalid
    cmp  r0,#0x0
    bne  dungeon_generation_attempt_loop_iter

    ; If the dungeon generation was succesful, make sure that there are at
    ; least 20 floor tiles and 2 rooms. Happens in multiple steps.
    mov r10,#0x0
    mov r2,#0x0
    mov r1,#0x0
zero_room_counter_loop:
    add  r0,sp,#0x14
    strb r1,[r0,r2]
    add  r2,r2,#0x1
    cmp  r2,#0x40
    blt  zero_room_counter_loop
    ; Init the loop to check the x cords.
    mov r8,#0x0
check_tile_x_loop:
    ; Init the loop to check the y cords.
    mov r11,#0x0
check_tile_y_loop:
    mov    r0,r8
    mov    r1,r11
    bl     GetTile
    str    r0,[sp,#0x10]
    bl     GetTileTerrain
    cmp    r0,#0x1      ; if the tile is a floor tile
    bne    check_tile_y_loop_iter
    ldr    r0,[sp,#0x10]
    ldrb   r2,[r0,#0x7] ; room index of the tile
    cmp    r2,#0xF0     ; if room index < 0xF0
    bhi    check_tile_y_loop_iter
    add    r10,r10,#0x1
    cmp    r2,#0x40
    movcc  r1,#0x1
    addcc  r0,sp,#0x14
    strccb r1,[r0,r2] 
check_tile_y_loop_iter:
    add r11,r11,#0x1
    cmp r11,#0x20
    blt check_tile_y_loop
check_tile_x_loop_iter:
    add r8,r8,#0x1
    cmp r8,#0x38
    blt check_tile_x_loop
    cmp r10,#0x1E ; check this earlier than original generate floor
    blt dungeon_generation_attempt_loop_iter
    ; The base game goes over every room counter for some reason? I just
    ; stop looking after a second room is found... it's not neccessary to
    ; count for every (mostly empty room). So the name of the loop
    ; doesn't match what it does now...
    mov r1,#0x0 ; Init room counting loop.
    mov r2,#0x0  
total_room_counter_loop:
    add   r0,sp,#0x14
    ldrb  r0,[r0,r2]
    add   r2,r2,#0x1 ; iterate
    cmp   r0,#0x0 ; this little added part maybe looks extremely weird
    addne r1,#0x1 ; and untrustworthy, but it does work if the room counter
    cmpne r1,#0x1 ; is not 1 here, stop checking for more rooms, we have 2
    bne   dungeon_generation_attempt_loop_end
    cmp   r2,#0x40
    blt   total_room_counter_loop
    
dungeon_generation_attempt_loop_iter:
    add r6,r6,#0x1
    cmp r6,#0xA
    blt dungeon_generation_attempt_loop
dungeon_generation_attempt_loop_end:
    
    ; Check if a valid floor has been generated in our 10 attempts.
    ; If not, just generate a One Room Monster House.
    cmp  r6,#0xA
    bne  failsafe_floor_check_end 
    mvn  r1,#0x0
    strh r1,[r5,#0x20] ; struct position kecleon_shop_middle (x)
    strh r1,[r5,#0x22] ; struct position kecleon_shop_middle (y)
    bl   GenerateOneRoomMonsterHouseFloor
    add  r0,r4,#0x4000
    strb r1,[r0,#0xC4] ; bool force_create_monster_house = true
failsafe_floor_check_end:
    
    ; Label junctions for AI and attempt to generate secondary terrain.
    bl   FinalizeJunctions
    ldr  r1,[sp,#0xC]
    cmp  r1,#0x0
    beq  secondary_terrain_check_end
    mov  r1,r9
    mov  r0,#0x1
    bl   GenerateSecondaryTerrainFormations
    secondary_terrain_check_end:
    
    ; Mark various spawns and then invalidate overlapping spawns or spawns
    ; that are impossible (ie, traps in walls).
    bl    DungeonRand100
    ldrb  r1,[r9,#0x19] ; uint8_t itemless_monster_house_chance
    cmp   r0,r1
    movlt r10,#0x1
    movge r10,#0x0
    mov   r0,r9
    mov   r1,r10
    bl    MarkNonEnemySpawns
    mov   r0,r9
    mov   r1,r10
    bl    MarkEnemySpawns
    bl    ResolveInvalidSpawns
    
    ; If the team spawn position is valid, the floor isn't a fixed room,
    ; and the stairs spawn is valid, check that the stairs can be
    ; reached from everywhere to avoid making the floor impossible
    ; to complete.
    mvn     r10,#0x0 ; -1
    add     r0,r4,#0xCC00
    ldrsh   r2,[r0,#0xE0] ; generation_info->team_spawn_pos (x)
    cmp     r2,r10
    ldrnesh r0,[r0,#0xE2] ; generation_info->team_spawn_pos (y)
    cmpne   r0,r10
    beq     dungeon_spawn_attempt_loop_iter
    bl      GetFloorType
    cmp     r0,#0x1
    beq     dungeon_spawn_attempt_loop_end
    add     r1,r4,#0xCC00
    ldrsh   r0,[r1,#0xE4]
    cmp     r0,r10
    ldrnesh r1,[r1,#0xE6]
    cmpne   r1,r10
    beq     dungeon_spawn_attempt_loop_iter
    mov     r2,#0x0
    bl      StairsAlwaysReachable
    cmp     r0,#0x0
    bne     dungeon_spawn_attempt_loop_end
    
dungeon_spawn_attempt_loop_iter:
    add r7,r7,#0x1
    cmp r7,#0xA
    blt dungeon_spawn_attempt_loop
dungeon_spawn_attempt_loop_end:

    ; If we have failed generation a spawn 10 times (that would be
    ; 100 total failed floor generations, extra fail safe and
    ; attempt to generate a one room monster house and spawn stuff
    ; regardless of the empty monster room chance.
    cmp  r7,#0xA
    bne  failsafe_spawn_check_end
failsafe_spawn_check:
    mvn  r1,#0x0 ; -1
    strh r1,[r5,#0x20] ; position kecleon_shop_middle (x)
    strh r1,[r5,#0x22] ; position kecleon_shop_middle (y)
    bl   ResetFloor
    bl   GenerateOneRoomMonsterHouseFloor
    mov  r1,#0x1
    add  r0,r4,#0x4000
    strb r1,[r0,#0xC4] ; bool force_create_monster_house
    bl   FinalizeJunctions
    mov  r0,r9
    mov  r1,#0x0
    bl   MarkNonEnemySpawns
    mov  r0,r9
    mov  r1,#0x0
    bl   MarkEnemySpawns
    bl   ResolveInvalidSpawns
failsafe_spawn_check_end:
    
    ; Handle Kecleon shop stuff (spawning, tiles, items)
    ldr     r1,[r5,#0x20] ; position kecleon_shop_middle (x)
    cmp     r1,#0x0
    ldrgesh r0,[r5,#0x22] ; position kecleon_shop_middle (x)
    cmpge   r0,#0x0
    blt     shopkeeper_spawn_check_end
    bl      GetKecleonIDToSpawnByFloor
    mov     r2,r0
    ldrsh   r0,[r5,#0x20]
    ldrsh   r1,[r5,#0x22]
    mov     r3,#0x0
    bl      MarkShopkeeperSpawn
shopkeeper_spawn_check_end:
    ldr   r0,[r5,#0x30]
    cmp   r0,#0x0
    movlt r1,#0x0
    blt   shop_floor_spawn_check_end
    mov   r0,r9
    mov   r1,#0x1
    bl  MarkShopkeeperFloor
shop_floor_spawn_check_end:
    mov  r2,#0x38      ; undefined field_0x2 is definitely related
    add  r0,r4,#0x4000 ; to a kecleon shop when it spawns
    strb r1,[r0,#0xC6] ; dungeon_generation_info-> undefined field_0x2
    
    ; Flag junctions in hallways across entire floor (trivial)
    mov r0,#0x0
    mov r1,#0x0
    mov r2,#0x38
    mov r3,#0x20
    bl  FlagHallwayJunctions
    
    ; If the terrain is chasm, change the secondary terrain to chasm
    ; terrain.
    ldrb r0,[r5,#0x4] ; bool has_chasms_as_secondary_terrain
    cmp  r0,#0x0
    bleq ConvertSecondaryTerrainToChasms
    
  
    ; If the tilset = 26/27 change the all the walls on the floor
    ; to chasms.
    add   r0,r4,#0x4000
    ldrsh r0,[r0,#0xD4] ; dungeon_generation_info->uint8_t tileset_id
    cmp   r0,#0x1A
    cmpne r0,#0x1B
    bne   tileset_26_check_end
    bl    ConvertWallsToChasms
tileset_26_check_end:
    
    ; Unload fixed room data and set pointer to NULL? (guess)
    bl UnloadFixedRoom
    
    add sp,sp,#0x54
    ldmia sp!,{r4,r5,r6,r7,r8,r9,r10,r11,pc}
    .pool
.endarea

; Speculation, DUNGEON_PTR+0x12AA4 = 0 if a fixed room isn't loaded

; Speculation, DUNGEON_PTR+0x3FC2 = number of items spawned during generation
; including item from mission