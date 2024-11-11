; -------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 10/30/2024
; Life Dew heals 1/4 of all allies health. Notably this move SHOULD have
; niche interactions with Water Absorb, Storm Drain, and Dry Dkin.
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
.definelabel TryIncreaseHp, 0x23152E4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryIncreaseHp, 0x2315D44

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x4
    
        ; Calculate Health
        ldr   r0,[r4,#0xB4] ; entity->monster
        ldrsh r1,[r0,#0x12] ; monster->max_hp_stat
        ldrsh r0,[r0,#0x16] ; monster->max_hp_booost
        add   r0,r0,r1 ; Max HP
        
        ; Heal 1/4 HP.
        lsr r2,r0,#2 ; Divide health by 4
        mov r0,r9
        mov r1,r4
        mov r3,#0 ; Don't increasce temp max HP
        str r3,[sp,#0x0]
        bl  TryIncreaseHp
    
        mov r10,TRUE
        add sp,sp,#0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close
