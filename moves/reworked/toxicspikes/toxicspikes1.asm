; ------------------------------------------------------------------------------
; Jawshoeuh 1/11/2023 - Confirmed Working 1/11/2023
; This move doesn't exist in PLA, but I made it poison the target and then
; leave toxic spikes behind? I suppose that people would prefer a damaging
; toxic spikes like the other hazards so find that in toxicspikes2.asm
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
.definelabel CanPlaceTrapHere, 0x022ED868
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel UpdateDisplay, 0x02336F4C

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x????????
;.definelabel TryCreateTrap, 0x????????
;.definelabel UpdateDisplay, 0x????????

; Universal
.definelabel ToxicSpikesTrapID, 0xC

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Attempt to poison target.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#0
        bl  Poison
        
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        mov r10,#1
        
        ; Can we place a trap here?
        bl  CanPlaceTrapHere
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Try to place a toxic spikes trap
        add   r0,r4,#0x4           ; r0 = pointer to x/y
        mov   r1,ToxicSpikesTrapID ; r1 = trap id
        ldr   r2,[r9,#0xB4]        ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]         ; notably it just checks for the non
        cmp   r2,#0                ; team member flag, so I guess traps
        movne r2,#2                ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                ; r3 = trap visible (bool)?
        bl    TryCreateTrap

        bl    UpdateDisplay
        b MoveJumpAddress
        .pool
    .endarea
.close
