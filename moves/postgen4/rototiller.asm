; -------------------------------------------------------------------------
; Jawshoeuh 01/09/2023 - Confirmed Working 11/12/2024
; Rototiller raises the Attack and Special Attack of grounded Grass type
; Pokemon. They specifically have to be grounded. So, this really only
; wont do anything to Hoppip and Carnavine...
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
.definelabel GravityIsActive, 0x2338390
.definelabel DefenderAbilityIsActive, 0x22F96CC
.definelabel LevitateIsActive, 0x2301E18
.definelabel IsFloating, 0x2318A4C
.definelabel BoostOffensiveStat, 0x231399C

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel GravityIsActive, 0x2338F60
;.definelabel DefenderAbilityIsActive, 0x22FA0D8
;.definelabel LevitateIsActive, 0x2302844
;.definelabel IsFloating, 0x23194AC
;.definelabel BoostOffensiveStat, 0x23143FC

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1
.definelabel ENUM_TYPE_ID_GRASS, 0x4 ; 4
.definelabel ENUM_TYPE_ID_FLYING, 0xA ; 10

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,FALSE
        
        ; Gravity pulls all down.
        bl  GravityIsActive
        cmp r0,TRUE
        beq target_is_grounded
        
        ; Check for Levitate
        mov r0,r4
        bl  LevitateIsActive
        cmp r0,TRUE
        beq return
        
        ; Check for Magnet Rise
        mov r0,r4
        bl  IsFloating
        cmp r0,TRUE
        beq return
        
        ; Check for flying type.
        ldr   r3,[r4,#0xB4] ; entity->monster
        ldrb  r0,[r3,#0x5E] ; monster->types[0]
        ldrb  r1,[r3,#0x5F] ; monster->types[1]
        cmp   r0,ENUM_TYPE_ID_FLYING
        cmpne r1,ENUM_TYPE_ID_FLYING
        beq   return
        
        ; Check if the grounded monster is a grass type.
        target_is_grounded:
        cmp   r0,ENUM_TYPE_ID_GRASS
        cmpne r1,ENUM_TYPE_ID_GRASS
        bne   return
        mov   r10,TRUE
        
        ; Raise attack 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
        ; Raise special attack 1 stage.
        mov r0,r9
        mov r1,r4
        mov r2,SPECIAL_STAT
        mov r3,#1
        bl  BoostOffensiveStat
        
    return:
        b   MoveJumpAddress
        .pool
    .endarea
.close
