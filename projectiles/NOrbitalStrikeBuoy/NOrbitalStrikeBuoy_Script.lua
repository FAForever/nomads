# acts like a bomb that when dropped calls in an orbital strike

local Buoy1 = import('/lua/nomadprojectiles.lua').Buoy1

NOrbitalStrikeBuoy = Class(Buoy1) {

    OrbitalStrikeData = {
        NumGuns = 1,
        NumStrikes = 3,
        Prio = 1,
    },

    GetSpec = function(self, targetType, targetEntity)
        local spec = Buoy1.GetSpec(self, targetType, targetEntity)

        spec.Guns = self.OrbitalStrikeData.NumGuns or 1
        spec.Prio = self.OrbitalStrikeData.Prio or 1
        spec.Strikes = self.OrbitalStrikeData.NumStrikes or 1

        if targetEntity and IsUnit( targetEntity ) then
            spec.AttachTo = targetEntity
        end

        return spec
    end,

    CreateBuoy = function(self, spec, targetType, targetEntity)
        return import('/lua/nomadbuoys.lua').NOrbitalStrikeBuoy(spec)
    end,
}

TypeClass = NOrbitalStrikeBuoy
