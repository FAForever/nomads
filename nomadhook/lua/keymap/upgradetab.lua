do

local nomadupgrades =
{
    -- nomads
    ['xnb0101'] = {'xnb0201', 'znb9501'}, -- LAND-1 = LAND-2-HQ , LAND-2-SUP
    ['xnb0102'] = {'xnb0202', 'znb9502'}, -- AIR-1 = AIR-2-HQ , AIR-2-SUP
    ['xnb0103'] = {'xnb0203', 'znb9503'}, -- SEA-1 = SEA-2-HQ , SEA-2-SUP

    ['xnb0201'] = 'xnb0301',  -- LAND-2-HQ = LAND-3-HQ
    ['xnb0202'] = 'xnb0302',  -- AIR-2-HQ = AIR-3-HQ
    ['xnb0203'] = 'xnb0303',  -- SEA-2-HQ = SEA-3-HQ

    ['znb9501']  = 'znb9601',  -- LAND-2-SUP = LAND-3-SUP
    ['znb9502']  = 'znb9602',  -- AIR-2-SUP = AIR-3-SUP
    ['znb9503']  = 'znb9603',  -- SEA-2-SUP = SEA-3-SUP

    ['xnb3102']  = 'xnb3202',   -- sonar
    ['xnb3202']  = 'xnb3302',
    ['xnb3101']  = 'xnb3201',   -- radar
    ['xnb3201']  = 'xnb3301',
    ['xnb1103']  = 'xnb1202',   -- mex
    ['xnb1202']  = 'xnb1302',
}

upgradeTab = table.merged(upgradeTab, nomadupgrades)

end
