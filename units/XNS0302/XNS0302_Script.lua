-- T3 heavy destroyer

local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local AAGun = import('/lua/nomadsweapons.lua').AAGun
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon
local StingrayCannon1 = import('/lua/nomadsweapons.lua').StingrayCannon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

NSeaUnit = AddNavalLights(NSeaUnit)

XNS0302 = Class(NSeaUnit) {
    Weapons = {
        MainTurret1 = Class(PlasmaCannon) {},
        MainTurret2 = Class(PlasmaCannon) {},
        SideTurret1 = Class(StingrayCannon1) {},
        SideTurret2 = Class(StingrayCannon1) {},
        AATurret = Class(RocketWeapon1) {
            PlayFxMuzzleSequence = function(self, muzzle)
                RocketWeapon1.PlayFxMuzzleSequence(self, muzzle)
                if muzzle == 'RocketLauncher_Muzzle1' then
                    self.unit:RotateAAturretRevolver(1)
                else
                    self.unit:RotateAAturretRevolver(2)
                end
            end,
        },
    },

    LightBone_Left = 'AntennaLeft3',
    LightBone_Right = 'AntennaRight3',
    HideTMD = true,

    OnCreate = function(self)
        NSeaUnit.OnCreate(self)

        local AATurret = self:GetWeaponByLabel('AATurret')
        if AATurret then
            local bp = AATurret:GetBlueprint()
            local RotateSpeed = 90 * (1 / ((1 / (bp.RateOfFire / table.getsize(bp.RackBones))) - 0.2))  -- calc how fast to rotate 90 degrees with current ROF and 0.2 sec free time
            self.AATurretRotators = {
                CreateRotator( self, bp.RackBones[1].RackBone, 'z', 0, RotateSpeed ),
                CreateRotator( self, bp.RackBones[2].RackBone, 'z', 0, RotateSpeed ),
            }
        end

        if self.HideTMD then self:HideBone('TMD', true) end
    end,

    RotateAAturretRevolver = function(self, revolver)
        local angle = self.AATurretRotators[revolver]:GetCurrentAngle()
        if revolver == 1 then
            angle = angle + 90
        else
            angle = angle - 90
        end
        self.AATurretRotators[revolver]:SetGoal(angle)
    end,
}

TypeClass = XNS0302
