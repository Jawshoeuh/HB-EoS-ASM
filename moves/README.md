# Custom
Contains custom moves that don't originate from any Pokemon game.

# Examples
Generic moves that can serve as the base for other moves and for help creating your own.

# Legacy
Contains old version of moves that either functioned differently or were vastly improved.

# Postgen4
Contains moves added after Gen 4 (Diamond/Pearl/Platinum/HG/SS)

# Reworked
Contains moves that had effects in the original game, but with a different type of effect.
# Importing Moves Into Skytemple
To import these ASM move effects into SkyTemple (1.4.2)...
1. Apply the ExtractMoveCode patch under ASM->Utility.
2. Go to ASM->Move Effects->Effects Code
3. Press + to add a new effect.
4. Go to the Move Effects tab and find the move you want to give the effect to. Change it to the newly created effect code number.
5. Save + Reload and double check the move effect works (Do not use your savestates in SkyTemple as they may not reflect the asm changes).

# Warning
The following moves (credit to Espik for testing them) have placeholder names and are used. Do not use them for your new move. <br/>
421: Secret Bazaar Escape <br/>
422: Secret Bazaar Cleanse <br/>
423: Secret Bazaar Healing Beam <br/>
424: Spurn Orb <br/>
425: Foe-Hold Orb <br/>
426: All-Mach Orb <br/>
427: Foe-Fear Orb <br/>
428: All-Hit Orb <br/>
429: Foe-Seal Orb <br/>
547: Dig second half <br/>
548: Razor Wind second half <br/>
549: Focus Punch second half <br/>
550: Sky Attack second half <br/>
551: SolarBeam second half <br/>
552: Fly second half <br/>
553: Dive second half <br/>
554: Bounce second half <br/>
555: Skull Bash second half <br/>
556: Ghost-type Curse animation <br/>

Additional regular moves that I have found you should not replace.
031: Weather Ball (has a special type check in GetMoveTypeForMonster <br/>
064: Thunder (has a special accuracy check in MoveHitCheck) <br/>
270: Blizzard (has a special accuracy check in MoveHitCheck) <br/>
324: Hidden Power (has a special check in GetMoveTypeForMonster) <br/>
471: Natural Gift (has a special check in GetMoveTypeForMonster) <br/>

