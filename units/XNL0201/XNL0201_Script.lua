local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

--- Tech 1 Tank
---@class XNl0201 : NLandUnit
XNL0201 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },

    ---@param self XNl0201
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self.RotateManip = CreateRotator(self, 'Antenna', 'x'):SetSpeed( 90 )
        self.RotateManip:SetGoal( 90 )
        self.Trash:Add(self.RotateManip)
    end,

    ---@param self XNl0201
    ---@param Weapon string
    OnGotTarget = function(self, Weapon)
        self.RotateManip:SetGoal( 0 )
        NLandUnit.OnGotTarget(self, Weapon)
    end,

    ---@param self XNl0201
    ---@param Weapon string
    OnLostTarget = function(self, Weapon)
        self.RotateManip:SetGoal( 90 )
        NLandUnit.OnLostTarget(self, Weapon)
    end,
}
TypeClass = XNL0201