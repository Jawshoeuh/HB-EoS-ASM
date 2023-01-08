; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - Confirmed Working 1/8/2023
; Relic Song deals damage and has 10% chance to sleep the target. Lots of
; work behind scenes because Relic song is a sound based move.
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
.definelabel CalcStatusDuration, 0x022EAB80

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel SLEEP_TURN_RANGE, 0x022C5078
;.definelabel CalcStatusDuration, 0x022EB530

; Universal
.definelabel SleepChance, 10
.definelabel SoundproofAbilityID, 0x3C ; 60
.definelabel SoundproofStrID, 0xEB9 ; 3769

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; There is a list of sound moves in the base game. A skypatch could
        ; be added to make a specific move id return positive, but this
        ; is more useful ease of use across multiple hacks. Before we do
        ; anything, check if the target has soundproof.
        mov r0,r4
        mov r1,SoundproofAbilityID
        bl  HasAbility
        cmp r0,#0
        mov r10,#0
        bne failed_soundproof

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
        cmp r0,#0
        beq MoveJumpAddress
        mov r10,#1
        
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
        mov r2,#1 ; factor self curer iq/natural cure
        bl  CalcStatusDuration
        
        ; Attempt to snooze target.
        mov r2,r0
        mov r0,r9
        mov r1,r4
        mov r3,#0 ; no message if fail
        bl  Sleep
        
        b MoveJumpAddress   
    failed_soundproof:
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; Sub Target
        
        ; Display soundproof msg.
        ldr r2,=SoundproofStrID
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        
        b MoveJumpAddress
        .pool
    .endarea
.close