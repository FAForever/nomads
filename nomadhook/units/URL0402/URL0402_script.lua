--------------------------------------------------------------------------
-- File     :  /cdimage/units/URL0402/URL0402_script.lua
-- Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos
-- Summary  :  Cybran Spider Bot Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CDFHeavyMicrowaveLaserGenerator = CybranWeaponsFile.CDFHeavyMicrowaveLaserGenerator
local CDFElectronBolterWeapon = CybranWeaponsFile.CDFElectronBolterWeapon
local CAAMissileNaniteWeapon = CybranWeaponsFile.CAAMissileNaniteWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local CANTorpedoLauncherWeapon = CybranWeaponsFile.CANTorpedoLauncherWeapon

local oldURL0402 = URL0402

URL0402 = Class(oldURL0402) {
    WalkingAnimRate = 1.2,

    Weapons = {
        MainGun = Class(CDFHeavyMicrowaveLaserGenerator) {},
        RightLaserTurret = Class(CDFElectronBolterWeapon) {},
        LeftLaserTurret = Class(CDFElectronBolterWeapon) {},
        RightAntiAirMissile = Class(CAAMissileNaniteWeapon) {},
        LeftAntiAirMissile = Class(CAAMissileNaniteWeapon) {},
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
    },

    OnKilled = function(self, inst, type, okr)
        if self.AmbientExhaustEffectsBag then
            EffectUtil.CleanupEffectBag(self, 'AmbientExhaustEffectsBag')
        end
        if not self.Dead then
            local wep = self:GetWeapon(1)
            if wep.Beams then
                if wep.Audio.BeamLoop and wep.Beams[1].Beam then
                    wep.Beams[1].Beam:SetAmbientSound(nil, nil)
                end
                for k, v in wep.Beams do
                    v.Beam:Disable()
                end
            end
        end
        CWalkingLandUnit.OnKilled(self, inst, type, okr)
    end,
}

TypeClass = URL0402
