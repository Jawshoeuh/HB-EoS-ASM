; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 1/6/2023
; Shell Smashes raises the User's Attack, Special Attack and Speed by 2 but
; also lowers the User's Defense and Special Defense by 1.
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x8
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#2 ; 2 stages
        bl AttackStatUp
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#2 ; 2 stages
        bl AttackStatUp
        
        ; Raise speed two stages.
        mov r3,#1
        mov r0,r9
        mov r1,r4
        mov r2,#2   ; 2 stages
        str r3,[sp] ; yes, fail message
        mov r3,#0   ; default number turns
        bl  SpeedStatUp
        
        ; Lower defense.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        str r2,[sp,#0x4]
        mov r3,#1
        str r3,[sp,#0x0]
        bl DefenseStatDown
        
        ; Lower special defense.
        mov r12,#0
        mov r0,r9
        mov r1,r4
        str r12,[sp,#0x4]
        mov r2,#1
        mov r3,#1
        str r3,[sp,#0x0]
        bl DefenseStatDown
        
        mov r10,#1
        add sp,sp,#0x8
        b MoveJumpAddress
        .pool
    .endarea
.close