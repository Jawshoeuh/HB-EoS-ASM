; ------------------------------------------------------------------------------
; Jawshoeuh 1/5/2023 - Confirmed Working 1/6/2023
; Reflect Type changes the user's type to be the same as the target's.
; Includes a special check for the ability Forecast! 
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
        
        ; For some bizarre reason, when Forecast is active, the type of the
        ; target can't be changed, but if suppressed with Gastro Acid,
        ; it can be? I'm not aware of a technical limitation that stops
        ; that from happening? Maybe the way it's programmed,
        ; the Forecast will just reset the target's type later, meaning
        ; this move won't do much even if it did change type? I don't
        ; feel like testing the specifics of Forecast, so just match what
        ; the game does baseline.
        mov r0,r9
        mov r1,ForecastAbilityID
        bl  HasAbility
        cmp r0,#0
        beq check_typeless
        
        ldr r2,=ForecastPreventStr
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        mov r10,#0
        b   MoveJumpAddress
        
    check_typeless:
        ldr   r12,[r4,#0xB4]
        ldrb  r0,[r12,#0x5E]
        ldrb  r1,[r12,#0x5F]
        cmp   r0,#0 ; check for typeless Pokemon, while this is unlikely,
        cmpeq r1,#0 ; check anyway (possible with Burn Up by fire type).
        bne   success
        
        ldr r1,=reflecttype_fail_str
        mov r0,r4
        bl  SendMessageWithStringLog
        mov r10,#0
        b MoveJumpAddress
        
    success:
        mov  r3,#1
        ldr  r2,[r9,#0xB4] ; Your type (are) belong to us.
        strb r0,[r2,#0x5E] ; Still loaded in r0 and r1
        strb r1,[r2,#0x5F]
        strb r3,[r2,#0xFF] ; Flag that the type has been changed.
        
        ; Display we stole type.
        ldr r1,=reflecttype_str
        mov r0,r9
        bl  SendMessageWithStringLog
        
        mov r10,#1
        b MoveJumpAddress
        .pool
    reflecttype_str:
        .asciiz "[string:0] converted to [string:1]'s[R]type!"
    reflecttype_fail_str:
        .asciiz "But [string:1] was typeless?"
    .endarea
.close