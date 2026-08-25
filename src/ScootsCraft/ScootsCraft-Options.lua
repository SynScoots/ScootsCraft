local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility = ScootsCraft.utility
local lookup = ScootsCraft.lookup

options = {
    ['defaultOptions'] = {
        ['minimap-button'] = true,
        ['drag-window'] = true,
        ['recipe-list-tooltip'] = 'none',
        ['select-next-on-hide'] = false,
        ['discount-summaries'] = true,
        ['reduce-wotlk-cloth'] = false,
        ['reduce-tbc-cloth'] = false,
        ['reduce-primal-might'] = false,
    },
    ['defaultFiltersValues'] = {
        ['search'] = '',
        ['search-include-reagents'] = false,
        ['search-include-tooltip'] = false,
        ['minimum-quantity'] = 0,
        ['exclude-items-in-bags'] = false,
        ['attuneable'] = 'all',
        ['attuned-level'] = 4,
        ['section'] = nil,
        ['inv-slot'] = -1,
    },
    ['load'] = function()
        for _, skill in ipairs(lookup.professionMap) do
            local skillKey = tostring(skill.skillId)
            
            options.defaultOptions[skillKey] = {
                ['default-filters'] = {},
            }
            
            for filterKey, filterValue in pairs(options.defaultFiltersValues) do
                options.defaultOptions[skillKey]['default-filters'][filterKey] = filterValue
            end
            
            if(skill.skillId == core.skillMap.Blacksmithing
            or skill.skillId == core.skillMap.Engineering
            or skill.skillId == core.skillMap.Jewelcrafting
            or skill.skillId == core.skillMap.Leatherworking
            or skill.skillId == core.skillMap.Tailoring) then
                options.defaultOptions[skillKey]['default-filters']['exclude-items-in-bags'] = true
                options.defaultOptions[skillKey]['default-filters']['attuneable'] = 'character'
                options.defaultOptions[skillKey]['default-filters']['attuned-level'] = 0
            end
        end
        
        storage.options = storage.options or {}
        
        options.loadNestedOptions(storage.options, options.defaultOptions)
        
        for _, skill in ipairs(lookup.professionMap) do
            for key, value in pairs(storage.options[tostring(skill.skillId)]['default-filters']) do
                core.filters[skill.skillId][key] = value
            end
        end
    end,
    ['loadNestedOptions'] = function(optionsTable, defaultTable)
        for key, value in pairs(defaultTable) do
            if(type(value) == 'table') then
                if(optionsTable[key] == nil or type(optionsTable[key]) ~= 'table') then
                    optionsTable[key] = {}
                end
                
                options.loadNestedOptions(optionsTable[key], value)
            elseif(optionsTable[key] == nil) then
                optionsTable[key] = value
            end
        end
    end,
    ['get'] = function(key, sourceTable)
        if(storage == nil or storage.options == nil) then
            return nil
        end
        
        if(sourceTable == nil) then
            sourceTable = storage.options
        end
        
        if(sourceTable[key] ~= nil) then
            return sourceTable[key]
        end
        
        local nestedKey = key:match('^([^%.]+)%.')
        
        if(nestedKey and sourceTable[nestedKey] ~= nil and type(sourceTable[nestedKey]) == 'table') then
            return options.get(key:match('^[^%.]+%.(.+)$'), sourceTable[nestedKey])
        end
    end,
    ['set'] = function(key, value, applyToField, sourceTable)
        if(storage == nil or storage.options == nil) then
            return
        end
        
        if(sourceTable == nil) then
            sourceTable = storage.options
        end
        
        local nestedKey = key:match('^([^%.]+)%.')
        
        if(nestedKey) then
            if(sourceTable[nestedKey] == nil or type(sourceTable[nestedKey]) ~= 'table') then
                sourceTable[nestedKey] = {}
            end
            
            options.set(key:match('^[^%.]+%.(.+)$'), value, nil, sourceTable[nestedKey])
        else
            sourceTable[key] = value
        end
        
        if(applyToField == true and options.fieldKeys and options.fieldKeys[key]) then
            options.fieldKeys[key].applyExternalValue(value)
        end
    end,
    ['open'] = function()
        if(frames.options ~= nil) then
            InterfaceOptionsFrame_OpenToCategory(frames.options.main)
        end
    end,
    ['build'] = function()
        if(frames.options ~= nil) then
            return
        end
        
        options.optionPageDefinitions = {
            ['general'] = {
                ['framename'] = 'General',
                ['title'] = 'General options',
                ['description'] = nil,
                ['callback'] = options.defineGeneralOptions,
            },
            ['summary'] = {
                ['framename'] = 'Summary',
                ['title'] = 'Summary options',
                ['description'] = nil,
                ['callback'] = options.defineSummaryOptions,
            },
        }
        
        for _, skill in ipairs(lookup.professionMap) do
            options.optionPageDefinitions[skill.skillId] = {
                ['framename'] = skill.name,
                ['title'] = skill.name,
                ['description'] = string.format('Options only for the %s skill.', skill.name),
                ['callback'] = function(data)
                    return options.defineSkillOptions(data, skill.skillId)
                end,
            }
        end
        
        frames.options = {}
        options.fieldKeys = {}
        frames.options.main = ScootsLibOptions.core.createOptionsInterface(
            frames.options,
            options.fieldKeys,
            {
                ['framename'] = 'ScootsCraft-Options',
                ['title'] = ScootsCraft.title,
                ['version'] = ScootsCraft.version,
                ['optionGetCallback'] = options.get,
                ['optionChangeCallback'] = function(pageKey, fieldKey, value)
                    options.set(fieldKey, value)
                end,
            },
            options.optionPageDefinitions,
            function()
                frames.options.menuLinks.general.select()
                frames.options.contentHolder.setActiveChild(frames.options.optionPages.general)
                options.sortMenuLinks()
                
                for key, menuLink in pairs(frames.options.menuLinks) do
                    menuLink.fade(options.get(key .. '-enabled') == false)
                end
            end
        )
    end,
    ['sortMenuLinks'] = function()
        frames.options.menuLinks['general']:SetPoint('TOPLEFT', frames.options.menuScrollChild, 'TOPLEFT', 0, -8)
        local height = frames.options.menuLinks['general']:GetHeight() + 8
        
        frames.options.menuLinks['summary']:SetPoint('TOPLEFT', frames.options.menuLinks['general'], 'BOTTOMLEFT', 0, 0)
        height = height + frames.options.menuLinks['summary']:GetHeight()
        
        local prevLink = frames.options.menuLinks['summary']
        
        for _, skill in ipairs(lookup.professionMap) do
            local menuLink = frames.options.menuLinks[skill.skillId]
            menuLink:SetPoint('TOPLEFT', prevLink, 'BOTTOMLEFT', 0, 0)
            
            prevLink = menuLink
            height = height + menuLink:GetHeight()
        end
        
        frames.options.menuScrollChild:SetHeight(height + 8)
    end,
    ['defineGeneralOptions'] = function(data)
        local fieldList = {
            {
                ['key'] = 'minimap-button',
                ['type'] = 'checkbox',
                ['framename'] = 'MinimapToggle',
                ['label'] = 'Show minimap button',
                ['tooltip'] = table.concat({
                    'Toggle displaying the minimap button.',
                    string.format('The %s window can still be toggled with the command:', ScootsCraft.title),
                    '/scootscraft',
                }, '\n\n'),
                ['callback'] = function(pageKey, fieldKey, value)
                    if(value) then
                        if(frames.minimapButton == nil) then
                            interface.buildMinimapButton()
                        end
                        
                        frames.minimapButton:Show()
                    else
                        frames.minimapButton:Hide()
                    end
                end,
            },
            {
                ['key'] = 'drag-window',
                ['type'] = 'checkbox',
                ['framename'] = 'Draggable',
                ['label'] = 'Allow dragging the window',
                ['tooltip'] = 'With this option enabled, click and drag on the title bar to move the crafting window.',
            },
            {
                ['key'] = 'recipe-list-tooltip',
                ['type'] = 'radio',
                ['framename'] = 'RecipeListTooltip',
                ['label'] = 'Recipe list tooltip',
                ['nullValue'] = 'none',
                ['choices'] = {
                    {
                        ['name'] = 'Item',
                        ['value'] = 'item',
                    },
                    {
                        ['name'] = 'Recipe',
                        ['value'] = 'recipe',
                    },
                },
            },
            {
                ['key'] = 'select-next-on-hide',
                ['type'] = 'checkbox',
                ['framename'] = 'SelectNextOnHide',
                ['label'] = 'Select next recipe when current is hidden',
                ['tooltip'] = 'With this option enabled, when your currently selected recipe gets hidden by filters, the next recipe will automatically be selected.',
            },
        }
        
        for _, field in ipairs(fieldList) do
            field.framename = string.format('%s-%s', data.framename, field.framename)
        end
        
        return fieldList
    end,
    ['defineSummaryOptions'] = function(data)
        local fieldList = {
            {
                ['key'] = 'discount-summaries',
                ['type'] = 'checkbox',
                ['framename'] = 'DiscountSummaries',
                ['label'] = 'Discount summaries by owned reagents',
                ['tooltip'] = 'With this option enabled, profession summaries have their counts reduced by reagents you already have.',
            },
            {
                ['key'] = 'reduce-wotlk-cloth',
                ['type'] = 'checkbox',
                ['framename'] = 'ReduceWotlkCloth',
                ['label'] = string.format(
                    'Split %s, %s, and %s into components',
                    (select(2, GetItemInfoCustom(41593))), -- Ebonweave
                    (select(2, GetItemInfoCustom(41594))), -- Moonshroud
                    (select(2, GetItemInfoCustom(41595)))  -- Spellweave
                ),
                ['callback'] = function(pageKey, fieldKey, value)
                    local exclude
                    if(not value) then
                        exclude = true
                    end
                    
                    lookup.summaryReductionExclusions[41593] = exclude -- Ebonweave
                    lookup.summaryReductionExclusions[41594] = exclude -- Moonshroud
                    lookup.summaryReductionExclusions[41595] = exclude -- Spellweave
                end,
            },
            {
                ['key'] = 'reduce-tbc-cloth',
                ['type'] = 'checkbox',
                ['framename'] = 'ReduceTbcCloth',
                ['label'] = string.format(
                    'Split %s, %s, and %s into components',
                    (select(2, GetItemInfoCustom(24272))), -- Shadowcloth
                    (select(2, GetItemInfoCustom(21845))), -- Primal Mooncloth
                    (select(2, GetItemInfoCustom(24271)))  -- Spellcloth
                ),
                ['callback'] = function(pageKey, fieldKey, value)
                    local exclude
                    if(not value) then
                        exclude = true
                    end
                    
                    lookup.summaryReductionExclusions[24272] = exclude -- Shadowcloth
                    lookup.summaryReductionExclusions[21845] = exclude -- Primal Mooncloth
                    lookup.summaryReductionExclusions[24271] = exclude -- Spellcloth
                end,
            },
            {
                ['key'] = 'reduce-primal-might',
                ['type'] = 'checkbox',
                ['framename'] = 'ReducePrimalMight',
                ['label'] = string.format(
                    'Split %s into components',
                    (select(2, GetItemInfoCustom(23571))) -- Primal Might
                ),
                ['callback'] = function(pageKey, fieldKey, value)
                    local exclude
                    if(not value) then
                        exclude = true
                    end
                    
                    lookup.summaryReductionExclusions[23571] = exclude -- Primal Might
                end,
            },
        }
        
        for _, field in ipairs(fieldList) do
            field.framename = string.format('%s-%s', data.framename, field.framename)
        end
        
        return fieldList
    end,
    ['defineSkillOptions'] = function(data, skillId)
        local fieldList = {
            {
                ['key'] = 'default-filters',
                ['type'] = 'group',
                ['framename'] = 'DefaultFilters',
                ['label'] = 'Default filters',
                ['callback'] = function(group, header)
                    local firstField, subHeight, xOffset, yOffset = ScootsLibOptions.core.processOptionsFieldList(frames.options, options.fieldKeys, {
                        ['parentAddon'] = {
                            ['framename'] = 'ScootsCraft-Options-' .. lookup.professionMap[core.skillIndexMap[skillId]].name,
                            ['title'] = ScootsCraft.title,
                            ['version'] = ScootsCraft.version,
                            ['optionGetCallback'] = options.get,
                            ['optionChangeCallback'] = function(pageKey, fieldKey, value)
                                options.set(fieldKey, value)
                            end,
                        },
                        ['key'] = data.key,
                        ['framename'] = data.framename,
                        ['parent'] = group,
                        ['callback'] = function()
                            local groupFieldList = {
                                {
                                    ['key'] = 'search',
                                    ['type'] = 'text',
                                    ['framename'] = 'Search',
                                    ['label'] = 'Search',
                                    ['width'] = 250,
                                },
                                {
                                    ['key'] = 'search-include-reagents',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'IncludeReagents',
                                    ['label'] = 'Include reagents',
                                },
                                {
                                    ['key'] = 'search-include-tooltip',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'IncludeTooltip',
                                    ['label'] = 'Include tooltip',
                                },
                                {
                                    ['key'] = 'minimum-quantity',
                                    ['type'] = 'increment-text',
                                    ['framename'] = 'MinimumQuantity',
                                    ['label'] = 'Minimum quantity',
                                    ['increment'] = 1,
                                    ['width'] = 70,
                                    ['min'] = 0,
                                },
                                {
                                    ['key'] = 'exclude-items-in-bags',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'ExcludeItemsInBags',
                                    ['label'] = 'Exclude items in bags',
                                },
                                {
                                    ['key'] = 'attuneable',
                                    ['type'] = 'radio',
                                    ['framename'] = 'Attuneable',
                                    ['label'] = 'Show equipment',
                                    ['choices'] = {
                                        {
                                            ['name'] = 'All',
                                            ['value'] = 'all',
                                        },
                                        {
                                            ['name'] = 'Attuneable (account)',
                                            ['value'] = 'account',
                                        },
                                        {
                                            ['name'] = 'Attuneable (character)',
                                            ['value'] = 'character',
                                        },
                                    },
                                },
                                {
                                    ['key'] = 'attuned-level',
                                    ['type'] = 'radio',
                                    ['framename'] = 'AttunedLevel',
                                    ['label'] = 'Attuned at',
                                    ['choices'] = {
                                        {
                                            ['name'] = 'Any',
                                            ['value'] = 4,
                                        },
                                        {
                                            ['name'] = 'Up to warforged',
                                            ['value'] = 3,
                                        },
                                        {
                                            ['name'] = 'Up to titanforged',
                                            ['value'] = 2,
                                        },
                                        {
                                            ['name'] = 'Up to baseline',
                                            ['value'] = 1,
                                        },
                                        {
                                            ['name'] = 'Unattuned only',
                                            ['value'] = 0,
                                        },
                                    },
                                },
                            }
        
                            for _, field in ipairs(groupFieldList) do
                                field.key = string.format('%d.%s.%s', skillId, 'default-filters', field.key)
                            end
                            
                            return groupFieldList
                        end,
                    })
            
                    firstField:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', xOffset or 0, 0 - (10 + (yOffset or 0)))
                    
                    return subHeight
                end,
            },
        }
        
        for _, field in ipairs(fieldList) do
            field.framename = string.format('%s-%s', data.framename, field.framename)
        end
        
        return fieldList
    end,
}

for funcName, func in pairs(options) do
    ScootsCraft.options[funcName] = func
end

options = ScootsCraft.options