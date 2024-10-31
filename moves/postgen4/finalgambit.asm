; -------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 10/30/1024
; Final Gambit does damage equal to the user's health and then they faint.
; I choose to make the user faint if damage is properly dealt because
; it's way simpler than account for niche scenarios with 9999 damage.
; Adex-8x's implementation is identical to how it works in GtI/PSMD
; if you wanted one more faithful to the mystery dungeon games.
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
.definelabel GetMoveCategory, 0x20151C8
.definelabel GetMoveType, 0x2013864
.definelabel CalcDamageFixedWrapper, 0x230D3F4
.definelabel GetFaintReasonWrapper, 0x2324E44
.definelabel HandleFaint, 0x22F7F30

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel GetMoveCategory, 0x2015270
;.definelabel GetMoveType, 0x201390C
;.definelabel CalcDamageFixedWrapper, 0x2030DE68
;.definelabel GetFaintReasonWrapper, 0x2324E44
;.definelabel HandleFaint, 0x22F8938

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel DAMAGE_SOURCE_RECOIL, 0x23C

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub  sp,sp,#0x20
        mov  r10,FALSE
        
        ; Get move type.
        mov   r0,#0
        strb  r0,[sp,#0x1C]
        mov   r0,r8
        bl    GetMoveType
        mov   r3,r0
        add   r0,sp,#0x1C
        stmia sp,{r0,r3}

        ; Get move category
        ldrh r0,[r8,#0x4]
        bl   GetMoveCategory
        mov  r5,r0
        str  r0,[sp,#0x8]

        ; Get faint reason (if move knocks out)
        mov r0,r8
        mov r1,r7
        bl  GetFaintReasonWrapper
        str r0,[sp,#0xC]
        
        ; Prepare the DAMAGE!
        mov   r3,#0x1
        mov   r2,#0x0
        str   r2,[sp,#0x10]
        str   r3,[sp,#0x14]
        str   r2,[sp,#0x18]
        ldr   r12,[r9,#0xB4]
        ldrsh r2,[r12,#0x10] ; Current HP
        mov   r1,r4
        mov   r0,r9
        bl    CalcDamageFixedWrapper

        ; Check if damage was dealt.
        ldrb  r0,[sp,#0x1C]
        cmp   r0,#0x0
        bne   return
        mov   r10,TRUE
        
        ; Dealing damage to ourself is way more work (and susceptible to
        ; bugs), so we just make ourselves faint!
        mov r0,r9
        mov r1,DAMAGE_SOURCE_RECOIL
        mov r2,r9
        bl  HandleFaint

    return:
        add sp,sp,#0x20
        b   MoveJumpAddress
        .pool
    .endarea
.close
