; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 11/29/2022
; Final gambit does damage equal to the user's health and then they faint.
; I choose to make the self damage 9999 so that there aren't any weird
; niche cases where a Pokemon lives and so I don't have to save health.
; Adex-8x's implementation is identical to how it works in GtI/PSMD
; if you wanted one more faithful to the games.
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
        
        ; Get current health
        ldr   r0,[r9,#0xb4]
        ldrsh r1,[r0,#0x10]
        
        ; Deal damage to opponent.
        mov r0,r4
        ; Current health loaded in r1
        mov r2,#0
        mov r3,#0
        bl ConstDamage
        
        ; Deal damage to self.
        mov r0,r9
        ldr r1,=#9999 ; survive this, loser
        mov r2,#0
        mov r3,#0
        bl ConstDamage
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close