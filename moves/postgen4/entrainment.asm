; ------------------------------------------------------------------------------
; Jawshoeuh 12/2/2022 - Confirmed Working 12/23/2022
; Entrainment changes the target's ability to match the user's.
; While Adex-8x's version will function identically most of the time,
; this one checks for Truant, Trace, Forecast, and Flower Gift
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
.definelabel AbilityEndStatuses, 0x022FA7DC
.definelabel FlowerGiftAbilityID, 0x71 ; 113
.definelabel ForecastAbilityID, 0x25 ; 37
.definelabel TraceAbilityID, 0x28 ; 40
.definelabel TruantAbilityID, 0x2A ; 42

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryEndStatuses, 0x????????
;.definelabel FlowerGiftAbilityID, 0x71 ; 113
;.definelabel ForecastAbilityID, 0x25 ; 37
;.definelabel TraceAbilityID, 0x28 ; 40
;.definelabel TruantAbilityID, 0x2A ; 42


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area

        ; Check for Truant Ability
        mov r0,r4
        mov r1,TruantAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability_truant

        ; Check for Flower Gift Ability
        mov r0,r9
        mov r1,FlowerGiftAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability
        
        ; Check for Forecast Ability
        mov r0,r9
        mov r1,ForecastAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability
        
        ; Check for Trace
        mov r0,r9
        mov r1,TraceAbilityID
        bl  HasAbility
        cmp r0,#0
        bne failed_ability
        
        ; Load our abilities.
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0x60]
        ldrb r2,[r0,#0x61]
        ; Give our abilities.
        ldr  r3,[r4,#0xb4]
        strb r1,[r3,#0x60]
        strb r2,[r3,#0x61]
        ; Set flag for dungeon to activate artificial weather abilities.
        mov   r0,#0x1
        ldr   r1,=DungeonBaseStructurePtr
        ldrsh r2,[r1,#0x0]
        strb  r0,[r2,#0xe]
        
        ; Log ability change.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl ChangeString ; Target
        mov r0,r9
        ldr r1,=entrainment_str
        bl SendMessageWithStringLog
        mov r10,#1
        
        ; Mark that a move was used on the target.
        ldr    r3,[r4,#0xB4]
        ldrb   r0,[r3,#0x108]
        cmp    r0,#0x0
        moveq  r0,#0x1
        streqb r0,[r3,#0x108]
        
        ; Double check if this new ability would end statuses.
        mov  r0,r9
        mov  r1,r4
        bl   AbilityEndStatuses
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_ability:
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString
        ldr r1,=failed_entrainment_str
        mov r0,r4
        bl SendMessageWithStringLog
        mov r10,#0
        
        b MoveJumpAddress

    failed_ability_truant:
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        ldr r1,=failed_entrainment_truant_str
        mov r0,r4
        bl SendMessageWithStringLog
        
        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    entrainment_str:
        .asciiz "[string:0] shared its ability[R]with [string:1]"
    failed_entrainment_truant_str:
        .asciiz "[string:0]'s Truant ability[R]can't be changed!"
    failed_entrainment_str:
        .asciiz "[string:0]'s ability can't be shared!"
    .endarea
.close
