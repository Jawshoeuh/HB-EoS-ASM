; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 10/29/2024
; Fairy Lock (translating this move to a mystery dungeon context is a
; little odd. In current PMD games it just applies the Shadow Hold or
; Immobilized status; however, this version just inflicts shadow hold for
; a small amount of time to be more in line with the base game.
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
.definelabel TryInflictShadowHoldStatus, 0x2312F78

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryInflictShadowHoldStatus, 0x23139D8

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel FAIRY_LOCK_SHADOW_HOLD_TURNS, 3

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,TRUE
        
        ; Inflict Shadow Hold (Immobilized).
        mov r0,r9
        mov r1,r4
        mov r2,FALSE
        bl  TryInflictShadowHoldStatus
        
        ; Check if inflicted properly.
        cmp r0,TRUE
        bne MoveJumpAddress
        
        ; Set the turns to a smaller (than default) value.
        ldr  r0,[r4,#0xB4]
        mov  r1,FAIRY_LOCK_SHADOW_HOLD_TURNS
        strb r1,[r0,#0xCC]
       
        b   MoveJumpAddress
        .pool
    .endarea
.close
