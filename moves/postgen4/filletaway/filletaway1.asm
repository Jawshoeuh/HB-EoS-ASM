; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Confirmed Working 12/1/2022
; Fillet Away deals 1/2 max health damage to the user and boosts
; attack, special attack, and speed by 2 stages.
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Calculate Health
        ldr   r0,[r9,#0xb4]
        ldrsh r1,[r0,#0x12]
        ldrsh r2,[r0,#0x16]
        ldrsh r0,[r0,#0x10] ; Current HP
        add r1,r1,r2        ; Max HP
        
        ; Check if recoil higher than current health.
        lsr r1,r1,#1 ; Max HP / 2
        cmp r1,r0
        bge failed_recoil
        
        ;Damage self
        mov r0,r9
        mov r2,#0
        mov r3,#0
        bl ConstDamage
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#2
        bl AttackStatUp
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#2
        bl AttackStatUp
        
        ; Raise speed 
        mov r3,#0
        str r3,[sp,#0x0] ; Put fail message num on stack
        mov r0,r9
        mov r1,r4
        mov r2,#2
        mov r3,#6 ; 6 turns like PSMD
        bl SpeedStatUp
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_recoil:
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; User
        mov r0,r4
        ldr r1,=filletaway_str
        bl  SendMessageWithStringLog
        
        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    filletaway_str:
        .asciiz "But [string:0] didn't have enough health!" 
    .endarea
.close