; ------------------------------------------------------------------------------
; Jawshoeuh 12/25/2022 - Confirmed Working 12/26/2022
; To avoid using complex ASM, the move should have guaranteed accuracy
; so that we can imitate/pretend to miss within hurricane itself.
; While it can't hit targets in the middle of bounce/fly currently
; (sorry!). It will never miss in the rain and will mostly have correct
; accuracy values. Doesn't take into account evasiveness/accuracy drops.
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
.definelabel ConfusionChance, 30
.definelabel NormalAccuracy, 73 ; based off of Thunder
.definelabel SunnyAccuracy, 50 ; based off of Thunder

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetApparentWeather, 0x02334D08
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
        beq   success
        cmp   r0,#0x1 ; Sunny ID
        moveq r2,SunnyAccuracy
        movne r2,NormalAccuracy
        
        ; Artifical accuracy check.
        mov r0,r9
        mov r1,r4
        ; Accuracy already put in above!
        bl  RandomChanceUT ; yes, this ignores evasiveness/accuracy changes
        cmp r0,#0
        bne success
        
        ; Generate artifical miss.
        mov r2,#0x1
        ldr r0,=0x270F ; animation id?
        mov r1,r4      ; must be entity to display it on.
        sub r3,r2,#0x2
        bl  PlayAnimation ; Guessing...
        ldr r2,=0xEC3
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTNoLog
        mov r0,r9
        mov r1,r4
        bl  0x022E576C ; Maybe related to the miss sound or something? idk.
        ; I will define the above function when I am certain how it works.
        mov r10,#1
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