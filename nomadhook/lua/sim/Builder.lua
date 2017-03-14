do


-- Injecting something to have the AI run the function GenericPlatoonBehaviors in AIBehaviors.lua each time a unit is created.

local AddNomadsModifications = function(SuperClass)
    return Class(SuperClass) {
        GetPlatoonAddBehaviors = function(self)
            --LOG('*DEBUG: AI GetPlatoonAddBehaviors')
            local behaviors = SuperClass.GetPlatoonAddBehaviors(self)
            if not behaviors then
                behaviors = {}
            end
            table.insert( behaviors, 'GenericPlatoonBehaviors' )
            return behaviors
        end,
    }
end

Builder = AddNomadsModifications(Builder)
FactoryBuilder = AddNomadsModifications(FactoryBuilder)
PlatoonBuilder = AddNomadsModifications(PlatoonBuilder)
EngineerBuilder = AddNomadsModifications(EngineerBuilder)



end