; -------------------------------------------------------------------------
; Jawshoeuh 12/05/2022 - Confirmed Working 07/07/2023
; Stone Axe deals damage and then places a trap below the target.
; I disagree with pmdsky-debug about UpdateTrapVisibility. I'm pretty
; sure it's for updating the tiles on the screen. In any case, 
; the name UpdateTrapVisibility is too narrow for what it does.
; Based on the template provided by https://github.com/SkyTemple
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel DealDamage, 0x02332B20
.definelabel TrySpawnTrap, 0x022EDCBC
.definelabel DungeonRandOutcomeUserAction, 0x02324A20
.definelabel AreLateGameTrapsEnabledWrapper, 0x022ED868
.definelabel UpdateTrapVisibility, 0x02336F4C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel DungeonRandOutcomeUserAction, 0x02325488
;.definelabel AreLateGameTrapsEnabledWrapper, 0x????????
;.definelabel UpdateTrapVisibility, 0x02337B1C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel SPIKE_TRAP_ID, 19 ; 0x13

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Save target X/Y for later.
        ldrsh r5,[r4,#0x4]
        ldrsh r6,[r4,#0x6]
        
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
        
        ; Check if user/target is still alive.
        mov r0,r9
        mov r1,#0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserAction
        cmp r0,FALSE
        beq return
        
        ; Check if traps can be placed here.
        bl  AreLateGameTrapsEnabledWrapper
        cmp r0,FALSE
        beq return
        
        ; Try to spawn a spike trap.
        strh  r5,[sp,#0x0]
        strh  r6,[sp,#0x2]
        mov   r0,sp
        mov   r1,SPIKE_TRAP_ID
        ldr   r3,[r9,#0xB4]
        ldrb  r2,[r3,#0x6]
        cmp   r2,#0
        movne r2,#2
        moveq r2,#1
        mov   r3,TRUE
        bl    TrySpawnTrap
        
        ; While this does update the trap's visibility, I'm pretty certain
        ; that this function has a a more general purpose like updating
        ; the tiles pointed to by the camera.
        bl  UpdateTrapVisibility

    return:
        add sp,sp,#0x4
        pop r5,r6
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1