; ------------------------------------------------------------------------------
; Jawshoeuh 12/24/2022
; Glacial Lance is just a damaging move; however, it plays the unfreeze
; animation so it looks cooler and more like it does in Sword/Shield.
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
.definelabel PlayUnfreezeAnimation, 0x022E6798

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel PlayUnfreezeAnimation, 0x????????

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Trivial damage!
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Display Unfreeze Animation
        mov r0,r4 ; r0 = monster to display animation on
        bl  PlayUnfreezeAnimation
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
