do


skins = table.merged( skins, {

    nomads = {
        default = "default",
        texturesPath = "/textures/ui/nomad",
        imagerMesh = "/meshes/game/map-border_squ_uef_mesh",
        imagerMeshHorz = "/meshes/game/map-border_hor_uef_mesh",
        bodyColor = "FFC1782A",
        factionFontOverColor = "FFff0000",
        factionFontDownColor = "FFFFFFFF",
        dialogCaptionColor = "FFD6C6BC",
        dialogColumnColor = "FFC1782A",
        dialogButtonColor = "FF4EAA7F",
        dialogButtonFont = "Zeroes Three",
        highlightColor = "FFA59075",
        disabledColor = "FF3D3630",
        tooltipBorderColor = "FFAF886D",
        tooltipTitleColor = "FF3F1700",
    },
})

skins['default']['cursors'] = table.merged( skins['default']['cursors'], {

    -- cursor format is: texture name, hotspotx, hotspoty, [optional] num frames, [optional] fps
    SPECABIL_Eye = {  '/textures/ui/common/game/cursors/eye-.dds', 15, 15, 11, 2},
    SPECABIL_Nuke = { '/textures/ui/common/game/cursors/nuke.dds', 15, 15 },
})



-- re-flatten after adding Nomads stuff
    for k, v in skins do
        local default = skins[v.default]
        while default do
            -- Copy the entire default chain into the toplevel skin.
            table.assimilate(v, default)

            default = skins[default.default]
        end
    end



end