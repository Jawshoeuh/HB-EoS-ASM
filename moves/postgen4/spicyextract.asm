; ------------------------------------------------------------------------------
; Jawshoeuh 11/28/2022 - Confirmed Working 11/28/2022
; Spicy Extract lowers defense by 2 and raises attack by 2.
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
    
        ; Lower defense.
        mov r10,#1 ; use to store 1 into sp
        mov r0,r9
        mov r1,r4
        mov r2,#0
        str r10,[sp,#0x4]
        mov r3,#2
        str r10,[sp,#0x0]
        bl DefenseStatDown
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#2 ; 2 stages
        bl AttackStatUp
        
        add sp,sp,#0x8
        b MoveJumpAddress
        .pool
    .endarea
.close