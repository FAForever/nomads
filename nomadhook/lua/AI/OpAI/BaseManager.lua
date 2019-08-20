local fafBaseManager = BaseManager

BaseManager = Class(fafBaseManager) {
    -- Determines if a specific unit needs upgrades, returns name of upgrade if needed
    UnitNeedsUpgrade = function(self, unit, unitType)
        if unit.Dead then
            return false
        end

        -- Find appropriate data about unit upgrade info
        local upgradeTable = false
        if unitType then
            upgradeTable = self.UnitUpgrades[unitType]
        else
            upgradeTable = self.UnitUpgrades[unit.UnitName]
        end

        if not upgradeTable then
            return false
        end

        -- Which table to use to determine upgrade dependencies.
        local crossCheckTable = false
        if unitType == 'DefaultACU' then
            crossCheckTable = self.ACUUpgradeNames
        elseif unitType == 'DefaultSACU' then
            crossCheckTable = self.SACUUpgradeNames
        end

        -- Find unit faction
        local faction = 0
        if EntityCategoryContains(categories.UEF, unit) then
            faction = 'uef'
        elseif EntityCategoryContains(categories.AEON, unit) then
            faction = 'aeon'
        elseif EntityCategoryContains(categories.CYBRAN, unit) then
            faction = 'cybran'
        elseif EntityCategoryContains(categories.SERAPHIM, unit) then
            faction = 'seraphim'
        elseif EntityCategoryContains(categories.NOMADS, unit) then
            faction = 'nomads'
        end

        -- Check upgrade info, if any final upgrades are missing or pre-requisites return true
        for num, upgradeName in upgradeTable do
            -- Check requirements for the upgrade
            if crossCheckTable then
                for uName, uData in crossCheckTable do
                    if not unit:HasEnhancement(upgradeName) then
                        -- Ff can build the upgradeName then return out that specific upgrade; already has requirement
                        if uName == upgradeName and not uData[1] and self:EnhancementFactionCheck(faction, uData[3]) then
                            return upgradeName
                        -- Ff it has a requirement and the requirement isn't built, spit out the requirement
                        elseif uName == upgradeName and uData[1] and self:EnhancementFactionCheck(faction, uData[3]) then
                            if not unit:HasEnhancement(uData[1]) then
                                return uData[1]
                            else
                                return upgradeName
                            end
                        end
                    end
                end
            else
                -- No requirement, return upgrade name
                if not unit:HasEnhancement(upgradeName) then
                    return upgradeName
                end
            end
        end

        return false
    end,

    -- Check if a unit has upgrade
    CheckEnhancement = function(self, unit, upgrade)
        if unit.Dead then
            return false
        end

        -- Find faction of the unit (for ACU and sACU upgrades)
        local faction
        if EntityCategoryContains(categories.UEF, unit) then
            faction = 'uef'
        elseif EntityCategoryContains(categories.CYBRAN, unit) then
            faction = 'cybran'
        elseif EntityCategoryContains(categories.AEON, unit) then
            faction = 'aeon'
        elseif EntityCategoryContains(categories.SERAPHIM, unit) then
            faction = 'seraphim'
        elseif EntityCategoryContains(categories.NOMADS, unit) then
            faction = 'nomads'
        end

        -- Choose which table to find the upgrade data in
        local upgradeTable = false
        if EntityCategoryContains(categories.COMMAND, unit) then
            upgradeTable = self.ACUUpgradeNames
        elseif EntityCategoryContains(categories.SUBCOMMANDER, unit) then
            upgradeTable = self.SACUUpgradeNames
        end

        -- Check upgrades
        if not upgradeTable then
            return true
        end

        for upgradeName, upgradeData in upgradeTable do
            if upgrade == upgradeName then
                for num, fac in upgradeData[3] do
                    if fac == 'all' or faction and faction == fac then
                        if upgradeData[1] then
                            if unit:HasEnhancement(upgradeData[1]) then
                                return true
                            else
                                return false
                            end
                        else
                            return true
                        end
                    end
                end
            end
        end

        return false
    end,
}

-- Table for upgrade requirements for ACU
local ACUUpgradeNames = {
    Teleporter = {false, 'Back', {'aeon', 'cybran', 'seraphim', 'uef'}},
    DoubleGuns = {'GunUpgrade', 'RCH', {'nomads'}},
    GunUpgrade = {false, 'RCH', {'nomads'}},
    IntelProbe = {false, 'RCH', {'nomads'}},
    IntelProbeAdv = {'IntelProbe', 'RCH', {'nomads'}},
    MovementSpeedIncrease = {false, 'LCH', {'nomads'}},
    Capacitor = {false, 'Back', {'nomads'}},
    OrbitalBombardment = {false, 'Back', {'nomads'}},
    PowerArmor = {'RapidRepair', 'Back', {'nomads'}},
    RapidRepair = {false, 'Back', {'nomads'}},
}
-- Table for upgrade requirements for SACU

local SACUUpgradeNames = {
    Capacitor = {false, 'RCH', {'nomads'}},
    AdditionalCapacitor = {'Capacitor', 'RCH', {'nomads'}},
    EngineeringLeft = {false, 'LCH', {'nomads'}},
    EngineeringRight = {false, 'RCH', {'nomads'}},
    GunLeft = {false, 'LCH', {'nomads'}},
    GunLeftUpgrade = {'GunLeft', 'LCH', {'nomads'}},
    GunRight = {false, 'RCH', {'nomads'}},
    LeftRocket = {false, 'LCH', {'nomads'}},
    MovementSpeedIncrease = {false, 'Back', {'nomads'}},
    PowerArmor = {'RapidRepair', 'Back', {'nomads'}},
    Railgun = {false, 'LCH', {'nomads'}},
    RapidRepair = {false, 'Back', {'nomads'}},
    ResourceAllocation = {false, 'RCH', {'aeon', 'cybran', 'uef', 'nomads'}},
    RightRocket = {false, 'RCH', {'nomads'}},
}

for k, v in ACUUpgradeNames do
    BaseManager.ACUUpgradeNames[k] = v
end

for k, v in SACUUpgradeNames do
    BaseManager.SACUUpgradeNames[k] = v
end
