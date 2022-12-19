; ------------------------------------------------------------------------------
; Jawshoeuh 12/19/2022 - Confirmed Working 12/19/2022
; An example of a fixed damage move.
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
.definelabel GetMoveCategory, 0x020151C8
.definelabel GetMoveType, 0x02013864
.definelabel CalcDamageFixedWrapper, 0x0230D3F4
.definelabel GetFaintReasonWrapper, 0x02324E44
.definelabel FixedDamage, 50

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetMoveCategory, 0x02015270
;.definelabel GetMoveType, 0x0201390C
;.definelabel CalcDamageFixedWrapper, 0x2030DE68
;.definelabel GetFaintReasonWrapper, 0x02324E44
;.definelabel FixedDamage, 50


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Get move type.
        sub sp,sp,#0x20
        mov r0,#0
        strb r0,[sp,#0x1C]
        mov r0,r8
        bl GetMoveType
        mov r3,r0
        add r0,sp,#0x1C
        stmia sp,{r0,r3}

        ; Get move category
        ldrh r0,[r8,#0x4]
        bl GetMoveCategory
        str r0,[sp,#+0x8]

        ; Get faint reason (if move knocks out)
        mov r0,r8
        mov r1,r7
        bl GetFaintReasonWrapper
        str r0,[sp,#0xC]
        
        ; Prepare calcdamagefixedwrapper
        mov r3,#0x1
        mov r2,#0x0
        str r2,[sp,#0x10]
        str r3,[sp,#0x14]
        str r2,[sp,#0x18]
        mov r2, FlatDamage
        mov r1,r4
        mov r0,r9
        bl CalcDamageFixedWrapper

        ; return success/failure
        ldrb r0,[sp]
        cmp r0,#0x0
        moveq r10,#0x1
        movne r10,#0x0
        add sp,sp,#0x20
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close