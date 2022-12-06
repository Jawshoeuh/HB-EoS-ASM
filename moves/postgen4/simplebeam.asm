; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Confirmed Working 12/2/2022
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

        ; Check for Truant Ability
        mov r0,r4
        mov r1,TruantAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability

        ; Change Ability To Simple
        ldr  r0,[r4,#0xb4]
        mov  r1,SimpleAbilityID
        mov  r2,#0x0       ; Ability 0 = None
        strb r1,[r0,#0x60] ; First Ability -> Simple
        strb r2,[r0,#0x61] ; Secon Ability -> None
        
        ; Log ability change.
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        mov r0,r9
        ldr r1,=simplebeam_str
        bl SendMessageWithStringLog
        mov r10,#1

        b MoveJumpAddress

    failed_ability:
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        ldr r1,=failed_simplebeam_str
        mov r0,r4
        bl SendMessageWithStringLog

        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    simplebeam_str:
        .asciiz "[string:0]'s ability became Simple!"
    failed_simplebeam_str:
        .asciiz "[string:0]'s Truant ability[R]prevents Simple!"
    .endarea
.close