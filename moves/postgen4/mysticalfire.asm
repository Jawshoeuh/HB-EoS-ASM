; -------------------------------------------------------------------------
; Jawshoeuh 01/06/2023 - Confirmed Working XX/XX/XXXX
; Mystical Fire thaws, deals damage, and lowers the opponent's special
; attack. 
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
.definelabel DealDamage, 0x02332B20
.definelabel EndFrozenStatus, 0x02307C78
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x02324934
.definelabel LowerOffensiveStat, 0x023135FC

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel EndFrozenStatus, 0x023086A4
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x0232539C
;.definelabel LowerOffensiveStat, 0x0231405C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
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
        beq return
        
        ; Drop the target's special attack.
        mov r3,FALSE
        str r3,[sp,#0x4]
        str r10,[sp,#0x0
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 stage
        bl  LowerOffensiveStat

    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1