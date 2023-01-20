; ------------------------------------------------------------------------------
; Jawshoeuh 1/14/2023 - Confirmed Working 1/15/2023
; Topsy-Turvy switches all stat boosts. Buffs to attack become debuffs and
; same for all other stats. For the stat multipliers, I realized the bits
; needed to be reversed. Unfortunately this version of arm doesn't have
; rbit. So, I based the algorithm based upon
; https://github.com/hcs0/Hackers-Delight/blob/master/reverse.c.txt
; function rev11. That rev11 function is based on "an old algorithm by
; Christopher Strachey (Bitwise Operations. Communications of the ACM 4, 3
; (March 1961), 146)."
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel UpdateStatusIconFlags, 0x022E4464

; Universal
.definelabel FirstSpeedUpCounter, 0x114
.definelabel LastSpeedUpCounter, 0x118
.definelabel FirstSpeedDownCounter, 0x119 ; illegal immediate!
.definelabel FirstStatStage,0x24
.definelabel LastStatStage,0x2E
.definelabel FirstStatModifier,0x34
.definelabel LastStatModifier,0x40
.definelabel MaxStatMultiplier, 0x10000 ; 65536 (256.0)
.definelabel NormalStatMultiplier, 0x100

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r5,r6,r7

        ; Store monster stuff in r12
        ldr r12,[r4,#0xB4]
        
        ; init stat boost swap loop
        mov r2,FirstStatStage
    stat_boost_loop:
        ldrh r0,[r12,r2] ; load this stage
        mov  r1,#0x14    ; 20, the max it can go
        sub  r0,r1,r0    ; invert value
        strh r0,[r12,r2] ; store inverted value
        add  r2,r2,#0x2  ; increment loop
        cmp  r2,LastStatStage
        ble  stat_boost_loop
        
        ; init stat modifier loop
        mov r2,FirstStatModifier
        ldr r5,=#0xF0F0F0F0
        ldr r6,=#0xCCCCCCCC
        ldr r7,=#0xAAAAAAAA
    stat_modifier_loop:
        ldr r3,[r12,r2]
        cmp r3,MaxStatMultiplier
        movge r0,#1
        bge store_new_value   ; Read more about this part below.
        and r0,r3,#0xFF       ; x = x | ((x & 0xFF) << 16)
        orr r3,r3,r0, lsl #16
        and r0,r3,r5          ; x = (x & 0xF0F0F0F0) | ((x & 0x0F0F0F0F) << 8);
        and r1,r3,r5, lsr #4
        orr r3,r0,r1, lsl #8
        and r0,r3,r6          ; x = (x & 0xCCCCCCCC) | ((x & 0x33333333) << 4);
        and r1,r3,r6, lsr #2
        orr r3,r0,r1, lsl #4
        and r0,r3,r7          ; x = (x & 0xAAAAAAAA) | ((x & 0x55555555) << 2);zz
        and r1,r3,r7, lsr #1
        orr r3,r0,r1, lsl #2
        lsr r0,r3,#15         ; x = x >> 15, 15 to actually reverse
        lsl r0,r0,#1          ; need to shift left 1 cause its 17 bits
                              
        store_new_value: ; indented to show it's part of the loop
        str r0,[r12,r2]  ; store new modifier value
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
        pop r5,r6,r7
        b MoveJumpAddress
        .pool
    topsyturvy_str:
        .asciiz "[string:0]'s stat boosts were[R]switched!"
    .endarea
.close

; Unfortunately, there isn't an innate way to reverse the bits in the
; version of arm in use. So, I resort to using a specialized algorithm to
; invert the last 16 bits. However we actually need to invert 17 bits.
; Since we know the 17th bit is 0 (we check before), we just shift the
; result one to the left. We manually check if the value needs to be 1/256.