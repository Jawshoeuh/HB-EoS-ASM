; ------------------------------------------------------------------------------
; Jawshoeuh 12/8/2022 - Confirmed Working 12/10/2022
; Instruct causes the target to use the first move it knows. Fails if
; the target's first move is out of PP or conditions that stop the
; first move from being used. This Instruct is by far the easiest,
; but also the most technically boring and my least favorite.
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
.definelabel TryUseMove, 0x0232145C

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
       
        ; Make sure move the move we are not instructing is not instruct.
        ; Without this check, it would be possible to create a softlock
        ; by having Pokemon infinitely chain instructs on each other.
        ldr  r0,[r4,#0xb4]
        add  r1,r0,#0x100
        ldrh r1,[r1,#0x28] ; Target Move 1 ID (0x128)
        ldrh r2,[r8,#0x4]  ; This Move ID
        cmp r1,r2
        moveq r10,#0
        beq MoveJumpAddress
        
        mov r0,r4        ; r0 = monster
        mov r1,#0        ; r1 = move slot #
        mov r2,#1        ; r2 = unknown?
        mov r3,#0        ; r3 = unknown?
        str r3,[sp,#0x0] ; sp,0x0 = unknown
        bl TryUseMove
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close