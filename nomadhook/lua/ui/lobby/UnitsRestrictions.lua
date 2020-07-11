-- ==========================================================================================
-- * File       : lua/modules/ui/lobby/UnitsRestrictions.lua
-- * Authors    : Gas Powered Games, FAF Community, HUSSAR
-- * Summary    : Contains mappings of restriction presets to restriction categories and/or enhancements
-- * Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ==========================================================================================

--We just add some values to the existing table to add a couple of special cases for nomads units, though most of them work out of the box

Expressions.NUKENAVAL   = "(NUKE * NAVAL) + xnl0403" --the crawler is a sort of naval nuke so if the Sera battleship is disabled the crawler should be as well.