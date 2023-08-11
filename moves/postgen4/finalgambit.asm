; -------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working XX/XX/XXXX
; Final Gambit does damage equal to the user's health and then they faint.
; I choose to make the self damage 9999 so that there aren't any weird
; niche cases where a Pokemon lives and so I don't have to save health.
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
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel GetMoveCategory, 0x020151C8
.definelabel GetMoveType, 0x02013864
.definelabel CalcDamageFixedWrapper, 0x0230D3F4
.definelabel GetFaintReasonWrapper, 0x02324E44
.definelabel HandleFaint, 0x022F7F30

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel GetMoveCategory, 0x02015270
;.definelabel GetMoveType, 0x0201390C
;.definelabel CalcDamageFixedWrapper, 0x2030DE68
;.definelabel GetFaintReasonWrapper, 0x02324E44
;.definelabel HandleFaint, 0x022F8938

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub  sp,sp,#0x20
        push r5
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
        mov r5,r0
        
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
        
        ; Dealing damage to ourself is way more work (and susceptible to
        ; bugs), so we just make ourselves faint!
        mov r0,r9
        mov r1,r5
        mov r2,r9
        bl  HandleFaint

    return:
        pop r5
        add sp,sp,#0x20
        b   MoveJumpAddress
        .pool
    .endarea
.close
