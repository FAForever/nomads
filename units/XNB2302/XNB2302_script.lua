-- T4 artillery
--this one is supposed to be N...FactoryUnit to use buildeffects, but for some reason it crashes game, will make buildable effects later, for now i need unit to work
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local NUtils = import('/lua/nomadsutils.lua')

XNB2302 = Class(NStructureUnit) {
    
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
    end,
    
    OnDestroy = function(self)
        NStructureUnit.OnDestroy(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
		
		--Destroy all orbital on Countdown's death
		local units = self:GetAIBrain():GetListOfUnits(categories.EXPERIMENTAL, false, false)
		local toRemove = {}
		for i, unit in ipairs(units) do
			local name = unit:GetBlueprint().General.UnitName
			
			--abort if another Countdown still exists
			if unit:GetUnitId() == "xnb2302" and unit:GetEntityId() ~= self:GetEntityId() then return end
			if unit:GetUnitId() == "xno2302" then
				toRemove[i] = unit
			end
		end
		
		for _, unit in pairs(toRemove) do
			unit:Kill()
		end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = XNB2302
