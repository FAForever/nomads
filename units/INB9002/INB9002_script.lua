# civilian structure (no gun)

local AddLights = import('/lua/nomadutils.lua').AddLights
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit

NStructureUnit = AddLights(NStructureUnit)

INB9002 = Class(NStructureUnit) {
    LightBones = { {'Light1', 'Light2', }, {}, {}, {'Light3', 'Light4', }, },

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self:HideBone('Turret', true)
    end,
}

TypeClass = INB9002