; ------------------------------------------------------------------------------
; Jawshoeuh 1/11/2023 - Confirmed Working 3/22/2023
; Stealth Rock reworked version does damage and then leaves
; 'jagged splinters' (stealth rock trap) behind.
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
.definelabel TryCreateTrap, 0x022EDCBC ; not in pmdsky-debug
.definelabel UpdateDisplay, 0x02336F4C ; not in pmdsky-debug

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x????????
;.definelabel TryCreateTrap, 0x???????? ; not in pmdsky-debug
;.definelabel UpdateDisplay, 0x???????? ; not in pmdsky-debug

; Universal
.definelabel StealthRockTrapID, 0x14

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r5
        sub  sp,sp,#0x4
        
        ; Save target X/Y for later.
        ldrsh r5,[r4,#0x4]
        ldrsh r10,[r4,#0x6]
        
        ; Deal damage.
        str   r7,[sp]
        mov   r0,r9
        mov   r1,r4
        mov   r2,r8
        mov   r3,#0x100 ; normal damage
        bl    DealDamage
        cmp   r0,#0
        moveq r10,#0x0
        beq   unallocate_memory
        
        ; Check user has not fainted.
        mov   r0,r9
        mov   r1,#0x0
        bl    RandomChanceU
        cmp   r0,#0x0
        moveq r10,#0x1
        beq   unallocate_memory
        
        ; Can we place a trap here?
        bl    CanPlaceTrapHere
        cmp   r0,#0
        moveq r10,#0x1
        beq   unallocate_memory
        
        ; Try to place a stealth rock trap
        strh  r5,[sp,#0x0]
        strh  r10,[sp,#0x2]
        mov   r0,sp                ; r0 = pointer to x/y
        mov   r1,StealthRockTrapID ; r1 = trap id
        ldr   r2,[r9,#0xB4]        ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]         ; notably it just checks for the non
        cmp   r2,#0                ; team member flag, so I guess traps
        movne r2,#2                ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                ; r3 = trap visible (bool)?
        bl    TryCreateTrap
        
        bl    UpdateDisplay
        
        mov   r10,#0x1
    unallocate_memory:
        add sp,sp,#0x4
        pop r5
        b MoveJumpAddress
        .pool
    .endarea
.close
