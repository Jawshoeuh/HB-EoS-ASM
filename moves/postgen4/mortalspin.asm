; ------------------------------------------------------------------------------
; Jawshoeuh 11/27/2022
; UNTESTED
; Mortal Spin removes entry hazards, bind wrap... (exactly like rapid spin)
; and poisons the enemy pokemon.
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
.definelabel DoMoveRapidSpin, 0x02327940

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DoMoveRapidSpin, 0x23283A8


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Branch to code for the move rapid spin.
        ; Adex-8x's implementation of rapid spin
        ; that gives a speed boost after uses this
        ; method and many moves effects have documented
        ; addresses in the community overlay29.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl DoMoveRapidSpin
        
        ; Check for succesful hit.
        mov r10,r0
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Attempt to poison target.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#0
        bl Poison
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
