; ------------------------------------------------------------------------------
; Jawshoeuh 3/30/2023 - Confirmed Working 3/30/2023
; Aurora Veil provides a buff that reduces the damage dealt to the user.
; It will only work if the weather is Snow or Hail.
; DO NOT USE WITHOUT SPECIAL SKYPATCH for THIS MOVE!
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
.definelabel CalcStatusDuration, 0x022EAB80
.definelabel GetApparentWeather, 0x02334D08

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; Universal
.definelabel TurnCountMinimum, 0xA
.definelabel TurnCountMaximum, 0xC
.definelabel HailWeatherID, 0x5
.definelabel SnowWeatherID, 0x7

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        push r5
        
        ; Check for Hail/Snow
        mov   r0,r9
        bl    GetApparentWeather
        cmp   r0,HailWeatherID
        cmpne r0,SnowWeatherID
        bne   failed_weather
        
        ldr  r5,[r4,#0xB4]
        ldrb r0,[r5,#0xD5]
        cmp  r0,#0x12
        beq  protected_already
        mov  r3,#0x12
        strb r3,[r5,#0xD5]
        mov  r0,r4
        ldr  r1,=AURORA_VEIL_TURN_RANGE
        mov  r2,#0x0
        bl   CalcStatusDuration
        add  r1,r0,#0x1
        strb r1,[r5,#0xD6]
        mov  r0,#0x1
        mov  r1,r4
        mov  r2,#0x0
        bl   ChangeString
        ldr  r2,=auroraveil_str
        mov  r0,r9
        mov  r1,r4
        bl   SendMessageWithStringCheckUTLog
        b    unallocate_memory
        
        failed_weather:
        ldr  r3,[sp,#0x7C] ; Some magical expletive value (0x78 from call)
        cmp  r3,#0x0
        bne  unallocate_memory
        mov  r0,#0x0
        mov  r1,r9
        mov  r2,#0x0
        bl   ChangeString
        ldr  r2,=aurovaveil_failed_str
        mov  r0,r9
        mov  r1,r4
        bl   SendMessageWithStringCheckUTLog
        b    unallocate_memory
        
        protected_already:
        mov  r0,#0x1
        mov  r1,r4
        mov  r2,#0x0
        bl   ChangeString
        ldr  r2,=aurovaveil_redundant_str
        mov  r0,r9
        mov  r1,r4
        bl   SendMessageWithStringCheckUTLog
        
    unallocate_memory:
        mov r10,#0x1
        pop r5
        b   MoveJumpAddress
        .pool
    auroraveil_str:
        .asciiz "[string:1] was protected by[R]Aurora Veil!"
    aurovaveil_redundant_str:
        .asciiz "[string:1] is already protected by[R]Aurora Veil."
    aurovaveil_failed_str:
        .asciiz "[string:0]'s Aurora Veil failed[R]in this weather!"
    AURORA_VEIL_TURN_RANGE:
        .halfword TurnCountMinimum
        .halfword TurnCountMaximum
    .endarea
.close