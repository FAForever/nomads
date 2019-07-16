
-- Hook for category.T3SUBMARINE units in formations (unit XNS0304)

-- Adding T3SUBMARINE
SubNaval = categories.T1SUBMARINE + categories.T2SUBMARINE + categories.T3SUBMARINE + (categories.NUKESUB * categories.ANTINAVY - categories.NUKE)

-- We also need to renew the childs, because we changed the parent (SubNaval)
NukeSubNaval = categories.NUKESUB - SubNaval

RemainingNaval = categories.NAVAL - (LightAttackNaval + FrigateNaval + SubNaval + DestroyerNaval + CruiserNaval + BattleshipNaval +
                        CarrierNaval + NukeSubNaval + DefensiveBoat + MobileSonar)

SubCategories = {
    SubCount = SubNaval,
}
