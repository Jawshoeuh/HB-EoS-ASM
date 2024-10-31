; -------------------------------------------------------------------------
; Jawshoeuh 6/19/2024 - Confirmed Working 10/29/2024
; Doodle changes the abilities of all allies to the ability of the target.
; This move is intended to only target a single enemy.
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
.definelabel TryEndStatusWithAbility, 0x22FA7DC
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel EntityIsValid, 0x232800C
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryEndStatusWithAbility, 0x22FB1E8
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel EntityIsValid, 0x2328A78
;.definelabel DUNGEON_PTR, 0x2354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel NULL, 0x0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        push r5,r6,r7,r8,r10,r11
        mov r10,TRUE
        
        ; Load target monsters abiilities
        ldr  r0,[r4,#0xB4] ; entity->monster
        ldrb r5,[r0,#0x60] ; monster->abilities[0]
        ldrb r6,[r0,#0x61] ; monster->abilities[1]
        
        ; Check user alignment to figure out which monsters to check.
        ldr   r12,[r9,#0xB4] ; entity->monster
        ldrb  r0,[r12,#0x6]  ; monster->is_not_team_member
        ldrb  r2,[r12,#0x8]  ; monster->is_ally
        eor   r12,r0,r2      ; 1 = enemy, 0 = friend
        cmp   r12,#0
        mov   r8,#0x12800
        orrne r7,r8,#0x338 ; r7 = 0x12B38 (Start Enemy, inclusive)
        orrne r8,r8,#0x378 ; r8 = 0x12B78 (End Enemy, not inclusive)
        orreq r7,r8,#0x328 ; r7 = 0x12B28 (Start Ally, inclusive)
        orreq r8,r8,#0x338 ; r8 = 0x12B38 (End Ally, not inclusive)
        ldr   r1,=DUNGEON_PTR
        ldr   r10,[r1,#0x0]
        ability_sharing_loop:
            ldr   r11,[r10,r7]
            mov   r0,r11
            bl    EntityIsValid
            cmp   r0,FALSE
            beq   ability_sharing_loop_iter
            ldr   r0,[r11,#0xB4] ; entity->monster
            strb  r5,[r0,#0x60] ; monster->abilities[0]
            strb  r6,[r0,#0x61] ; monster->abilities[1]
            ability_sharing_loop_iter:
                add r7,r7,#0x4
                cmp r7,r8
                blt ability_sharing_loop
                
        ; Feedback message.
        mov r0,#1
        mov r1,r4
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,r9
        mov r1,r4
        ldr r2,=doodle_str
        bl  LogMessageWithPopupCheckUserTarget
        
        ; Make user worth more exp (to keep parity with the game, uncertain
        ; why the game rewards more exp from monsters if they change their
        ; ability.)
        ldr    r3,[r9,#0xB4]  ; entity->monster
        ldrb   r0,[r3,#0x108] ; monster->statuses->exp_yield
        cmp    r0,#0x0
        moveq  r0,#0x1
        streqb r0,[r3,#0x108] ; monster->statuses->exp_yield
        
        ; Set flag for dungeon to activate artificial weather abilities.
        mov   r0,TRUE
        ldr   r1,=DUNGEON_PTR
        ldr   r2,[r1,#0x0]
        strb  r0,[r2,#0xE] ; dungeon->activate_artificial_weather_flag = true
        
    return:
        pop r5,r6,r7,r8,r10,r11
        b   MoveJumpAddress
        .pool
    doodle_str:
        .asciiz "[string:0] gave all allies the[R]abilities of [string:1]!"
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