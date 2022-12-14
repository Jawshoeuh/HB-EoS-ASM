; ------------------------------------------------------------------------------
; Jawshoeuh 1/6/2023 - Confirmed Working 1/6/2023
; Soak changes the target's type to water. Appropritely fail if the user
; has Forecast active.
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

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C

; Universal
.definelabel WaterTypeID, 3
.definelabel ForecastAbilityID, 0x25 ; 37
.definelabel ForecastPreventStr, 0xDC3 ; 3523

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        
        ; Preemptively substitute strings.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl ChangeString ; Target
        
        ; Base game wont change the type of a monster with an active
        ; forecast ability. So I don't either. Not sure why? Maybe it will
        ; just change back to whatever the weather sets it to right after?
        mov r0,r9
        mov r1,ForecastAbilityID
        bl  HasAbility
        cmp r0,#0
        beq success
        
        ldr r2,=ForecastPreventStr
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        mov r10,#0
        b   MoveJumpAddress
        
    success:
        mov  r10,#1 ; set r10 to be true, and use later for 0xFF
        mov  r0,WaterTypeID
        mov  r2,#0
        ldr  r12,[r4,#0xB4]
        strb r0,[r12,#0x5E]  ; Type 1 = Water
        strb r2,[r12,#0x5F]  ; Type 2 = None
        strb r10,[r12,#0xFF] ; Use r10 to set flag that type was changed
        
        ; Put some kind of inappopriate joke here about the move.
        ldr r1,=soak_str
        mov r0,r4
        bl  SendMessageWithStringLog

        b MoveJumpAddress
        .pool
    soak_str:
        .asciiz "[string:1] converted to the[R]Water type!"
    .endarea
.close