; ------------------------------------------------------------------------------
; Jawshoeuh 11/17/2022 - Untested
; Venoshock deals extra damage if the pokemon is poisoned.
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
        
        ; Get poisoned status.
        ldr  r0,[r4,#0xb4]
        ldrb r1,[r0,#0xbf]
        
        ; Set damage accordingly.
        cmp   r1,#0x2   ; TryInflictPoisonedStatus sets this to 2.
        cmpne r1,#0x3   ; TryInflictBadlyPoisonedStatus sets to 3
        moveq r3,#0x180 ; Damage amp if badly poisoned/poisoned
        movne r3,#0x100 ; Regular damage otherwise.
        
        ; Damage enemy.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        bl  DealDamage
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close