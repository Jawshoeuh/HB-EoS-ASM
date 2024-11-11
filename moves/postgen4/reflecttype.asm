; -------------------------------------------------------------------------
; Jawshoeuh 01/05/2023 - Confirmed Working 11/11/2024
; Reflect Type changes the user's type to be the same as the target's.
; Includes a special check for the ability Forecast! 
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
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel AbilityIsActive, 0x2301D10

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel AbilityIsActive, 0x230273C

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel FORECAST_ABILITY_ID, 0x25 ; 37
.definelabel FORECAST_PREVENT_STR_ID, 3523 ; 0xDC3
.definelabel ENUM_TYPE_ID_NONE, 0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x0
        mov r10,FALSE
        
        ; Preemptively substitute strings.
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        
        ; The game prevents type changing if Forecast is active. However,
        ; if it's suppressed with Gastro Acid it allows it. For parity,
        ; keep this interaction.
        mov r0,r9
        mov r1,FORECAST_ABILITY_ID
        bl  AbilityIsActive
        cmp r0,FALSE
        beq check_typeless
        
        ldr r2,=FORECAST_PREVENT_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        b   return
        
        check_typeless:
        ldr   r3,[r4,#0xB4] ; entity->monster
        ldrb  r0,[r3,#0x5E] ; monster->types[0]
        ldrb  r1,[r3,#0x5F] ; monster->types[1]
        cmp   r0,ENUM_TYPE_ID_NONE
        cmpeq r1,ENUM_TYPE_ID_NONE
        bne   not_typeless
        
        ldr r2,=reflecttype_fail_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        b   return
        
        not_typeless:
        mov  r10,TRUE
        ldr  r3,[r9,#0xB4]  ; entity->monster
        strb r0,[r3,#0x5E]  ; monster->types[0]
        strb r1,[r3,#0x5F]  ; monster->types[1]
        strb r10,[r3,#0xFF] ; monster->type_changed = TRUE
        
        ldr r2,=reflecttype_str
        mov r0,r9
        mov r1,r4
        bl  LogMessageWithPopupCheckUserTarget
        
    return:
        add sp,sp,#0x0
        b   MoveJumpAddress
        .pool
    reflecttype_str:
        .asciiz "[string:0] converted to [string:1]'s[R]type!"
    reflecttype_fail_str:
        .asciiz "But [string:1] was typeless?"
    .endarea
.close
