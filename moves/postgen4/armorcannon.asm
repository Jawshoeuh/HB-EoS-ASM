; -------------------------------------------------------------------------
; Jawshoeuh 01/08/2023 - Tested 6/18/2024
; Armor Cannon thaws the target, damages the target , and lowers the user's
; defense and special defense. For some reason the debuff from Close Combat
; can be blocked by abilities/items that prevent stat drops despite other
; moves like Leaf Storm avoiding those checks. So for parity, this MoveJumpAddress
; also doesn't check for them.
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
.definelabel LowerDefensiveStat, 0x2313814

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DealDamage, 0x2333560
;.definelabel EndFrozenStatus, 0x23086A4
;.definelabel LowerDefensiveStat, 0x2314274

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
        
        ; Lower defense one stage.
        mov r3,FALSE
        str r10,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r9
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 Stage
        bl  LowerDefensiveStat
        
        ; Lower special defense one stage.
        mov r3,FALSE
        str r10,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r9
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 Stage
        bl  LowerDefensiveStat
        
    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1