; ------------------------------------------------------------------------------
; Jawshoeuh 11/27/2022
; Tidy up removes traps and boosts the users attack and speed!
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
.definelabel DoMoveTrapBuster, 0x0232CB18

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DoMoveTrapBuster, 0x????????


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		
        ; Branch to code for the move Trap Buster.
        ; Adex-8x's implementation of rapid spin
        ; that gives a speed boost after uses this
        ; method and many moves effects have documented
        ; addresses in the community overlay29.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl DoMoveTrapBuster 
        
        ; Check for succesful trap busting? I've choosen to have
        ; it raise speed and attack even if trap busting fails.
        ; mov r10,r0
        ; cmp r0,#0
        ; beq MoveJumpAddress
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        bl AttackStatUp
        
        ; Raise speed
        mov r0,r9
        mov r1,r4
        mov r2,#6
        mov r3,#0
        bl SpeedStatUpOneStage
        
		; Always branch at the end
		b MoveJumpAddress
		.pool
	.endarea
.close
