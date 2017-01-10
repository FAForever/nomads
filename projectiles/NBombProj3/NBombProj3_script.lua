local ConcussionBomb = import('/lua/nomadprojectiles.lua').ConcussionBomb

NBombProj3 = Class(ConcussionBomb) {

    OnImpact = function(self, TargetType, TargetEntity)
        -- if these parameters are nil then we detonate because we're below a certain height, see BP
        if TargetType == 'Air' and not TargetEntity then
            self:DiveDown()
        else
            ConcussionBomb.OnImpact(self, TargetType, TargetEntity)
        end
    end,

    DiveDown = function(self)
        local vx, vy, vz = self:GetVelocity()
        self:SetVelocity(vx, vy * 3, vz)
        self:SetVelocity(20)
        self:ChangeDetonateBelowHeight(0)
    end,
}

TypeClass = NBombProj3
