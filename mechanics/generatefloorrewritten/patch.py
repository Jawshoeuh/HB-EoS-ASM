#  Copyright 2020-2022 Capypara and the SkyTemple Contributors
#
#  This file is part of SkyTemple.
#
#  SkyTemple is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SkyTemple is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SkyTemple.  If not, see <https://www.gnu.org/licenses/>.
from typing import Callable

from ndspy.rom import NintendoDSRom

from skytemple_files.common.util import read_u32, get_binary_from_rom
from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.category import PatchCategory
from skytemple_files.patch.handler.abstract import AbstractPatchHandler#, DependantPatch
from skytemple_files.common.i18n_util import f, _

ORIGINAL_INSTRUCTION = 0xE3A08000
OFFSET_US = 0x5E4A4
OFFSET_EU = 0x5E748

class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'GenerateFloorRewritten'

    @property
    def description(self) -> str:
        return "A rewrite of GenerateFloor to base changes off of."

    @property
    def author(self) -> str:
        return 'HeckaBad'

    @property
    def version(self) -> str:
        return '0.1.0'

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
         overlay29 = get_binary_from_rom(rom, config.bin_sections.overlay29)
         if config.game_version == GAME_VERSION_EOS:
             if config.game_region == GAME_REGION_US:
                 return read_u32(overlay29, OFFSET_US) != ORIGINAL_INSTRUCTION
             if config.game_region == GAME_REGION_EU:
                 return read_u32(overlay29, OFFSET_EU) != ORIGINAL_INSTRUCTION
         raise NotImplementedError()

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        # Apply the patch
        apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()
