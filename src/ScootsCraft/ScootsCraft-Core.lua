local core
local storage = ScootsCraft.storage
local options = ScootsCraft.options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility = ScootsCraft.utility
local lookup = ScootsCraft.lookup

core = {
    ['preBuildChecks'] = function()
        if(UnitAffectingCombat('player')) then
            utility.pushMessage('Please wait until you are out-of-combat before attempting to open ' .. ScootsCraft.title .. ' for the first time.')
            return false
        end

        return true
    end,
    ['init'] = function()
        core.skills = {}
        core.skillMap = {}
        core.skillIndexMap = {}
        core.inventorySlots = {}
        core.sections = {}
        core.sectionList = {}
        core.filters = {}
        core.selectedCraft = {}
        core.scrollOffsets = {}
        core.forgeHelper = nil
        core.forgeHelperItem = false
        core.forgeHelperQuantity = nil
        core.merchantOpen = false

        utility.cacheProfessions()
        
        if(_G['SCOOTSCRAFT_SAVEDDATA'] ~= nil) then
            if(_G['SCOOTSCRAFT_SAVEDDATA'].options ~= nil) then
                storage.options = _G['SCOOTSCRAFT_SAVEDDATA'].options
            end
            
            if(_G['SCOOTSCRAFT_SAVEDDATA'].lastActiveSkill ~= nil) then
                storage.lastActiveSkill = _G['SCOOTSCRAFT_SAVEDDATA'].lastActiveSkill
            end
        end
        
        if(storage.lastActiveSkill ~= nil) then
            core.activeSkill = storage.lastActiveSkill
        end
        
        options.load()
        options.build()
        interface.buildMinimapButton()
    end,
    ['eventHandler'] = function(self, event, arg1)
        if(event == 'BAG_UPDATE'
        or event == 'SKILL_LINES_CHANGED') then
            core.triggeredEvents[event] = true
        elseif(event == 'MERCHANT_SHOW') then
            core.merchantOpen = true
        elseif(event == 'MERCHANT_CLOSED') then
            core.merchantOpen = false
        elseif(event == 'ADDON_LOADED' and arg1 == 'ScootsCraft') then
            SynastriaSafeInvoke('ScootsCraft_Core_Init')
        elseif(event == 'PLAYER_LOGOUT') then
            _G['SCOOTSCRAFT_SAVEDDATA'] = storage
        end
    end,
    ['updateLoop'] = function()
        if(frames.master ~= nil and frames.master:IsVisible()) then
            if(core.triggeredEvents['BAG_UPDATE'] ~= nil) then
                local skillIndex = core.skillIndexMap[core.activeSkill]
            
                core.triggeredEvents['BAG_UPDATE'] = nil
                frames.quantity:SetNumber(1)
                utility.cacheSkillLevels()
                frames.title.skillName:SetText(string.format(' - %s [%d/%d]', core.skills[skillIndex].displayName, core.skills[skillIndex].currentLevel, core.skills[skillIndex].maxLevel))
                core.refreshRecipeList()
                core.renderRecipe(core.visibleSpellId)
                
                if(core.forgeHelper ~= nil and core.forgeHelperItem ~= nil) then
                    core.handleForgeHelper()
                end
            end
            
            if(core.triggeredEvents['SKILL_LINES_CHANGED'] ~= nil) then
                core.triggeredEvents['SKILL_LINES_CHANGED'] = nil
                utility.cacheProfessions()
                interface.buildProfessionSwatch()
            end
        end
    end,
    ['setActiveSkill'] = function(skillIndex)
        core.activeSkill = core.skills[skillIndex].skillId
        
        for _, button in pairs(frames.skillButtons) do
            button:Enable()
            button.activeGlow:SetAlpha(0)
        end
        
        frames.skillButtons[core.skills[skillIndex].name]:Disable()
        frames.skillButtons[core.skills[skillIndex].name].activeGlow:SetVertexColor(0.8, 0.8, 0)
        frames.skillButtons[core.skills[skillIndex].name].activeGlow:SetAlpha(1)
        
        frames.title.skillName:SetText(string.format(' - %s [%d/%d]', core.skills[skillIndex].displayName, core.skills[skillIndex].currentLevel, core.skills[skillIndex].maxLevel))
        SetPortraitToTexture(frames.master.icon, core.skills[skillIndex].icon)
        
        --
        
        core.totalRecipeCount = 0
        
        core.inventorySlots = {}
        local invSlotCheck = {}
        
        core.sectionList = {}
        local sectionCheck = {}
        
        local recipes = Custom_GetProfessionRecipes(core.activeSkill)
        local headerRewrites = lookup.getSectionRewrites()
        local spellHeaderRewrites = lookup.getSpellSectionRewrites()
        
        for _, spellId in pairs(recipes) do
            core.totalRecipeCount = core.totalRecipeCount + 1
            local _, _, createdItemId, _, _, _, headerName = Custom_GetProfessionRecipeInfo(spellId)
            
            if(spellHeaderRewrites[core.activeSkill][spellId] ~= nil) then
                headerName = spellHeaderRewrites[core.activeSkill][spellId]
            elseif(headerRewrites[core.activeSkill][headerName] ~= nil) then
                headerName = headerRewrites[core.activeSkill][headerName]
            end
            
            if(headerName == nil) then
                headerName = 'Unknown'
            end
            
            if(sectionCheck[headerName] == nil) then
                sectionCheck[headerName] = true
                table.insert(core.sectionList, headerName)
            end
            
            --
            
            if((createdItemId or 0) ~= 0) then
                local invSlot = select(9, GetItemInfoCustom(createdItemId))
                
                if(invSlot == 'INVTYPE_ROBE') then
                    invSlot = 'INVTYPE_BODY'
                end
                
                if((invSlot or '') ~= '' and sectionCheck[invSlot] == nil) then
                    sectionCheck[invSlot] = true
                    table.insert(core.inventorySlots, invSlot)
                end
            end
        end
        
        table.sort(core.sectionList, function(a, b)
            if(a < b) then
                return true
            end
            
            return false
        end)
        
        --
        
        interface.updateFilterDisplay()
        core.refreshRecipeList()
        core.setToggleAllSectionsVisibleState()
        
        core.renderRecipe(core.selectedCraft[core.activeSkill])
        storage.lastActiveSkill = core.activeSkill
    end,
    ['fetchRecipes'] = function(skillId)
        local filters = core.filters[core.activeSkill] or options.defaultFiltersValues

        local includeFilter = bit.bor(
            core.getFilter('attuneable') == 'character' and 1 or 0,
            (core.getFilter('attuneable') == 'account' or core.getFilter('attuneable') == 'character') and 4 or 0,
            core.getFilter('search-include-reagents') and 8 or 0,
            core.getFilter('have-materials') and 0x20 or 0
        )
        
        local excludeFilter = bit.bor(
            core.getFilter('exclude-items-in-bags') and 0x10 or 0,
            core.getFilter('attuned-level') ~= 4 and 0x40 or 0
        )
        
        return Custom_GetProfessionRecipes(
            skillId,
            includeFilter,
            excludeFilter,
            -3, -- Sort flag
            core.getFilter('search'),        
            core.getFilter('attuned-level'), 
            -1, -- Item class
            -1, -- Item sub-class
            core.getFilter('inv-slot')
        )
    end,
    ['refreshRecipeList'] = function()
        core.recipes = {}
        local recipes = core.fetchRecipes(core.activeSkill)
        
        local headersFlat = {}
        
        local headerRewrites = lookup.getSectionRewrites()
        local spellHeaderRewrites = lookup.getSpellSectionRewrites()
        
        for spellIndex, spellId in ipairs(recipes) do
            local headerName = select(7, Custom_GetProfessionRecipeInfo(spellId))
            
            if(spellHeaderRewrites[core.activeSkill][spellId] ~= nil) then
                headerName = spellHeaderRewrites[core.activeSkill][spellId]
            elseif(headerRewrites[core.activeSkill][headerName] ~= nil) then
                headerName = headerRewrites[core.activeSkill][headerName]
            end
            
            if(core.getFilter('section') == nil or core.getFilter('section') == headerName) then
                table.insert(core.recipes, {
                    ['section'] = headerName,
                    ['spellId'] = spellId,
                    ['index'] = spellIndex,
                })
            end
        end
        
        local sectionsToTop = lookup.getSectionsPushedToTop()
        
        table.sort(core.recipes, function(a, b)
            if(a ~= nil and b == nil) then
                return true
            elseif(a == nil and b ~= nil) then
                return false
            elseif(a == nil and b == nil) then
                return false
            end
            
            if(sectionsToTop[core.activeSkill][a.section] ~= nil and sectionsToTop[core.activeSkill][b.section] == nil) then
                return true
            elseif(sectionsToTop[core.activeSkill][a.section] == nil and sectionsToTop[core.activeSkill][b.section] ~= nil) then
                return false
            elseif(sectionsToTop[core.activeSkill][a.section] ~= nil and sectionsToTop[core.activeSkill][b.section] ~= nil) then
                if(sectionsToTop[core.activeSkill][a.section] < sectionsToTop[core.activeSkill][b.section]) then
                    return true
                elseif(sectionsToTop[core.activeSkill][a.section] > sectionsToTop[core.activeSkill][b.section]) then
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
        
        if(core.sections[core.activeSkill] == nil) then
            core.sections[core.activeSkill] = {}
        end
        
        for craftIndex, recipe in ipairs(core.recipes) do
            if(type(recipe) ~= 'string') then
                if(headersFlat[recipe.section] == nil) then
                    headersFlat[recipe.section] = true
                    table.insert(core.recipes, craftIndex, recipe.section)
                    
                    if(core.sections[core.activeSkill][recipe.section] == nil) then
                        core.sections[core.activeSkill][recipe.section] = true
                    end
                end
            end
        end
        
        local recipesAfterReductions = 0
        
        for craftIndex = #core.recipes, 1, -1 do
            if(type(core.recipes[craftIndex]) == 'table') then
                if(core.sections[core.activeSkill][core.recipes[craftIndex].section] == true) then
                    recipesAfterReductions = recipesAfterReductions + 1
                else
                    table.remove(core.recipes, craftIndex)
                end
            end
        end
        
        frames.front.recipeCount:SetText(tostring(recipesAfterReductions) .. '/' .. tostring(core.totalRecipeCount))
        
        local offset = core.scrollOffsets[core.activeSkill]
        
        if(offset == nil) then
            offset = 0
        elseif(offset > (#core.recipes - core.recipesVisible)) then
            offset = #core.recipes - core.recipesVisible
            
            if(offset < 0) then
                offset = 0
            end
        end
        
        FauxScrollFrame_SetOffset(frames.recipeFrame, offset)
        frames.recipeFrame:SetVerticalScroll(offset * core.recipeLineHeight)
        
        core.renderRecipeList()
        core.setToggleAllSectionsVisibleState()
    end,
    ['toggleSection'] = function(section)
        core.sections[core.activeSkill][section] = not core.sections[core.activeSkill][section]
        core.refreshRecipeList()
        core.setToggleAllSectionsVisibleState()
    end,
    ['toggleAllSections'] = function()
        local targetValue = true
        
        for _, value in pairs(core.sections[core.activeSkill]) do
            if(value == true) then
                targetValue = false
                break
            end
        end
        
        for sectionIndex, _ in pairs(core.sections[core.activeSkill]) do
            core.sections[core.activeSkill][sectionIndex] = targetValue
        end
        
        core.setToggleAllSectionsVisibleState()
        core.refreshRecipeList()
    end,
    ['setToggleAllSectionsVisibleState'] = function()
        local state = true
        
        for _, value in pairs(core.sections[core.activeSkill]) do
            if(value == true) then
                state = false
                break
            end
        end
        
        if(state == false) then
            frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
            frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
        else
            frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
            frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
        end
    end,
    ['renderRecipeList'] = function()
        local skillIndex = core.skillIndexMap[core.activeSkill]

        if(#core.recipes == 0) then
            frames.toggleAllSections:Hide()
        else
            frames.toggleAllSections:Show()
        end

        FauxScrollFrame_Update(frames.recipeFrame, #core.recipes, core.recipesVisible, core.recipeLineHeight, nil, nil, nil, nil, nil, nil, true)
        local offset = FauxScrollFrame_GetOffset(frames.recipeFrame)
        
        core.scrollOffsets[core.activeSkill] = offset
        
        for i = 1, core.recipesVisible do
            local recipeIndex = i + offset
            local frame = frames.recipes[i]
            frame.icon:SetAlpha(0)
            
            if(type(core.recipes[recipeIndex]) == 'string') then
                -- Section header
                local sectionName = core.recipes[recipeIndex]
                
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
                
                if(core.sections[core.activeSkill][sectionName]) then
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
                else
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
                end
            elseif(type(core.recipes[recipeIndex]) == 'table') then
                -- Craft
                local recipe = core.recipes[recipeIndex]
                local spellId = core.recipes[recipeIndex].spellId
                
                frame.isSectionHead = false
                frame.section = nil
                
                if(recipe.spellId == nil) then
                    frame:Hide()
                    frame.recipe = nil
                else
                    frame:Show()
                    frame.recipe = core.recipes[recipeIndex]
                    
                    frame.underline:SetAlpha(0)
                    frame.selected:SetAlpha(0)
                    frame.sectionToggle:Hide()
                    
                    local skillId, spellName, createdItemId, craftedItemCount, canCraftTimesNow, altVerb, headerName, levelUpDifficulty = Custom_GetProfessionRecipeInfo(recipe.spellId)
                    
                    if(levelUpDifficulty ~= 'trivial' and core.skills[skillIndex].currentLevel < core.skills[skillIndex].maxLevel) then
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
                    
                    if(core.selectedCraft[core.activeSkill] and recipe.spellId == core.selectedCraft[core.activeSkill]) then
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
    end,
    ['selectRecipe'] = function(spellId)
        core.selectedCraft[core.activeSkill] = spellId
        core.renderRecipe(spellId)
        core.renderRecipeList()
        frames.quantity:SetNumber(1)
    end,
    ['renderRecipe'] = function(spellId)
        if(spellId == nil) then
            core.visibleSpellId = nil
        
            frames.craftItem:Hide()
            frames.createButton:Disable()
            frames.increment:Hide()
            frames.quantity:Hide()
            frames.decrement:Hide()
            frames.createAllButton:Hide()
            
            for _, checkbox in pairs(frames.front.forgeHelper) do
                checkbox:Hide()
            end
            
            frames.front.forgeHelperTitle:Hide()
            
            return false
        end
        
        core.visibleSpellId = spellId
        frames.summaryFrame:Hide()
        frames.craftItemScroller:Show()
        frames.craftItem:Show()
        frames.createButton:Enable()

        local skillId, spellName, createdItemId, craftedItemCount, canCraftTimesNow, altVerb = Custom_GetProfessionRecipeInfo(spellId)
        local height = 0
        
        --
        
        frames.craftItem.canCraftText:SetText('Can craft: ' .. tostring(canCraftTimesNow))
        frames.craftItem.spellIdText:SetText('Spell ID: ' .. tostring(spellId))
        height = height + frames.craftItem.canCraftText:GetHeight()
        
        --
        
        local iconTexture
        if((createdItemId or 0) ~= 0) then
            iconTexture = GetItemIcon(createdItemId)
        else
            iconTexture = select(3, GetSpellInfo(spellId))
        end
        
        frames.craftIcon:SetNormalTexture(iconTexture)
        frames.craftIcon.spellId = spellId
        height = height + frames.craftIcon:GetHeight() + 4
        
        local _, minCraft, maxCraft = Custom_GetSpellEffect(spellId, 0)
        if(minCraft > 0 or maxCraft > 1) then
            maxCraft = minCraft + maxCraft
            minCraft = minCraft + 1
            
            if(maxCraft > minCraft) then
                frames.craftIcon.text:SetText(string.format('%d-%d', minCraft, maxCraft))
            else
                frames.craftIcon.text:SetText(minCraft)
            end
        else
            if(craftedItemCount > 1) then
                frames.craftIcon.text:SetText(craftedItemCount)
            else
                frames.craftIcon.text:SetText('')
            end
        end
        
        --
        
        frames.craftItem.name:SetText(spellName)
        
        --
        
        local requires = core.parseRequirements(spellId)
        if(requires) then
            frames.craftItem.requiresLabel:SetText('Requires:')
            frames.craftItem.requires:SetText(requires)
        else
            frames.craftItem.requiresLabel:SetText('')
            frames.craftItem.requires:SetText('')
        end
        
        --
        
        local cooldown = Custom_GetSpellCooldown(spellId)
        if(cooldown > 0) then
            frames.craftItem.cooldown:SetText('Cooldown remaining: ' .. SecondsToTime(math.ceil(cooldown / 1000)))
        else
            frames.craftItem.cooldown:SetText('')
        end
        
        --
        
        local description = Custom_GetSpellDesc(spellId, 5)
        if(description) then
            frames.craftItem.description:SetPoint('TOPLEFT', frames.craftIcon, 'BOTTOMLEFT', 0, -10)
            frames.craftItem.description:SetText(description)
            height = height + frames.craftItem.description:GetHeight() + 10
        else
            frames.craftItem.description:SetPoint('TOPLEFT', frames.craftIcon, 'BOTTOMLEFT', 0, 0)
            frames.craftItem.description:SetText('')
        end
        
        --
        
        local reagents = utility.getRecipeReagents(spellId)
        
        for reagentIndex = 1, 8 do
            local reagent = reagents[reagentIndex]
            
            if(reagent == nil) then
                frames.reagents[reagentIndex]:Hide()
                frames.reagents[reagentIndex].itemId = nil
            else
                if(reagentIndex == 1) then
                    frames.craftItem.reagentsLabel:Show()
                    height = height + frames.craftItem.reagentsLabel:GetHeight() + 10 + frames.reagents[reagentIndex]:GetHeight() + 3
                elseif(reagentIndex % 2 == 1) then
                    height = height + frames.reagents[reagentIndex]:GetHeight() + 2
                end
                
                frames.reagents[reagentIndex]:Show()
                SetItemButtonTexture(frames.reagents[reagentIndex], GetItemIcon(reagent.itemId))
                _G[frames.reagents[reagentIndex]:GetName() .. 'Name']:SetText((select(1, GetItemInfoCustom(reagent.itemId))))
                frames.reagents[reagentIndex].itemId = reagent.itemId
                
                if(reagent.required <= reagent.owned) then
                    SetItemButtonTextureVertexColor(frames.reagents[reagentIndex], 1, 1, 1)
                    _G[frames.reagents[reagentIndex]:GetName() .. 'Name']:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
                else
                    SetItemButtonTextureVertexColor(frames.reagents[reagentIndex], 0.5, 0.5, 0.5)
                    _G[frames.reagents[reagentIndex]:GetName() .. 'Name']:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
                end
                
                local reagentOwnedText = tostring(reagent.owned)
                if(reagent.owned > 99) then
                    reagentOwnedText = '*'
                end
                _G[frames.reagents[reagentIndex]:GetName() .. 'Count']:SetText(reagentOwnedText .. ' /' .. tostring(reagent.required))
            end
        end
        
        --
        
        frames.craftItem:SetHeight(height)
        frames.craftItemHolder:SetHeight(height + 10)
        
        --
        
        if(altVerb ~= nil) then
            frames.createButton:SetText(altVerb)
            frames.increment:Hide()
            frames.quantity:Hide()
            frames.decrement:Hide()
            frames.createAllButton:Hide()
            
            for _, checkbox in pairs(frames.front.forgeHelper) do
                checkbox:Hide()
            end
            
            frames.front.forgeHelperTitle:Hide()
        else
            frames.createButton:SetText('Create')
            frames.increment:Show()
            frames.quantity:Show()
            frames.decrement:Show()
            frames.createAllButton:Show()
            
            if(utility.getItemCanForge(createdItemId)) then
                for _, checkbox in pairs(frames.front.forgeHelper) do
                    checkbox:Show()
                end
                
                frames.front.forgeHelperTitle:Show()
            else
                for _, checkbox in pairs(frames.front.forgeHelper) do
                    checkbox:Hide()
                end
                
                frames.front.forgeHelperTitle:Hide()
            end
        end
    end,
    ['parseRequirements'] = function(spellId)
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
    end,
    ['generateSummary'] = function(skillId)
        core.selectRecipe(nil)
        
        local bagContents = {}
        if(options.get('discount-summaries')) then
            local bagContents = utility.getBagContents()
        end
        
        local reagentCosts = {}
        
        local recipes = core.fetchRecipes(skillId or -1)
        
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
            reagentCosts, doReduction = core.reduceSummary(reagentCosts, bagContents)
        end

        core.summary = {}
        
        for itemId, itemCount in pairs(reagentCosts) do
            if(itemCount > 0) then
                table.insert(core.summary, {
                    ['itemId'] = itemId,
                    ['count'] = itemCount,
                })
            end
        end
        
        table.sort(core.summary, function(a, b)
            return a.count > b.count
        end)
        
        core.renderSummary()
    end,
    ['reduceSummary'] = function(reagents, bagContents)
        local didReduction = false
        local newReagents = {}
        local exclusions = lookup.summaryReductionExclusions
        
        for itemId, _ in pairs(reagents) do
            if(reagents[itemId] > 0 and exclusions[itemId] == nil) then
                local spellId = Custom_GetProfessionRecipeFromCraftedItem(itemId)
                
                if(spellId ~= nil) then
                    if(options.get('discount-summaries')) then
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
        elseif(options.get('discount-summaries')) then
            for itemId, _ in pairs(reagents) do
                if(reagents[itemId] > 0) then
                    local bankOwned = GetCustomGameData(13, itemId) or 0
                    reagents[itemId] = reagents[itemId] - (bankOwned + (bagContents[itemId] or 0))
                end
            end
        end
        
        return reagents, didReduction
    end,
    ['renderSummary'] = function()
        frames.craftItemScroller:Hide()
        frames.summaryFrame:Show()
        
        FauxScrollFrame_Update(frames.summaryFrame, #core.summary, core.summaryLinesVisible, core.summaryLineHeight, nil, nil, nil, nil, nil, nil, true)
        local offset = FauxScrollFrame_GetOffset(frames.summaryFrame)
        
        for i = 1, core.summaryLinesVisible do
            local summaryLine = core.summary[i + offset]
            local frame = frames.summaryLines[i]
            
            if(summaryLine == nil) then
                frame:Hide()
            else
                frame:Show()
                
                frame.icon:SetTexture(GetItemIcon(summaryLine.itemId))
                frame.leftText:SetText(utility.getItemLink(summaryLine.itemId))
                frame.rightText:SetText(summaryLine.count)
                frame.itemId = summaryLine.itemId
            end
        end
    end,
    ['craftItem'] = function()
        EditBox_ClearFocus(frames.quantity)
        
        local quantity = frames.quantity:GetNumber()
        if(not frames.quantity:IsVisible()) then
            quantity = 1
        end
        
        if(core.forgeHelper ~= nil) then
            local _, _, createdItemId, _, _, altVerb = Custom_GetProfessionRecipeInfo(core.visibleSpellId)
            
            if(altVerb == nil and utility.getItemCanForge(createdItemId)) then
                core.forgeHelperItem = createdItemId
                core.forgeHelperQuantity = quantity
            end
        end
        
        Custom_DoProfessionRecipe(core.visibleSpellId, quantity)
    end,
    ['handleForgeHelper'] = function()
        for bagIndex = 0, 4 do
            local bagSlots = GetContainerNumSlots(bagIndex)
            
            for slotIndex = 1, bagSlots do
                local _, bagItemCount, _, _, _, _, bagItemLink = GetContainerItemInfo(bagIndex, slotIndex)
                
                if(bagItemLink ~= nil) then
                    local bagItemId = CustomExtractItemId(bagItemLink)
                    
                    if(bagItemId == core.forgeHelperItem) then
                        if(GetItemLinkTitanforge(bagItemLink) >= core.forgeHelper) then
                            core.forgeHelperItem = nil
                            -- TODO: insert a delay to vendor unforged here
                        else
                            if(core.merchantOpen) then
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
        
        if(core.forgeHelperItem ~= nil) then
            frames.quantity:SetNumber(core.forgeHelperQuantity)
        end
    end,
    ['handleReagentJump'] = function(itemId)
        local spellId = Custom_GetProfessionRecipeFromCraftedItem(itemId)
        
        if(spellId ~= nil) then
            local skillId = Custom_GetProfessionRecipeInfo(spellId)
            
            if(skillId) then
                local recipes = Custom_GetProfessionRecipes(skillId)
                
                for recipeIndex = 1, #recipes do
                    if(recipes[recipeIndex] == spellId) then
                        core.renderRecipe(spellId)
                        break
                    end
                end
            end
        end
    end,
    ['setFilter'] = function(key, value)
        core.filters[core.activeSkill][key] = value
        core.refreshRecipeList()
    end,
    ['getFilter'] = function(key)
        if(core.filters[core.activeSkill] == nil or core.filters[core.activeSkill][key] == nil) then
            return options.defaultFiltersValues[key]
        end
        
        return core.filters[core.activeSkill][key]
    end,
}

for funcName, func in pairs(core) do
    ScootsCraft.core[funcName] = func
end

core = ScootsCraft.core

frames.events:SetScript('OnUpdate', core.updateLoop)
frames.events:SetScript('OnEvent', core.eventHandler)

frames.events:RegisterEvent('ADDON_LOADED')
frames.events:RegisterEvent('PLAYER_LOGOUT')
frames.events:RegisterEvent('SKILL_LINES_CHANGED')
frames.events:RegisterEvent('MERCHANT_SHOW')
frames.events:RegisterEvent('MERCHANT_CLOSED')

function ScootsCraft_Core_Init()
    core.init()
end