-- T3 SMD

-- TODO: make this a normal anti-nuke. Currently the game errors out on the weapon which does not exist

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local StrategicMissileDefenseWeapon = import('/lua/nomadweapons.lua').StrategicMissileDefenseWeapon
local nukeFiredOnGotTarget = false

INB4302 = Class(NStructureUnit) {

    Weapons = {
        AntiNuke = Class(StrategicMissileDefenseWeapon) {

            IdleState = State(StrategicMissileDefenseWeapon.IdleState) {

                OnGotTarget = function(self)
                    local bp = self:GetBlueprint()
                    --only say we've fired if the parent fire conditions are met
                    if (bp.WeaponUnpackLockMotion ~= true or (bp.WeaponUnpackLocksMotion == true and not self.unit:IsUnitState('Moving'))) then
                        if (bp.CountedProjectile == false) or self:CanFire() then
                             nukeFiredOnGotTarget = true
                        end
                    end
                    StrategicMissileDefenseWeapon.IdleState.OnGotTarget(self)
                end,

                -- uses OnGotTarget, so we shouldn't do this.
                OnFire = function(self)
                    if not nukeFiredOnGotTarget then
                        StrategicMissileDefenseWeapon.IdleState.OnFire(self)
                    end
                    nukeFiredOnGotTarget = false
                    
                    self:ForkThread(function()
                        self.unit:SetBusy(true)
                        WaitSeconds(1/self.unit:GetBlueprint().Weapon[1].RateOfFire + .2)
                        self.unit:SetBusy(false)
                    end)
                end,
            },    
        },
    },
}

TypeClass = INB4302