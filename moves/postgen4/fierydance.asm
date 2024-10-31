; -------------------------------------------------------------------------
; Jawshoeuh 01/06/2023 - Confirmed Working 10/30/2024
; Fiery Dance thaws the target, deals damage, and has a 50% chance to raise
; the user's special attack.
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
.definelabel EndFrozenStatus, 0x2307C78
.definelabel BoostOffensiveStat, 0x231399C
.definelabel DungeonRandOutcomeUserAction, 0x2324A20


; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel EndFrozenStatus, 0x23086A4
;.definelabel BoostOffensiveStat, 0x23143FC
;.definelabel DungeonRandOutcomeUserAction, 0x2325488

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Try to thaw target.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl  EndFrozenStatus
        
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
        
        ; Check to boost special attack (50% chance)
        mov r0,r9
        mov r1,#50
        bl  DungeonRandOutcomeUserAction
        cmp r0,FALSE
        beq return
        
        ; Raise special attack 1 stage.
        mov r0,r9
        mov r1,r9
        mov r2,SPECIAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1