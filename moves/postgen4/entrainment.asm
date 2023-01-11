; ------------------------------------------------------------------------------
; Jawshoeuh 12/2/2022 - WIP
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel AbilityEndStatuses, 0x????????

; Universal
.definelabel FlowerGiftAbilityID, 0x71 ; 113
.definelabel ForecastAbilityID, 0x25 ; 37
.definelabel TraceAbilityID, 0x28 ; 40
.definelabel TruantAbilityID, 0x2A ; 42

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Preemptively substitute strings.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl ChangeString ; Target

        ; Check for Truant manually since we don't want to accidentally
        ; share it even if it is suppressed by Gastro Acid!
        ldr   r3,[r4,#0xB4]
        ldrb  r1,[r3,#0x60]
        ldrb  r2,[r3,#0x61]
        cmp   r1,TruantAbilityID
        cmpne r2,TruantAbilityID
        beq   failed_ability_truant

        ; Check abilities manually since we don't want to accidentally
        ; share illegal abilities if the ability is suppresed.
        ; Load our abilities.
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0x60]
        ldrb r2,[r0,#0x61]
        
        ; Check for illegal abilities.
        cmp   r1,FlowerGiftAbilityID
        cmpne r1,ForecastAbilityID
        cmpne r1,TraceAbilityID
        cmpne r2,FlowerGiftAbilityID
        cmpne r2,ForecastAbilityID
        cmpne r2,TraceAbilityID
        beq   failed_ability ; failed, banned entrainment ability!
        
        ; Give our abilities.
        strb r1,[r3,#0x60]
        strb r2,[r3,#0x61]
        
        ; Set flag for dungeon to check artificial weather abilities.
        mov   r0,#0x1
        ldr   r1,=DungeonBaseStructurePtr
        ldrsh r2,[r1,#0x0]
        strb  r0,[r2,#0xe]
        
        ldr r2,=entrainment_str
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithStringCheckUTLog
        
        ; Double check if this new ability would end statuses.
        mov r0,r9
        mov r1,r4
        bl  AbilityEndStatuses
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_ability:
        ldr r2,=failed_entrainment_str
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithStringCheckUTLog
        
        mov r10,#0
        b MoveJumpAddress

    failed_ability_truant:
        ldr r2,=failed_entrainment_truant_str
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithStringCheckUTLog
        
        mov r10,#0
        b MoveJumpAddress
        .pool
    entrainment_str:
        .asciiz "[string:0] shared its ability[R]with [string:1]"
    failed_entrainment_truant_str:
        .asciiz "[string:1]'s Truant ability[R]can't be changed!"
    failed_entrainment_str:
        .asciiz "[string:0]'s abilities can't be shared!"
    .endarea
.close
