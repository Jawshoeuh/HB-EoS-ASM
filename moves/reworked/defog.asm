; ------------------------------------------------------------------------------
; Jawshoeuh 12/6/2022 - Confirmed Working 12/6/2022
; Reworked Defog removes traps, lowers evasiveness, and disperses fog.
; Kinda wacky that the trap busting happens multiple times though.
; That message is probably annoying if this is used in a monster house...
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
.definelabel DoMoveDefog, 0x0232D4AC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DoMoveTrapBuster, 0x????????
;.definelabel DoMoveDefog, 0x????????


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Branch to two other (very complex) move effects.
        ; This tricked can be seen used in Adex-8x'seen
        ; implementation of Rapid Spin.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl DoMoveTrapBuster
        
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,r7
        bl DoMoveDefog
        
        mov r10,r0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
