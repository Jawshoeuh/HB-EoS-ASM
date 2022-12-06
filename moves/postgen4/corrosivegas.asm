; ------------------------------------------------------------------------------
; Jawshoeuh 12/6/2022 - Confirmed Working 12/6/2022
; Corrosive Gas simple makes the targets item sticky. This was the
; best way I could think of for temporarily disabling the held item.
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
.definelabel DoTrapSticky, 0x022EE434

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryActivateTrap, 0x0???????
;.definelabel ChangeStringTrap, 0x????????
;.definelabel TryCreateTrap, 0x????????
;.definelabel StickyTrapID, 0xA


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Branch to code for the 'move' stickytrap.
        ; Adex-8x's implementation of rapid spin
        ; that gives a speed boost after uses this
        ; method and many moves effects have documented
        ; addresses in the community overlay29.
        mov r0,r9
        mov r1,r4
        bl DoTrapSticky
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
