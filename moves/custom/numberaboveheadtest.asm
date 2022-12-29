; ------------------------------------------------------------------------------
; Jawshoeuh 12/28/2022 - Confirmed Working 12/28/2022
; 
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
.definelabel AdvanceFrame, 0x022E9FE0
.definelabel DisplayTextAbove, 0x022EA718
.definelabel ChangeStringNumber, 0x0234B09C
.definelabel FramesBetweenAnimations, 40
.definelabel FramesAfterText, 20
.definelabel FirstPalette, 0
.definelabel LastPalette, 15

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r4,r7,r8
        
        ; Init Loop
        mov r7,FirstPalette
        mov r8,LastPalette
        
    loop:
        mov r0,#0
        mov r1,r7
        bl  ChangeStringNumber
        mov r0,r9
        ldr r1,=palette_str
        bl SendMessageWithStringLog
    
    ; Wait for the popup box to move down for our text.
        mov r4,#0
    wait1:
        bl  AdvanceFrame
        cmp r4,FramesAfterText
        add r4,r4,#1
        blt wait1
        
        ldr   r0,=0xF  ; r0 = Number, +9999 is hard coded as a miss
        mov   r1,r9    ; r1 = entity to display numbers above
        tst   r7,#0b1
        moveq r2,#0    ; r2 = (bool) to show sign 0 for no +/-
        movne r2,#1
        mov   r3,r7    ; r3 = palette (0xFFFFFFFF defaults to 3 for
                       ; negative numbers and 10 for positive numbers
                       ; 0xB for stockpile number
        bl  DisplayTextAbove
        
    ; Give time for the text to show.
        mov r4,#0
    wait2:
        bl  AdvanceFrame
        cmp r4,FramesBetweenAnimations
        add r4,r4,#1
        blt wait2
    
    ; End if we used the last palette.
        cmp r7,r8
        add r7,r7,#0x1
        blt loop
        
        mov r10,#1
        pop r4,r7,r8
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    palette_str:
        .asciiz "[R][R]Palette #[digits_c:0]" 
    .endarea
.close