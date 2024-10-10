local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

-- upvalue for performance
local CreateRotator = CreateRotator
local TrashBagAdd = TrashBag.Add

--- Tech 1 Tank
---@class XNl0201 : NLandUnit
XNL0201 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },

    ---@param self XNl0201
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        local trash = self.Trash
        self.RotateManip = CreateRotator(self, 'Antenna', 'x'):SetSpeed( 90 )
        self.RotateManip:SetGoal( 90 )
        TrashBagAdd(trash,(self.RotateManip))
    end,

    ---@param self XNl0201
    ---@param Weapon Weapon
    OnGotTarget = function(self, Weapon)
        self.RotateManip:SetGoal( 90 )
        NLandUnit.OnGotTarget(self, Weapon)
    end,

    ---@param self XNl0201
    ---@param Weapon Weapon
    OnLostTarget = function(self, Weapon)
        self.RotateManip:SetGoal( 90 )
        NLandUnit.OnLostTarget(self, Weapon)
    end,
}
TypeClass = XNL0201