#  Copyright 2020 Parakoopa
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

from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.handler.abstract import AbstractPatchHandler

PATCH_STRING = b'strhne r5,[r0,0x58]'
PATCH_STRING_ADDR_O11_US = 0x470BC

class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'SnowWarningGen9'

    @property
    def description(self) -> str:
        return "Makes the ability Snow Warning cause Snow instead of Hail"

    @property
    def author(self) -> str:
        return 'HeckaBad'

    @property
    def version(self) -> str:
        return '0.1.0'

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        ov11 = rom.loadArm9Overlays([11])[11].data
        if config.game_version == GAME_VERSION_EOS:
            if config.game_region == GAME_REGION_US:
                return ov11[PATCH_STRING_ADDR_O11_US:PATCH_STRING_ADDR_O11_US + len(PATCH_STRING)] == PATCH_STRING
            if config.game_region == GAME_REGION_EU:
                raise NotImplementedError()
        raise NotImplementedError()

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        # First make absolute sure, that we aren't doing it again by accident, this isn't supported.
        if self.is_applied(rom, config):
            raise RuntimeError("This patch can not be re-applied.")

        # Apply the patch
        apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()
