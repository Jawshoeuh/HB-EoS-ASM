; ------------------------------------------------------------------------------
; Jawshoeuh 12/1/2022 - Confirmed Working 12/1/2022
; Fillet Away empties the users belly (like belly drum) and boosts
; attack, special attack, and speed by 2 stages. This function is based
; on DoMoveBellyDrum @ 0x0232AC54 (NA)
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
.definelabel IntToFixedPoint, 0x02050ff8
.definelabel CeilFixedPoint, 0x02051064
.definelabel BellyTooLowStr, 0xEEB

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DecToFixedPoint, 0x????????
;.definelabel CeilFixedPoint, 0x0205139C
;.definelabel BellyTooLowStr, 0x???


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Get Belly Values
        ldr  r2,[r4,#0xb4]
        sub  r3,sp,#0x4 ; Allocate space on stack
        add  r2,r2,#0x100
        ldrh r1,[r2,#0x46] ; Belly, integer
        strh r1,[r3,#0x0]
        ldrh r0,[r2,#0x48] ; Belly, decimal
        strh r0,[r3,#0x2]
        ldr  r0,[r3,#0x0]
        bl CeilFixedPoint
        cmp  r0,#1
        ble failed_belly_empty
        
        ; Raise attack.
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#2
        bl AttackStatUp
        
        ; Raise special attack.
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#2
        bl AttackStatUp
        
        ; Raise speed 
        mov r3,#0
        str r3,[sp,#0x0] ; Put fail message num on stack
        mov r0,r9
        mov r1,r4
        mov r2,#2
        mov r3,#0 ; default turns
        bl SpeedStatUp
        
        ; Lower belly to 1. Identical implementation to original
        ; belly drum, but I suspect this can be done by manually putting
        ; the result into the registers since the result of the 
        ; function will always be the same.
        mov  r0,#1
        bl   IntToFixedPoint
        strh r0,[sp,#0x0]
        mov  r0,r0, lsr #0x10 ; Right shift by 16
        strh r0,[sp,#0x2]
        ldrh r2,[sp,#0x0]
        ldrh r1,[sp,#0x2]
        ldr  r3,[r4,#0xb4]
        add  r3,r3,#0x100
        strh r2,[r3,#0x46]
        strh r1,[r3,#0x48]
        
        mov r10,#1
        b MoveJumpAddress
        
    failed_belly_empty:
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl ChangeString
        ldr r2,=BellyTooLowStr
        mov r0,r9
        mov r1,r4
        bl SendMessageWithIDCheckUTLog
        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close