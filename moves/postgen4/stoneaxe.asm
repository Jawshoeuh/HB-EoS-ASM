; ------------------------------------------------------------------------------
; Jawshoeuh 12/3/2022 - Confirmed Working 12/5/2022
; TODO: Make this move better (works but not well made).
; Stone Axe does damage, tries to place down a trap, and
; activates the effect of a stealth rock  trap. Sometimes traps don't
; get shown?
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
.definelabel DoTrapStealthRock, 0x022EEE50
.definelabel ChangeStringTrap, 0x22EDF5C
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel StealthRockTrapID, 0x14

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryActivateTrap, 0x0???????
;.definelabel DoTrapStealthRock, 0x0???????
;.definelabel ChangeStringTrap, 0x????????
;.definelabel TryCreateTrap, 0x????????
;.definelabel StealthRockTrapID, 0x14

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Deal damage.
        sub sp,sp,#0x4
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        add sp,sp,#0x4
        
        ; Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        
        ; Can we place a trap here?
        bl  CanPlaceTrapHere
        cmp r0,#0
        beq failed_trap_place
        
        ; Try to place a stealth rock trap
        add   r0,r4,#0x4            ; r0 = pointer to x/y
        mov   r1,StealthRockTrapID  ; r1 = trap id
        ldr   r2,[r9,#0xB4]         ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]          ; notably it just checks for the non
        cmp   r2,#0                 ; team member flag, so I guess traps
        movne r2,#2                 ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                 ; r3 = trap visible (bool)?
        bl TryCreateTrap
        ; Note to self, if fainted pokemon cause bugs, add a health check.
        ; Activate trap if possible.
        cmp  r0,#0
        beq  failed_trap_place
        mov  r0,r4
        add  r1,r4,#0x4
        mov  r2,#0
        mov  r3,#0
        bl   TryActivateTrap
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_trap_place: ; When in hallways, pretend a trap activated.
        ; Manually say a stealth rock trap was activated!
        mov r0,#0
        mov r1,StealthRockTrapID
        bl  ChangeStringTrap
        mov r0,r4
        mov r1,StealthRockTrapID
        add r1,r1,#0x51
        add r1,r1,#0xB00
        bl  SendMessageWithIDCheckULog
                              ; I think I could get away with just moving
        mov r0,r9             ; the target into r4 because the function
        mov r1,r4             ; only uses r1, but it's called with both r0
        bl  DoTrapStealthRock ; and r1 being set, so I do this to match.

        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
