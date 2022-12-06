; ------------------------------------------------------------------------------
; Jawshoeuh 12/5/2022
; This reworked spikes activates the trap below the target. So
; that it is a damgaing move like in PLA. If a trap can't be placed
; (like in hallways), call the effect directly on the target.
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
.definelabel DoTrapSpike, 0x0230D11C
.definelabel ChangeStringTrap, 0x22EDF5C
.definelabel TryCreateTrap, 0x022EDCBC
.definelabel SpikeDamagePtr, 0x022C4418
.definelabel SpikeTrapID, 0x13

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CanPlaceTrapHere, 0x???????? ; loads fixed room properties?
;.definelabel TryActivateTrap, 0x0???????
;.definelabel DoTrapSpike, 0x0???????
;.definelabel ChangeStringTrap, 0x????????
;.definelabel TryCreateTrap, 0x????????
;.definelabel SpikeTrapID, 0x13


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
        beq failed_trap_place
        
        ; Try to place a spike trap
        add   r0,r4,#0x4            ; r0 = pointer to x/y
        mov   r1,SpikeTrapID  ; r1 = trap id
        ldr   r2,[r9,#0xb4]         ; r2 = trap alignment
        ldrb  r2,[r2,#0x6]          ; notably it just checks for the non
        cmp   r2,#0                 ; team member flag, so I guess traps
        movne r2,#2                 ; placed by allied NPCs can hurt us?
        moveq r2,#1
        mov   r3,#1                 ; r3 = trap visible (bool)?
        bl TryCreateTrap
        
        ; Activate trap if possible so it's definitely visible.
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
        ; Manually say a spike trap was activated!
        mov r0,#0
        mov r1,SpikeTrapID
        bl  ChangeStringTrap
        mov r0,r4
        mov r1,SpikeTrapID
        add r1,r1,#0x51
        add r1,r1,#0xb00
        bl  SendMessageWithIDCheckULog
        
        ldr   r0,=SpikeDamagePtr
        ldr   r3,=#0x022EF474 ; r3 = unknown
        ldrsh r1,[r0,#0x0]    ; r1 = Damage (20 by default)
        mov   r0,r4           ; r0 = Target
        mov   r2,#0xa         ; r2 = unknown
        bl    DoTrapSpike
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close
