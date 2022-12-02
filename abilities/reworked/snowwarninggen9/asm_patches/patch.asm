;-------------------------------------
; Replaces the top screen background
; with one of the others.
;-------------------------------------
.org StringTopBg
.area 0x4
    strhne r5,[r0,0x58]
.endarea
