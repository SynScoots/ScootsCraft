local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options = ScootsCraft.options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility
local lookup = ScootsCraft.lookup

utility = {
    ['cacheProfessions'] = function()
        local skillIdMap = lookup.professionMap

        for skillIndex = 1, #skillIdMap do
            local skill = skillIdMap[skillIndex]
            core.skills[skillIndex] = skillIdMap[skillIndex]
            core.skillMap[skillIdMap[skillIndex].name] = skillIdMap[skillIndex].skillId
            core.skillIndexMap[skillIdMap[skillIndex].skillId] = skillIndex
            
            if(core.filters[skill.skillId] == nil) then
                core.filters[skill.skillId] = {}
                for key, value in pairs(options.defaultFiltersValues) do
                    core.filters[skill.skillId][key] = value
                end
            end
            
            local knowsSkill = false
            for _, spellIdCheck in ipairs(core.skills[skillIndex].possibleSpellIds) do
                if(IsSpellKnown(spellIdCheck)) then
                    knowsSkill = true
                    core.skills[skillIndex].spellId = spellIdCheck
                    break
                end
            end
            
            if(knowsSkill) then
                local name, _, icon = GetSpellInfo(core.skills[skillIndex].spellId)
                
                core.skills[skillIndex].displayName = name
                core.skills[skillIndex].icon = icon
            end
        end
        
        utility.cacheSkillLevels()
    end,
    ['cacheSkillLevels'] = function()
        for skillIndex, skill in pairs(core.skills) do
            local internalSkillIndex = Custom_GetSkillIndex(skill.skillId)
            local _, _, _, currentLevel, _, _, maxLevel = GetSkillLineInfo(internalSkillIndex)
            
            core.skills[skillIndex].currentLevel = currentLevel
            core.skills[skillIndex].maxLevel = maxLevel
        end
    end,
    ['pushMessage'] = function(message)
        print('\124cff' .. '98fb98' .. ScootsCraft.title .. ' ' .. ScootsCraft.version .. '\124r')
        print(message)
    end,
    ['getCraftingLink'] = function(spellId)
        local skillId, spellName = Custom_GetProfessionRecipeInfo(spellId)

        return string.format('|cffffd000|Henchant:%d|h[%s: %s]|h|r', spellId, core.skills[core.skillIndexMap[skillId]].displayName, spellName)
    end,
    ['getItemLink'] = function(itemId)
        return (select(2, GetItemInfoCustom(itemId)))
    end,
    ['getRecipeReagents'] = function(spellId)
        local reagents = {}
        local requiredReagents = Custom_GetProfessionRecipeReagents(spellId)
        
        Custom_CacheHaveItems()
        local reagentsInBags = {}
        
        for itemId, requiredCount in pairs(requiredReagents) do
            local reagentDetail = {
                ['itemId'] = itemId,
                ['required'] = requiredCount,
                ['owned'] = GetCustomGameData(13, itemId)
            }
            
            reagentDetail.owned = reagentDetail.owned + (Custom_IsHaveItem(itemId) or 0)
            
            table.insert(reagents, reagentDetail)
        end
        
        return reagents
    end,
    ['getBagContents'] = function()
        lookup.bagContents = lookup.bagContents or {}
        
        if(lookup.bagCached) then
            return lookup.bagContents
        end
        
        for key, _ in pairs(lookup.bagContents) do
            lookup.bagContents[key] = nil
        end
        
        for slotId = 0, 38 do
            utility.cacheBagSlot(0xff, slotId)
        end
        
        for bagId = 19, 22 do
            for slotId = 0, (GetContainerNumSlots(bagId - 19) - 1) do
                utility.cacheBagSlot(bagId, slotId)
            end
        end
        
        lookup.bagCached = true
        return lookup.bagContents
    end,
    ['cacheBagSlot'] = function(bagId, slotId)
        local itemLink = Custom_GetItemLinkBySlot(bagId, slotId)
        local itemId = CustomExtractItemId(itemLink)
        
        if((itemId or 0) ~= 0) then
            lookup.bagContents[itemId] = (lookup.bagContents[itemId] or 0) + Custom_GetItemCount(bagId, slotId)
        end
    end,
    ['getItemCanForge'] = function(itemId)
        if((itemId or 0) == 0) then
            return false
        end

        local itemRarity = select(3, GetItemInfoCustom(itemId))
        if(itemRarity == nil or itemRarity < 2 or itemRarity > 4) then
            return false
        end
        
        if((IsAttunableBySomeone(itemId) or 0) == 0) then
            return false
        end
        
        if(CanAttuneItemHelper(itemId) <= 0) then
            local _, itemTagsTwo = GetItemTagsCustom(itemId)
            if(bit.band(itemTagsTwo or 0, 0x80) > 0) then -- Check if item is BoP
                return false
            end
        end
        
        return true
    end,
    ['craftingTooltipContains'] = function(spellId, searchString)
        if(storage.tooltipCache[spellId] == nil) then
            if(utility.scanTooltip == nil) then
                utility.scanTooltip = CreateFrame('GameTooltip', 'ScootsCraft-ScanTooltip', UIParent, 'GameTooltipTemplate')
            end
            
            utility.scanTooltip:SetOwner(UIParent)
            utility.scanTooltip:ClearLines()
            
            local itemId = select(3, Custom_GetProfessionRecipeInfo(spellId))
            
            if((itemId or 0) ~= 0) then
                utility.scanTooltip:SetHyperlink(utility.getItemLink(itemId))
            else
                utility.scanTooltip:SetHyperlink(utility.getCraftingLink(spellId))
            end
            
            utility.scanTooltip:Show()
            
            storage.tooltipCache[spellId] = ''
            local tooltipLines = {utility.scanTooltip:GetRegions()}
            
            for _, line in ipairs(tooltipLines) do
                if(line:IsObjectType('FontString')) then
                    local text = line:GetText()
                    
                    if(text) then
                        storage.tooltipCache[spellId] = storage.tooltipCache[spellId] .. string.lower(text)
                    end
                end
            end
            
            utility.scanTooltip:Hide()
        end
        
        return storage.tooltipCache[spellId]:match(string.lower(searchString)) ~= nil
    end,
}

for funcName, func in pairs(utility) do
    ScootsCraft.utility[funcName] = func
end

utility = ScootsCraft.utility