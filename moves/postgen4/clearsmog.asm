; -------------------------------------------------------------------------
; Jawshoeuh 03/22/2023 - Confirmed Working 07/08/XXXX
; Clear Smog deals damage and resets all stat changes to 0 (default).
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel DealDamage, 0x02332B20
.definelabel EntityIsValid, 0x022E0354
.definelabel TryResetStatChanges, 0x02319624

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel EntityIsValid, 0x022E0C94
;.definelabel TryResetStatChanges, 0x????????

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        beq return
        mov r10,TRUE
        
        ; Because this stat removal is not considered a secondary effect,
        ; check for validity of the user and target instead of checking for
        ; a user target interaction.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,TRUE
        bne return
        mov r0,r9
        bl  EntityIsValid
        cmp r0,TRUE
        bne return
        
        ; Reset the stats of the target.
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        bl  TryResetStatChanges

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1