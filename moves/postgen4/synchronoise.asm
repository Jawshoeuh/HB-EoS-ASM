; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - WIP
; Synchronoise only deals damage if the user and target share a type.
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Get User Types
        ldr   r12,[r9,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        
        ; Get Target Types
        ldr   r10,[r4,#0xB4]
        ldrb  r2,[r10,#0x5E]
        ldrb  r3,[r10,#0x5F]
        
        ; Check first type.
        cmp   r0,#0
        beq   check_second_type
        cmp   r0,r2
        cmpne r0,r3
        beq   target_shares_type
        
    check_second_type:
        cmp   r1,#0
        mov   r10,#0
        beq   MoveJumpAddress ; failed, no secondary type
        cmp   r1,r2
        cmpne r1,r3
        bne   MoveJumpAddress ; failed, no match found
        
    target_shares_type: ; Deal like damage or something man.
        sub sp,sp,#0x4
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        add sp,sp,#0x4
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    .endarea
.close