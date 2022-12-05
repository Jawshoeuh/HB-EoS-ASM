; ------------------------------------------------------------------------------
; Jawshoeuh 12/3/2022 - Confirmed Working 12/4/2022
; Stone Axe deals damage and places a Stealth Rock trap below
; the target. While I could branch to the DoMoveStealthRock, the trap
; would just spawn below us. Also, I don't want a message
; if spawning a trap fails. Trap isn't visible despite the offset
; described in the documentation I saw to #1? Still works fine.
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
.definelabel TryActivateTrap, 0x022EDFA0
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel StealthRockTrapID, 0x14

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryCreateTrap, 0x????????
;.definelabel StealthRockTrapID, 0x14


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Deal damage.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        
        ; Can we place a trap here?
        bl  CanPlaceTrapHere
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Try to place a stealth rock trap
        add   r0,r4,#0x4            ; r0 = pointer to x/y
        mov   r1,StealthRockTrapID  ; r1 = trap id
        ldr   r2,[r9,#0xb4]         ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]          ; notably it just checks for the non
        cmp   r2,#0                 ; team member flag, so I guess traps
        movne r2,#2                 ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                 ; r3 = trap visible (bool)?
        bl TryCreateTrap
        
        ; Activate trap if possible
        cmp  r0,r4
        add  r1,r4,#0x4
        mov  r2,#0
        mov  r3,#0
        blne TryActivateTrap
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
