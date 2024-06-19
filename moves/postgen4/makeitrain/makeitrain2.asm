; -------------------------------------------------------------------------
; Jawshoeuh 08/01/2023 - Tested 6/17/2024
; Make It Rain deals damage, drops coins and lowers user special attack.
; This version handles the special attack drop the same way as the move
; Overheat and lowers the special attack after the move has completed.
; For a version that drops the special attack like Draco Meteor, see
; makeitrain1.asm
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
.definelabel EntityIsValid, 0x22E0354
.definelabel DungeonRandOutcomeUserAction, 0x2324A20
.definelabel SpawnDroppedItemAtOffset, 0x232A834
.definelabel GenerateStandardItem, 0x2344BD0

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel EntityIsValid, 0x22E0C94
;.definelabel DungeonRandOutcomeUserAction, 0x2325488
;.definelabel SpawnDroppedItemAtOffset, 0x????????
;.definelabel GenerateStandardItem, 0x23457B4

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel POKE_ITEM_ID, 183 ; 0xB7

; File creation
.create "./code_out.bin", 0x02330134 ; Currently EU Incompatible
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x10
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
        
        ; While a validity check is enough here, call
        ; DungeonRandOutcomeUserAction anyway to keep parity with the game
        ; just in case.
        mov r0,r9
        mov r1,#0 ; Guaranteed
        bl  DungeonRandOutcomeUserAction
        cmp r0,#0
        beq return
        
        ; Mark the target to get their special attack lowered.
        ldr  r3,[r9,#0xB4]
        mov  r2,TRUE
        strb r2,[r3,#0x15F] ; monster->overheat_special_attack_drop_flag = true;
        
        ; Check if target died.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,#0x0
        bne return
        
        ; Spawn Poke (money).
        add  r0,sp,#0x8
        mov  r1,POKE_ITEM_ID
        mov  r2,#0x2
        bl   GenerateStandardItem
        
        ; Drop Poke on ground (weirdly at an offset of (0, 0).
        mov  r3,#0
        strh r3,[sp,#0x4]
        strh r3,[sp,#0x6]
        mov  r0,r9
        mov  r1,r4
        add  r2,sp,#0x8
        add  r3,sp,#0x4
        bl   SpawnDroppedItemAtOffset

    return:
        add sp,sp,#0x10
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1