# Modified to support custom factions field engineers

do


local oldCreateIdleEngineerList = CreateIdleEngineerList

function CreateIdleEngineerList(parent, units)

    local group = oldCreateIdleEngineerList(parent, units)
    
    group.Update = function(self, unitData)
        local function CreateUnitEntry(techLevel, userUnits, icontexture)
            local entry = Group(self)
            
            entry.icon = Bitmap(entry)
            if DiskGetFileInfo('/textures/ui/common'..icontexture) then
                entry.icon:SetTexture('/textures/ui/common'..icontexture)
            else
                entry.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
            end
            entry.icon.Height:Set(34)
            entry.icon.Width:Set(34)
            LayoutHelpers.AtRightIn(entry.icon, entry, 22)
            LayoutHelpers.AtVerticalCenterIn(entry.icon, entry)
            
            entry.iconBG = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds'))
            LayoutHelpers.AtCenterIn(entry.iconBG, entry.icon)
            entry.iconBG.Depth:Set(function() return entry.icon.Depth() - 1 end)
            
            entry.techIcon = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-engineers-panel/tech-'..techLevel..'_bmp.dds'))
            LayoutHelpers.AtLeftIn(entry.techIcon, entry)
            LayoutHelpers.AtVerticalCenterIn(entry.techIcon, entry.icon)
            
            entry.count = UIUtil.CreateText(entry, '', 20, UIUtil.bodyFont)
            entry.count:SetColor('ffffffff')
            entry.count:SetDropShadow(true)
            LayoutHelpers.AtRightIn(entry.count, entry.icon)
            LayoutHelpers.AtBottomIn(entry.count, entry.icon)
            
            entry.countBG = Bitmap(entry)
            entry.countBG:SetSolidColor('77000000')
            entry.countBG.Top:Set(function() return entry.count.Top() - 1 end)
            entry.countBG.Left:Set(function() return entry.count.Left() - 1 end)
            entry.countBG.Right:Set(function() return entry.count.Right() + 1 end)
            entry.countBG.Bottom:Set(function() return entry.count.Bottom() + 1 end)
            
            entry.countBG.Depth:Set(function() return entry.Depth() + 1 end)
            entry.count.Depth:Set(function() return entry.countBG.Depth() + 1 end)
            
            entry.Height:Set(function() return entry.iconBG.Height() end)
            entry.Width:Set(self.Width)
            
            entry.icon:DisableHitTest()
            entry.iconBG:DisableHitTest()
            entry.techIcon:DisableHitTest()
            entry.count:DisableHitTest()
            entry.countBG:DisableHitTest()
            
            entry.curIndex = 1
            entry.units = userUnits
            entry.HandleEvent = ClickFunc
            
            return entry
        end
        local engineers = {}
        engineers[5] = EntityCategoryFilterDown(categories.SUBCOMMANDER, unitData)
        engineers[4] = EntityCategoryFilterDown(categories.TECH3 - categories.SUBCOMMANDER, unitData)
        engineers[3] = EntityCategoryFilterDown(categories.FIELDENGINEER, unitData)
        engineers[2] = EntityCategoryFilterDown(categories.TECH2 - categories.FIELDENGINEER, unitData)
        engineers[1] = EntityCategoryFilterDown(categories.TECH1, unitData)
        
        local indexToIcon = {'1', '2', '2', '3', '3'}
        local keyToIcon = {'T1','T2','T2F','T3','SCU'}
        for index, units in engineers do
            local i = index

            # ADDED SUPPORT FOR CUSTOM FACTIONS HAVING FIELD ENGINEERS
            if i == 3 and (not Factions[currentFaction].IdleEngTextures or not Factions[currentFaction].IdleEngTextures.T2F) then
                continue
            end
            if not self.icons[i] then
                self.icons[i] = CreateUnitEntry(indexToIcon[i], units, Factions[currentFaction].IdleEngTextures[keyToIcon[index]])
                self.icons[i].priority = i
            end
            if table.getn(units) > 0 and not self.icons[i]:IsHidden() then
                self.icons[i].units = units
                self.icons[i].count:SetText(table.getn(units))
                self.icons[i].count:Show()
                self.icons[i].countBG:Show()
                self.icons[i].icon:SetAlpha(1)
            else
                self.icons[i].units = {}
                self.icons[i].count:Hide()
                self.icons[i].countBG:Hide()
                self.icons[i].icon:SetAlpha(.2)
            end
        end
        local prevGroup = false
        local groupHeight = 0
        for index, engGroup in engineers do
            local i = index
            if not self.icons[i] then continue end
            if prevGroup then
                LayoutHelpers.Above(self.icons[i], prevGroup)
            else
                LayoutHelpers.AtLeftIn(self.icons[i], self, 7)
                LayoutHelpers.AtBottomIn(self.icons[i], self, 2)
            end
            groupHeight = groupHeight + self.icons[i].Height()
            prevGroup = self.icons[i]
        end
        group.Height:Set(groupHeight)
    end
    
    group:Update(units)
    
    return group
end


end