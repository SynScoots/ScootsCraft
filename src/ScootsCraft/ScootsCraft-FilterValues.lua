ScootsCraft.setSubclassFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    info.text = 'All Subclasses'
    info.func = function()
        UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, 'All Subclasses')
        ScootsCraft.setFilter('subclass', nil)
    end
    UIDropDownMenu_AddButton(info, level)
    
    for sectionIndex, sectionName in ipairs(ScootsCraft.cachedCraftSections) do
        info.text = sectionName
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, sectionName)
            ScootsCraft.setFilter('subclass', sectionIndex)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsCraft.setSlotFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    info.text = 'All Slots'
    info.func = function()
        UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, 'All Slots')
        ScootsCraft.setFilter('slot', nil)
    end
    UIDropDownMenu_AddButton(info, level)
    
    local slots = {
        'Head', 'Neck', 'Shoulders', 'Back', 'Chest', 'Shirt', 'Wrist', 'Hands', 'Waist', 'Legs', 'Feet', 'Finger', 'Trinket', '1H Weapon', '2H Weapon', 'Off Hand', 'Ranged', 'Ammunition', 'Container', 'Created Items'
    }
    
    for _, slotName in ipairs(slots) do
        if(ScootsCraft.cachedEquipmentSlots[slotName]) then
            info.text = slotName
            info.func = function()
                UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, slotName)
                ScootsCraft.setFilter('slot', slotName)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

ScootsCraft.setEquipmentFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    for _, choice in ipairs(ScootsCraft.filterChoices.equipment) do
        info.text = choice[2]
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.equipmentFilter, choice[2])
            ScootsCraft.setFilter('equipment', choice[1])
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsCraft.setForgeFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    for _, choice in ipairs(ScootsCraft.filterChoices.forge) do
        info.text = choice[2]
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.forgeFilter, choice[2])
            ScootsCraft.setFilter('forge', choice[1])
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end