; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - WIP
; Relic Song deals damage and has 10% chance to sleep the target.
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
.definelabel SLEEP_TURN_RANGE, 0x022C4720
.definelbale CalcStatusDuration, 0x022EAB80

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel SLEEP_TURN_RANGE, 0x022C5078
;.definelabel CalcStatusDuration, 0x022EB530

; Universal
.definelabel SleepChance, 10

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
        
        ; Check for succesful hit.
        cmp   r0,#0
        movne r10,#1
        moveq r10,#0
        beq   MoveJumpAddress
        
        ; Check to snooze target.
        mov r0,r9
        mov r1,r4
        mov r2,SleepChance
        bl  RandomChanceUT
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Calculate nap time (turns of sleep).
        mov r0,r4
        ldr r1,=SLEEP_TURN_RANGE
        mov r2,#0x1 ; factor self curer iq/natural cure
        bl  CalcStatusDuration
        
        ; Attempt cause sleep.
        mov r2,r0
        mov r0,r9
        mov r1,r4
        mov r3,#0 ; no message if fail
        bl  Sleep
        
        b MoveJumpAddress
        .pool
    .endarea
.close