; -------------------------------------------------------------------------
; Jawshoeuh 01/07/2023 - Confirmed Working 11/11/2024
; Parting Shot reduces Attack & Special Attack of the Target. Since Gen 7,
; this move fails if the user's attack/special attack doesn't get dropped.
; Since that's such a niche scenario (the target must be at the lowest
; attack AND special attack), I decided not to implement it. However,
; it does check for immunities from stat drops.
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
.definelabel DefenderAbilityIsActive, 0x22F96CC
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234B350
.definelabel LowerOffensiveStat, 0x23135FC
.definelabel ItemIsActive, 0x22E330C
.definelabel GetTile, 0x23360FC
.definelabel TrySwitchPlace, 0x22EB178
.definelabel IsProtectedFromStatDrops, 0x2301B2C
.definelabel DIRECTIONS_XY, 0x0235171C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageByIdWithPopupCheckUserTarget, 0x234BF50
;.definelabel LowerOffensiveStat, 0x231405C
;.definelabel ItemIsActive, 0x22E3CBC
;.definelabel GetTile, 0x2336CCC
;.definelabel TrySwitchPlace, 0x22EBB28
;.definelabel IsProtectedFromStatDrops, 0x2302558
;.definelabel DIRECTIONS_XY, 0x2352328

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel NULL, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel SOUNDPROOF_ABILITY_ID, 60 ; 0x3C
.definelabel SOUNDPROOF_STR_ID, 3769 ; 0xEB9
.definelabel TWIST_BAND_ITEM_ID, 0x12
.definelabel PROTECTED_BY_BAND_STR_ID, 3506 ; 0xDB2

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
        mov r10,FALSE
        
        ; There is a list of sound moves in the base game. A skypatch could
        ; be added to add a move ID to the list of sound moves in game, but
        ; this is easier for people to implement and doesn't require a
        ; custom skypatch.
        mov r0,r9
        mov r1,r4
        mov r2,SOUNDPROOF_ABILITY_ID
        mov r3,TRUE
        bl  DefenderAbilityIsActive
        cmp r0,FALSE
        beq not_blocked
        
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Sub Target
        ldr r2,=SOUNDPROOF_STR_ID
        mov r0,r9
        mov r1,r4
        bl  LogMessageByIdWithPopupCheckUserTarget
        b   return
        
        not_blocked:
        mov r0,r9
        mov r1,r4
        mov r2,TRUE
        bl  IsProtectedFromStatDrops
        cmp r0,TRUE
        beq return
        
        ; Check for Twist Band
        mov r0,r4
        mov r1,TWIST_BAND_ITEM_ID
        bl  ItemIsActive
        cmp r0,FALSE
        beq not_stopped_by_twist_band
        mov r0,#0
        mov r1,r4
        mov r2,#0
        bl SubstitutePlaceholderStringTags
        mov r0,r9
        mov r1,r4
        ldr r2,=PROTECTED_BY_BAND_STR_ID
        bl  LogMessageByIdWithPopupCheckUserTarget
        
        
        not_stopped_by_twist_band:
        mov r10,TRUE
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 stage
        str r10,[sp,#0x0]
        str r10,[sp,#0x4]
        bl  LowerOffensiveStat
        
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1 ; 1 stage
        str r10,[sp,#0x0]
        str r10,[sp,#0x4]
        bl  LowerOffensiveStat
        
        ; Get User Direction and Flip
        ldr  r0, [r9,#0xB4]
        ldrb r12,[r0,#0x4C] ; User Direction
        add  r12,r12,#0x4
        and  r12,r12,#0x7   ; Flip Direction
        
        ; See Note 1
        ldr   r10,=DIRECTIONS_XY
        mov   r2,r12, lsl #0x2     ; Array Offset For Dir Value
        add   r3,r10,r12, lsl #0x2 ; Array Offset For Dir Value
        ldrsh r0,[r10,r2]          ; X Offset
        ldrsh r1,[r3,#0x2]         ; Y Offset
        ldrh  r2,[r9,#0x4]         ; User X Pos
        ldrh  r3,[r9,#0x6]         ; User Y Pos
        
        ; Add values together
        add r0,r0,r2
        add r1,r1,r3
        
        ; Check tile for Monster.
        bl    GetTile
        ldr   r1,[r0,#0xC]
        cmp   r1,NULL
        beq   return
        
        ; Check if friend or enemy.
        ldr   r12,[r1,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r3,r0,r2 ; 1 = enemy, 0 = friend
        ldr   r12,[r9,#0xB4]
        ldrb  r0,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r12,r0,r2 ; 1 = enemy, 0 = friend
        cmp   r12,r3
        bne   return
        
        ; Try to swap places
        mov r0,r9
        ; Monster behind still in r1.
        bl  TrySwitchPlace

    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: Visualization of values loaded from direction array.
; 5   4   3   (y-1)
;   \ | /
; 6 - E - 2   (y)
;   / | \
; 7   0   1   (y+1)
;
; x   x   x
; -       +
; 1       1