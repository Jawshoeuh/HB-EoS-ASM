; ------------------------------------------------------------------------------
; Jawshoeuh 12/31/2022 - WIP
; Trick Room swaps the speeds of all afffected monsters. Monsters
; with speed boosts become slow and slowed monsters become fast. This is
; intended to be used on everyone in a room or floor. If you plan on
; repurposing this for a single target, comment out line 62. There is
; a less optimal version in the legacy folder.
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
        
        ; I got the idea to load and store multiple at once by viewing
        ; Adex-8x's speed swap.
        ; Load Speed Up Counters
        ldr  r0,[r12,#0x114]
        ldrb r1,[r12,#0x118]
        
        ; Load Speed Down Counters
        ldr  r2,[r12,#0x119]
        ldrb r3,[r12,#0x11D]
        
        ; Store Speed Down -> Speed Up
        str  r2,[r12,#0x114]
        strb r3,[r12,#0x118]
        
        ; Store Speed Up -> Speed Down
        str  r0,[r12,#0x119]
        strb r1,[r12,#0x11D]
        
        ; Recalculate new speed stage.
        mov r0,r4
        mov r1,#1
        bl  CalcSpeedStage
        
        mov r0,r4
        bl UpdateStatusIconFlags
        
        ; When swapping own speed, display message.
        ; This is done so the message is only seen once.
        cmp r9,r4
        mov r10,#1
        bne MoveJumpAddress
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString
        mov r0,r9
        ldr r1,=trickroom_str
        bl SendMessageWithStringLog
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    trickroom_str:
        .asciiz "[string:0] twisted the dimensions!"
    .endarea
.close