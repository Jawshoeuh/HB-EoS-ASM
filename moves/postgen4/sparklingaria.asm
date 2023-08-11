; ------------------------------------------------------------------------------
; Jawshoeuh 1/7/2023 - Confirmed Working 1/8/2023
; Sparkling Aria does damage and heals the target of their burn. Also accept
; sound move, so check for Soundproof.
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; Uncomment the correct version

; For US
.definelabel MoveStartAddress, 0x02330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel EndBurnClassStatus, 0x023061A8
.definelabel DefenderAbilityIsActive, 0x022F96CC

; For EU
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EndBurnClassStatus, 0x????????
;.definelabel DefenderAbilityIsActive, 0x022FA0D8

; Constants
.definelabel SoundproofAbilityID, 0x3C ; 60
.definelabel SoundproofStrID, 0xEB9 ; 3769


; Change to the actual offset as this directive doesn't accept labels
;                             |
;                             V
.create "./code_out.bin", 0x02330134
    .org MoveStartAddress
    .area MaxSize
    
        ; There is a list of sound moves in the base game. A skypatch could
        ; be added to make a specific move id return positive, but this
        ; is more useful ease of use across multiple hacks. Before we do
        ; anything, check if the target has Soundproof.
        mov r0,r4
        mov r1,SoundproofAbilityID
        bl  HasAbility
        cmp r0,#0
        mov r10,#0
        bne failed_soundproof

        ; Deal damage.
        sub sp,sp,#0x4
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        add sp,sp,#0x4
        
        ; Check for succesful hit.
        cmp r0,#0
        beq MoveJumpAddress
        mov r10,#1
        
        ; For some twisted reason, Sparkling Aria won't heal a target's
        ; burn if they have Shield Dust. Why? WHY?
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; guaranteed
        bl  RandomChanceUT
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Check for Burn, heal if has Burn
        ldr  r0,[r9,#0xB4]
        ldrb r1,[r0,#0xBF]
        cmp  r1,#0x1
        bne  MoveJumpAddress
        mov  r0,r9
        mov  r1,r4
        bl   EndBurnClassStatus
        b    MoveJumpAddress
        
    failed_soundproof:
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  ChangeString ; Sub Target
        
        ; Display soundproof msg.
        ldr r2,=SoundproofStrID
        mov r0,r9
        mov r1,r4
        bl  SendMessageWithIDCheckUTLog
        
        b MoveJumpAddress
        .pool
    .endarea
.close