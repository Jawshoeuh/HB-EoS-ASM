; ------------------------------------------------------------------------------
; Jawshoeuh 12/7/2022 - Confirmed Working 12/7/2022
; Topsy-Turvy switches all stat boosts. Buffs to attack become
; debuffs, defense buffs become debuff... etc. However, I can't
; find a single move that raises the stat modifiers. While it does
; work in the damage calculation formula, using this move on
; a pokemon at 1/256 attack and changing that to 256x is going to
; hurt a lot.
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
.definelabel UpdateStatusIconFlags, 0x022E3AB4
.definelabel FirstSpeedUpCounter, 0x114
.definelabel LastSpeedUpCounter, 0x118
.definelabel FirstSpeedDownCounter, 0x119 ; illegal immediate!
.definelabel FirstStatStage,0x24
.definelabel LastStatStage,0x2E
.definelabel FirstStatModifier,0x34
.definelabel LastStatModifier,0x40
.definelabel MaxStatMultiplier, 0x10000 ; 65536

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel UpdateStatusIconFlags, 0x022E4464
;.definelabel FirstSpeedUpCounter, 0x114
;.definelabel LastSpeedUpCounter, 0x118
;.definelabel FirstSpeedDownCounter, 0x119
;.definelabel FirstStatStage,0x24
;.definelabel LastStatStage,0x2E
;.definelabel FirstStatModifier,0x34
;.definelabel LastStatModifier,0x40
;.definelabel MaxStatMultiplier, 0x10000 ; 65536


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Store monster stuff in r12
        ldr r12,[r4,#0xb4]
        
        ; init stat boost swap loop
        mov r2,FirstStatStage
    stat_boost_loop:
        ldrh r0,[r12,r2] ; load this stage
        mov  r1,#0x14    ; 20, the max it can go
        sub  r0,r1,r0    ; invert value
        strh r0,[r12,r2] ; store inverted value
        add  r2,r2,#0x2     ; increment loop
        cmp  r2,LastStatStage
        ble  stat_boost_loop
        
        ; init stat modifier loop
        mov r2,FirstStatModifier
    stat_modifier_loop:
        ldr r0,[r12,r2]
        mov r1,MaxStatMultiplier
        new_modifier_calc_loop: ; See bottom of file for detailed
            cmp   r0,#0x1       ; description of this loop.
            lsr   r0,r0,#0x1 ; divide by 2
            lsrgt r1,r1,#0x1 ; divide by 2
            bgt   new_modifier_calc_loop
        str r1,[r12,r2] ; store new modifier value
        add r2,r2,#0x4
        cmp r2,LastStatModifier
        ble stat_modifier_loop
        
        ; init speed swap loop
        mov r2,FirstSpeedUpCounter
        mov r3,#0x1
        add r3,r3,#0x118 ; workaround because 0x119 not allowed immediate
    speed_swap_loop:
        ldrb r0,[r12,r2] ; Load Speed Up
        ldrb r1,[r12,r3] ; Load Speed Down
        strb r0,[r12,r3] ; Store Speed Up Into Speed Down
        strb r1,[r12,r2] ; Store Speed Down into Speed Up
        add  r2,r2,#1 ; increment loop
        add  r3,r3,#1 ; increment loop
        cmp  r2,LastSpeedUpCounter
        ble  speed_swap_loop
        
        ; Update entity status.
        mov r0,r4
        bl UpdateStatusIconFlags
        
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        mov r0,r4
        ldr r1,=topsyturvy_str
        bl SendMessageWithStringLog
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    topsyturvy_str:
        .asciiz "[string:0]'s stat boosts were[R]switched!"
    .endarea
.close

; The new_modifier_calc_loop takes the current multiplier and the
; max multiplier. It divides both by two until the original multiplier
; is 0x1. For example, with the default 0x100 (0b100000000) gets divided
; by 2 until it equals 0x1 (0b1). While this is going on, the max
; multiplier has been divided by 2 eight times (in other words divided
; by 2^8. 35536/(2^8) = 256 = 0x100. If the smallest value of 0x1,
; the new value will be the max. 