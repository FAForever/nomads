do


-- Adding Nomads experimentals for better AI support

local oldPlatoon = Platoon

Platoon = Class(oldPlatoon) {

    ExperimentalAIHub = function(self)
        --LOG('*DEBUG: AI ExperimentalAIHub')
        local experimental = self:GetPlatoonUnits()[1]
        if experimental then
            local behaviors = import('/lua/ai/AIBehaviors.lua')
            local ID = experimental:GetUnitId()
            --LOG('*DEBUG: AI choosing behavior for nomads experimental '..repr(ID))
            if ID == 'ina4001' then
                return behaviors.CometBehavior(self)
            elseif ID == 'inu2007' then
                return behaviors.BeamerBehavior(self)
            elseif ID == 'inu4001' then
                return behaviors.CrawlerBehavior(self)
            elseif ID == 'inu4002' then
                return behaviors.BullfrogBehavior(self)
            end
        end

        return oldPlatoon.ExperimentalAIHub(self)
    end,

    ExperimentalAIHubSorian = function(self)
        -- trying to have Sorian support Nomads aswell. This is mostly copy-paste from Sorians code. Hooking doesn't work here 
        -- because the function call seems to be terminated when one of the behaviours is returned. So by using hooking only the call to
        -- SOrians function is executed. Everything coming after (Nomads code) is neglected.
        --local ret = oldPlatoon.ExperimentalAIHubSorian(self)

        --LOG('*DEBUG: AI ExperimentalAIHubSorian')

        local experimental = self:GetPlatoonUnits()[1]
        if experimental then
            local ID = experimental:GetUnitId()

            if ID == 'ina4001' or ID == 'inu2007' or ID == 'inu4001' or ID == 'inu4002' then

                -- The next 7 lines or so are copy-paste from Sorian
                local aiBrain = self:GetBrain()
                if Random(1,5) == 3 and (not aiBrain.LastTaunt or GetGameTimeSeconds() - aiBrain.LastTaunt > 90) then
                    local randelay = Random(60,180)
                    aiBrain.LastTaunt = GetGameTimeSeconds() + randelay
                    local SUtils = import('/lua/AI/sorianutilities.lua')
                    SUtils.AIDelayChat('enemies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 't4taunt', nil, randelay)
                end
                self:SetPlatoonFormationOverride('AttackFormation')


                local behaviors = import('/lua/ai/AIBehaviors.lua')
                --LOG('*DEBUG: AI choosing behavior for nomads experimental '..repr(ID))
                if ID == 'ina4001' then
                    return behaviors.CometBehavior(self)
                elseif ID == 'inu2007' then
                    return behaviors.BeamerBehavior(self)
                elseif ID == 'inu4001' then
                    return behaviors.CrawlerBehavior(self)
                elseif ID == 'inu4002' then
                    return behaviors.BullfrogBehavior(self)
                end
            end
        end

        --return ret
        return oldPlatoon.ExperimentalAIHubSorian(self)
    end,
}



end