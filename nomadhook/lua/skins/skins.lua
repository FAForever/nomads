do

skins = table.merged( skins, {

    nomads = {
        default = "uef",
        texturesPath = "/textures/ui/nomad",
        imagerMesh = "/meshes/game/map-border_squ_uef_mesh",
        imagerMeshHorz = "/meshes/game/map-border_hor_uef_mesh",
        buttonFont = "Zeroes Three",
        factionFont = "Zeroes Three",
        bodyFont = "Arial",
        fixedFont = "Arial",
        titleFont = "Zeroes Three",
        fontColor = "FFD8AF97",
        bodyColor = "FFC1782A",
        fontOverColor = "FFFFFFFF",
        fontDownColor = "FF513923",
        dialogCaptionColor = "FFD6C6BC",
        dialogColumnColor = "FFAD976E",
        dialogButtonColor = "FF4EAA7F",
        dialogButtonFont = "Zeroes Three",
        highlightColor = "FFA59075",
        disabledColor = "FF3D3630",
        tooltipBorderColor = "FFAF886D",
        tooltipTitleColor = "FF3F1700",
        tooltipBackgroundColor = "FF000000",
        dialogColumnColor = "FFC1782A",
        menuFontSize = 18,
        layouts = {
            "bottom",
            "left",
            "right"
        },
    },
})

skins['default']['cursors'] = table.merged( skins['default']['cursors'], {

    # cursor format is: texture name, hotspotx, hotspoty, [optional] num frames, [optional] fps
    SPECABIL_Eye = {  '/textures/ui/common/game/cursors/eye-.dds', 15, 15, 11, 2},
    SPECABIL_Nuke = { '/textures/ui/common/game/cursors/nuke.dds', 15, 15 },
})

end