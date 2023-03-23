; ------------------------------------------------------------------------------
; Jawshoeuh 12/12/2022 - Confirmed Working 3/22/2023
; Dragon Tail deals damage and then does the blowback effect like Roar.
; This implementation should function identically to Adex-8x's but
; this doesn't use the stack.
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
.definelabel TryBlowAway, 0x0231FDE0
.definelabel EntityIsValid, 0x22E0354

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryBlowAway, 0x02320848
;.definelabel EntityIsValid, 0x0022E0C94

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
        
        ; Damage enemy.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0, #0x0
        mov r10,#0x0
        beq unallocate_memory
        mov r10,#0x1
        
        ; Check both targets are still alive.
        mov r0,r9
        mov r1,r4
        mov r2,#0x0 ; Guaranteed
        bl  RandomChanceUT
        cmp r0,#0x0
        beq unallocate_memory
        
        ; Uh? Yeet (throw) the target?
        mov  r0,r9
        mov  r1,r4
        ldr  r2,[r9,#0xB4]
        ldrb r2,[r2,#0x4C]
        bl TryBlowAway
        
    unallocate_memory:
        add sp,sp,#0x4
        b MoveJumpAddress
        .pool
    .endarea
.close