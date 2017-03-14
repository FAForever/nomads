do

-- TODO: make sure all tooltips are in

local NomadsTooltips = {

    -- Options stuff
    options_unitsnd_selection = {
        title = "<LOC NomadsNewOptions0006>Unit selection sounds",
        description = "<LOC NomadsNewOptions0005>Sets the audio response level when selecting units",
    },
    options_unitsnd_acknowledge = {
        title = "<LOC NomadsNewOptions0016>Unit command acknowledge sounds",
        description = "<LOC NomadsNewOptions0015>Sets the audio response level when giving commands to units",
    },

    -- Game menu stuff
    lob_nomads = {
        title = "<LOC tooltip_lobby_nomadsfaction_title>Nomads (should not see this)",
        description = '<LOC tooltip_lobby_nomadsfaction_desc>',
    },
    restricted_units_nomads = {
        title = "<LOC tooltip_lobby_unit_restriction_nonomads_title>No Nomads",
        description = '<LOC tooltip_lobby_unit_restriction_nonomads_desc>',
    },

    -- in game - toggles
    toggle_radar_boost = {
        title = "<LOC tooltip_radar_boost_title>Radar Toggle",
        description = "<LOC tooltip_radar_boost_desc>Turn the selection units radar on/off",
    },
    toggle_bombardmode = {
        title = "<LOC tooltip_bombardmode_title>Bombard Mode Toggle",
        description = "<LOC tooltip_bombardmode_desc>Turn the selection units bombard mode on/off",
    },
    toggle_weapon_no_air = {
        title = "<LOC tooltip_no_air_title>Anti-Air Toggle",
        description = "<LOC tooltip_no_air_desc>Turn the selection units anti-air attack on/off",
    },
    toggle_snipermode = {
        title = "<LOC tooltip_snipermode_title>Sniper Mode Toggle",
        description = "<LOC tooltip_snipermode_desc>Turn sniper mode on/off",
    },
    toggle_capacitor = {
        title = "<LOC tooltip_usecapacitor_title>Capacitor Toggle",
        description = "<LOC tooltip_usecapacitor_desc>Boost unit temporarily (vision range, build power, regeneration) using the capacitor ability. Capacitor is filled when overflowing power and loses stored power when not overflowing.",
    },
    toggle_anchor = {
        title = "<LOC tooltip_anchor_title>Anchor Toggle",
        description = "<LOC tooltip_anchor_desc>Immobilizes the unit",
    },
    toggle_stealthshield_dome = {
        title = "<LOC tooltip_stealthshield_title>Stealth Shield Toggle",
        description = "<LOC tooltip_stealthshield_desc>Turn the select units shield and stealth field on/off",
    },

    -- special ability texts
    specabil_launch_nuke = {
        title = "<LOC SpecAbil_LaunchNuke_title>",
        description = "<LOC SpecAbil_LaunchNuke_desc>",
    },
    specabil_launch_tacmissile = {
        title = "<LOC SpecAbil_LaunchTacMissile_title>",
        description = "<LOC SpecAbil_LaunchTacMissile_desc>",
    },
    specabil_areabombardment = {
        title = "<LOC SpecAbil_AreaBombardment_title>",
        description = "<LOC SpecAbil_AreaBombardment_desc>",
    },
    specabil_areareinforcement = {
        title = "<LOC SpecAbil_AreaReinforcement_title>",
        description = "<LOC SpecAbil_AreaReinforcement_desc>",
    },
    specabil_intelovercharge = {
        title = "<LOC SpecAbil_IntelOvercharge_title>",
        description = "<LOC SpecAbil_IntelOvercharge_desc>",
    },
    specabil_intelprobe = {
        title = "<LOC SpecAbil_IntelProbe_title>",
        description = "<LOC SpecAbil_IntelProbe_desc>",
    },
    specabil_remoteviewing = {
        title = "<LOC SpecAbil_RemoteViewing_title>",
        description = "<LOC SpecAbil_RemoteViewing_desc>",
    },
}

Tooltips = table.merged( Tooltips, NomadsTooltips )

end