; ------------------------------------------------------------------------------
; Jawshoeuh 12/5/2022 - Confirmed Working 12/6/2022
; Implements sticky web based upon stealth rock, spikes, toxic spikes
; originally in PMD:EoS. For an implementation like the reworks in my
; repository, look at stickyweb2.
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
.definelabel CanPlaceTrapHere, 0x022ED868 ; loads fixed room properties?
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel UpdateDisplay, 0x02336F4C
.definelabel TrapFailedStr, 0xEEF
.definelabel SlowTrapID, 0xA

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryCreateTrap, 0x????????
;.definelabel SlowTrapID, 0xA


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Can we place a trap here?
        bl  CanPlaceTrapHere
        cmp r0,#0
        beq failed_trap
        
        ; Try to place a slow trap
        add   r0,r4,#0x4    ; r0 = pointer to x/y
        mov   r1,SlowTrapID ; r1 = trap id
        ldr   r2,[r9,#0xb4] ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]  ; notably it just checks for the non
        cmp   r2,#0         ; team member flag, so I guess traps
        movne r2,#2         ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1         ; r3 = trap visible (bool)?
        bl TryCreateTrap
        
        ;Show trap if made.
        cmp r0,#0
        beq failed_trap
        bl  UpdateDisplay
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_trap:
        mov r0,r9
        mov r1,r4
        ldr r2,=TrapFailedStr
        bl SendMessageWithIDCheckUTLog
        
        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
