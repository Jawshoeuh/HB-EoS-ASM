; -------------------------------------------------------------------------
; Jawshoeuh 08/10/2023 - Confirmed Working 11/12/2024
; Revelation Dance deals damage equal to the first type of the user. It
; ignores Normalize, Pixilate, Refrigerate, Aerilate, and Galvanize. An
; extra small check is added to use the seconary type of the user if the
; first one is gonne (ie from Burn Up). Note: For the Purposes of Lightning
; Rod/Storm Drain, the game will use its type as determined by
; GetMoveTypeForMonster.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel GetMovePower, 0x230231C
.definelabel GetMoveCritChance, 0x2013B10
.definelabel CalcDamage, 0x230BBAC
.definelabel GetDamageSourceWrapper, 0x2324E44
.definelabel PerformDamageSequence, 0x2332D6C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel GetMovePower, 0x2302D48
;.definelabel GetMoveCritChance,0x2013BB8
;.definelabel CalcDamage, 0x230C620
;.definelabel GetDamageSourceWrapper, 0x23258AC
;.definelabel PerformDamageSequence, 0x23337AC

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel ENUM_TYPE_ID_NONE, 0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5
        sub sp,sp,#0x28
        
        ; Get the user's type. If the primary time is none, grab the second
        ; type. If that's also None just use the None type.
        ldr    r0,[r9,#0xB4]
        ldrb   r5,[r0,#0x5E]
        cmp    r5,#0x0
        ldreqb r5,[r0,#0x5F]
        
        mov r0,r9
        mov r1,r8
        bl  GetMovePower
        mov r5,r0
        
        mov r0,r8
        bl  GetMoveCritChance
        
        mov    r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        str    r0,[sp,#0x0]
        add    r0,sp,#0x14
        stmib  sp,{r0,r3}
        ldrh   r3,[r8,#0x4] ; move->id
        mov    r12,TRUE
        str    r3,[sp,#0xC]
        ldr    r1,[r9,#0xB4] ; entity->monster
        ldrb   r2,[r1,#0x5E] ; entity->types[0]
        cmp    r2,ENUM_TYPE_ID_NONE
        ldreqb r2,[r1,#0x5F] ; entity->types[1]
        mov    r0,r9
        mov    r1,r4
        mov    r3,r5
        str    r12,[sp,#0x10]
        bl     CalcDamage
        
        mov r0,r8
        mov r1,r7
        bl  GetDamageSourceWrapper
        
        str r0,[sp,#0x0]
        mov r1,r4
        mov r2,r8
        mov r0,r9
        add r3,sp,#0x14
        bl  PerformDamageSequence
        
        cmp   r0,#0
        movne r0,TRUE
        ; moveq r0,FALSE ; this instruction is redundant
    return:
        add sp,sp,#0x28
        pop r5
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1