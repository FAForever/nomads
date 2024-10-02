local AddLights = import('/lua/nomadsutils.lua').AddLights
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit

NStructureUnit = AddLights(NStructureUnit)

--- Civilian Structure (No Gun)
---@class XNB9002 : NStructureUnit
XNB9002 = Class(NStructureUnit) {
    LightBones = { {'Light1', 'Light2', }, {}, {}, {'Light3', 'Light4', }, },

    ---@param self XNB9002
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self:HideBone('Turret', true)
    end,
}
TypeClass = XNB9002