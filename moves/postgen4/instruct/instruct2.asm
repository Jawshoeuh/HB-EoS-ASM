; ------------------------------------------------------------------------------
; Jawshoeuh 12/8/2022
; Instruct causes the target to use the first move it knows. Fails if
; the target is out of PP.
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
.definelabel UseMove, 0x0232145C

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel UseMove, 0x????????


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        mov r0,r4        ; r0 = monster
        mov r1,#0        ; r1 = move id
        mov r2,#1        ; r2 = unknown?
        mov r3,#0        ; r3 = unknown?
        str r3,[sp,#0x0] ; sp,0x0 = unknown
        bl UseMove
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close