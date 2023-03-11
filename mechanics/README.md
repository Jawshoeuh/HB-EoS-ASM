# SkyPatches
These skypatches are actually zip files with the extension changed to .skypatch. The inner files can be viewed by changing the extension to .zip and unzipping them.<br/>

# Easier Status Checker Check
This patch is unzipped as it is intended to be uses a a basis for creating your own patch that fits the specific needs of your game. Easier Status Checker Check is a rewrite of the original function that makes it easier to modify the check you want a specific move to do. I have included a few extra checks that don't exist in the base game for convenience. If you need more space in StatusCheckerCheck than it can fit, please use the ExtraSpace patch (overlay36).<br/>

# GenerateFloorRewritten
This patch is a rewrite of the GenerateFloorFunction it makes a few optimizations but should make it easier to edit GenerateFloor to customize dungeon generation to be tailored to the needs of the user.<br/>

# ExtraFloorTypes
This patch requires Overlay36 (ExtraSpace). It replaces the extra Medium Large floor types 12/13/14/15 with a few custom floor types. Feel free to examine it and create your own custom floor types using the baseline work in the patch.<br/>

# SnowGen9
This patch removes the increasced speed from snow and repurposes that space to instead bolster the defense of Ice types in the damage calculation formula.<br/>

# StopKecleonJam
This patch stops the music from being overwritten by entering a Kecleon shop or attempting to runaway from Kecleon. This is useful if you use snd_stream to play custom music in a cutscene before a dungeon as the sounds become a little messed up and play on each other without it...<br/>
