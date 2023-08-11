; -------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 08/02/2023
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
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel TryIncreaseHp, 0x023152E4

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel TryIncreaseHp, 0x02315D44

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
    
        ; Calculate Health
        ldr   r0,[r4,#0xB4]
        ldrsh r1,[r0,#0x12]
        ldrsh r0,[r0,#0x16]
        add   r0,r0,r1 ; Max HP
        
        ; Heal 1/4 HP.
        lsr r2,r0,#2 ; Divide health by 4
        mov r0,r9
        mov r1,r4
        mov r3,#0 ; Don't increasce temp max HP
        bl  TryIncreaseHp
    
        mov r10,TRUE
        b   MoveJumpAddress
        .pool
    .endarea
.close
