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
        local bagItems = Custom_GetHaveItems()
        local reagentsInBags = {}
        
        for itemId, requiredCount in pairs(requiredReagents) do
            local reagentDetail = {
                ['itemId'] = itemId,
                ['required'] = requiredCount,
                ['owned'] = GetCustomGameData(13, itemId)
            }
        
            for _, cachedBagItemId in pairs(bagItems) do
                if(itemId == cachedBagItemId) then
                    for bagIndex = 0, 4 do
                        local bagSlots = GetContainerNumSlots(bagIndex)
                        
                        for slotIndex = 1, bagSlots do
                            local _, bagItemCount, _, _, _, _, bagItemLink = GetContainerItemInfo(bagIndex, slotIndex)
                            
                            if(bagItemLink ~= nil) then
                                local bagItemId = CustomExtractItemId(bagItemLink)
                                
                                if(bagItemId == itemId) then
                                    reagentDetail.owned = reagentDetail.owned + bagItemCount
                                end
                            end
                        end
                    end
                    
                    break
                end
            end
            
            table.insert(reagents, reagentDetail)
        end
        
        return reagents
    end,
    ['getBagContents'] = function()
        local bagContents = {}

        for bagIndex = 0, 4 do
            local bagSlots = GetContainerNumSlots(bagIndex)
            
            for slotIndex = 1, bagSlots do
                local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagIndex, slotIndex)
                
                if(itemLink ~= nil) then
                    local itemId = CustomExtractItemId(itemLink)
                    
                    if(bagContents[itemId] == nil) then
                        bagContents[itemId] = itemCount
                    else
                        bagContents[itemId] = bagContents[itemId] + itemCount
                    end
                end
            end
        end
        
        return bagContents
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
}

for funcName, func in pairs(utility) do
    ScootsCraft.utility[funcName] = func
end

utility = ScootsCraft.utility