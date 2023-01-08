; ------------------------------------------------------------------------------
; Jawshoeuh 11/12/2022 - Confirmed Working 1/8/2023
; Snarl deals damage and lowers the opponent's special attack. Despite
; being so simple, there is a lot of work behind the scenes because snarl
; is a sound based move.
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
.definelabel SoundproofAbilityID, 0x3C ; 60
.definelabel SoundproofStrID, 0xEB9 ; 3769

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
    
        ; There is a list of sound moves in the base game. A skypatch could
        ; be added to make a specific move id return positive, but this
        ; is more useful ease of use across multiple hacks. Before we do
        ; anything, check if the target has soundproof.
        mov r0,r4
        mov r1,SoundproofAbilityID
        bl  HasAbility
        cmp r0,#0
        mov r10,#0
        bne failed_soundproof
    
        ; Now do stuff.
        sub sp,sp,#0x8
        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        beq unallocate_memory
        mov r10,#1
        
        ; Basiclly just a valid/shield dust check.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; guaranteed
        bl  RandomChanceUT
        cmp r0,#0
        beq unallocate_memory
        
        ; Lower special attack if hit target.
        mov r12,#0
        str r12,[sp,#0x4] ; don't display message on failure
        str r10,[sp,#0x0] ; check items/abilities, r10 = 1 here
        mov r0,r9
        mov r1,r4
        mov r2,#1 ; special attack
        mov r3,#1 ; 1 stage
        bl  AttackStatDown
        
    unallocate_memory:
        add sp,sp,#0x8
        b MoveJumpAddress
        
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
