; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - Previously Working 1/9/2023, New Version Untested
; Eerie impulse lowers special attack by two! Almost trivial, except
; moves that drop two or more stages use some weird multipliers instead...
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; Uncomment the correct version

; For US
.include "lib/stdlib_us.asm"
.include "lib/dunlib_us.asm"
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel ApplyOffensiveStatMultiplier, 0x02313D40
.definelabel ActivateMotorDrive, 0x0231B060

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel ApplyOffensiveStatMultiplier, 0x023147A0

; Universal
.definelabel MotorDriveAbilityID, 0x66 ; 102

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
        
        ; Unfortunately because of how the game is programmed, Motor Drive
        ; only activates normally from electric damage. Thus, (like Thunder
        ; Wave) the move must manually check to activate the ability Motor
        ; Drive...
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
        mov r2,MotorDriveAbilityID
        mov r3,#0x1
        bl  DefenderAbilityIsActive
        cmp r0,#0x0
        beq motor_drive_inactive
        mov r0,r4
        bl  ActivateMotorDrive
        b   unallocate_memory
        
    motor_drive_inactive:
        ; Not sure why, but moves that normally reduce by 2 stages modify
        ; stat multipliers instead of the stat stages.
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; special attack
        mov r3,#0x80
        str r2,[sp] ; DoMoveCharm uses 1 here PROBABLY to check for stuff
        bl  ApplyOffensiveStatMultiplier ; like Clear Body/White Smoke
        
    unallocate_memory:
        mov r10,#1
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close