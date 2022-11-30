; ------------------------------------------------------------------------------
; Jawshoeuh 11/30/2022
; Changes Snow Warning to summon Snow instead of Hail like in Gen9+
; Based on the template provided by https://github.com/SkyTemple
; ------------------------------------------------------------------------------
.nds
.open "overlay_0029.bin", 0x22DC240

    .org 0x22f93bc
    .area 0x4
    strhne r5,[r0,0x58]
    .endarea
    
.close