; ------------------------------------------------------------------------------
; Jawshoeuh 12/12/2022 - Confirmed Working 12/13/2022
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryBlowAway, 0x02320848

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Damage enemy.
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0, #0
        mov r10,#0
        beq MoveJumpAddress
        
        ; Check if still alive.
        ldr  r0,[r4,#0xb4]
        ldrh r0,[r0,#0x10]
        cmp  r0,#0
        ble  MoveJumpAddress
        
        ; Uh? Yeet (throw) the target?
        mov  r0,r9
        mov  r1,r4
        ldr  r2,[r9,#0xb4]
        ldrb r2,[r2,#0x4c]
        bl TryBlowAway
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close