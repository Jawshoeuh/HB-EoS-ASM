; ------------------------------------------------------------------------------
; Jawshoeuh 12/25/2022 - Confirmed Working 12/26/2022
; To avoid using complex ASM, the move should have guaranteed accuracy
; so that we can imitate/pretend to miss within hurricane itself.
; It can't hit targets in the middle of bounce/fly currently
; (sorry!).
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
.definelabel GetApparentWeather, 0x02334D08
.definelabel PlayAnimation, 0x022EA718
.definelabel MoveHitCheckJump, 0x02323C68
.definelabel ConfusionChance, 30
.definelabel NormalAccuracy, 73 ; based off of Thunder
.definelabel SunnyAccuracy, 50 ; based off of Thunder

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetApparentWeather, 0x02334D08
;.definelabel MoveHitCheckJump, 0x02323C68
;.definelabel PlayAnimation, 0x022EA718
;.definelabel ConfusionChance, 30
;.definelabel HurrianceAccuracy, 73 ; based off of Thunder

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; Check if it is raining.
        mov   r0,r9
        bl    GetApparentWeather
        cmp   r0,#0x4 ; Rain ID
        beq   success ; skip check if raining
        
        ; Branch into middle of move hit check in the middle.
        ; Probably very not good practice. However, I don't feel like
        ; implementing most of movehitcheck inside of my move...
        push  lr ; preserve current lr
        sub   sp,sp,#0x4
        mov   r0,#0x1
        str   r0,[sp]
        ldr   r12,=after_check
        stmdb sp!,{r4,r5,r6,r7,r8,r9,r10,r11,r12}
        sub   sp,sp,#0xc
        mov   r11,r8
        mov   r7,r9
        mov   r6,r4
        cmp   r0,#0x1 ; Sunny ID
        moveq r0,SunnyAccuracy
        movne r0,NormalAccuracy
        bl    MoveHitCheckJump
    after_check:
        pop   lr
        add   sp,sp,#0x4
        cmp   r0,#0x0
        bne   success
        
        ; Generate artifical miss.
        mov r2,#0x1    ; ???
        ldr r0,=0x270F ; animation id?
        mov r1,r4      ; must be entity to display it on.
        sub r3,r2,#0x2 ; ???
        bl  PlayAnimation ; Guessing...
        ldr r2,=0xEC3
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTNoLog
        mov r0,r9
        mov r1,r4
        bl  0x022E576C ; Maybe related to the miss sound or something? idk.
        ; I will define the above function if someone knows what to call it.
        mov r10,#1
        b   MoveJumpAddress
        
    success:
        ; Deal damage.
        sub sp,sp,#0x4
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        add sp,sp,#0x4
        
        ;Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        beq MoveJumpAddress
        
        ; Random confuse chance.
        mov r0,r9
        mov r1,r4
        mov r2,ConfusionChance
        bl  RandomChanceUT
        cmp r0,#0
        mov r10,#1
        beq MoveJumpAddress
        
        ; Confuse target (or try at least).
        mov r0,r9
        mov r1,r4
        mov r2,#0
        mov r3,#0
        bl  Confuse
        
        mov r10,#1
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close