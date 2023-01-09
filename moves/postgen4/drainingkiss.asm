; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - WIP
; Drainking Kiss heals for 75% of the damage instead of 50% like other
; draining moves. To accomplish this, multiply by 3 and then divide by 4.
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
.definelabel EntityIsValid, 0x22E0354
.definelabel GenerateStandardItem, 0x02344BD0
.definelabel SpawnItemDrop, 0x0232A834 ; may be poorly named...

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x0022E0C94
;.definelabel GenerateStandardItem, 0x23457B4
;.definelabel SpawnItemDrop, 0x???????? ; may be poorly named...

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close