; ------------------------------------------------------------------------------
; Jawshoeuh 12/25/2022 - Confirmed Working 12/26/2022
; To avoid using complex ASM, the move should have guaranteed accuracy
; so that we can imitate/pretend to miss within hurricane itself.
; It can't hit targets in the middle of bounce/fly currently
; (sorry!). Credits to End for suggesting optimizations to
; this effect.
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
.definelabel DisplayTextAbove, 0x022EA718
.definelabel PlayMissSound, 0x022E576C ; May be wrongly named.
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
;.definelabel DisplayTextAbove, 0x????????
;.definelabel PlayMissSound, 0x???????? ; May be wrongly named.
;.definelabel MoveHitCheckJump, 0x???????? ; instruction = 00 80 a0 e1

; Universal 
.definelabel ConfusionChance, 30
.definelabel NormalAccuracy, 73 ; based off of Thunder
.definelabel SunnyAccuracy, 50 ; based off of Thunder
.definelabel RainWeatherID, 4
.definelabel MissStr, 0xEC3

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x4
    
        ; Check if it is raining.
        mov   r0,r9
        bl    GetApparentWeather
        cmp   r0,RainWeatherID
        beq   success ; skip check if raining
        
        ; Branch into middle of move hit check in the middle.
        ; Probably very not good practice. However, I don't feel like
        ; implementing most of movehitcheck inside of my move...
        mov   r0,#0x1
        str   r0,[sp]
        add   lr,=after_check
        push  r4-r11,lr
        sub   sp,sp,#0xC ; MoveHitCheck reserves 0xC memory when called
        mov   r11,r8
        mov   r7,r9
        mov   r6,r4
        cmp   r0,#0x1 ; Sunny ID
        moveq r0,SunnyAccuracy
        movne r0,NormalAccuracy
        b     MoveHitCheckJump
    after_check:
        cmp   r0,#0x0
        bne   success
        
        ; Generate artifical miss.
        mov r2,#0x1    ; not certain?
        ldr r0,=0x270F ; number to show (0x270F is hardcoded to show MISS).
        mov r1,r4      ; entityt to display text above
        sub r3,r2,#0x2 ; color related, 0xfffffff normally, 0xb for stockpile
        bl  DisplayTextAbove
        ldr r2,=MissStr
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTNoLog
        mov r0,r9
        mov r1,r4
        bl  PlayMissSound ; Doesn't actually use r0, also guessing this is
        ; the actual purpose of this function.
        mov r10,#0
        add sp,sp,#0x4
        b   MoveJumpAddress
        
    success:
        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ;Check for succesful hit.
        cmp r0,#0
        mov r10,#0
        add sp,sp,#0x4
        beq MoveJumpAddress ; failed, we did no damage
        
        ; Random confuse chance.
        mov r0,r9
        mov r1,r4
        mov r2,ConfusionChance
        bl  RandomChanceUT
        cmp r0,#0
        mov r10,#1
        beq MoveJumpAddress ; chance to confuse didn't pass
        
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