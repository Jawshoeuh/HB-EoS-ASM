; ------------------------------------------------------------------------------
; Jawshoeuh 1/3/2023 - Confirmed Working 1/3/2023
; Shift gear increasces attack by 1 and speed by 2.
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
        sub sp,sp,#0x4
        
        ; Raise attack
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; attack
        mov r3,#1
        bl  AttackStatUp
        
        ; Raise speed two stages.
        mov r3,#1
        mov r0,r9
        mov r1,r4
        mov r2,#2   ; 2 stages
        str r3,[sp] ; yes, fail message
        mov r3,#0   ; default number turns
        bl  SpeedStatUp
        
        mov r10,#1
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close