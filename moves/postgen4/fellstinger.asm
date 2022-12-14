; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 11/29/2022
; Fell Stinger deals damage and boosts attack if knocks out the target.
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x0022E0C94

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
        
        ;Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        
        ; Check if still alive.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,#0x0
        beq MoveJumpAddress
        
        ; Raise attack.
        mov r0,r9
        mov r1,r9
        mov r2,#0
        mov r3,#3
        bl AttackStatUp

        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close