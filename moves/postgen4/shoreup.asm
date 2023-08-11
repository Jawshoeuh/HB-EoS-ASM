; ------------------------------------------------------------------------------
; Jawshoeuh 3/22/2023 - WIP
; Shore Up heals the user's health, but heals more if the weather
; is sandstorm. The healing values are based upon Moonlight and
; Morning Sun
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetApparentWeather, 0x02335748

; Universal
.definelabel HealingWeatherClear, 0x32 ; 50
.definelabel HealingWeatherSandstorm, 0x50 ; 80

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
       sub sp,sp,#0x4
       
        ; Check weather.
        mov   r0,r4
        bl    GetApparentWeather
        cmp   r0,#0x2
        moveq r2,HealingWeatherSandstorm
        movne r2,HealingWeatherClear
       
        ; Healing time.
        mov r12,#0x1
        mov r0,r9
        mov r1,r4
        ; Healing amount from above in r2.
        mov r3,#0x0
        str r12,[sp,#0x1]
        bl  TryIncreaseHp
        
        mov r10,#0x1
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close
