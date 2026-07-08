-- TODO:
--  Forgehelper post-forge destroy/vendor unforged fix
--  Options to add special cloth to summary reduction exclusions

ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['version'] = '2.0.0',
    ['frames'] = {
        ['events'] = CreateFrame('Frame', 'ScootsCraft-EventsFrame', UIParent),
    },
    ['skills'] = {},
    ['skillMap'] = {},
    ['skillIndexMap'] = {},
    ['inventorySlots'] = {},
    ['sections'] = {},
    ['sectionList'] = {},
    ['filters'] = {},
    ['selectedCraft'] = {},
    ['scrollOffsets'] = {},
    ['defaultFilters'] = {
        ['search'] = '',
        ['search-include-reagents'] = false,
        ['have-materials'] = false,
        ['exclude-items-in-bags'] = false,
        ['attuneable'] = 'all',
        ['attuned-level'] = 4,
        ['section'] = nil,
        ['inv-slot'] = -1,
    },
    ['storage'] = {
        ['options'] = {},
    },
    ['triggeredEvents'] = {},
    ['forgeHelper'] = nil,
    ['forgeHelperItem'] = false,
    ['forgeHelperQuantity'] = nil,
    ['merchantOpen'] = false,
}

BINDING_HEADER_ScootsCraft = ScootsCraft.title
BINDING_NAME_SCOOTSCRAFT_TOGGLE_WINDOW = 'Toggle window'

SLASH_SCOOTSCRAFT1 = '/scootscraft'
SlashCmdList['SCOOTSCRAFT'] = function(...)
    ScootsCraft.interface.toggle()
end

function ScootsCraft_Core_Init()
    ScootsCraft.synastriaApiLoaded = true
end

ScootsCraft.preInitChecks = function()
    if(ScootsCraft.interface == nil
    or ScootsCraft.data == nil
    or ScootsCraft.options == nil
    or ScootsCraft.synastriaApiLoaded ~= true) then
        return false
    end

    return true
end

ScootsCraft.preBuildChecks = function()
    if(UnitAffectingCombat('player')) then
        ScootsCraft.pushMessage('Please wait until you are out-of-combat before attempting to open ' .. ScootsCraft.title .. ' for the first time.')
        return false
    end
    
    if(not ScootsCraft.preInitChecks()) then
        ScootsCraft.pushMessage('Please wait until the custom server API has finished loading before opening ' .. ScootsCraft.title .. '.')
    end

    return true
end

ScootsCraft.init = function()
    ScootsCraft.cacheProfessions()
    
    local storage = _G['SCOOTSCRAFT_SAVEDDATA']
    
    if(storage ~= nil) then
        if(storage.options ~= nil) then
            ScootsCraft.storage.options = storage.options
        end
        
        if(storage.lastActiveSkill ~= nil) then
            ScootsCraft.storage.lastActiveSkill = storage.lastActiveSkill
        end
    end
    
    if(ScootsCraft.storage.lastActiveSkill ~= nil) then
        ScootsCraft.activeSkill = ScootsCraft.storage.lastActiveSkill
    end
end

ScootsCraft.cacheProfessions = function()
    local skillIdMap = ScootsCraft.data.getProfessionMap()

    for skillIndex = 1, #skillIdMap do
        local skill = skillIdMap[skillIndex]
        ScootsCraft.skills[skillIndex] = skillIdMap[skillIndex]
        ScootsCraft.skillMap[skillIdMap[skillIndex].name] = skillIdMap[skillIndex].skillId
        ScootsCraft.skillIndexMap[skillIdMap[skillIndex].skillId] = skillIndex
        
        if(ScootsCraft.filters[skill.skillId] == nil) then
            ScootsCraft.filters[skill.skillId] = {}
            for key, value in pairs(ScootsCraft.defaultFilters) do
                ScootsCraft.filters[skill.skillId][key] = value
            end
        end
        
        local knowsSkill = false
        for _, spellIdCheck in ipairs(ScootsCraft.skills[skillIndex].possibleSpellIds) do
            if(IsSpellKnown(spellIdCheck)) then
                knowsSkill = true
                ScootsCraft.skills[skillIndex].spellId = spellIdCheck
                break
            end
        end
        
        if(knowsSkill) then
            local name, _, icon = GetSpellInfo(ScootsCraft.skills[skillIndex].spellId)
            
            ScootsCraft.skills[skillIndex].displayName = name
            ScootsCraft.skills[skillIndex].icon = icon
        end
    end
    
    ScootsCraft.cacheSkillLevels()
end

ScootsCraft.cacheSkillLevels = function()
    for skillIndex, skill in pairs(ScootsCraft.skills) do
        local internalSkillIndex = Custom_GetSkillIndex(skill.skillId)
        local _, _, _, currentLevel, _, _, maxLevel = GetSkillLineInfo(internalSkillIndex)
        
        ScootsCraft.skills[skillIndex].currentLevel = currentLevel
        ScootsCraft.skills[skillIndex].maxLevel = maxLevel
    end
end

ScootsCraft.shutdown = function()
    _G['SCOOTSCRAFT_SAVEDDATA'] = ScootsCraft.storage
end

ScootsCraft.eventHandler = function(self, event)
    if(event == 'BAG_UPDATE'
    or event == 'ADDON_LOADED'
    or event == 'SKILL_LINES_CHANGED') then
        ScootsCraft.triggeredEvents[event] = true
    elseif(event == 'MERCHANT_SHOW') then
        ScootsCraft.merchantOpen = true
    elseif(event == 'MERCHANT_CLOSED') then
        ScootsCraft.merchantOpen = false
    elseif(event == 'PLAYER_LOGOUT') then
        ScootsCraft.shutdown()
    end
end

ScootsCraft.updateLoop = function()
    if(ScootsCraft.triggeredEvents['ADDON_LOADED'] ~= nil) then
        if(ScootsCraft.preInitChecks()) then
            ScootsCraft.triggeredEvents['ADDON_LOADED'] = nil
            
            if(ScootsCraft.initDone == nil) then
                ScootsCraft.init()
                ScootsCraft.options.load()
                ScootsCraft.options.build()
                ScootsCraft.interface.buildMinimapButton()
                
                ScootsCraft.initDone = true
            end
        end
    end
            
    if(ScootsCraft.frames.master ~= nil and ScootsCraft.frames.master:IsVisible()) then
        if(ScootsCraft.triggeredEvents['BAG_UPDATE'] ~= nil) then
            local skillIndex = ScootsCraft.skillIndexMap[ScootsCraft.activeSkill]
        
            ScootsCraft.triggeredEvents['BAG_UPDATE'] = nil
            ScootsCraft.frames.quantity:SetNumber(1)
            ScootsCraft.cacheSkillLevels()
            ScootsCraft.frames.title.skillName:SetText(string.format(' - %s [%d/%d]', ScootsCraft.skills[skillIndex].displayName, ScootsCraft.skills[skillIndex].currentLevel, ScootsCraft.skills[skillIndex].maxLevel))
            ScootsCraft.refreshRecipeList()
            ScootsCraft.renderRecipe(ScootsCraft.visibleSpellId)
            
            if(ScootsCraft.forgeHelper ~= nil and ScootsCraft.forgeHelperItem ~= nil) then
                ScootsCraft.handleForgeHelper()
            end
        end
        
        if(ScootsCraft.triggeredEvents['SKILL_LINES_CHANGED'] ~= nil) then
            ScootsCraft.triggeredEvents['SKILL_LINES_CHANGED'] = nil
            ScootsCraft.cacheProfessions()
            ScootsCraft.interface.buildProfessionSwatch()
        end
    end
end

ScootsCraft.setActiveSkill = function(skillIndex)
    ScootsCraft.activeSkill = ScootsCraft.skills[skillIndex].skillId
    
    for _, button in pairs(ScootsCraft.frames.skillButtons) do
        button:Enable()
        button.activeGlow:SetAlpha(0)
    end
    
    ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name]:Disable()
    ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name].activeGlow:SetVertexColor(0.8, 0.8, 0)
    ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name].activeGlow:SetAlpha(1)
    
    ScootsCraft.frames.title.skillName:SetText(string.format(' - %s [%d/%d]', ScootsCraft.skills[skillIndex].displayName, ScootsCraft.skills[skillIndex].currentLevel, ScootsCraft.skills[skillIndex].maxLevel))
    SetPortraitToTexture(ScootsCraft.frames.master.icon, ScootsCraft.skills[skillIndex].icon)
    
    --
    
    ScootsCraft.totalRecipeCount = 0
    
    ScootsCraft.inventorySlots = {}
    local invSlotCheck = {}
    
    ScootsCraft.sectionList = {}
    local sectionCheck = {}
    
    local recipes = Custom_GetProfessionRecipes(ScootsCraft.activeSkill)
    local headerRewrites = ScootsCraft.data.getSectionRewrites()
    local spellHeaderRewrites = ScootsCraft.data.getSpellSectionRewrites()
    
    for _, spellId in pairs(recipes) do
        ScootsCraft.totalRecipeCount = ScootsCraft.totalRecipeCount + 1
        local _, _, createdItemId, _, _, _, headerName = Custom_GetProfessionRecipeInfo(spellId)
        
        if(spellHeaderRewrites[ScootsCraft.activeSkill][spellId] ~= nil) then
            headerName = spellHeaderRewrites[ScootsCraft.activeSkill][spellId]
        elseif(headerRewrites[ScootsCraft.activeSkill][headerName] ~= nil) then
            headerName = headerRewrites[ScootsCraft.activeSkill][headerName]
        end
        
        if(headerName == nil) then
            headerName = 'Unknown'
        end
        
        if(sectionCheck[headerName] == nil) then
            sectionCheck[headerName] = true
            table.insert(ScootsCraft.sectionList, headerName)
        end
        
        --
        
        if((createdItemId or 0) ~= 0) then
            local invSlot = select(9, GetItemInfoCustom(createdItemId))
            
            if(invSlot == 'INVTYPE_ROBE') then
                invSlot = 'INVTYPE_BODY'
            end
            
            if((invSlot or '') ~= '' and sectionCheck[invSlot] == nil) then
                sectionCheck[invSlot] = true
                table.insert(ScootsCraft.inventorySlots, invSlot)
            end
        end
    end
    
    table.sort(ScootsCraft.sectionList, function(a, b)
        if(a < b) then
            return true
        end
        
        return false
    end)
    
    --
    
    ScootsCraft.interface.updateFilterDisplay()
    ScootsCraft.refreshRecipeList()
    ScootsCraft.setToggleAllSectionsVisibleState()
    
    ScootsCraft.renderRecipe(ScootsCraft.selectedCraft[ScootsCraft.activeSkill])
    ScootsCraft.storage.lastActiveSkill = ScootsCraft.activeSkill
end

ScootsCraft.fetchRecipes = function(skillId)
    local filters = ScootsCraft.filters[ScootsCraft.activeSkill] or ScootsCraft.defaultFilters

    local includeFilter = bit.bor(
        ScootsCraft.getFilter('attuneable') == 'character' and 1 or 0,
        (ScootsCraft.getFilter('attuneable') == 'account' or ScootsCraft.getFilter('attuneable') == 'character') and 4 or 0,
        ScootsCraft.getFilter('search-include-reagents') and 8 or 0,
        ScootsCraft.getFilter('have-materials') and 0x20 or 0
    )
    
    local excludeFilter = bit.bor(
        ScootsCraft.getFilter('exclude-items-in-bags') and 0x10 or 0,
        ScootsCraft.getFilter('attuned-level') ~= 4 and 0x40 or 0
    )
    
    return Custom_GetProfessionRecipes(
        skillId,
        includeFilter,
        excludeFilter,
        -3, -- Sort flag
        ScootsCraft.getFilter('search'),        
        ScootsCraft.getFilter('attuned-level'), 
        -1, -- Item class
        -1, -- Item sub-class
        ScootsCraft.getFilter('inv-slot')
    )
end

ScootsCraft.refreshRecipeList = function()
    ScootsCraft.recipes = {}
    local recipes = ScootsCraft.fetchRecipes(ScootsCraft.activeSkill)
    
    local headersFlat = {}
    
    local headerRewrites = ScootsCraft.data.getSectionRewrites()
    local spellHeaderRewrites = ScootsCraft.data.getSpellSectionRewrites()
    
    for spellIndex, spellId in ipairs(recipes) do
        local headerName = select(7, Custom_GetProfessionRecipeInfo(spellId))
        
        if(spellHeaderRewrites[ScootsCraft.activeSkill][spellId] ~= nil) then
            headerName = spellHeaderRewrites[ScootsCraft.activeSkill][spellId]
        elseif(headerRewrites[ScootsCraft.activeSkill][headerName] ~= nil) then
            headerName = headerRewrites[ScootsCraft.activeSkill][headerName]
        end
        
        if(ScootsCraft.getFilter('section') == nil or ScootsCraft.getFilter('section') == headerName) then
            table.insert(ScootsCraft.recipes, {
                ['section'] = headerName,
                ['spellId'] = spellId,
                ['index'] = spellIndex,
            })
        end
    end
    
    local sectionsToTop = ScootsCraft.data.getSectionsPushedToTop()
    
    table.sort(ScootsCraft.recipes, function(a, b)
        if(a ~= nil and b == nil) then
            return true
        elseif(a == nil and b ~= nil) then
            return false
        elseif(a == nil and b == nil) then
            return false
        end
        
        if(sectionsToTop[ScootsCraft.activeSkill][a.section] ~= nil and sectionsToTop[ScootsCraft.activeSkill][b.section] == nil) then
            return true
        elseif(sectionsToTop[ScootsCraft.activeSkill][a.section] == nil and sectionsToTop[ScootsCraft.activeSkill][b.section] ~= nil) then
            return false
        elseif(sectionsToTop[ScootsCraft.activeSkill][a.section] ~= nil and sectionsToTop[ScootsCraft.activeSkill][b.section] ~= nil) then
            if(sectionsToTop[ScootsCraft.activeSkill][a.section] < sectionsToTop[ScootsCraft.activeSkill][b.section]) then
                return true
            elseif(sectionsToTop[ScootsCraft.activeSkill][a.section] > sectionsToTop[ScootsCraft.activeSkill][b.section]) then
                return false
            end
        end
        
        if(a.section < b.section) then
            return true
        elseif(a.section > b.section) then
            return false
        end
        
        if(a.index < b.index) then
            return true
        end
            
        return false
    end)
    
    if(ScootsCraft.sections[ScootsCraft.activeSkill] == nil) then
        ScootsCraft.sections[ScootsCraft.activeSkill] = {}
    end
    
    for craftIndex, recipe in ipairs(ScootsCraft.recipes) do
        if(type(recipe) ~= 'string') then
            if(headersFlat[recipe.section] == nil) then
                headersFlat[recipe.section] = true
                table.insert(ScootsCraft.recipes, craftIndex, recipe.section)
                
                if(ScootsCraft.sections[ScootsCraft.activeSkill][recipe.section] == nil) then
                    ScootsCraft.sections[ScootsCraft.activeSkill][recipe.section] = true
                end
            end
        end
    end
    
    local recipesAfterReductions = 0
    
    for craftIndex = #ScootsCraft.recipes, 1, -1 do
        if(type(ScootsCraft.recipes[craftIndex]) == 'table') then
            if(ScootsCraft.sections[ScootsCraft.activeSkill][ScootsCraft.recipes[craftIndex].section] == true) then
                recipesAfterReductions = recipesAfterReductions + 1
            else
                table.remove(ScootsCraft.recipes, craftIndex)
            end
        end
    end
    
    ScootsCraft.frames.front.recipeCount:SetText(tostring(recipesAfterReductions) .. '/' .. tostring(ScootsCraft.totalRecipeCount))
    
    local offset = ScootsCraft.scrollOffsets[ScootsCraft.activeSkill]
    
    if(offset == nil) then
        offset = 0
    elseif(offset > (#ScootsCraft.recipes - ScootsCraft.recipesVisible)) then
        offset = #ScootsCraft.recipes - ScootsCraft.recipesVisible
        
        if(offset < 0) then
            offset = 0
        end
    end
    
    FauxScrollFrame_SetOffset(ScootsCraft.frames.recipeFrame, offset)
    ScootsCraft.frames.recipeFrame:SetVerticalScroll(offset * ScootsCraft.recipeLineHeight)
    
    ScootsCraft.renderRecipeList()
    ScootsCraft.setToggleAllSectionsVisibleState()
end

ScootsCraft.toggleSection = function(section)
    ScootsCraft.sections[ScootsCraft.activeSkill][section] = not ScootsCraft.sections[ScootsCraft.activeSkill][section]
    ScootsCraft.refreshRecipeList()
    ScootsCraft.setToggleAllSectionsVisibleState()
end

ScootsCraft.toggleAllSections = function()
    local targetValue = true
    
    for _, value in pairs(ScootsCraft.sections[ScootsCraft.activeSkill]) do
        if(value == true) then
            targetValue = false
            break
        end
    end
    
    for sectionIndex, _ in pairs(ScootsCraft.sections[ScootsCraft.activeSkill]) do
        ScootsCraft.sections[ScootsCraft.activeSkill][sectionIndex] = targetValue
    end
    
    ScootsCraft.setToggleAllSectionsVisibleState()
    ScootsCraft.refreshRecipeList()
end

ScootsCraft.setToggleAllSectionsVisibleState = function()
    local state = true
    
    for _, value in pairs(ScootsCraft.sections[ScootsCraft.activeSkill]) do
        if(value == true) then
            state = false
            break
        end
    end
    
    if(state == false) then
        ScootsCraft.frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        ScootsCraft.frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
    else
        ScootsCraft.frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
        ScootsCraft.frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
    end
end

ScootsCraft.renderRecipeList = function()
    local skillIndex = ScootsCraft.skillIndexMap[ScootsCraft.activeSkill]

    if(#ScootsCraft.recipes == 0) then
        ScootsCraft.frames.toggleAllSections:Hide()
    else
        ScootsCraft.frames.toggleAllSections:Show()
    end

    FauxScrollFrame_Update(ScootsCraft.frames.recipeFrame, #ScootsCraft.recipes, ScootsCraft.recipesVisible, ScootsCraft.recipeLineHeight, nil, nil, nil, nil, nil, nil, true)
    local offset = FauxScrollFrame_GetOffset(ScootsCraft.frames.recipeFrame)
    
    ScootsCraft.scrollOffsets[ScootsCraft.activeSkill] = offset
    
    for i = 1, ScootsCraft.recipesVisible do
        local recipeIndex = i + offset
        local frame = ScootsCraft.frames.recipes[i]
        frame.icon:SetAlpha(0)
        
        if(type(ScootsCraft.recipes[recipeIndex]) == 'string') then
            -- Section header
            local sectionName = ScootsCraft.recipes[recipeIndex]
            
            frame:Show()
            frame.recipe = nil
            
            frame.text:SetText(sectionName)
            frame.text:SetTextColor(1, 1, 1)
            frame.underline:SetAlpha(1)
            frame.selected:SetAlpha(0)
            frame.sectionToggle:Show()
            frame.isSectionHead = true
            frame.section = sectionName
            frame.bounty:SetAlpha(0)
            
            if(ScootsCraft.sections[ScootsCraft.activeSkill][sectionName]) then
                frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
                frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
            else
                frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
                frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
            end
        elseif(type(ScootsCraft.recipes[recipeIndex]) == 'table') then
            -- Craft
            local recipe = ScootsCraft.recipes[recipeIndex]
            local spellId = ScootsCraft.recipes[recipeIndex].spellId
            
            frame.isSectionHead = false
            frame.section = nil
            
            if(recipe.spellId == nil) then
                frame:Hide()
                frame.recipe = nil
            else
                frame:Show()
                frame.recipe = ScootsCraft.recipes[recipeIndex]
                
                frame.underline:SetAlpha(0)
                frame.selected:SetAlpha(0)
                frame.sectionToggle:Hide()
                
                local skillId, spellName, createdItemId, craftedItemCount, canCraftTimesNow, altVerb, headerName, levelUpDifficulty = Custom_GetProfessionRecipeInfo(recipe.spellId)
                
                if(levelUpDifficulty ~= 'trivial' and ScootsCraft.skills[skillIndex].currentLevel < ScootsCraft.skills[skillIndex].maxLevel) then
                    frame.icon:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Craft-' .. (levelUpDifficulty:gsub('^%l', string.upper)))
                    frame.icon:SetAlpha(1)
                else
                    frame.icon:SetAlpha(0)
                end
                
                if(canCraftTimesNow and canCraftTimesNow > 0) then
                    frame.text:SetText(spellName .. ' [' .. tostring(canCraftTimesNow) .. ']')
                else
                    frame.text:SetText(spellName)
                end
                
                if(ScootsCraft.selectedCraft[ScootsCraft.activeSkill] and recipe.spellId == ScootsCraft.selectedCraft[ScootsCraft.activeSkill]) then
                    frame.selected:SetAlpha(0.3)
                end
                
                if((createdItemId or 0) == 0) then
                    frame.text:SetTextColor(0.5, 0.5, 0.5)
                    frame.selected:SetVertexColor(0.5, 0.5, 0.5)
                    frame.bounty:SetAlpha(0)
                else
                    local attuneable = CanAttuneItemHelper(createdItemId)
                    local forgeLevel = GetItemAttuneForge(createdItemId)
                    
                    if(attuneable <= 0 and forgeLevel < 0) then
                        frame.text:SetTextColor(0.5, 0.5, 0.5)
                        frame.selected:SetVertexColor(0.5, 0.5, 0.5)
                    else
                        if(forgeLevel == 0) then
                            frame.text:SetTextColor(0.65, 1, 0.5)
                            frame.selected:SetVertexColor(0.65, 1, 0.5)
                        elseif(forgeLevel == 1) then
                            frame.text:SetTextColor(0.5, 0.5, 1)
                            frame.selected:SetVertexColor(0.5, 0.5, 1)
                        elseif(forgeLevel == 2) then
                            frame.text:SetTextColor(1, 0.65, 0.5)
                            frame.selected:SetVertexColor(1, 0.65, 0.5)
                        elseif(forgeLevel == 3) then
                            frame.text:SetTextColor(1, 1, 0.65)
                            frame.selected:SetVertexColor(1, 1, 0.65)
                        else
                            frame.text:SetTextColor(0.8, 0.8, 0.8)
                            frame.selected:SetVertexColor(0.8, 0.8, 0.8)
                        end
                    end
                    
                    if(GetCustomGameData(31, createdItemId) > 0) then
                        frame.bounty:SetAlpha(1)
                    else
                        frame.bounty:SetAlpha(0)
                    end
                end
            end
        else
            frame:Hide()
        end
    end
end

ScootsCraft.selectRecipe = function(spellId)
    ScootsCraft.selectedCraft[ScootsCraft.activeSkill] = spellId
    ScootsCraft.renderRecipe(spellId)
    ScootsCraft.renderRecipeList()
    ScootsCraft.frames.quantity:SetNumber(1)
end

ScootsCraft.renderRecipe = function(spellId)
    if(spellId == nil) then
        ScootsCraft.visibleSpellId = nil
    
        ScootsCraft.frames.craftItem:Hide()
        ScootsCraft.frames.createButton:Disable()
        ScootsCraft.frames.increment:Hide()
        ScootsCraft.frames.quantity:Hide()
        ScootsCraft.frames.decrement:Hide()
        ScootsCraft.frames.createAllButton:Hide()
        
        for _, checkbox in pairs(ScootsCraft.frames.front.forgeHelper) do
            checkbox:Hide()
        end
        
        ScootsCraft.frames.front.forgeHelperTitle:Hide()
        
        return false
    end
    
    ScootsCraft.visibleSpellId = spellId
    ScootsCraft.frames.summaryFrame:Hide()
    ScootsCraft.frames.craftItemScroller:Show()
    ScootsCraft.frames.craftItem:Show()
    ScootsCraft.frames.createButton:Enable()

    local skillId, spellName, createdItemId, craftedItemCount, canCraftTimesNow, altVerb = Custom_GetProfessionRecipeInfo(spellId)
    local height = 0
    
    --
    
    ScootsCraft.frames.craftItem.canCraftText:SetText('Can craft: ' .. tostring(canCraftTimesNow))
    ScootsCraft.frames.craftItem.spellIdText:SetText('Spell ID: ' .. tostring(spellId))
    height = height + ScootsCraft.frames.craftItem.canCraftText:GetHeight()
    
    --
    
    local iconTexture
    if((createdItemId or 0) ~= 0) then
        iconTexture = GetItemIcon(createdItemId)
    else
        iconTexture = select(3, GetSpellInfo(spellId))
    end
    
    ScootsCraft.frames.craftIcon:SetNormalTexture(iconTexture)
    ScootsCraft.frames.craftIcon.spellId = spellId
    height = height + ScootsCraft.frames.craftIcon:GetHeight() + 4
    
    local _, minCraft, maxCraft = Custom_GetSpellEffect(spellId, 0)
    if(minCraft > 0 or maxCraft > 1) then
        maxCraft = minCraft + maxCraft
        minCraft = minCraft + 1
        
        if(maxCraft > minCraft) then
            ScootsCraft.frames.craftIcon.text:SetText(string.format('%d-%d', minCraft, maxCraft))
        else
            ScootsCraft.frames.craftIcon.text:SetText(minCraft)
        end
    else
        if(craftedItemCount > 1) then
            ScootsCraft.frames.craftIcon.text:SetText(craftedItemCount)
        else
            ScootsCraft.frames.craftIcon.text:SetText('')
        end
    end
    
    --
    
    ScootsCraft.frames.craftItem.name:SetText(spellName)
    
    --
    
    local requires = ScootsCraft.parseRequirements(spellId)
    if(requires) then
        ScootsCraft.frames.craftItem.requiresLabel:SetText('Requires:')
        ScootsCraft.frames.craftItem.requires:SetText(requires)
    else
        ScootsCraft.frames.craftItem.requiresLabel:SetText('')
        ScootsCraft.frames.craftItem.requires:SetText('')
    end
    
    --
    
    local cooldown = Custom_GetSpellCooldown(spellId)
    if(cooldown > 0) then
        ScootsCraft.frames.craftItem.cooldown:SetText('Cooldown remaining: ' .. SecondsToTime(math.ceil(cooldown / 1000)))
    else
        ScootsCraft.frames.craftItem.cooldown:SetText('')
    end
    
    --
    
    local description = Custom_GetSpellDesc(spellId, 5)
    if(description) then
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, -10)
        ScootsCraft.frames.craftItem.description:SetText(description)
        height = height + ScootsCraft.frames.craftItem.description:GetHeight() + 10
    else
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, 0)
        ScootsCraft.frames.craftItem.description:SetText('')
    end
    
    --
    
    local reagents = ScootsCraft.data.getRecipeReagents(spellId)
    
    for reagentIndex = 1, 8 do
        local reagent = reagents[reagentIndex]
        
        if(reagent == nil) then
            ScootsCraft.frames.reagents[reagentIndex]:Hide()
            ScootsCraft.frames.reagents[reagentIndex].itemId = nil
        else
            if(reagentIndex == 1) then
                ScootsCraft.frames.craftItem.reagentsLabel:Show()
                height = height + ScootsCraft.frames.craftItem.reagentsLabel:GetHeight() + 10 + ScootsCraft.frames.reagents[reagentIndex]:GetHeight() + 3
            elseif(reagentIndex % 2 == 1) then
                height = height + ScootsCraft.frames.reagents[reagentIndex]:GetHeight() + 2
            end
            
            ScootsCraft.frames.reagents[reagentIndex]:Show()
            SetItemButtonTexture(ScootsCraft.frames.reagents[reagentIndex], GetItemIcon(reagent.itemId))
            _G[ScootsCraft.frames.reagents[reagentIndex]:GetName() .. 'Name']:SetText((select(1, GetItemInfoCustom(reagent.itemId))))
            ScootsCraft.frames.reagents[reagentIndex].itemId = reagent.itemId
            
            if(reagent.required <= reagent.owned) then
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[reagentIndex], 1, 1, 1)
                _G[ScootsCraft.frames.reagents[reagentIndex]:GetName() .. 'Name']:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            else
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[reagentIndex], 0.5, 0.5, 0.5)
                _G[ScootsCraft.frames.reagents[reagentIndex]:GetName() .. 'Name']:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
            
            local reagentOwnedText = tostring(reagent.owned)
            if(reagent.owned > 99) then
                reagentOwnedText = '*'
            end
            _G[ScootsCraft.frames.reagents[reagentIndex]:GetName() .. 'Count']:SetText(reagentOwnedText .. ' /' .. tostring(reagent.required))
        end
    end
    
    --
    
    ScootsCraft.frames.craftItem:SetHeight(height)
    ScootsCraft.frames.craftItemHolder:SetHeight(height + 10)
    
    --
    
    if(altVerb ~= nil) then
        ScootsCraft.frames.createButton:SetText(altVerb)
        ScootsCraft.frames.increment:Hide()
        ScootsCraft.frames.quantity:Hide()
        ScootsCraft.frames.decrement:Hide()
        ScootsCraft.frames.createAllButton:Hide()
        
        for _, checkbox in pairs(ScootsCraft.frames.front.forgeHelper) do
            checkbox:Hide()
        end
        
        ScootsCraft.frames.front.forgeHelperTitle:Hide()
    else
        ScootsCraft.frames.createButton:SetText('Create')
        ScootsCraft.frames.increment:Show()
        ScootsCraft.frames.quantity:Show()
        ScootsCraft.frames.decrement:Show()
        ScootsCraft.frames.createAllButton:Show()
        
        if(ScootsCraft.data.getItemCanForge(createdItemId)) then
            for _, checkbox in pairs(ScootsCraft.frames.front.forgeHelper) do
                checkbox:Show()
            end
            
            ScootsCraft.frames.front.forgeHelperTitle:Show()
        else
            for _, checkbox in pairs(ScootsCraft.frames.front.forgeHelper) do
                checkbox:Hide()
            end
            
            ScootsCraft.frames.front.forgeHelperTitle:Hide()
        end
    end
end

ScootsCraft.parseRequirements = function(spellId)
    local _, focusName, _, areaName, _, totemOneName, _, totemTwoName, _, totemOneCatName, _, totemTwoCatName = Custom_GetSpellTools(spellId)
    local output = {}
    
    for _, requirement in pairs({
        focusName,
        areaName,
        totemOneName,
        totemTwoName,
        totemOneCatName,
        totemTwoCatName,
    }) do
        if(requirement ~= nil) then
            table.insert(output, requirement)
        end
    end
    
    if(#output == 0) then
        return nil
    else
        return table.concat(output, ', ')
    end
end

ScootsCraft.generateSummary = function(skillId)
    ScootsCraft.selectRecipe(nil)
    
    local bagContents = {}
    if(ScootsCraft.options.get('discount-summaries')) then
        local bagContents = ScootsCraft.data.getBagContents()
    end
    
    local reagentCosts = {}
    
    local recipes = ScootsCraft.fetchRecipes(skillId or -1)
    
    for _, spellId in pairs(recipes) do
        local reagents = Custom_GetProfessionRecipeReagents(spellId)
        
        for itemId, itemCount in pairs(reagents) do
            if(reagentCosts[itemId] == nil) then
                reagentCosts[itemId] = itemCount
            else
                reagentCosts[itemId] = reagentCosts[itemId] + itemCount
            end
        end
    end
    
    local doReduction = true
    while doReduction do
        reagentCosts, doReduction = ScootsCraft.reduceSummary(reagentCosts, bagContents)
    end

    ScootsCraft.summary = {}
    
    for itemId, itemCount in pairs(reagentCosts) do
        if(itemCount > 0) then
            table.insert(ScootsCraft.summary, {
                ['itemId'] = itemId,
                ['count'] = itemCount,
            })
        end
    end
    
    table.sort(ScootsCraft.summary, function(a, b)
        return a.count > b.count
    end)
    
    ScootsCraft.renderSummary()
end

ScootsCraft.reduceSummary = function(reagents, bagContents)
    local didReduction = false
    local newReagents = {}
    local exclusions = ScootsCraft.data.getSummaryReductionExclusions()
    
    for itemId, _ in pairs(reagents) do
        if(reagents[itemId] > 0 and exclusions[itemId] == nil) then
            local spellId = Custom_GetProfessionRecipeFromCraftedItem(itemId)
            
            if(spellId ~= nil) then
                if(ScootsCraft.options.get('discount-summaries')) then
                    local bankOwned = GetCustomGameData(13, itemId) or 0
                    reagents[itemId] = reagents[itemId] - (bankOwned + (bagContents[itemId] or 0))
                end
                
                if(reagents[itemId] > 0) then
                    didReduction = true
                    
                    local subReagents = Custom_GetProfessionRecipeReagents(spellId)
                    
                    for subItemId, subItemCount in pairs(subReagents) do
                        if(newReagents[subItemId] == nil) then
                            newReagents[subItemId] = (subItemCount * reagents[itemId])
                        else
                            newReagents[subItemId] = newReagents[subItemId] + (subItemCount * reagents[itemId])
                        end
                    end
                    
                    reagents[itemId] = 0
                end
            end
        end
    end
    
    if(didReduction == true) then
        for itemId, itemCount in pairs(newReagents) do
            if(reagents[itemId] == nil) then
                reagents[itemId] = itemCount
            else
                reagents[itemId] = reagents[itemId] + itemCount
            end
        end
    elseif(ScootsCraft.options.get('discount-summaries')) then
        for itemId, _ in pairs(reagents) do
            if(reagents[itemId] > 0) then
                local bankOwned = GetCustomGameData(13, itemId) or 0
                reagents[itemId] = reagents[itemId] - (bankOwned + (bagContents[itemId] or 0))
            end
        end
    end
    
    return reagents, didReduction
end

ScootsCraft.renderSummary = function()
    ScootsCraft.frames.craftItemScroller:Hide()
    ScootsCraft.frames.summaryFrame:Show()
    
    FauxScrollFrame_Update(ScootsCraft.frames.summaryFrame, #ScootsCraft.summary, ScootsCraft.summaryLinesVisible, ScootsCraft.summaryLineHeight, nil, nil, nil, nil, nil, nil, true)
    local offset = FauxScrollFrame_GetOffset(ScootsCraft.frames.summaryFrame)
    
    for i = 1, ScootsCraft.summaryLinesVisible do
        local summaryLine = ScootsCraft.summary[i + offset]
        local frame = ScootsCraft.frames.summaryLines[i]
        
        if(summaryLine == nil) then
            frame:Hide()
        else
            frame:Show()
            
            frame.icon:SetTexture(GetItemIcon(summaryLine.itemId))
            frame.leftText:SetText(ScootsCraft.getItemLink(summaryLine.itemId))
            frame.rightText:SetText(summaryLine.count)
            frame.itemId = summaryLine.itemId
        end
    end
end

ScootsCraft.craftItem = function()
    EditBox_ClearFocus(ScootsCraft.frames.quantity)
    
    local quantity = ScootsCraft.frames.quantity:GetNumber()
    if(not ScootsCraft.frames.quantity:IsVisible()) then
        quantity = 1
    end
    
    if(ScootsCraft.forgeHelper ~= nil) then
        local _, _, createdItemId, _, _, altVerb = Custom_GetProfessionRecipeInfo(ScootsCraft.visibleSpellId)
        
        if(altVerb == nil and ScootsCraft.data.getItemCanForge(createdItemId)) then
            ScootsCraft.forgeHelperItem = createdItemId
            ScootsCraft.forgeHelperQuantity = quantity
        end
    end
    
    Custom_DoProfessionRecipe(ScootsCraft.visibleSpellId, quantity)
end

ScootsCraft.handleForgeHelper = function()
    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        
        for slotIndex = 1, bagSlots do
            local _, bagItemCount, _, _, _, _, bagItemLink = GetContainerItemInfo(bagIndex, slotIndex)
            
            if(bagItemLink ~= nil) then
                local bagItemId = CustomExtractItemId(bagItemLink)
                
                if(bagItemId == ScootsCraft.forgeHelperItem) then
                    if(GetItemLinkTitanforge(bagItemLink) >= ScootsCraft.forgeHelper) then
                        ScootsCraft.forgeHelperItem = nil
                        -- TODO: insert a delay to vendor unforged here
                    else
                        if(ScootsCraft.merchantOpen) then
                            UseContainerItem(bagIndex, slotIndex)
                        else
                            PickupContainerItem(bagIndex, slotIndex)
                            DeleteCursorItem()
                        end
                    end
                end
            end
        end
    end
    
    if(ScootsCraft.forgeHelperItem ~= nil) then
        ScootsCraft.frames.quantity:SetNumber(ScootsCraft.forgeHelperQuantity)
    end
end

ScootsCraft.handleReagentJump = function(itemId)
    local spellId = Custom_GetProfessionRecipeFromCraftedItem(itemId)
    
    if(spellId ~= nil) then
        local skillId = Custom_GetProfessionRecipeInfo(spellId)
        
        if(skillId) then
            local recipes = Custom_GetProfessionRecipes(skillId)
            
            for recipeIndex = 1, #recipes do
                if(recipes[recipeIndex] == spellId) then
                    ScootsCraft.renderRecipe(spellId)
                    break
                end
            end
        end
    end
end

ScootsCraft.setFilter = function(key, value)
    ScootsCraft.filters[ScootsCraft.activeSkill][key] = value
    ScootsCraft.refreshRecipeList()
end

ScootsCraft.getFilter = function(key)
    if(ScootsCraft.filters[ScootsCraft.activeSkill] == nil or ScootsCraft.filters[ScootsCraft.activeSkill][key] == nil) then
        return ScootsCraft.defaultFilters[key]
    end
    
    return ScootsCraft.filters[ScootsCraft.activeSkill][key]
end

ScootsCraft.pushMessage = function(message)
    print('\124cff' .. '98fb98' .. ScootsCraft.title .. ' ' .. ScootsCraft.version .. '\124r')
    print(message)
end

ScootsCraft.getCraftingLink = function(spellId)
    local skillId, spellName = Custom_GetProfessionRecipeInfo(spellId)

    return string.format('|cffffd000|Henchant:%d|h[%s: %s]|h|r', spellId, ScootsCraft.skills[ScootsCraft.skillIndexMap[skillId]].displayName, spellName)
end

ScootsCraft.getItemLink = function(itemId)
    return (select(2, GetItemInfoCustom(itemId)))
end

ScootsCraft.frames.events:SetScript('OnUpdate', ScootsCraft.updateLoop)
ScootsCraft.frames.events:SetScript('OnEvent', ScootsCraft.eventHandler)

ScootsCraft.frames.events:RegisterEvent('ADDON_LOADED')
ScootsCraft.frames.events:RegisterEvent('PLAYER_LOGOUT')
ScootsCraft.frames.events:RegisterEvent('SKILL_LINES_CHANGED')
ScootsCraft.frames.events:RegisterEvent('MERCHANT_SHOW')
ScootsCraft.frames.events:RegisterEvent('MERCHANT_CLOSED')

SynastriaSafeInvoke('ScootsCraft_Core_Init')