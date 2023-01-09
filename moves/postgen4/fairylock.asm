; ------------------------------------------------------------------------------
; Jawshoeuh 1/9/2023 - WIP
; Fairy Lock is kinda weird. My PMD interpretation will inflict 
; Shadow Hold for 1 turn, but it's intended to be used on an entire room.
; So... maybe not a useful interpretation but...
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
        
        ; Immobilize the target.
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; yes, failure message
        bl  Immobilize
        cmp r0,#0
        mov r10,#1
        beq MoveJumpAddress
        
        ; Modify turn count. The reason I modify the value post-function
        ; call is so that if anyone has patches that give ghost types
        ; immunity to shadow hold, it will still work :).
        ldr  r12,[r4,#0xB4]
        strb r10,[r12,#0xCC] ; set turns of immobilize to 1
        
        b MoveJumpAddress
        .pool
    .endarea
.close