; -------------------------------------------------------------------------
; Jawshoeuh 11/28/2022 - Tested 6/17/2024
; Make It Rain deals damage, drops coins and lowers user special attack.
; This version handles the special attack drop identically to the move
; Draco Meteor and drops the special attack after the first target. For a
; version that drops the special attack (but 2 stages) after the move, see
; makeitrain2.asm
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
.definelabel LowerOffensiveStat, 0x23135FC
.definelabel GenerateStandardItem, 0x2344BD0

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel EntityIsValid, 0x22E0C94
;.definelabel DungeonRandOutcomeUserAction, 0x2325488
;.definelabel SpawnDroppedItemAtOffset, 0x????????
;.definelabel LowerOffensiveStat, 0x231405C
;.definelabel GenerateStandardItem, 0x23457B4

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
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
        
        ; Check if target died.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,#0x0
        bne entity_lived
        
        ; Spawn Poke (money).
        add  r0,sp,#0x8
        mov  r1,POKE_ITEM_ID
        mov  r2,#0x2
        bl   GenerateStandardItem
        
        ; Drop Poke on ground (weirdly this uses an offset of 0,0 instead
		; of dropping it directly on the ground at a spot).
        mov  r3,#0
        strh r3,[sp,#0x4]
        strh r3,[sp,#0x6]
        mov  r0,r9
        mov  r1,r4
        add  r2,sp,#0x8
        add  r3,sp,#0x4
        bl   SpawnDroppedItemAtOffset
        
    entity_lived:
        ; I don't know why the developers decided on this when the game
        ; already has an easy and convenient way to drop the special attack
        ; for the move Overheat (Overheat technically drops 2 special
        ; attack stages instead of 1, but I don't see why they couldn't
        ; do something similar for Draco Meteor.)
        ldr r0,[sp,#0x88] ; The number of the target in the loop.
        cmp r0,#0x0
        bne return
    
        ; Lower special attack if first target.
        mov r3,FALSE
        str r3,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r9
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 stage
        bl  LowerOffensiveStat

    return:
        add sp,sp,#0x10
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1