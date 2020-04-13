-- A proximity detector is an entity with a large collision sphere attached to another entity or unit. It can detect projectiles when
-- the projectile crosses the collision sphere. When that happens an event is triggered, allowing the parent entity to do react.

local Entity = import('/lua/sim/Entity.lua').Entity


function ProximityDetector(SuperClass)
    return Class(SuperClass) {

        CreateProximityDetector = function(self, Name, Radius, Category, AlertIfOwnArmy, AlertIfAlliedArmy, AlertIfEnemyArmy)
            local spec = {
                Name = Name,
                Owner = self,
                Radius = Radius or 0,
                Category = Category or '',
                AlertIfEnemyArmy = AlertIfEnemyArmy or true,
                AlertIfAlliedArmy = AlertIfAlliedArmy or false,
                AlertIfOwnArmy = AlertIfOwnArmy or false,
            }
            self.MyProximityDetector = ProxDetectEntity(spec)
            if self.Trash then
                self.Trash:Add(self.MyProximityDetector)
            end
            return self.MyProximityDetector
        end,

        OnProximityAlert = function(self, other, radius, proxDetectorName)
            -- called when the proximity detector detects something so hook this. Doesn't detect units though!
        end,
    }
end

ProxDetectEntity = Class(Entity) {

    __init = function(self, spec)
        --LOG('__ProxDetectEntity')
        Entity.__init(self, spec)
        self.Name = spec.Name or ''
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.Category = spec.Category
        self.AlertIfEnemyArmy = spec.AlertIfEnemyArmy
        self.AlertIfOwnArmy = spec.AlertIfOwnArmy
        self.AlertIfAlliedArmy = spec.AlertIfAlliedArmy
        self.Enabled = spec.InitiallyEnabled or true
        self.CanTakeDamage = false
    end,

    OnCreate = function(self)
        Entity.OnCreate(self)
        self.Owner:AddUnitCallback(self.Kill, 'OnKilled')
        self:AttachTo(self.Owner, -1)
        self:SetVizToAllies('Never')
        self:SetVizToEnemies('Never')
        self:SetVizToFocusPlayer('Never')
        self:SetVizToNeutrals('Never')
        self:SetDetectCategory(self.Category)

        if self:IsEnabled() then
            self:Enable()
        end
    end,

    Enable = function(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
        self.Enabled = true
    end,

    Disable = function(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 0)
        self:SetDrawScale(0)
        self.Enabled = false
    end,

    IsEnabled = function(self)
        return self.Enabled
    end,

    SetDetectCategory = function(self, cat)
        if type(cat) == 'string' then
            self.CollisionCategories = ParseEntityCategory(cat)
        else
            self.CollisionCategories = cat
        end
    end,

    SetDetectRadius = function(self, radius)
        self.Radius = radius
        if self:IsEnabled() then
            self:Enable() -- to reinitialise and use the new radius
        end
    end,

    OnCollisionCheck = function(self, other, firingWeapon)
        -- doesn't detect units!
        if not self:IsEnabled() then
            return false
        end
        if other.Army == -1 then -- -1 == observer
            return false
        end
        if self.Owner.Dead then
            self:Disable()
            return false
        end
        if not self.CollisionCategories or not EntityCategoryContains(self.CollisionCategories, other) then
            return false
        end

        if self.AlertIfOwnArmy and other.Army == self.Army then
            self:ProximityAlarm(other)
        elseif self.AlertIfEnemyArmy and (IsEnemy(self.Army, other.Army) or ArmyIsCivilian(other.Army)) then
            self:ProximityAlarm(other)
        elseif self.AlertIfAlliedArmy and IsAlly(self.Army, other.Army) then
            self:ProximityAlarm(other)
        end

        return false
    end,

    ProximityAlarm = function(self, other)
        -- doesn't detect units!
        self.Owner:OnProximityAlert(other, self.Radius, self.Name)
    end,
}
