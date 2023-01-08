; ------------------------------------------------------------------------------
; Jawshoeuh 1/7/2023 - Confirmed Working 1/8/2023
; This version of Eerie Spell stays more true to the original games by
; Zeroing PP like the move Spite.
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
.definelabel PPZeroedStrID, 0xECE ; 3790
.definelabel FailedStrID, 0xECF ; 3791

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
        
        ; Basiclly just a valid/shield dust check.
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; guaranteed
        bl  RandomChanceUT
        cmp r0,#0
        beq MoveJumpAddress
        
        ; Substitute strings before hand.
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  ChangeString
        
        ; Could branch to DoMoveSpite, but I personally like doing the
        ; work by 'hand' in the ASM effect itself (for precise control).
        ldr r12,[r4,#0xB4]
        add r12,r12,#0x124 ; Monster Move Data
        mov r3,#0  ; Iterator
    loop:
        add  r0,r12,r3, lsl #0x3
        ldrb r1,[r0]
        tst  r1,#0b1    ; test existence bit
        beq  iter_loop  ; invalid move, try again
        tst  r1,#0b10000 ; test last used flag
        beq  iter_loop  ; not last used, try again
        mov  r2,#0
        strb r2,[r0,#0x6] ; Set PP to 0!
        ldr  r2,=PPZeroedStrID
        b    print_msg
    iter_loop:
        add r3,r3,#1
        cmp r3,#4
        blt loop
        
        ldr r2,=FailedStrID
    print_msg: ; I acknowledge this setup is weird and maybe unintuitive.
        mov r0,r9
        mov r1,r4
        bl SendMessageWithIDCheckUTLog
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
