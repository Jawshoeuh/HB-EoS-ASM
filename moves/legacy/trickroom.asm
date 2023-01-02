; ------------------------------------------------------------------------------
; Jawshoeuh 12/6/2022 - Confirmed Working 12/6/2022
; Trick Room swaps the speeds of all afffected monsters. Monsters
; with speed boosts become slow and slowed monsters become fast.
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
.definelabel CalcSpeedStage, 0x022FFDF4
.definelabel UpdateStatusIconFlags,0x022E3AB4

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel CalcSpeedStage, 0x02300820
;.definelabel UpdateStatusIconFlags, 0x022E4464


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ldr r12,[r4,#0xB4]
        
        ; Swap First Speed Up/Down Counters
        ldrb r0,[r12,#0x114]
        ldrb r1,[r12,#0x119]
        strb r0,[r12,#0x119]
        strb r1,[r12,#0x114]
        
        ; Swap Second Speed Up/Down Counters
        ldrb r0,[r12,#0x115]
        ldrb r1,[r12,#0x11A]
        strb r0,[r12,#0x11A]
        strb r1,[r12,#0x115]
        
        ; Swap Third Speed Up/Down Counters
        ldrb r0,[r12,#0x116]
        ldrb r1,[r12,#0x11B]
        strb r0,[r12,#0x11B]
        strb r1,[r12,#0x116]
        
        ; Swap Fourth Speed Up/Down Counters
        ldrb r0,[r12,#0x117]
        ldrb r1,[r12,#0x11C]
        strb r0,[r12,#0x11C]
        strb r1,[r12,#0x117]
        
        ; Swap Fifth Speed Up/Down Counters
        ldrb r0,[r12,#0x118]
        ldrb r1,[r12,#0x11D]
        strb r0,[r12,#0x11D]
        strb r1,[r12,#0x118]
        
        ; Recalculate new speed stage.
        mov r0,r4
        mov r1,#1
        bl  CalcSpeedStage
        
        mov r0,r4
        bl  UpdateStatusIconFlags
        
        ; When swapping own speed, display message.
        ; This is done so the message is only seen once.
        cmp r9,r4
        mov r10,#1
        bne MoveJumpAddress
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  ChangeString
        mov r0,r9
        ldr r1,=trickroom_str
        bl  SendMessageWithStringLog
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    trickroom_str:
        .asciiz "[string:0] twisted the dimensions!"
    .endarea
.close