do

local oldXSL0305 = XSL0305

XSL0305 = Class(oldXSL0305) {

    OnScriptBitSet = function(self, bit)
        oldXSL0305.OnScriptBitSet(self, bit)
        if bit == 1 then 
            local bp = self:GetBlueprint()
            self:SetSpeedMult(bp.Physics.LandSpeedMultiplier * math.pow(0.75,2)) # bug in SetSpeedMult fixed, adjusting value to keep same speed
        end
    end,

    OnScriptBitClear = function(self, bit)
        oldXSL0305.OnScriptBitClear(self, bit)
        if bit == 1 then 
            local bp = self:GetBlueprint()
            self:SetSpeedMult(bp.Physics.LandSpeedMultiplier)
        end
    end,
}

TypeClass = XSL0305

end
