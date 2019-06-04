-- T2 cruiser

local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local EMPGun = import('/lua/nomadsweapons.lua').EMPGun
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon2

NSeaUnit = AddNavalLights(NSeaUnit)

XNS0202 = Class(NSeaUnit) {
    Weapons = {
        AATurret = Class(RocketWeapon1) {},
        GunTurret = Class(EMPGun) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = EMPGun.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().DamageToShields
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
            end,
        },
        CruiseMissile = Class(TacticalMissileWeapon1) {},
    },

    LightBone_Left = 'Light2',
    LightBone_Right = 'Light1',
    DestructionTicks = 200,
}

TypeClass = XNS0202
