; ------------------------------------------------------------------------------
; Jawshoeuh 3/22/2022 - WIP
; Revelation Dance deals damage equal to the first type of the user. It
; ignores Normalize, Pixilate, Refrigerate, Aerilate, and Galvanize. An
; extra small check is added to use the seconary type of the user if the
; first one is gonne (ie from Burn Up).
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
.definelabel GetMovePower, 0x0230231C
.definelabel GetMoveCritChance, 0x02013B10
.definelabel CalcDamage, 0x0230BBAC
.definelabel GetDamageSourceWrapper, 0x02324E44

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetMovePower, 0x02302D48
;.definelabel GetMoveCritChance, 0x02013BB8
;.definelabel CalcDamage, 0x0230C620
;.definelabel GetDamageSourceWrapper, 0x023258AC

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r5
        sub  sp,sp,#0x28
        
        ; Find and save primary type. If the primary type is None,
        ; grab the secondary type. If that is also None, the type
        ; is None.
        ldr    r0,[r9,#0xB4]
        ldrb   r5,[r0,#0x5E]
        cmp    r5,#0x0
        ldrbeq r5,[r0,#0x5F]
        
        ; Normal DealDamage things
        mov    r0,r9
        mov    r1,r8
        bl     GetMovePower
        mov    r10,r0
        mov    r0,r8
        bl     GetMoveCritChance
        str    r0,[sp,#0x0]   ; param 5
        add    r0,sp,#0x14
        mov    r1,#0x100
        stmib  sp,{r0,r1}     ; param 6,7
        ldrh   r1,[r8,#0x4]
        mov    r2,r5          ; param 3
        mov    r3,r10         ; param 4
        mov    r12,#0x1
        str    r1,[sp,#0xC]   ; param 8
        mov    r0,r9          ; param 1
        mov    r1,r4          ; param 2
        str    r12,[sp,#0x10] ; param 9
        bl     CalcDamage
        mov    r0,r8
        mov    r1,r7
        bl     GetDamageSourceWrapper
        str    r0,[sp,#0x0]
        mov    r0,r9
        mov    r1,r4
        mov    r2,r8
        add    r3,sp,#0x14
        bl     PerformDamageSequence
        
        cmp    r0,#0x0
        moveq  r10,#0x0
        movne  r10,#0x1
        
        add sp,sp,#0x28
        pop r5
        b MoveJumpAddress
        .pool
    .endarea
.close
