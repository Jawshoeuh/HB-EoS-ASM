; -------------------------------------------------------------------------
; Jawshoeuh 03/23/2023 - Confirmed Working 11/11/2024
; Pollen Puff damages enemies and heals allies!
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
.definelabel TryIncreaseHp, 0x23152E4
.definelabel DealDamage, 0x2332B20

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryIncreaseHp, 0x2315D44
;.definelabel DealDamage, 0x2333560

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
        
        ldr   r3,[r4,#0xB4]
        ldrb  r0,[r3,#0x6]
        ldrb  r1,[r3,#0x8]
        eor   r2,r0,r1 ; 1 = enemy, 0 = friend
        ldr   r3,[r9,#0xB4]
        ldrb  r0,[r3,#0x6]
        ldrb  r1,[r3,#0x8]
        eor   r3,r0,r1 ; 1 = enemy, 0 = friend
        cmp   r3,r2
        beq   heal_ally
        
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp   r0,#0
        moveq r10,TRUE
        b     return
        
        heal_ally:
        mov   r10,TRUE
        ldr   r2,[r4,#0xB4] ; entity->monster
        ldrsh r1,[r2,#0x12] ; monster->max_hp_stat
        ldrsh r2,[r2,#0x16] ; monster->max_hp_booost
        add   r2,r2,r1 ; Max HP
        lsl   r2,r2,#0x1 ; Max HP / 2
        mov r0,r9
        mov r1,r4
        ; heal hp already in r2 above
        mov r3,#0
        str r10,[sp,#0x0]
        bl  TryIncreaseHp

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1
