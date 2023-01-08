; ------------------------------------------------------------------------------
; Jawshoeuh 1/7/2023 - Confirmed Working 1/8/2023
; Clangorous Soul boosts all stats (except evasion/accuracy) and costs
; 1/3 of the players health. Is a sound move, so check for Soundproof.
; Also a minor abuse of fixed point multiplication to divide by 3. This
; could maybe lead to a problem? But it worked fine in my testing.
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
;.definelabel UpdateStatusIconFlags, 0x22E4464

; Universal
.definelabel SoundproofAbilityID, 0x3C ; 60
.definelabel SoundproofStrID, 0xEB9 ; 3769

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Fail if the target has Soundproof. But the target the user... How
        ; would you naturally get this interaction? HOW. You have to go
        ; out of your way to do this.
        mov r0,r4
        mov r1,SoundproofAbilityID
        bl  HasAbility
        cmp r0,#0
        mov r10,#0
        bne failed_soundproof
        
        ; Calculate Health
        ldr   r12,[r4,#0xB4]
        ldrsh r1,[r12,#0x12]
        ldrsh r2,[r12,#0x16]
        ldrsh r3,[r12,#0x10]  ; Current HP
        add   r1,r1,r2        ; Max HP
        
        ldr   r2,=div3_magic_number
        ldr   r2,[r2]
        umull r10,r0,r1,r2
        subs  r3,r3,r0
        bgt   success
        
        ; FAILED, HEALTH TOO LOW
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; User
        mov r0,r4
        ldr r1,=clangoroussoul_fail_str
        bl  SendMessageWithStringLog
        b MoveJumpAddress
        
    success:
        mov r10,#1
        ; Simply set our health lower and update.
        strh r3,[r12,#0x10]
        mov  r0,r4
        bl   UpdateStatusIconFlags
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        bl AttackStatUp
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#1
        bl  AttackStatUp
        
        ; Raise defense.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        bl  DefenseStatUp
        
        ; Raise special defense.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#1
        bl  DefenseStatUp
        
        ; Raise speed
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#1
        bl  SpeedStatUpOneStage
        
        ; Health cut message.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; User
        mov r0,r4
        ldr r1,=clangoroussoul_pass_str
        bl  SendMessageWithStringLog
        b MoveJumpAddress   
        
    failed_soundproof:
        mov r0,#1
        mov r1,r9
        mov r2,#0
        bl  ChangeString ; Sub Target
        
        ; Display soundproof msg.
        ldr r2,=SoundproofStrID
        mov r0,r4
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        
        b MoveJumpAddress
        .pool
    div3_magic_number:
        .word 1431655766 ; Fixed point multiplication number
    clangoroussoul_pass_str:
        .asciiz "[string:0] cut its health by a third!" 
    clangoroussoul_fail_str:
        .asciiz "But [string:0] didn't have enough health!" 
    .endarea
.close