; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - WIP
; Flower Shield raises the defense of grass type Pokemon! I'm not sure why
; anyone would ever want to use this move to be honest?
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

; Universal
.definelabel GrassTypeID, 4

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Find target type.
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        cmp   r0,GrassTypeID
        cmpne r1,GrassTypeID
        mov   r10,#0
        bne   MoveJumpAddress ; failed, not a grass type
        
        ; Raise defense.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; defense
        mob r3,#1 ; 1 stage
        bl DefenseStatUp
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    .endarea
.close