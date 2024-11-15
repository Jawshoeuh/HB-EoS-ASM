; -------------------------------------------------------------------------
; Jawshoeuh 03/22/2023 - Confirmed Working 11/15/2024
; Shore Up heals the user's health, but heals more if the weather
; is sandstorm. The healing values are based upon Moonlight and
; Morning Sun
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US (comment for EU)
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel GetApparentWeather, 0x2334D08
.definelabel TryIncreaseHp, 0x23152E4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel GetApparentWeather, 0x2335748
;.definelabel TryIncreaseHp, 0x2315D44

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel ENUM_WEATHER_ID_SANDSTORM, 0x2

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
        mov r10,TRUE
        
        ; Check for a sandstorm.
        mov   r0,r4
        bl    GetApparentWeather
        cmp   r0,ENUM_WEATHER_ID_SANDSTORM
        moveq r2,#80 ; Sandstorm healing.
        movne r2,#50 ; Normal healing.
        
        ; Healing time.
        mov r0,r9
        mov r1,r4
        ; Healing amount from above in r2.
        mov r3,#0x0
        str r10,[sp,#0x0]
        bl  TryIncreaseHp
        
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close
