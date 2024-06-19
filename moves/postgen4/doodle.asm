; -------------------------------------------------------------------------
; Jawshoeuh 11/29/2022 - Todo
; Doodle changes the abilities of all allies to the ability of the target.
; Unfortunately, we need to check for an enemy for every target which is
; a bit wasteful, but I don't see a way around it...
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
.definelabel GetTile, 0x23360FC
.definelabel SubstitutePlaceholderStringTags, 0x22E2AD8
.definelabel LogMessageWithPopupCheckUserTarget, 0x234B3A4
.definelabel DIRECTIONS_XY, 0x235171C
.definelabel DUNGEON_PTR, 0x2353538

; For EU (uncomment for EU)
;.definelabel MoveStartAddress, 0x2330B74
;.definelabel MoveJumpAddress, 0x233310C
;.definelabel TryEndStatusWithAbility, 0x22FB1E8
;.definelabel GetTile, 0x2336CCC
;.definelabel SubstitutePlaceholderStringTags, 0x22E3418
;.definelabel LogMessageWithPopupCheckUserTarget, 0x234BFA4
;.definelabel DIRECTIONS_XY, 0x2352328
;.definelabel DUNGEON_PTR, 0x2354138

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel NULL, 0x0

; File creation
.create "./code_out.bin", 0x02330134 ; Change to 0x02330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        mov r10,FALSE
        
        ; Attempt to find a target in front of user.
        ldr   r0,[r9,#0xB4] ; entity->monster
        ldrb  r1,[r0,#0x4C] ; entity->action->direction
        ldr   r12,=DIRECTIONS_XY  ; See Note 1 Below
        mov   r2,r1, lsl #0x2     ; Array Offset For Dir Value
        add   r3,r12,r1, lsl #0x2 ; Array Offset For Dir Value
        ldrsh r0,[r12,r2]          ; X Offset
        ldrsh r1,[r3,#0x2]         ; Y Offset
        ldrh  r2,[r9,#0x4]         ; User X Pos
        ldrh  r3,[r9,#0x6]         ; User Y Pos
        
        ; Add values together
        add r0,r0,r2
        add r1,r1,r3
        
        ; Check tile for monster.
        bl    GetTile
        ldr   r12,[r0,#0xC]
        cmp   r12,NULL
        beq   MoveJumpAddress ; failed, no monster
        mov   r10,TRUE
        
        ; Load that monsters abiilities
        ldr  r0,[r12,#0xB4]
        ldrb r1,[r0,#0x60]
        ldrb r0,[r0,#0x61]
        
        ; Store that monsters abilities
        ldr  r2,[r4,#0xB4]
        strb r1,[r2,#0x60]
        strb r0,[r2,#0x61]
        
        ; When giving self ability, display feedback message.
        ldr r1,[sp,#0x78] ; Appears to be number of target in a loop.
        cmp r1,#0
        bne skip_message
        mov r0,#1
        mov r1,r12
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; Target
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl  SubstitutePlaceholderStringTags ; User
        mov r0,r9
        mov r1,r9
        ldr r2,=doodle_str
        bl  LogMessageWithPopupCheckUserTarget
        
        ; Set flag for dungeon to activate artificial weather abilities.
        mov   r0,TRUE
        ldr   r1,=DUNGEON_PTR
        ldrsh r2,[r1,#0x0]
        strb  r0,[r2,#0xE] ; dungeon->activate_artificial_weather_flag = true
        
        ; Make user worth more exp (to keep parity with the game, uncertain
        ; why the game rewards more exp from monsters if they change their
        ; ability.)
        ldr    r3,[r9,#0xB4]  ; entity->monster
        ldrb   r0,[r3,#0x108] ; monster->statuses->exp_yield
        cmp    r0,#0x0
        moveq  r0,#0x1
        streqb r0,[r3,#0x108] ; monster->statuses->exp_yield
        
    skip_message:
        ; Check if this new ability would end a status condition currently
        ; inflicted on the monster.
        mov r0,r9
        mov r1,r4
        bl  TryEndStatusWithAbility
        
        b   MoveJumpAddress
        .pool
    doodle_str:
        .asciiz "[string:0] gave all nearby allies[R]the abilities of [string:1]!"
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