; ------------------------------------------------------------------------------
; Jawshoeuh 12/3/2022 - WIP
; Stone Axe does damage, does stealth rock damage, and then tries to place
; a trap below the target. Currently, there is a bug that causes a freeze
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
.definelabel LoadAnimation, 0x022BDEB4
.definelabel PlayAnimation, 0x022E35E4
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel UpdateDisplay, 0x02336F4C

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryActivateTrap, 0x0???????
;.definelabel DoTrapStealthRock, 0x0???????
;.definelabel LoadAnimation, 0x????????
;.definelabel PlayAnimation, 0x????????
;.definelabel ChangeStringTrap, 0x????????
;.definelabel TryCreateTrap, 0x????????

; Universal
.definelabel StealthRockTrapID, 0x14
.definelabel StealthRockAnimationID, 0x20D ; 525

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
        
        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        mov r10,#1
        
        ; Play Stealth Rock Animation
        ldr   r0,=StealthRockAnimationID
        bl    LoadAnimation
        mov   r1,r0
        and   r3,r1,#0xFF
        mov   r0,#0x2
        mov   r12,#0x0
        stmia sp,{r0,r12}
        sub   r0,r12,#0x1
        str   r0,[sp,#0x8]
        mov   r0,r4
        ldr   r1,=StealthRockAnimationID
        mov   r2,#0x1
        str   r12,[sp,#0xC]
        bl    PlayAnimation
                              ; I think I could get away with just moving
        mov r0,r9             ; the target into r4 because the function
        mov r1,r4             ; only uses r1, but it's called with both r0
        bl  DoTrapStealthRock ; and r1 being set, so I do this to match.
        
        ; Can we place a trap here?
        bl  CanPlaceTrapHere
        cmp r0,#0
        beq unallocate_memory
        
        ; Try to place a stealth rock trap
        add   r0,r4,#0x4            ; r0 = pointer to x/y
        mov   r1,StealthRockTrapID  ; r1 = trap id
        ldr   r2,[r9,#0xB4]         ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]          ; notably it just checks for the non
        cmp   r2,#0                 ; team member flag, so I guess traps
        movne r2,#2                 ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                 ; r3 = trap visible (bool)?
        bl    TryCreateTrap
        
        bl    UpdateDisplay
    unallocate_memory:
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close
