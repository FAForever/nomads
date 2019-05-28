do

local nomadupgrades =
{
    -- nomads
    ['xnb0101'] = {'xnb0211', 'xnb0201'},
    ['xnb0102'] = {'xnb0212', 'xnb0202'},
    ['xnb0103'] = {'xnb0213', 'xnb0203'},

    ['xnb0201'] = 'xnb0301',    -- HQs
    ['xnb0202'] = 'xnb0302',
    ['xnb0203'] = 'xnb0303',

    ['xnb0211']  = 'xnb0311',   -- support factories
    ['xnb0212']  = 'xnb0312',
    ['xnb0213']  = 'xnb0313',
    ['xnb3102']  = 'xnb3202',   -- sonar
    ['xnb3202']  = 'xnb3302',
    ['xnb3101']  = 'xnb3201',   -- radar
    ['xnb3201']  = 'xnb3301',
    ['xnb1102']  = 'xnb1202',   -- mex
    ['xnb1202']  = 'xnb1302',
}

upgradeTab = table.merged(upgradeTab, nomadupgrades)

end