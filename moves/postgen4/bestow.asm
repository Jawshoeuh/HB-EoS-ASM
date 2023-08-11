; -------------------------------------------------------------------------
; Jawshoeuh 12/29/2022 - Confirmed Working 07/02/2023
; Move does things and stuff.; Bestow gives the target their held item.
; This move is probably extremely useless as you can normally just throw
; items to give them or open the menu to give them to your partner.
; However, it exists for the sake of completion. I could also probably make
; it force items into the bag, but that feels unnecessary and weird.
; (Technically has a niche use as a way to get rid of sticky items).
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel EntityIsValid, 0x022E0354
.definelabel TryActivateItem, 0x022F9EA0
.definelabel RemoveEquivItem, 0x0200F558
.definelabel AddHeldItemToBag, 0x02346F14
.definelabel ItemZInit, 0x0200D81C
.definelabel SubstitutePlaceholderStringTags, 0x022E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel LogMessageWithPopupCheckUserTarget, 0x0234B3A4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x0022E0C94
;.definelabel TryActivateItem, 0x????????
;.definelabel RemoveEquivItem, 0x0200F600
;.definelabel AddHeldItemToBag, 0x????????
;.definelabel ItemZInit, 0x0200D8A4
;.definelabel SubstitutePlaceholderStringTags, 0x022E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel LogMessageWithPopupCheckUserTarget, 0x0234BFA4

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel NO_ITEM_STR_ID, 3835 ; 0xEFB

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6
        mov  r10,FALSE
        
        ; Check if the user has an item, fail if no item is held.
        ldr  r5,[r9,#0xB4]
        ldrb r1,[r5,#0x62]
        tst  r1,#0b1
        bne  check_target_item
        mov  r0,#0
        mov  r1,r4
        mov  r2,#0
        bl   SubstitutePlaceholderStringTags ; Target
        mov  r0,#1
        mov  r1,r9
        mov  r2,#0
        bl   SubstitutePlaceholderStringTags ; User
        ldr  r2,=NO_ITEM_STR_ID
        mov  r0,r9
        mov  r1,r4
        bl   LogMessageByIdWithPopupCheckUserTarget
        b    return
        
        ; Check if the target has an item, fail if they are.
    check_target_item:
        ldr  r6,[r4,#0xB4]
        ldrb r3,[r6,#0x62]
        tst  r3,#0b1
        beq  give_target_item
        mov  r0,#0
        mov  r1,r4
        mov  r2,#0
        bl   SubstitutePlaceholderStringTags ; Target
        mov  r0,#1
        mov  r1,r9
        mov  r2,#0
        bl   SubstitutePlaceholderStringTags ; User
        ldr  r2,=bestow_held_str
        mov  r0,r9
        mov  r1,r4
        bl   LogMessageWithPopupCheckUserTarget
        b    return
        
        ; Actually give target our item.
    give_target_item:
        ; Overwrite target item data with our own.
        ldrh r0,[r5,#0x66]
        strh r0,[r6,#0x66]
        ldrh r1,[r5,#0x64]
        strh r1,[r6,#0x64]
        ldrh r2,[r5,#0x62]
        strh r2,[r6,#0x62]
        
        ; If user on the team, also remove this item from the bag.
        ldrb  r3,[r5,#0x6]
        cmp   r3,FALSE
        addeq r0,r5,#0x62
        bleq  RemoveEquivItem
        
        ; If target is on team, properly add the item to the bag.
        ldr   r1,[r6,#0x6]
        cmp   r1,FALSE
        moveq r0,r6
        bleq  AddHeldItemToBag
        
        ; Remove the item from the user.
        add r0,r5,#0x62
        bl  ItemZInit
        
        ; Tries to activate specific held items (ie, X-Ray Specs)
        mov r0,r9
        bl  TryActivateItem
        mov r0,r4
        bl  TryActivateItem
        
        ; Like Trick, the User will give more XP when killed.
        ldr    r3,[r9,#0xB4]
        ldrb   r0,[r3,#0x108]
        cmp    r0,#0
        movcc  r0,#1
        strccb r0,[r3,#0x108]
        
        ; Display the target got the item.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        ldr r2,=bestow_get_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        
        mov r10,TRUE
    return:
        pop r5,r6
        b   MoveJumpAddress
        .pool
    bestow_held_str:
        .asciiz "[string:0] has an item already. It can't[R]hold another item!" 
    bestow_get_str:
        .asciiz "[string:0] got [string:1]'s item." 
    .endarea
.close
