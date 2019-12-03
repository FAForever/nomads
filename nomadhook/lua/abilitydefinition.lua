do

abilities = table.merged( abilities, {

    ShowPosition = {
        UISlot = 1, -- which slot should this order go into.
        script = 'ShowPosition', -- which script to use .. these are in /lua/sim/tasks/
        UIBitmapId = 'repair', -- these are in /game/orders/
        UIHelpText = 'ShowPosition', --this can use the LOC< blah> system if you wish, make sure you enter the data into the correct loc table.
        cursor = 'RULEUCC_Capture', --these are defined in skins.lua

        --important entry... we need this set to false to activate the ability,
        --basicly were saying a unit does not need to be selected to activate the ability script.
        --if this is nil or true then the abilty needs units to be selected to activate.
        --usage types are: Event, Selected or Valid
        usage = 'Event',

        --mouse decal.
        --entering data into this table will show a decal on the mouse WHEN the ability is activated if decal = true.
        --we do not need to specify a full path to the texture IF its a default game decal, however
        --if you want to use your own custom decal you will have to add this to your textures folder in the nomads.scd,
        --dms will find textures in a mods folder.. so its not a problem for me.. nor you i suspect.
        MouseDecal = {
            decal = true,
            size = 5,
            texture = '/game/AreaTargetDecal/nuke_icon_small.dds',
        },

        --any information contained in this table will be available in the task script.. in commandData
        ExtraInfo = {
            CoolDownTime = 10,
            AbilMinRange = 10,  -- minimum range, 0 means no range limit, def = 0
            AbilMaxRange = 100, -- maximum range, 0 means no range limit, def = 0
        },
    },

-- TODO: active ability decals for most

    LaunchNuke = {
        UIBitmapId = 'nuke',
        cursor = 'RULEUCC_Tactical',
        enabled = true,
        ExtraInfo = {},
        UIHelpText = 'specabil_launch_nuke',
        UISlot = 1,
        script = 'LaunchNuke',
        usage = 'Event',

        UIBehaviorSingleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            DragDelta = 0,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            AllReticulesAtStart = true,
            DragDelta = 2,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
    },

    LaunchTacMissile = {
        UIBitmapId = 'tactical',
        cursor = 'RULEUCC_Tactical',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = true,
            NumReticules = 1,
        },
        UIHelpText = 'specabil_launch_tacmissile',
        UISlot = 2,
        script = 'LaunchTacMissile',
        usage = 'Event',

        UIBehaviorSingleClick = {
            DragDelta = 0,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadsAreaBombardment = {
        UIBitmapId = 'area-assist',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = true,
            NumReticules = 1,
        },
        UIHelpText = 'specabil_areabombardment',
        UISlot = 3,
        script = 'NomadsAreaBombardment',
        usage = 'Event',

        UIBehaviorSingleClick = {
            DragDelta = 1,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            AllReticulesAtStart = true,
            DragDelta = 2,
            UseSelected = true,
        },

--        SoundReady = 'OrbitalStrikeReady',
--        SoundLaunched = 'OrbitalStrikeLaunched',

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadsIntelProbe = {
        UIBitmapId = 'intelprobe',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            CoolDownTime = 60,
            DoRangeCheck = false,
            Lifetime = 60,
        },
        UIHelpText = 'specabil_intelprobe',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 4,
        preferredSlot = 10,
        script = 'NomadsIntelProbe',
        usage = 'Event',

        SoundReady = 'IntelProbeReady',
        SoundLaunched = 'IntelProbeLaunched',

        UIBehaviorSingleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = false,
            DragDelta = 0,
            ReticuleSizeOverride = 70,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        
        AbilityRequirement = function(unit)
            return UnitData[unit:GetEntityId()].HasIntelProbeAbility
        end,
    },

    NomadsIntelProbeAdvanced = {
        UIBitmapId = 'intelprobe',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            CoolDownTime = 60,
            DoRangeCheck = false,
            Lifetime = 30,
        },
        UIHelpText = 'specabil_intelprobe',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 4,
        preferredSlot = 10,
        script = 'NomadsIntelProbeAdvanced',
        usage = 'Event',

-- TODO: Perhaps these sound vars should be in an Audio section to conform to for example units?
        SoundReady = 'IntelProbeReady',
        SoundLaunched = 'IntelProbeLaunched',

        UIBehaviorSingleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = false,
            DragDelta = 0,
            ReticuleSizeOverride = 35,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        
        AbilityRequirement = function(unit)
            return UnitData[unit:GetEntityId()].HasIntelProbeAdvancedAbility
        end,
    },

    TargetLocation = {
        UIBitmapId = 'skry-target',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = false,
            Radius = 45,

            NumReticules = 10,

        },
        UIHelpText = 'specabil_remoteviewing',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 1,
        script = 'TargetLocation',
        usage = 'Event',

        UIBehaviorSingleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            AllReticulesAtStart = false,
            DragDelta = 1,
            UseSelected = true,
        },

        UIBehaviorDoubleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = false,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
    },
    
    Capacitor = {
        preferredSlot = 9,
        onframe = function (self, deltaTime)
            local UIUtil = import('/lua/ui/uiutil.lua')
            
            --ask what state the capacitors are in
            local CapacitorState = false
            for i,unit in import('/lua/ui/game/orders.lua').GetCurrentSelection() do
                if unit and not unit.Dead then
                    CapacitorState = UnitData[unit:GetEntityId()].CapacitorState --'Charging' 'Discharging' 'Filled' 'Unfilled'
                end
            end
            
            --capacitor switches icon to a disabled icon when discharging
            if CapacitorState == 'Discharging' and not self:IsDisabled()then 
                self:Disable()
            elseif CapacitorState ~= 'Discharging' and self:IsDisabled() then
                self:Enable()
            end
            
            --setting textures is a bit of a mess. There are 4 states but toggle buttons have two. So we need to mess with them a bit.
            
            local bitmapId = CapacitorState or "unfilled"
            local button_prefix = "/game/orders/" .. bitmapId .. "_btn_"
            local textures = {
                button_prefix .. "up.dds",
                button_prefix .. "up_sel.dds",
                button_prefix .. "over.dds",
                button_prefix .. "over.dds",
                button_prefix .. "dis.dds",
                button_prefix .. "dis.dds",
            }
            --make the discharging capacitor icon green, even though its disabled
            if CapacitorState == "Discharging" then
                textures[6] = textures[2]
            end
            
            self:SetNewTextures(
                    UIUtil.SkinnableFile(textures[1], true),
                    UIUtil.SkinnableFile(textures[2], true),
                    UIUtil.SkinnableFile(textures[3], true),
                    UIUtil.SkinnableFile(textures[4], true),
                    UIUtil.SkinnableFile(textures[5], true),
                    UIUtil.SkinnableFile(textures[6], true))
            
            if self._isAutoMode then
                self.autoModeIcon:SetAlpha(1)
            else
                self.autoModeIcon:SetAlpha(0)
            end
            
            --when unchecked, the icon shows a full battery, shown during charging
            self:SetCheck(CapacitorState ~= 'Charging')
        end,
        
        behavior = function(self, modifiers)
            local controls = import('/lua/ui/controls.lua').Get()
            if modifiers.Left then
                local cb = { Func = 'ActivateCapacitor'}
                SimCallback(cb, true)
            elseif modifiers.Right then
                self._curHelpText = self._data.helpText
                
                --toggle the autocapacitor mode
                self._isAutoMode = not self._isAutoMode
                
                if controls.mouseoverDisplay.text then
                    controls.mouseoverDisplay.text:SetText(self._curHelpText)
                end
                
                local cb = { Func = 'AutoCapacitor', Args = { auto = self._isAutoMode == true }}
                SimCallback(cb, true)
            end
            
            --update icon
            if self._isAutoMode then
                self.autoModeIcon:SetAlpha(0)
            else
                self.autoModeIcon:SetAlpha(1)
            end
        end,
        
        initialStateFunc = function(control, unitList)
            local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
            local UIUtil = import('/lua/ui/uiutil.lua')
            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            
            if not control.autoModeIcon then
                control.autoModeIcon = Bitmap(control, UIUtil.UIFile('/game/orders/autocast_green.dds'))
                LayoutHelpers.AtCenterIn(control.autoModeIcon, control)
                control.autoModeIcon:DisableHitTest()
                control.autoModeIcon:SetAlpha(0)
                control.autoModeIcon.OnHide = function(self, hidden)
                    if not hidden and control:IsDisabled() then
                        return true
                    end
                end
            end

            if not control.mixedModeIcon then
                control.mixedModeIcon = Bitmap(control.autoModeIcon, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
                LayoutHelpers.AtRightTopIn(control.mixedModeIcon, control)
                control.mixedModeIcon:DisableHitTest()
                control.mixedModeIcon:SetAlpha(0)
                control.mixedModeIcon.OnHide = function(self, hidden)
                    if not hidden and control:IsDisabled() then
                        return true
                    end
                end
            end

            control._isAutoMode = UnitData[unitList[1]:GetEntityId()].AutoCapacitor == true

            control._curHelpText = control._data.helpText
            if control._isAutoMode then
                control.autoModeIcon:SetAlpha(1)
            else
                control.autoModeIcon:SetAlpha(0)
            end

            -- needs to override this to prevent call to self:DisableHitTest()
            control.Disable = function(self)
                self._isDisabled = true
                self:OnDisable()
            end
        end,
        
        AbilityRequirement = function(unit)
            return UnitData[unit:GetEntityId()].HasCapacitorAbility
        end,
    }
})

end
