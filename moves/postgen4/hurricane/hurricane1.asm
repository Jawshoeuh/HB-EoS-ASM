; -------------------------------------------------------------------------
; Jawshoeuh 12/25/2022 - Confirmed Working XX/XX/XXXX
; To avoid using complex ASM, the move should have guaranteed accuracy
; so that we can imitate/pretend to miss within hurricane itself. To use
; this move properly, the accuracy should be set to 125 (never miss) in
; SkyTemple. IT IS ILL ADVISED TO JUMP TO THE MIDDLE OF A FUNCTION! If
; you're willing to use better practices and create your own SkyPatch,
; use hurricane2.asm
; It can't hit targets in the middle of bounce/fly currently
; (sorry!). Credits to end45#0 for suggesting optimizations to
; this effect.
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
.definelabel GetApparentWeather, 0x02334D08
.definelabel DisplayCombatNumber, 0x022EA718
.definelabel PlayMissSound, 0x022E576C ; May be wrongly named.
.definelabel MoveHitCheckJump, 0x02323C68
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234B350
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x02324934
.definelabel TryInflictConfusedStatus, 0x02314F38

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel DealDamage, 0x02333560
;.definelabel GetApparentWeather, 0x02334D08
;.definelabel DisplayTextAbove, 0x????????
;.definelabel PlayMissSound, 0x???????? ; May be wrongly named.
;.definelabel MoveHitCheckJump, 0x???????? ; instruction = 00 80 a0 e1
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x0234BF50
;.definelabel DungeonRandOutcomeUserTargetInteraction, 0x0232539C
;.definelabel TryInflictConfusedStatus, 0x02315998

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel MISS_STR_ID, 3779 ; 0xEC3
.definelabel SUNNY_WEATHER_ID, 1
.definelabel RAIN_WEATHER_ID, 4

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,FALSE
        
        ; Check if it is raining.
        mov   r0,r9
        bl    GetApparentWeather
        cmp   r0,RAIN_WEATHER_ID
        beq   success ; skip check if raining
        
        ; Branch into middle of move hit check in the middle.
        ; Probably very not good practice. However, I don't feel like
        ; implementing most of movehitcheck inside of my move...
        mov   r1,#0x1
        str   r1,[sp,#0x0]
        add   lr,=after_check
        push  r4-r11,lr
        sub   sp,sp,#0xC ; MoveHitCheck reserves 0xC memory when called
        mov   r11,r8
        mov   r7,r9
        mov   r6,r4
        cmp   r0,SUNNY_WEATHER_ID
        moveq r0,#50  ; Sunny Accuracy
        movne r0,#73  ; Normal Accuracy
        b     MoveHitCheckJump
        after_check:
        cmp   r0,TRUE
        beq   success
        
        ; Generate artifical miss.
        mov r2,#0x1    ; not certain?
        ldr r0,=0x270F ; number to show (0x270F is hardcoded to show MISS).
        mov r1,r4      ; entityt to display text above
        sub r3,r2,#0x2 ; color related, 0xfffffff normally, 0xb for stockpile
        bl  DisplayCombatNumber
        ldr r2,=MISS_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        mov r0,r9
        mov r1,r4
        bl  PlayMissSound ; Doesn't actually use r0, also guessing this is
        ; the actual purpose of this function.
        b   return
        
    success:
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
        
        ; Attempt to apply secondary effects (fails if the target has
        ; fainted or has Shield Dust).
        mov r0,r9
        mov r1,r4
        mov r2,#30 ; 30% chance
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
        
        ; Confuse target (or try, I guess).
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        mov r3,FALSE
        bl  TryInflictConfusedStatus

    return:
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1