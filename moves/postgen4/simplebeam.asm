; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Confirmed Working 12/23/2022
; Chanegs the target's ability to Simple. Adex-8x's implementaion
; will function identically most of the time, but this one check for
; fails on Truant. It should also fail when the ability is already
; Simple, but this is not neccessary.
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
.definelabel SimpleAbilityID, 0x61 ; 97
.definelabel TruantAbilityID, 0x2A ; 40

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel SimpleAbilityID, 0x61 ; 97
;.definelabel TruantAbilityID, 0x2A ; 40

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Preemptively substitute target into slot 1.
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  ChangeString

        ; Check for Truant Ability
        mov r0,r4
        mov r1,TruantAbilityID
        bl  HasAbility
        cmp r0,#0
        beq success
        
        ; Failed!
        ldr r1,=failed_simplebeam_str
        mov r0,r4
        bl  SendMessageWithStringLog

        mov r10,#0
        b MoveJumpAddress
        
    success:
        ldr r1,=simplebeam_str
        mov r0,r4
        bl  SendMessageWithStringLog

        ; Change Ability To Simple
        ldr  r0,[r4,#0xB4]
        mov  r1,SimpleAbilityID
        mov  r2,#0x0       ; Ability 0 = None
        strb r1,[r0,#0x60] ; First Ability -> Simple
        strb r2,[r0,#0x61] ; Secon Ability -> None
        
        ; Log ability change.
        mov r0,r4
        ldr r1,=simplebeam_str
        bl  SendMessageWithStringLog
        
        ; I don't know why, but Skill Swap/Role Play does this to the
        ; user so they give more XP. Why? I don't know?
        ldr    r3,[r9,#0xB4]
        ldrb   r0,[r3,#0x108]
        cmp    r0,#0x0
        moveq  r0,#0x1
        streqb r0,[r3,#0x108]
        
        ; Normally, you would call 022FA7DC after changing an ability, but
        ; because we know Simple isn't going to remove any statuses
        ; (for example, Own Tempo stopping confusion) I just don't bother.
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    simplebeam_str:
        .asciiz "[string:1]'s ability became Simple!"
    failed_simplebeam_str:
        .asciiz "[string:1]'s Truant ability[R]prevents Simple!"
    .endarea
.close
