; -------------------------------------------------------------------------
; Jawshoeuh 12/01/2022 - Tested 6/17/2024
; Acid Spray deals damage and lowers the opponent's special defense by 2.
; This version modifies the defensive multiplier, for a version that
; modifies the stat stages, see acidspray1.asm
; Based on the template provided by https://github.com/SkyTemple
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel DealDamage, 0x2332B20
.definelabel ApplyDefensiveStatMultiplier, 0x2313F64
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x2324934


; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel ApplyDefensiveStatMultiplier, 0x23149C4
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x232539C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
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
        mov r2,#0x0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
        
        ; Lower special defense two stages.
        mov r3,FALSE
        str r3,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#0x40 ; (64/256) = 1/4 = 0.25 *(See Note 1 Below)
        bl  ApplyDefensiveStatMultiplier
        
    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1