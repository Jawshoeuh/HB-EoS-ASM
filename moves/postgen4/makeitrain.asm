; ------------------------------------------------------------------------------
; Jawshoeuh 11/28/2022 - Confirmed Working 1/5/2023
; Make It Rain deals damage, drops coins and lowers user special attack.
; Unfortunately, the special attack is lowered after the first target.
; HOWEVER, I wont be fixing this because Draco Meteor does this too (and
; that sounds like a lotta work).
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
.definelabel EntityIsValid, 0x22E0354
.definelabel GenerateStandardItem, 0x02344BD0
.definelabel SpawnItemDrop, 0x0232A834 ; may be poorly named...

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel EntityIsValid, 0x0022E0C94
;.definelabel GenerateStandardItem, 0x23457B4
;.definelabel SpawnItemDrop, 0x???????? ; may be poorly named...

; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        sub sp,sp,#0x10
        
        ; Deal damage.
        str r7,[sp]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; normal damage
        bl  DealDamage
        
        ; Return if no damage.
        cmp r0,#0
        mov r10,#0
        beq unallocate_memory
        
        ; Check if monster died.
        mov r0,r4
        bl  EntityIsValid
        cmp r0,#0x0
        bne entity_lived
        
        ; Cha ching cha ching (create money if entity died).
        ; Based off of DoMovePayDay (around 0x0232A390 NA)
        ; Create Poke.
        add r0,sp,#0x8
        mov r12,#0x0
        str r12,[sp,#0x4] ; original uses two strh's to do this
        mov r1,#0xB7
        mov r2,#0x2
        bl  GenerateStandardItem
        
        ; Drop Poke on ground.
        add  r2,sp,#0x8
        add  r3,sp,#0x4
        mov  r0,r9
        mov  r1,r4
        bl   SpawnItemDrop
        
    entity_lived:
        ; I don't know why, I don't want to know why, but Draco Meteor does
        ; this while Overheat does something much simpler and causes the
        ; special to lower 2 stages. UNFORTUNATELY, I need to lower special
        ; attack 1 stage. AHHHHHHHHHHHHH. Don't know where 0x78 comes from
        ; don't care either. I mean obviously it's something on the stack.
        ; Maybe the number of this target.
        
        ldr r0,[sp,#0x88] ; Some magical expletive value (0x78 from call)
        cmp r0,#0x0
        bne unallocate_memory
    
        ; Lower special attack if last target.
        mov r0,r9
        mov r1,r9
        mov r2,#1 ; special attack
        mov r3,#1 ; 1 stage
        bl  AttackStatDown
        
        mov r10,#1
    unallocate_memory:
        add sp,sp,#0x10
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close