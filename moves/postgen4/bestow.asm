; ------------------------------------------------------------------------------
; Jawshoeuh 12/29/2022 - Confirmed Working 1/8/2023
; Bestow gives the target their held item. This move is probably extremely
; useless as you can normally just throw items to give them or open
; the menu to give them to your partner. However, it exists for the
; sake of completion. I could also probably make it force items into
; the bag, but that feels unnecessary and weird.
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
.definelabel EntityIsValid, 0x22E0354
.definelabel UpdateItemEffect, 0x022F9EA0
.definelabel RemoveEquivItem, 0x0200F558
.definelabel TryPickupItem, 0x02346F14
.definelabel ItemZInit, 0x0200D81C

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x0022E0C94
;.definelabel UpdateItemEffect, 0x????????
;.definelabel RemoveEquivItem, 0x0200F600
;.definelabel TryPickupItem, 0x????????
;.definelabel ItemZInit, 0x0200D8A4

; Universal
.definelabel NoItemStrID, 0xEFB ; 3835
.definelabel GotItemStrID, 0xEF9 ; 3833

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        ; Could maybe push/pop r6/r7 instead of loading the user/target
        ; extra monster data. It probably doesn't make a huge difference.
    
        ; Subs strings earlier for fail messages.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; Target
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  ChangeString ; User
        
        ; Check for user item, fail if no item.
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0x62]
        tst  r1,#0b1
        bne  check_target_item
        ldr  r2,=NoItemStrID
        mov  r0,r9
        mov  r1,r4
        bl   SendMessageWithIDCheckUTLog
        mov  r10,#0
        b    MoveJumpAddress
        
        ; Check for target item, fail if holding item.
    check_target_item:
        ldr  r2,[r4,#0xB4]
        ldrb r3,[r2,#0x62]
        tst  r3,#0b1
        beq  give_target_item
        mov  r0,r4
        ldr  r1,=bestow_held_str
        bl   SendMessageWithStringLog
        mov  r10,#0
        b MoveJumpAddress
    
        ; Actually give target our item.
    give_target_item:
        ; Overwrite their item data with our own.
        ldrh r1,[r0,#0x66]
        strh r1,[r2,#0x66]
        ldrh r1,[r0,#0x64]
        strh r1,[r2,#0x64]
        ldrh r1,[r0,#0x62]
        strh r1,[r2,#0x62]
        
        ; If on the team, also remove this relevant item data from the bag.
        ldrb  r3,[r0,#0x6]
        cmp   r3,#0x0
        addeq r0,r0,#0x62
        bleq  RemoveEquivItem
        
        ; If target is on team, properly add its info to the bag.
        ; Yes, just because the target's item is updated, it also needs to
        ; be added to the bag for us to be able to put it back in the bag
        ; and to be able to see it from the menu bag.
        ldr  r0,[r4,#0xB4]
        ldrb r1,[r0,#0x6]
        cmp  r1,#0x0
        bleq TryPickupItem
        
        ; Remove the item from the user.
        ldr r0,[r9,#0xB4]
        add r0,r0,#0x62
        bl  ItemZInit
        
        ; Update item effects/passives/actives on monsters.
        mov r0,r9
        bl  UpdateItemEffect
        mov r0,r4
        bl  UpdateItemEffect
        
        ; Like Trick, the User will give more XP when killed. Why? Idk???
        ldr    r3,[r9,#0xB4]
        ldrb   r0,[r3,#0x108]
        cmp    r0,#0
        movcc  r0,#1
        strccb r0,[r3,#0x108]
        
        ; Display target got item.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; Target
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  ChangeString ; User
        ldr r1,=bestow_get_str
        mov r0,r9
        bl SendMessageWithStringLog
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    bestow_held_str:
        .asciiz "[string:0] has an item already. It couldn't[R]hold another item!" 
    bestow_get_str:
        .asciiz "[string:0] got [string:1]'s item." 
    .endarea
.close
