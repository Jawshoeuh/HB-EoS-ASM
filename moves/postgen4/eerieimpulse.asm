; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - Confirmed Working 1/9/2023
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel ApplyOffensiveStatMultiplier, 0x023147A0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
        ; Not sure why, but moves that normally reduce by 2 stages modify
        ; stat multipliers instead of the stat stages.
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; special attack
        mov r3,#0x80
        str r2,[sp] ; DoMoveCharm uses 1 here PROBABLY to check for stuff
        bl  ApplyOffensiveStatMultiplier ; like Clear Body/White Smoke
        
        mov r10,#1
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close