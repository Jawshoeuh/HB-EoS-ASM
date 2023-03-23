; ------------------------------------------------------------------------------
; Jawshoeuh 12/23/2022 - Confirmed Working 12/23/2022
; Reworked Defog removes traps, lowers evasiveness, and disperses fog.
; Notably, tries to remove traps from around the targets instead of the
; user, so that may be a bit odd... Why not just branch to the original
; effect for removing traps? Because it spams the message for not
; traps found/traps found because it's only called on the user
; in the base game. Looks way better without message spam.
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
.definelabel MistIsActive, 0x023197CC ; also exclusive item effect check
.definelabel EndProtectionClassStatus, 0x023064F4
.definelabel IsFullFloorFixedRoom, 0x023361D4
.definelabel GetTileAtEntity, 0x022E1628
.definelabel HasDropeyeStatus, 0x02301F50
.definelabel UpdateMinimap, 0x02339CE8 ; not in pmdsky-debug
.definelabel UpdateDisplay, 0x02336F4C ; not in pmdsky-debug
.definelabel DestroyTrap, 0x022EDE7C ; not in pmdsky-debug
.definelabel GetTileSafe, 0x02336164
.definelabel TryActivateWeather, 0x023354C4
.definelabel GetVisibilityRange, 0x022E333C
.definelabel WeatherTurnValue, 0x022C4654 ; 0xBB8 (3000) by default.
.definelabel SomeDataThing, 0x02352B38 ; No clue really.

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel MistIsActive, 0x????????
;.definelabel EndProtectionClassStatus, 0x????????
;.definelabel IsFullFloorFixedRoom, 0x02336DA4
;.definelabel GetTileAtEntity, 0x022E1F68
;.definelabel HasDropeyeStatus, 0x0230297C
;.definelabel UpdateMinimap, 0x????????
;.definelabel UpdateDisplay, 0x????????
;.definelabel DestroyTrap, 0x022EDE7C 
;.definelabel GetTileSafe, 0x02336D34
;.definelabel GetVisibilityRange, 0x022E3CEC
;.definelabel TryActivateWeather, 0x02335F04
;.definelabel WeatherTurnValue, 0x022C4FAC ; 0xBB8 (3000) by default.
;.definelabel SomeDataThing, 0x???????? ; No clue really.

; Universal
.definelabel ProtectionRemovedStr, 0xED2

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Check for mist.
        mov r0,r4        ; This function also checks for some kind of
        bl  MistIsActive ; exclusive effect that blocks stat changes.
        cmp r0,#0x0
        bne clear_buffs
        
        ; Check for light screen, reflect, safeguard
        ldr  r7,[r4,#0xB4]
        ldrb r0,[r7,#0xD5]
        add  r0,r0,#0xFF
        and  r0,r0,#0xFF
        cmp  r0,#0x2
        bhi  lower_evasion
    
    clear_buffs:
        ldr r2,=ProtectionRemovedStr
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        mov r0,r9
        mov r1,r4
        bl  EndProtectionClassStatus
        
    lower_evasion:
        ; Lower evasion.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        bl  FocusStatDown
        
        ; Check for fog.
        mov r0,r9
        bl  GetWeather
        cmp r0,#0x6
        bne remove_traps
        
        ; Blow away fog. (Set weather to clear)
        ldr   r3,=WeatherTurnValue
        ldrsh r3,[r3]
        ldr   r2,=DungeonBaseStructurePtr
        ldrsh r3,[r3,#0x0]
        ldr   r2,[r2,#0x0] ; DungeonBaseStrPtr
        add   r2,r2,#0xCD00
        mov   r0,#0x1
        mov   r1,#0x0
        strh  r3,[r2,#0x3A]
        bl    TryActivateWeather
        
    remove_traps:
        bl    IsFullFloorFixedRoom
        cmp   r0,#0x0
        mov   r10,#0
        bne   MoveJumpAddress ; failed, don't work in fixed rooms
        
        ; Init loop to check for traps!
        push r5,r6,r7,r8,r9
        sub  sp,sp,#0xC
        mov  r0,r4
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
        bl    GetVisibilityRange
        ldrsh r2,[r4,#0x4]
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
        ldr  r0,=SomeDataThing
        ldrh r1,[r0,#0x0]
        ldrh r0,[r0,#0x2]
        strh r1,[sp,#4]
        strh r0,[sp,#6]
        b    check_outer_loop
    init_inner_loop:
        mov r0,r8, lsl #0x10
        mov r0,r0, asr #0x10
        mov r6,r9
        str r0,[sp]
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
        ldr  r0,[r0,#0xB4] ; original trap buster calls a function for this
        ldrb r1,[r0,#0x2]
        tst  r1,#0x1       ; can break trap flag
        bne  iter_inner_loop
        ldrb r0,[r0,#0x0]
        cmp  r0,#0x11 ; Check if this 'trap' is actually a wonder tile.
        beq  iter_inner_loop
        ldr  r2,[sp]
        add  r0,sp,#0x8
        mov  r1,#0x0
        strh r2,[sp,#0x8]
        strh r6,[sp,#0xA]
        bl   DestroyTrap   
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
        add sp,sp,#0xC
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