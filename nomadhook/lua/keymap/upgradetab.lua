do

local nomadupgrades =
{
    -- nomads
    ['xnb0101'] = {'znb9501', 'xnb0201'}, -- LAND-1 = LAND-2-HQ , LAND-2-SUP
    ['xnb0102'] = {'znb9502', 'xnb0202'}, -- AIR-1 = AIR-2-HQ , AIR-2-SUP
    ['xnb0103'] = {'znb9503', 'xnb0203'}, -- SEA-1 = SEA-2-HQ , SEA-2-SUP
}

upgradeTab = table.merged(upgradeTab, nomadupgrades)

end
