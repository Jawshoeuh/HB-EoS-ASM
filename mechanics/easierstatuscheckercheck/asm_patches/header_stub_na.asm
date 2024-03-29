; ------------------------------------------------------------------------------
; Jawshoeuh 2/14/2023
; Will update function names when/if they get added to pmdsky-debug.
; ------------------------------------------------------------------------------
.relativeinclude on
.nds
.arm

.definelabel StatusCheckerCheck, 0x02333074
.definelabel GetApparentWeather, 0x02334D08
.definelabel IsCurrentFixedRoomBossFight, 0x022E0880
.definelabel CanPlaceTrapBelow, 0x022EDC30 ; not in pmdsky-debug
.definelabel MonsterHasNegativeStatus, 0x02300634
.definelabel MonsterHPBelowFourth, 0x023007DC ; not in pmdsky-debug
.definelabel CeilFixedPoint, 0x02051064
.definelabel GetTileAtEntity, 0x022E1628
.definelabel EntityIsValid, 0x02333FAC
.definelabel CanSeeTarget, 0x022E274C
.definelabel SomeDiveDigTileCheck, 0x02337E2C ; not in pmdsky-debug
.definelabel MonsterIsType, 0x02301E50
.definelabel IsMirrorMoveEffectActive, 0x02319748 ; not in pmdsky-debug
.definelabel GravityIsActive, 0x02338390
.definelabel LevitateIsActive, 0x02301E18
.definelabel HasLowHealth, 0x022FB610

.definelabel PTR_DUNGEON_PTR, 0x02353538
.definelabel PTR_CAMOUFLAGE_TYPES, 0x022C6322

.definelabel LAST_MOVE, 558 ; unused, illegal immediate

.definelabel MAX_STAT_BOOST, 20
.definelabel DEFAULT_SPEED, 1
.definelabel MAX_SPEED, 4

.definelabel WEATHER_CLEAR_ID, 0
.definelabel WEATHER_SUN_ID, 1
.definelabel WEATHER_SANDSTORM_ID, 2
.definelabel WEATHER_CLOUDY_ID, 3
.definelabel WEATHER_RAIN_ID, 4
.definelabel WEATHER_HAIL_ID, 5
.definelabel WEATHER_FOG_ID, 6
.definelabel WEATHER_SNOW_ID, 7

.definelabel MAX_STOCKPILE, 3
