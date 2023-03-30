; ------------------------------------------------------------------------------
; Jawshoeuh 3/22/2023 - WIP
; Smack Down deals damage and causes the target to become "grounded".
; Because this status doesn't exist in the game, I take creative liberties
; and take away the Flying type, take away the ability Levitate, and
; remove the Magnet Rise status effect.
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
.definelabel EntityIsValid, 0x022E0354
.definelabel UpdateStatusIconFlags,0x022E3AB4

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x022E0C94
;.definelabel UpdateStatusIconFlags, 0x022E4464

; Universal
.definelabel LevitateAbilityID, 0x37
.definelabel FlyingTypeID, 10

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
       push r5,r11
       sub  sp,sp,#0x4
        
        ; Damage!
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        mov r10,#0x0
        beq unallocate_memory
        
        ; Normally use RandomChanceUT for effects after; however,
        ; Smack Down isn't considered a secondary effect. So, just
        ; check validity of the target.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,#0x0
        bne unallocate_memory
        mov r0,r9
        bl  EntityIsValid
        cmp r0,#0x0
        bne unallocate_memory
        
        ; Remove Flying Type
        ldr    r12,[r4,#0xB4]
        ldrb   r1,[r12,#0x5E]
        ldrb   r2,[r12,#0x5F]
        mov    r0,#0x0
        mov    r5,#0x0
        cmp    r1,FlyingTypeID
        streqb r0,[r12,#0x5E]
        moveq  r5,#0x1
        cmp    r2,FlyingTypeID
        streqb r0,[r12,#0x5E]
        moveq  r5,#0x1
        cmp    r5,#0x1
        streqb r5,[r12,#0xFF] ; Flag that the type was changed.
        
        ; Cancel Magnet Rise
        ldrb   r1,[r12,#0xF7]
        cmp    r1,#0x0
        movne  r11,#0x1
        strneb r0,[r12,#0xF7]
        strneb r0,[r12,#0xF8]
        
        ; Remove Levitate
        mov    r0,#0x0
        mov    r10,#0x0
        ldrb   r2,[r12,#0x60]
        cmp    r2,LevitateAbilityID
        streqb r0,[r12,#0x60]
        moveq  r10,#0x1
        ldrb   r3,[r12,#0x61]
        cmp    r3,LevitateAbilityID
        streqb r0,[r12,#0x61]
        moveq  r10,#0x1
        
    feedback_message:
        mov   r0,#0
        mov   r1,r9
        mov   r2,#0
        bl    ChangeString ; User
        mov   r0,#1
        mov   r1,r4
        mov   r2,#0
        bl    ChangeString ; Target
        
        cmp   r10,#0x1
        ldreq r2,=smackdown_levitate_str
        moveq r0,r9
        moveq r1,r4
        bleq  SendMessageWithStringCheckUTLog
        
        cmp   r5,#0x1
        ldreq r2,=smackdown_flying_str
        moveq r0,r9
        moveq r1,r4
        bleq  SendMessageWithStringCheckUTLog
        
        cmp   r11,#0x1
        ldreq r2,=smackdown_magnet_rise_str
        movqe r0,r9
        moveq r1,r4
        bleq  SendMessageWithStringCheckUTLog
        
        mov   r0,r4
        bl    UpdateStatusIconFlags
        mov   r10,#0x1
    unallocate_memory:
        add sp,sp,#0x4
        pop r5,r11
        b MoveJumpAddress
        .pool
    smackdown_flying_str:
        .asciiz "[string:1] lost its Flying-type[R]designation!"
    smackdown_levitate_str:
        .asciiz "[string:1] lost its Levitate ability!"
    smackdown_magnet_rise_str:
        .asciiz "[string:1]'s Magnet Rise status ended!"
    .endarea
.close