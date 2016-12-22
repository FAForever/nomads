do


local oldNBlackhole = NBlackhole

NBlackhole = Class(oldNBlackhole) {

    SetWreckageProperties = function(self, prop, resources)
        prop:SetMaxReclaimValues( 1, resources['m'], resources['e'] ) # notice there is one less argument here compared to "shared" version

        # FAF removed this function call so disabling it here
        #prop:SetReclaimValues( 1, 1, resources['m'], resources['e'] )

        prop:AddBoundedProp( resources['m'] )

        prop:SetMaxHealth( resources['h'] )
        prop:SetHealth( self, resources['h'] )
    end,
}

TypeClass = NBlackhole



end