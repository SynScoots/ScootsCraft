ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['frames'] = {
        ['events'] = CreateFrame('Frame', 'ScootsCraft-EventsFrame', UIParent)
    },
    ['skillLevels'] = {},
    ['cachedCrafts'] = {},
    ['cachedCraftSections'] = {},
    ['cachedEquipmentSlots'] = {},
    ['hiddenSections'] = {},
    ['filteredCrafts'] = {},
    ['selectedCraft'] = {},
    ['scrollOffsets'] = {},
    ['defaultFilters'] = {
        ['available'] = false,
        ['equipment-only'] = false,
        ['subclass'] = nil,
        ['search'] = nil,
        ['slot'] = nil,
        ['equipment'] = nil,
        ['forge'] = nil
    },
    ['filters'] = {},
    ['filterChoices'] = {
        ['equipment'] = {
            {nil, 'All Equipment'},
            {'account', 'Attuneable (Acc)'},
            {'character', 'Attuneable (Char)'},
        },
        ['forge'] = {
            {nil, 'All Forge Levels'},
            {-1, 'Unattuned'},
            {0, '<= Baseline'},
            {1, '<= Titanforged'},
            {2, '<= Warforged'},
            {3, '<= Lightforged'}
        }
    },
    ['cachedReagentCrafts'] = {},
    ['runeforging'] = 53428
}
ScootsCraft.spellIds = {
    {ScootsCraft.runeforging},                  -- Runeforging
    {51304, 28596, 11611, 3464,  3101,  2259},  -- Alchemy
    {51300, 29844, 9785,  3538,  3100,  2018},  -- Blacksmithing
    {51313, 28029, 13920, 7413,  7412,  7411},  -- Enchanting
    {51306, 30350, 12656, 4038,  4037,  4036},  -- Engineering
    {45363, 45361, 45360, 45359, 45358, 45357}, -- Inscription
    {51311, 28897, 28895, 28894, 25230, 25229}, -- Jewelcrafting
    {51302, 32549, 10662, 3811,  3104,  2108},  -- Leatherworking
    {2656},                                     -- Smelting
    {51309, 26790, 12180, 3910,  3909,  3908},  -- Tailoring
    {51296, 33359, 18260, 3413,  3102,  2550},  -- Cooking
    {45542, 27028, 10846, 7924,  3274,  3273}   -- First Aid
}

ScootsCraft.onLoad = function()
    ScootsCraft.addonLoaded = true
    ScootsCraft.lockedActive = ScootsCraft.getOption('active')
end

ScootsCraft.onHide = function()
    ScootsCraft.cachedCrafts = {}
    ScootsCraft.cachedCraftSections = {}
    ScootsCraft.cachedEquipmentSlots = {}
    ScootsCraft.filteredCrafts = {}
    CloseTradeSkill()
end

ScootsCraft.onLogout = function()
    if(ScootsCraft.optionsLoaded) then
        _G['SCOOTSCRAFT_OPTIONS'] = ScootsCraft.options
        ScootsCraft.closeCraftPanel()
    end
end

ScootsCraft.openCraftPanel = function()
    ScootsCraft.buildUi()
    ScootsCraft.setAckisButton()
    
    if(ScootsCraft.getOption('remember-filters') and not ScootsCraft.restoredRememberedFilters) then
        ScootsCraft.restoredRememberedFilters = true
        if(ScootsCraft.getOption('remembered-filter-data')) then
            ScootsCraft.filters = ScootsCraft.getOption('remembered-filter-data')
        end
    end
    
    ScootsCraft.frames.master:ClearAllPoints()
    ScootsCraft.frames.master:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 0, -104)
    
    ShowUIPanel(ScootsCraft.frames.master)
    
    ScootsCraft.masterPanelOpen = true
end

ScootsCraft.closeCraftPanel = function()
    if(ScootsCraft.uiBuilt) then
        HideUIPanel(ScootsCraft.frames.master)
    end
    
    ScootsCraft.masterPanelOpen = false
end

ScootsCraft.setProfessionButtons = function()
    local offsetMulti = 0
    
    for spellIndex, spellIdCollection in ipairs(ScootsCraft.spellIds) do
        local spellId = nil
        for _, checkSpellId in ipairs(spellIdCollection) do
            if(IsSpellKnown(checkSpellId)) then
                spellId = checkSpellId
                break
            end
        end
        
        if(spellId) then
            local name, _, icon = GetSpellInfo(spellId)
            ScootsCraft.professionSpells[spellIndex].id = spellId
            ScootsCraft.professionSpells[spellIndex].name = name
            ScootsCraft.professionSpells[spellIndex].icon = icon
            
            for i = 1, MAX_SPELLS do
                bookSpellName = GetSpellName(i, BOOKTYPE_SPELL)
                
                if(bookSpellName == name) then
                    ScootsCraft.professionSpells[spellIndex].bookId = i
                    break
                end
            end
            
            ScootsCraft.professionSpells[spellIndex].button:SetAttribute('spell', spellId)
            ScootsCraft.professionSpells[spellIndex].button:SetNormalTexture(icon)
            
            ScootsCraft.professionSpells[spellIndex].button:SetPoint('TOPLEFT', ScootsCraft.frames.professionButtonsHolder, 'TOPLEFT', (ScootsCraft.professionSpells[spellIndex].button:GetWidth() * offsetMulti), 0)
            ScootsCraft.professionSpells[spellIndex].button:Show()
            
            offsetMulti = offsetMulti + 1
        end
    end
    
    ScootsCraft.frames.professionButtonsHolder:SetWidth(ScootsCraft.professionSpells[1].button:GetWidth() * offsetMulti)
    ScootsCraft.frames.professionButtonsHolder:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', (670 - ScootsCraft.frames.professionButtonsHolder:GetWidth()), -42)
end

ScootsCraft.renderProfession = function()
    local professionName, currentSkill, maxSkill = GetTradeSkillLine()
    
    if(ScootsCraft.uiBuilt ~= true or professionName == 'UNKNOWN') then
        HideUIPanel(ScootsCraft.frames.master)
        return nil
    end
    
    ScootsCraft.activeProfession = professionName
    ScootsCraft.activeProfessionName = professionName
    
    -- Make the active profession button glow
    ScootsCraft.setProfessionButtons()
    for _, spell in pairs(ScootsCraft.professionSpells) do
        spell.button.glow:SetAlpha(0)
        spell.button:Enable()
        
        if(spell.name == professionName or (spell.name == 'Smelting' and professionName == 'Mining')) then
            spell.button.glow:SetVertexColor(0.8, 0.8, 0)
            spell.button.glow:SetAlpha(1)
            spell.button:Disable()
            
            ScootsCraft.activeProfession = spell.id
            SetPortraitToTexture(ScootsCraft.frames.master.icon, spell.icon)
        end
    end
    
    -- Set default filter values
    if(ScootsCraft.filters[ScootsCraft.activeProfession] == nil) then
        ScootsCraft.filters[ScootsCraft.activeProfession] = {}
        
        for key, value in pairs(ScootsCraft.defaultFilters) do
            ScootsCraft.filters[ScootsCraft.activeProfession][key] = value
        end
    end
    
    -- Bring collapsed sections/scroll position from last time we were on this profession
    if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession] == nil) then
        ScootsCraft.hiddenSections[ScootsCraft.activeProfession] = {}
    end
        
    if(ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] ~= nil) then
        FauxScrollFrame_SetOffset(ScootsCraft.frames.recipeFrame, ScootsCraft.scrollOffsets[ScootsCraft.activeProfession])
        ScootsCraft.frames.recipeFrame:SetVerticalScroll(ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] * ScootsCraft.recipeLineHeight)
    else
        FauxScrollFrame_SetOffset(ScootsCraft.frames.recipeFrame, 0)
        ScootsCraft.frames.recipeFrame:SetVerticalScroll(0)
    end
        
    -- Setup filters
    UIDropDownMenu_Initialize(ScootsCraft.frames.subclassFilter, ScootsCraft.setSubclassFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.slotFilter, ScootsCraft.setSlotFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.equipmentFilter, ScootsCraft.setEquipmentFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.forgeFilter, ScootsCraft.setForgeFilterValues)
    
    -- Set title up
    ScootsCraft.frames.title.text:SetText(ScootsCraft.title .. ' - ' .. professionName .. ' [' .. tostring(currentSkill) .. ' / ' .. tostring(maxSkill) .. ']')
    ScootsCraft.skillLevels[ScootsCraft.activeProfession] = {currentSkill, maxSkill}
    ScootsCraft.frames.professionLink:SetPoint('LEFT', ScootsCraft.frames.title.text, 'RIGHT', 20, 0)
    
    -- Prepare profession
    ScootsCraft.cacheProfession()

    -- Apply filters from last time we viewed this profession
    -- Available
    ScootsCraft.frames.availableFilter:SetChecked(ScootsCraft.filters[ScootsCraft.activeProfession].available)
    ScootsCraft.frames.availableFilter:Show()
    
    -- Equipment Only
    ScootsCraft.frames.equipmentOnlyFilter:SetChecked(ScootsCraft.filters[ScootsCraft.activeProfession]['equipment-only'])
    ScootsCraft.frames.equipmentOnlyFilter:Show()
    
    -- Subclass
    if(ScootsCraft.filters[ScootsCraft.activeProfession].subclass) then
        local index = 1
        for sectionIndex, sectionName in ipairs(ScootsCraft.cachedCraftSections) do
            index = index + 1
            if(ScootsCraft.filters[ScootsCraft.activeProfession].subclass == sectionIndex) then
                UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.subclassFilter, index)
                UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, sectionName)
                break
            end
        end
    else
        UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.subclassFilter, 1)
        UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, 'All Subclasses')
    end
    ScootsCraft.frames.subclassFilter:Show()
    
    -- Slot
    if(ScootsCraft.filters[ScootsCraft.activeProfession].slot) then
        local index = 1
        for slotName, _ in ipairs(ScootsCraft.cachedEquipmentSlots) do
            index = index + 1
            if(ScootsCraft.filters[ScootsCraft.activeProfession].slot == slotName) then
                UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.slotFilter, index)
                UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, sectionName)
                break
            end
        end
    else
        UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.slotFilter, 1)
        UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, 'All Slots')
    end
    ScootsCraft.frames.slotFilter:Show()    
    
    -- Search
    if(ScootsCraft.filters[ScootsCraft.activeProfession].search) then
        ScootsCraft.frames.searchFilter:SetText(ScootsCraft.filters[ScootsCraft.activeProfession].search)
    else
        ScootsCraft.frames.searchFilter:SetText('')
    end
    
    if(ScootsCraft.frames.searchFilter:GetText() == '' and not ScootsCraft.searchFilterFocussed) then
        ScootsCraft.frames.searchFilter.label:Show()
    else
        ScootsCraft.frames.searchFilter.label:Hide()
    end
    
    -- Equipment
    local index = 0
    for _, choice in ipairs(ScootsCraft.filterChoices.equipment) do
        index = index + 1
        if(ScootsCraft.filters[ScootsCraft.activeProfession].equipment == choice[1]) then
            UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.equipmentFilter, index)
            UIDropDownMenu_SetText(ScootsCraft.frames.equipmentFilter, choice[2])
            break
        end
    end
    ScootsCraft.frames.equipmentFilter:Show()
    
    -- Forge
    local index = 0
    for _, choice in ipairs(ScootsCraft.filterChoices.forge) do
        index = index + 1
        if(ScootsCraft.filters[ScootsCraft.activeProfession].forge == choice[1]) then
            UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.forgeFilter, index)
            UIDropDownMenu_SetText(ScootsCraft.frames.forgeFilter, choice[2])
            break
        end
    end
    ScootsCraft.frames.forgeFilter:Show()
    
    -- Hide options if they're open
    if(ScootsCraft.frames.options and ScootsCraft.frames.options:IsVisible()) then
        ScootsCraft.frames.options:Hide()
        ScootsCraft.frames.optionsButton:SetText('Options')
    end
    
    -- Display it all
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
    ScootsCraft.setFrameLevels()
end

ScootsCraft.toggleSection = function(sectionIndex)
    if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex]) then
        ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = nil
    else
        ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = true
    end
    
    local anyVisible = false
    for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
        if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] == nil) then
            anyVisible = true
            break
        end
    end
    
    if(anyVisible) then
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
    else
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
    end
    
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.toggleAllSections = function()
    local hiddenAny = false
    
    for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
        if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] == nil) then
            ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = true
            hiddenAny = true
        end
    end
    
    if(hiddenAny) then
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
    else
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
        
        for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
            ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = nil
        end
    end
    
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.cacheProfession = function()
    local recipeCount = GetNumTradeSkills()
    ScootsCraft.cachedCrafts = {}
    ScootsCraft.cachedCraftSections = {}
    ScootsCraft.cachedEquipmentSlots = {}
    local sectionIndex = 0
    
    for skillIndex = 1, recipeCount do
        local skillName, skillType, numAvailable, _, altVerb = GetTradeSkillInfo(skillIndex)
        
        if(skillType == 'header') then
            sectionIndex = sectionIndex + 1
            ScootsCraft.cachedCraftSections[sectionIndex] = skillName
            ScootsCraft.cachedCrafts[sectionIndex] = {}
        else
            if(ScootsCraft.cachedCrafts[sectionIndex] == nil) then
                sectionIndex = sectionIndex + 1
                ScootsCraft.cachedCraftSections[sectionIndex] = 'Uncategorised'
                ScootsCraft.cachedCrafts[sectionIndex] = {}
            end
        
            local minMade, maxMade = GetTradeSkillNumMade(skillIndex)
            
            local craft = {
                ['index'] = skillIndex,
                ['section'] = sectionIndex,
                ['name'] = skillName,
                ['description'] = GetTradeSkillDescription(skillIndex),
                ['type'] = skillType,
                ['number'] = numAvailable,
                ['verb'] = altVerb,
                ['link'] = GetTradeSkillItemLink(skillIndex),
                ['tradelink'] = GetTradeSkillRecipeLink(skillIndex),
                ['icon'] = GetTradeSkillIcon(skillIndex),
                ['slot'] = nil,
                ['equippable'] = false,
                ['min'] = minMade,
                ['max'] = maxMade,
                ['forge'] = -1,
                ['attune'] = false,
                ['attuneany'] = false,
                ['requires'] = BuildColoredListString(GetTradeSkillTools(skillIndex)),
                ['reagents'] = {},
            }
            
            if(craft.link) then
                local linkType, linkId = ScootsCraft.extractId(craft.link)
                craft.id = linkId
                craft.craftid = linkType .. '-' .. tostring(linkId)
                craft.crafttype = linkType
                
                if(linkType == 'item') then
                    craft.equippable = IsEquippableItem(craft.id)
                    craft.slot = ScootsCraft.mapInvTypeToSlot(select(9, GetItemInfo(craft.link)))
                elseif(linkType == 'spell') then
                    craft.slot = ScootsCraft.mapSpellIdToSlot(linkId)
                end
            end
            
            if(craft.crafttype and craft.crafttype == 'item') then
                if(GetItemAttuneForge and craft.id) then
                    craft.forge = GetItemAttuneForge(craft.id)
                end
                
                if(GetItemTagsCustom) then
                    local tags = GetItemTagsCustom(craft.id)
                    if(tags and bit.band(tags, 96) == 64) then
                        if(CanAttuneItemHelper and CanAttuneItemHelper(craft.id) > 0) then
                            craft.attune = true
                            craft.attuneany = true
                        elseif(IsAttunableBySomeone) then
                            local check = IsAttunableBySomeone(craft.id)
                            if(check ~= nil and check ~= 0) then
                                craft.attuneany = true
                            end
                        end
                    end
                end
            end
            
            local reagentCount = GetTradeSkillNumReagents(skillIndex)
            
            for reagentIndex = 1, reagentCount do
                local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(skillIndex, reagentIndex)
                local reagent = {
                    ['name'] = reagentName,
                    ['icon'] = reagentTexture,
                    ['required'] = reagentCount,
                    ['owned'] = playerReagentCount,
                    ['link'] = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
                }
                
                craft.reagents[reagentIndex] = reagent
            end
            
            if(craft.slot ~= nil) then
                ScootsCraft.cachedEquipmentSlots[craft.slot] = true
            end
            
            table.insert(ScootsCraft.cachedCrafts[sectionIndex], craft)
        end
    end
end

ScootsCraft.filterCrafts = function()
    ScootsCraft.filteredCrafts = {}
    
    local selectedCraftInFilter = false
    
    for sectionIndex, crafts in ipairs(ScootsCraft.cachedCrafts) do
        table.insert(ScootsCraft.filteredCrafts, {
            ['type'] = 'section',
            ['detail'] = {
                ['name'] = ScootsCraft.cachedCraftSections[sectionIndex],
                ['index'] = sectionIndex
            }
        })
        
        local addedAny = false
    
        for _, craft in ipairs(crafts) do
            repeat
                if(ScootsCraft.activeProfession ~= ScootsCraft.runeforging) then
                    -- Filter: Have Materials
                    if(ScootsCraft.filters[ScootsCraft.activeProfession].available and craft.number < 1) then
                        break
                    end
                end
                    
                -- Filter: Equipment Only
                if(ScootsCraft.filters[ScootsCraft.activeProfession]['equipment-only'] and not craft.equippable) then
                    break
                end
                
                -- Filter: Subclass
                if(ScootsCraft.filters[ScootsCraft.activeProfession].subclass) then
                    if(sectionIndex ~= ScootsCraft.filters[ScootsCraft.activeProfession].subclass) then
                        break
                    end
                end
                
                -- Filter: Slot
                if(ScootsCraft.filters[ScootsCraft.activeProfession].slot) then
                    if(craft.slot ~= ScootsCraft.filters[ScootsCraft.activeProfession].slot) then
                        break
                    end
                end
                
                -- Filter: Equipment (attuneable)
                if(ScootsCraft.filters[ScootsCraft.activeProfession].equipment and craft.equippable) then
                    if(ScootsCraft.filters[ScootsCraft.activeProfession].equipment == 'account') then
                        if(craft.attuneany ~= true) then
                            break
                        end
                    elseif(ScootsCraft.filters[ScootsCraft.activeProfession].equipment == 'character') then
                        if(craft.attune ~= true) then
                            break
                        end
                    end
                end
                
                -- Filter: Forge level
                if(ScootsCraft.filters[ScootsCraft.activeProfession].forge) then
                    if(craft.forge and craft.forge > ScootsCraft.filters[ScootsCraft.activeProfession].forge) then
                        break
                    end
                end
                
                -- Filter: Search
                if(ScootsCraft.filters[ScootsCraft.activeProfession].search) then
                    if(not string.match(string.lower(ScootsCraft.getItemLinkTooltipAsString(craft.tradelink)), string.lower(ScootsCraft.filters[ScootsCraft.activeProfession].search))) then
                        break
                    end
                end
                
                addedAny = true
                
                if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex]) then
                    break
                end
                
                table.insert(ScootsCraft.filteredCrafts, {
                    ['type'] = 'craft',
                    ['detail'] = craft
                })
                
                if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession] and ScootsCraft.selectedCraft[ScootsCraft.activeProfession].craftid == craft.craftid) then
                    selectedCraftInFilter = true
                    ScootsCraft.selectRecipe(craft)
                end
            until true
        end
            
        if(addedAny ~= true) then
            table.remove(ScootsCraft.filteredCrafts)
        end
    end
    
    if(selectedCraftInFilter == false) then
        for _, craft in ipairs(ScootsCraft.filteredCrafts) do
            if(craft.type == 'craft') then
                ScootsCraft.selectRecipe(craft.detail)
                break
            end
        end
    end
end

ScootsCraft.updateDisplayedRecipes = function()
    if(ScootsCraft.filteredCrafts == nil) then
        return nil
    end
    
    FauxScrollFrame_Update(ScootsCraft.frames.recipeFrame, #ScootsCraft.filteredCrafts, ScootsCraft.recipesVisible, ScootsCraft.recipeLineHeight, nil, nil, nil, nil, nil, nil, true)
    local offset = FauxScrollFrame_GetOffset(ScootsCraft.frames.recipeFrame)
    
    ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] = offset
    
    for i = 1, ScootsCraft.recipesVisible do
        local recipeIndex = i + offset
        local recipe = ScootsCraft.filteredCrafts[recipeIndex]
        local frame = ScootsCraft.frames.recipes[i]
        
        if(recipe == nil) then
            frame:Hide()
            frame.recipe = nil
        else
            frame:Show()
            frame.icon:SetAlpha(0)
            
            if(recipe.type == 'section') then
                frame.isSectionHead = true
                frame.section = recipe.detail.index
                frame.text:SetText(recipe.detail.name)
                frame.text:SetTextColor(1, 1, 1)
                frame.recipe = nil
                frame.underline:SetAlpha(1)
                frame.selected:SetAlpha(0)
                frame.sectionToggle:Show()
                
                if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][frame.section]) then
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
                else
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
                end
            else
                frame.isSectionHead = false
                frame.section = nil
                frame.recipe = recipe.detail
                frame.underline:SetAlpha(0)
                frame.selected:SetAlpha(0)
                frame.sectionToggle:Hide()
                
                if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession] and recipe.detail.craftid == ScootsCraft.selectedCraft[ScootsCraft.activeProfession].craftid) then
                    frame.selected:SetAlpha(0.3)
                end
                
                if(recipe.detail.forge == 0) then
                    frame.text:SetTextColor(0.65, 1, 0.5)
                    frame.selected:SetVertexColor(0.65, 1, 0.5)
                elseif(recipe.detail.forge == 1) then
                    frame.text:SetTextColor(0.5, 0.5, 1)
                    frame.selected:SetVertexColor(0.5, 0.5, 1)
                elseif(recipe.detail.forge == 2) then
                    frame.text:SetTextColor(1, 0.65, 0.5)
                    frame.selected:SetVertexColor(1, 0.65, 0.5)
                elseif(recipe.detail.forge == 3) then
                    frame.text:SetTextColor(1, 1, 0.65)
                    frame.selected:SetVertexColor(1, 1, 0.65)
                else
                    if(recipe.detail.attune) then
                        frame.text:SetTextColor(0.8, 0.8, 0.8)
                        frame.selected:SetVertexColor(0.8, 0.8, 0.8)
                    else
                        frame.text:SetTextColor(0.5, 0.5, 0.5)
                        frame.selected:SetVertexColor(0.5, 0.5, 0.5)
                    end
                end
                
                if(recipe.detail.type == nil or recipe.detail.type == 'trivial' or ScootsCraft.skillLevels[ScootsCraft.activeProfession][1] >= ScootsCraft.skillLevels[ScootsCraft.activeProfession][2]) then
                    frame.icon:SetAlpha(0)
                else
                    frame.icon:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Craft-' .. recipe.detail.type)
                    frame.icon:SetAlpha(1)
                end
                
                local suffix = ''
                if(recipe.detail.number > 0) then
                    suffix = ' [' .. recipe.detail.number .. ']'
                end
                frame.text:SetText(recipe.detail.name .. suffix)
            end
        end
    end
end

ScootsCraft.selectRecipe = function(craft)
    ScootsCraft.selectedCraft[ScootsCraft.activeProfession] = craft
    ScootsCraft.frames.craftIcon:SetNormalTexture(craft.icon)
    
    local height = ScootsCraft.frames.craftIcon:GetHeight()
    
    if(craft.max > 1) then
        if(craft.min == craft.max) then
            ScootsCraft.frames.craftIcon.text:SetText(craft.min)
        else
            ScootsCraft.frames.craftIcon.text:SetText(craft.min .. '-' .. craft.max)
        end
        
        if(ScootsCraft.frames.craftIcon.text:GetWidth() > ScootsCraft.frames.craftIcon:GetWidth()) then
            ScootsCraft.frames.craftIcon.text:SetText('~' .. math.floor((craft.min + craft.max) / 2))
        end
    else
        ScootsCraft.frames.craftIcon.text:SetText('')
    end
    
    ScootsCraft.frames.craftItem.name:SetText(craft.name)
    
    if(craft.requires) then
        ScootsCraft.frames.craftItem.requiresLabel:SetText('Requires:')
        ScootsCraft.frames.craftItem.requires:SetText(craft.requires)
    else
        ScootsCraft.frames.craftItem.requiresLabel:SetText('')
        ScootsCraft.frames.craftItem.requires:SetText('')
    end
    
    local cooldown = GetTradeSkillCooldown(craft.index)
    if(cooldown) then
        ScootsCraft.frames.craftItem.cooldown:SetText('Cooldown remaining: ' .. SecondsToTime(cooldown))
    else
        ScootsCraft.frames.craftItem.cooldown:SetText('')
    end
    
    if(craft.description) then
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, -10)
        ScootsCraft.frames.craftItem.description:SetText(craft.description)
        height = height + ScootsCraft.frames.craftItem.description:GetHeight() + 10
    else
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, 0)
        ScootsCraft.frames.craftItem.description:SetText('')
    end
    
    ScootsCraft.frames.craftItem.reagentsLabel:Hide()
    for i = 1, 8 do
        local reagent = craft.reagents[i]

        if(reagent and reagent.name and reagent.icon) then
            if(i == 1) then
                ScootsCraft.frames.craftItem.reagentsLabel:Show()
                height = height + ScootsCraft.frames.craftItem.reagentsLabel:GetHeight() + 10 + ScootsCraft.frames.reagents[i]:GetHeight() + 3
            elseif(i % 2 == 1) then
                height = height + ScootsCraft.frames.reagents[i]:GetHeight() + 2
            end
        
            ScootsCraft.frames.reagents[i]:Show()
            SetItemButtonTexture(ScootsCraft.frames.reagents[i], reagent.icon)
            _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetText(reagent.name)
            
            if(reagent.link) then
                local _, reagentItemId = ScootsCraft.extractId(reagent.link)
                if(reagentItemId) then
                    ScootsCraft.frames.reagents[i].itemId = reagentItemId
                end
            else
                ScootsCraft.frames.reagents[i].itemId = nil
            end
            
            if(reagent.required <= reagent.owned) then
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[i], 1, 1, 1)
                _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            else
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[i], 0.5, 0.5, 0.5)
                _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
            
            local reagentOwnedText = reagent.owned
            if(reagent.owned > 99) then
                reagentOwnedText = '*'
            end
            _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Count']:SetText(reagentOwnedText .. ' /' .. reagent.required)
        else
            ScootsCraft.frames.reagents[i]:Hide()
        end
    end
    
    ScootsCraft.frames.craftItem:SetHeight(height)
    ScootsCraft.frames.craftItemHolder:SetHeight(height + 10)
    
    ScootsCraft.frames.createButton:SetText(craft.verb or 'Create')
    
    ScootsCraft.frames.createButton:Disable()
    ScootsCraft.frames.quantity:Hide()
    ScootsCraft.frames.increment:Hide()
    ScootsCraft.frames.decrement:Hide()
    ScootsCraft.frames.createAllButton:Hide()
    
    if(craft.number > 0 or ScootsCraft.activeProfession == ScootsCraft.runeforging) then
        ScootsCraft.frames.createButton:Enable()
        ScootsCraft.frames.quantity:SetText('1')
        
        if(not craft.verb) then
            ScootsCraft.frames.quantity:Show()
            ScootsCraft.frames.increment:Show()
            ScootsCraft.frames.decrement:Show()
            ScootsCraft.frames.createAllButton:Show()
            
            if(craft.number == 1) then
                ScootsCraft.frames.increment:Disable()
            else
                ScootsCraft.frames.increment:Enable()
            end
        end
    end
end

ScootsCraft.jumpToItemId = function(itemId)
    if(not ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession]) then
        ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession] = {}
    end
    
    if(ScootsCraft.cachedReagentCrafts[itemId] ~= nil) then
        if(ScootsCraft.cachedReagentCrafts[itemId] ~= false) then
            ScootsCraft.selectRecipe(ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId])
            ScootsCraft.updateDisplayedRecipes()
        end
        
        return nil
    end
    
    for _, crafts in pairs(ScootsCraft.cachedCrafts) do
        for _, craft in pairs(crafts) do
            if(craft.crafttype == 'item' and craft.id == itemId) then
                ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId] = craft
                ScootsCraft.selectRecipe(craft)
                ScootsCraft.updateDisplayedRecipes()
                return nil
            end
        end
    end
    
    ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId] = false
end

ScootsCraft.setFilter = function(key, value)
    if(type(value) == 'string' and value == '') then
        value = nil
    end
    
    ScootsCraft.filters[ScootsCraft.activeProfession][key] = value
    ScootsCraft.setOption('remembered-filter-data', ScootsCraft.filters)
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.toggleOptions = function()
    if(not ScootsCraft.frames.options) then
        ScootsCraft.buildUiOptions()
        ScootsCraft.frames.options:Hide()
    end
    
    if(ScootsCraft.frames.options:IsVisible()) then
        ScootsCraft.frames.options:Hide()
        ScootsCraft.frames.optionsButton:SetText('Options')
    else
        ScootsCraft.frames.options:Show()
        ScootsCraft.frames.optionsButton:SetText('Close')
        ScootsCraft.setFrameLevels()
    end
end

StaticPopupDialogs['SCOOTSCRAFT_RELOAD'] = {
    ['text'] = 'This action requires reloading the UI to take effect. Reload now?',
    ['button1'] = 'Yes',
    ['button2'] = 'No',
    ['OnAccept'] = ReloadUI,
    ['timeout'] = 0,
    ['whileDead'] = true,
    ['hideOnEscape'] = true
}

SLASH_SCOOTSCRAFT1 = '/scootscraft'
SlashCmdList['SCOOTSCRAFT'] = function(...)
    local arg1 = select(1, ...)
    if(arg1 and string.lower(arg1) == 'toggle') then
        ScootsCraft.setOption('active', not ScootsCraft.options.active)
        StaticPopup_Show('SCOOTSCRAFT_RELOAD')
    else
        print('\124cff' .. '98fb98' .. ScootsCraft.title .. '\124r' .. ' usage:')
        print('\124cff' .. '98fb98' .. '/scootscraft toggle' .. '\124r' .. ' - Activates or deactivates' .. ScootsCraft.title .. '.')
    end
end

ScootsCraft.eventHandler = function(self, event, arg1)
    if(event == 'ADDON_LOADED' and arg1 == 'ScootsCraft') then
        ScootsCraft.onLoad()
    elseif(event == 'PLAYER_LOGOUT') then
        ScootsCraft.onLogout()
    elseif(event == 'PLAYER_LEAVING_WORLD') then
        ScootsCraft.closeCraftPanel()
    elseif(event == 'TRADE_SKILL_SHOW' or event == 'TRADE_SKILL_UPDATE') then
        if(ScootsCraft.lockedActive ~= true) then
            ScootsCraft.addEnableButton()
        else
            ScootsCraft.buildUpdate = true
        end
    elseif(event == 'TRADE_SKILL_CLOSE') then
        if(ScootsCraft.lockedActive) then
            ScootsCraft.closeCraftPanel()
        end
    end
end

ScootsCraft.updateLoop = function()
    if(ScootsCraft.buildUpdate) then
        ScootsCraft.buildUpdate = false
        if(ScootsCraft.masterPanelOpen ~= true) then
            ScootsCraft.openCraftPanel()
        end
        ScootsCraft.renderProfession()
    end
end

ScootsCraft.frames.events:SetScript('OnEvent', ScootsCraft.eventHandler)
ScootsCraft.frames.events:SetScript('OnUpdate', ScootsCraft.updateLoop)

ScootsCraft.frames.events:RegisterEvent('ADDON_LOADED')
ScootsCraft.frames.events:RegisterEvent('PLAYER_LOGOUT')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_SHOW')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_UPDATE')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_CLOSE')
ScootsCraft.frames.events:RegisterEvent('PLAYER_LEAVING_WORLD')