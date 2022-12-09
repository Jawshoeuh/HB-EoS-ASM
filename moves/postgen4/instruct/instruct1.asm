; ------------------------------------------------------------------------------
; Jawshoeuh 12/7/2022 - Confirmed Working 12/7/2022
; Instruct(v1) causes the target to regular attack an enemy nearby.
; Check out instruct2 for a version that causes the target to use
; the first move that it knows.
; Check out instruct3 for a version that causes the rarget to use
; the last move that it used.
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
.definelabel RegularAttackOrStruggle, 0x022F6058
.definelabel ChangeDirection, 0x023049A8
.definelabel DIRECTIONS_XY, 0x0235171C
.definelabel ButNothingStr, 0xE64
.definelabel GetTile, 0x023360FC

; For EU
;.include "lib/stdlib_eu.asm"
;.include "lib/dunlib_eu.asm"
;.definelabel MoveStartAddress, 0x02330B74
;.definelabel MoveJumpAddress, 0x0233310C
;.definelabel RegularAttackOrStruggle, 0x????????
;.definelabel ChangeDirection, 0x????????
;.definelabel DIRECTIONS_XY, 0x02352328
;.definelabel GetTile, 0x2336CCC


; File creation
.create "./code_out.bin", 0x02330134 ; Change to the actual offset as this directive doesn't accept labels
    .org MoveStartAddress
    .area MaxSize ; Define the size of the area
        ; Choose five scratch registers
        push {r5,r6,r7,r8,r9}
        ldr  r5,=DIRECTIONS_XY ; Direction Array
        ldr  r0,[r4,#0xb4]
        ldrb r6,[r0,#0x4c]     ; Target Direction
        ldrh r7,[r4,#0x4]      ; Target X Pos
        ldrh r8,[r4,#0x6]      ; Target Y Pos
        mov  r9,r6             ; Target Direction (const)
        b skip_check
    
    ; 'Spin' and look around the target for an enemy!
    spin_search: ; increment loop
        add r6,r6,#1
        and r6,r6,#7
        cmp r6,r9
        beq failure_no_target
    skip_check:
        mov   r2,r6, lsl #0x2     ; Array Offset For Dir Value
        add   r3,r5,r6, lsl #0x2  ; Array Offset For Dir Value
        ldrsh r0,[r5,r2]          ; X Offset
        ldrsh r1,[r3,#0x2]        ; Y Offset
        add   r0,r0,r7            ; X + Offset
        add   r1,r1,r8            ; Y + Offset
        bl    GetTile
        ldr   r0,[r0,#0xc]        ; Get Monster on Tile
        cmp   r0,#0
        beq   spin_search         ; no monster found
        ; Check if friend or enemy.
        ldr   r12,[r0,#0xb4]
        ldrb  r1,[r12,#0x6]
        ldrb  r2,[r12,#0x8]
        eor   r1,r1,r2 ; 1 = enemy, 0 = friend
        ldr   r12,[r4,#0xb4]
        ldrb  r2,[r12,#0x6]
        ldrb  r3,[r12,#0x8]
        eor   r2,r2,r3 ; 1 = enemy, 0 = friend
        cmp   r1,r2
        beq   spin_search ; failed on, same team
        
        ; Modify our direction
        ldr  r1,[r4,#0xb4]
        strb r6,[r1,#0x4c] ; Change internal direction
        mov  r0,r4   ; r0 = monster
        mov  r1,#0x6 ; r1 = unknown, 0x6 in all calls I saw
        mov  r2,r6   ; r2 = new direction
        bl   ChangeDirection ; game crash without this call
        
        ; Execute regular attack.
        mov r0,r4        ; r0 = monster
        mov r1,#0x1      ; r1 = move id (0x163 for regular attack)
        rsb r1,r1,#0x164 ; workaround because 0x163 not allowed immediate
        bl  RegularAttackOrStruggle
        
        pop {r5,r6,r7,r8,r9}
        mov r10,#1
        b MoveJumpAddress
    failure_no_target:
        pop {r5,r6,r7,r8,r9}
        ldr r2,=ButNothingStr
        mov r0,r9
        mov r1,r4
        bl SendMessageWithIDCheckUTLog
        mov r10,#0
        ; Always branch at the end
        b MoveJumpAddress
        .pool
    .endarea
.close