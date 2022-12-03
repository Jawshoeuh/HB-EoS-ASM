; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Confirmed Working 12/2/2022
; Actually changes the target's ability to Insomnia instead of
; applying the sleepless status. Even properly doesn't apply it
; to Pokemon with the ability Truant! In Gen5+ the move fails
; on Pokemon with the ability Insomnia, but I don't see a reason
; to add a fail message for it.
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
.definelabel ChangeStringAbility, 0x0234B084
.definelabel InsomniaFailedStr, 0xF13
.definelabel InsomniaAbiilityID, 0x36 ; 54
.definelabel TruantAbilityID, 0x2A ; 40
.definelabel TryWakeUp, 0x02305FDC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel ChangeStringAbility, 0x????????
;.definelabel InsomniaFailedStr, 0x???
;.definelabel InsomniaAbiilityID, 0x36 ; 54
;.definelabel TruantAbilityID, 0x2A ; 40
;.definelabel TryWakeUp, 0x????????


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area

        ; Check for Truant Ability
        mov r0,r4
        mov r1,TruantAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability

        ; Change Ability To Insomnia
        ldr  r0,[r4,#0xb4]
        mov  r1,InsomniaAbiilityID
        mov  r2,#0x0       ; Ability 0 = None
        strb r1,[r0,#0x60] ; First Ability -> Insomnia
        strb r2,[r0,#0x61] ; Secon Ability -> None
        
        ; Log ability change.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        mov r0,r9
        ldr r1,=worryseed_str
        bl SendMessageWithStringLog
        
        ; Check If Asleep (This section is similar to
        ; DoMoveWakeUpSlap @ 0x0232E400)
        ldr   r0,[r4,#0xb4]
        ldrb  r1,[r0,#0xbd] ; IsAsleep?
        cmp   r1,#1
        cmpne r1,#3
        cmpne r1,#5
        mov   r10,#1
        bne MoveJumpAddress
        
        ; THOU SHALL NOT SLEEP (Wake Up Target... I think?)
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        str r2,[sp,#0x0]
        bl  TryWakeUp

        mov r10,#1
        b MoveJumpAddress

    failed_ability: ; Based off of original Worry Seed
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        mov r0,#1
        mov r1,TruantAbilityID
        bl ChangeStringAbility
        ldr r2,=InsomniaFailedStr
        mov r0,r9
        mov r1,r4
        bl SendMessageWithIDCheckUTLog

        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    worryseed_str:
        .asciiz "[string:0]'s ability became Insomnia!" 
    .endarea
.close
