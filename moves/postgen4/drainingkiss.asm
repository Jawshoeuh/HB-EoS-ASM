; -------------------------------------------------------------------------
; Jawshoeuh 01/06/2023 - Confirmed Working 10/29/2024
; Drainking Kiss heals for 75% of the damage instead of 50% like other
; draining moves. To accomplish this, multiply by 3 and then divide by 4.
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
.definelabel EntityIsValid, 0x022E0354
.definelabel DungeonRandOutcomeUserAction, 0x02324A20
.definelabel ExclusiveItemEffectFlagTest, 0x02010FA4
.definelabel DefenderAbilityIsActive, 0x022F96CC
.definelabel TryIncreaseHp, 0x023152E4
.definelabel ApplyDamageAndEffectsWrapper, 0x0230D11C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel EntityIsValid, 0x022E0C94
;.definelabel DungeonRandOutcomeUserAction, 0x02325488
;.definelabel ExclusiveItemEffectFlagTest, 0x0201104C
;.definelabel DefenderAbilityIsActive, 0x022FA0D8
;.definelabel TryIncreaseHp, 0x02315D44
;.definelabel ApplyDamageAndEffectsWrapper, 0x????????

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel LIQUID_OOZE_ABILITY_ID, 58 ; 0x3A
.definelabel DAMAGE_MESSAGE_SLUDGE, 13 ; 0xD
.definelabel DAMAGE_SOURCE_SLUDGE, 569 ; 0x239
.definelabel EXCLUSIVE_EFF_HP_DRAIN_RECOVERY_BOOST, 87 ; 0x57

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5
        sub  sp,sp,#0x4
        mov  r10,FALSE
        
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
        mov r5,r0 ; Save the damage dealt for later.
        mov r10,TRUE
        
        ; Check if the user is still valid.
        mov r0,r9
        bl  EntityIsValid
        cmp r0,FALSE
        beq return
        
        ; Call a user interaction check. (This check is redundant in this
        ; scenario, but to keep parity with the game call it anyway. This
        ; will essentially check if the user is valid again.)
        mov r0,r9
        mov r1,#0 ; Guaranteed, 100% chance.
        bl  DungeonRandOutcomeUserAction
        cmp r0,FALSE
        beq return
        
        add    r5,r5,r5,asl #1 ; r5 = r5 * 3
        ldr    r0,[r9,#0xB4]
        ldrb   r2,[r0,#0x108]
        cmp    r2,#1
        strccb r10,[r0,#0x108] ; monster::statuses::exp_yield = 1
        ldrb   r1,[r0,#0x6]
        cmp    r0,FALSE
        bne    normal_healing
        ldr    r2,[r9,#0xB4]
        mov    r1,EXCLUSIVE_EFF_HP_DRAIN_RECOVERY_BOOST
        add    r0,r2,#0x228
        bl     ExclusiveItemEffectFlagTest
        cmp    r0,TRUE
        asreq  r5,r5,#1        ; r5 = r5 / 2
    normal_healing:
        asrne  r5,r5,#2        ; r5 = r5 / 4
        
        ; Check for Liquid Ooze (ability).
        mov r0,r9
        mov r1,r4
        mov r2,LIQUID_OOZE_ABILITY_ID
        mov r3,TRUE
        bl  DefenderAbilityIsActive
        cmp r0,TRUE
        bne apply_healing
        
        ; Liquid Ooze is active, apply damage instead.
        mov r0,r9
        mov r1,r5
        mov r2,DAMAGE_MESSAGE_SLUDGE
        ldr r3,=DAMAGE_SOURCE_SLUDGE
        bl  ApplyDamageAndEffectsWrapper
        b   return
    
    apply_healing:
        mov r3,FALSE
        str r3,[sp,#0x0]
        mov r0,r9
        mov r1,r9
        mov r2,r5
        mov r3,#0
        bl  TryIncreaseHp

    return:
        add sp,sp,#0x4
        pop r5
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1