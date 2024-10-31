; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Tested 10/29/2024
; Eerie impulse lowers special attack by two 'stages'! Technically lowers
; the special attack multiplier.
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
.definelabel ApplyOffensiveStatMultiplier, 0x2313D40
.definelabel ActivateMotorDrive, 0x231B060
.definelabel GetMoveTypeForMonster, 0x230227C
.definelabel GetMoveType, 0x2013864
.definelabel DefenderAbilityIsActive, 0x22F96CC

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel ApplyOffensiveStatMultiplier, 0x23147A0
;.definelabel ActivateMotorDrive, 0x231BAC0
;.definelabel GetMoveTypeForMonster, 0x2302CA8
;.definelabel GetMoveType, 0x201390C
;.definelabel DefenderAbilityIsActive, 0x22FA0D8

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel MOTOR_DRIVE_ABILITY_ID, 102 ; 0x66

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        
        ; Check for Motor Drive manually.
        mov r0,r9
        mov r1,r8
        bl  GetMoveTypeForMonster
        mov r10,r0
        mov r0,r8
        bl  GetMoveType
        cmp r0,r10
        bne motor_drive_inactive
        mov r0,r9
        mov r1,r4
        mov r2,MOTOR_DRIVE_ABILITY_ID
        mov r3,TRUE
        bl  DefenderAbilityIsActive
        cmp r0,FALSE
        beq motor_drive_inactive
        mov r0,r4
        bl  ActivateMotorDrive
        b   return
        
    motor_drive_inactive:
        ; Because it's 2 'stages' lower the special attack multiplier.
        mov r3,TRUE
        str r3,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#0x80 ; 128/256 = 1/2 = 0.5x *(See Note 1 Below)
        bl  ApplyOffensiveStatMultiplier

    return:
        mov r10,TRUE
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1