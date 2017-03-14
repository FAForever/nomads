-- Adding nomads terrain effects.
-- I would have used the nomads template file if the game allowed me to use the import function in this file. I guess this file
-- is run in a separate layer or when the import function is not available. Going back to hard coding the effects.

local path = '/effects/Emitters/'

TerrainTypes[1]['FXIdle']['Land']['NomadsHoverGroundFx1'] = { path..'nomads_hover_idle01_emit.bp', }
TerrainTypes[1]['FXIdle']['Water']['NomadsHoverGroundFx1'] = { path..'nomads_hover_idle01_emit.bp', }
TerrainTypes[1]['FXMovement']['Land']['NomadsHoverGroundFx1'] = { path..'nomads_hover_moving01_emit.bp', }
TerrainTypes[1]['FXMovement']['Water']['NomadsHoverGroundFx1'] = { path..'nomads_hover_moving01_emit.bp', }

