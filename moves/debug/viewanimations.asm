; ------------------------------------------------------------------------------
; Jawshoeuh 12/27/2022 - Confirmed Working 12/28/2022
; View Animations displays all animations. May crash the game after
; because some animations are not intended to be loaded in dungeons and
; corrupt, clobber, or overwrite some of the other relevant data for the
; screen/dungeon. It is better to remove looping from the animations
; themselves as not doing so messes with the visual number displayed
; additionally, they stay for an absurdly long time (probably because
; I don't use the function to stop the current animation that is playing
; don't know what that function is.
; 639, 640, 653, 659, 660, 661, 662, 668 are likely only intended to be
; loaded in cutscenes. Playing the animation in dungeon mode will break
; the game.
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
.definelabel MemAlloc, 0x02001170
.definelabel AdvanceFrame, 0x022E9FE0
.definelabel ChangeStringNumber, 0x0234B09C
.definelabel LoadAnimation, 0x022BDEB4
.definelabel PlayAnimation, 0x022E35E4
.definelabel FramesBetweenAnimations, 80
.definelabel FramesAfterText, 20
.definelabel FirstAnimation, 0
.definelabel LastAnimation, 696 ; 697 causes a freeze, may miss 698 & 699

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel MemAlloc, 0x02001170
;.definelabel AdvanceFrame, 0x022EA990
;.definelabel ChangeStringNumber, 0x????????
;.definelabel LoadAnimation, 0x????????
;.definelabel PlayAnimation, 0x????????
;.definelabel FramesBetweenAnimations, 80
;.definelabel FramesAfterText, 20
;.definelabel FirstAnimation, 0
;.definelabel LastAnimation, 696 ; 697 causes a freeze, may miss 698 & 699

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r4,r7,r8
        sub  sp,sp,#0x10
        
        ; Init Loop
        mov r7,FirstAnimation
        mov r8,LastAnimation
        
    loop:
        mov r0,#0
        mov r1,r7
        bl  ChangeStringNumber
        ldr r1,=#0xEAA ; By default, use the Magnitude String
        mov r0,r9
        bl  SendMessageWithIDLog
    
    ; Wait for the popup box to move down for our string.
        mov r4,#0
    wait1:
        bl  AdvanceFrame
        cmp r4,FramesAfterText
        add r4,r4,#1
        blt wait1
        
        ; Load or get the animation.
        ; This is almost always called before PlayAnimation. However,
        ; is sparsely not loaded beforehand. Perhaps there is another
        ; function to load animations or this function is embedded in
        ; another that gets called?
        mov r0,r7
        bl  LoadAnimation
        
        ; Play the animation.
        ; r0 = Entity/Monster to display animation on.
        ; r1 = Annimation ID
        ; r2 = Usually 1.
        ; r3 = Output of LoadAnimation, maybe just a pointer to anim data.
        ; sp = Usually 2.
        ; sp+0x4 = Usually 0
        ; sp+0x8 = Usually 0xFFFFFFFF
        ; sp+0xC = Usually 0, calls 0x0201C000 (NA) if 0. Does some loop
        ; stuff otherwise.
        mov r1,r0
        and r3,r1,#0xFF
        mov r0,#0x2
        mov r12,#0x0
        stmia sp,{r0,r12}
        sub r0,r12,#0x1
        str r0,[sp,#0x8]
        mov r0,r9
        mov r1,r7
        mov r2,#0x1
        str r12,[sp,#0xC]
        bl  PlayAnimation
        
    ; Give time for animation to playout.
        mov r4,#0
    wait2:
        bl  AdvanceFrame
        cmp r4,FramesBetweenAnimations
        add r4,r4,#1
        blt wait2
    
    ; End if we have played the last animation.
        cmp r7,r8
        add r7,r7,#0x1
        blt loop
        
        
        mov r10,#1
        pop r4,r7,r8
        add sp,sp,#0x10
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close